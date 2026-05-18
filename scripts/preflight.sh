#!/usr/bin/env bash
# Preflight check: detect-first — PATH, /Applications, then Homebrew when present.
# Exits 0 if up to date, 1 if any items are pending.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ALL_CONFIG="$REPO_ROOT/group_vars/all.yml"
PROFILE_FILE="${HOME}/.workstation_profile"
PROFILE="${WORKSTATION_PROFILE:-$(tr -d '[:space:]' < "$PROFILE_FILE" 2>/dev/null || echo personal)}"
PROFILE_CONFIG="$REPO_ROOT/group_vars/${PROFILE}.yml"
PROJECTS_ROOT="$HOME/Projects"

if [[ ! -f "$PROFILE_CONFIG" ]]; then
  printf "\033[31m✗ Unknown profile '%s' — run: make profile\033[0m\n" "$PROFILE"
  exit 1
fi

pending=0

ok()   { :; }
miss() { printf "  \033[31m✗\033[0m %s — %s\n" "$1" "$2"; pending=$((pending + 1)); }
note() { printf "  \033[90m%s\033[0m\n" "$1"; }

# Profile overrides all.yml defaults (yq emits bare true/false)
yq_bool() {
  local key=$1 file=$2 default=${3:-false}
  local val
  val=$(yq ".$key" "$file" 2>/dev/null || true)
  if [[ "$val" == "null" || -z "$val" ]]; then
    val=$(yq ".$key" "$ALL_CONFIG" 2>/dev/null || true)
  fi
  if [[ "$val" == "null" || -z "$val" ]]; then
    [[ "$default" == "true" ]] && echo true || echo false
  else
    echo "$val"
  fi
}

install_packages=$(yq_bool homebrew_install_packages "$PROFILE_CONFIG" true)
mas_enabled=$(yq_bool homebrew_mas_enabled "$PROFILE_CONFIG" false)

brew_available=false
brew_prefix=/usr/local
if command -v brew &>/dev/null; then
  brew_available=true
  brew_prefix=$(brew --prefix 2>/dev/null || echo /usr/local)
fi

installed_formulae=""
installed_casks=""
if [[ "$brew_available" == true ]]; then
  installed_formulae=$(brew list --formula 2>/dev/null || true)
  installed_casks=$(brew list --cask 2>/dev/null || true)
fi

echo "Profile: ${PROFILE} (${PROFILE_FILE})"
if [[ "$brew_available" == true ]]; then
  note "Homebrew: ${brew_prefix} (install_via_brew=${install_packages})"
else
  note "Homebrew: not installed — checking PATH and /Applications only"
fi
note "Mac App Store installs: ${mas_enabled}"
echo ""

# ── Directories ──────────────────────────────────────────────────────────────
while IFS= read -r name; do
  if [[ -d "$PROJECTS_ROOT/$name" ]]; then
    ok "$name"
  else
    miss "$name" "make apply will create"
  fi
done < <(yq '.projects_buckets[].name' "$PROFILE_CONFIG")

# ── Repos (common + profile) ─────────────────────────────────────────────────
while IFS=$'\t' read -r dest repo; do
  [[ -z "$dest" ]] && continue
  if [[ -d "$PROJECTS_ROOT/$dest/.git" ]]; then
    ok "$dest"
  else
    miss "$dest" "not cloned ($repo)"
  fi
done < <({
  yq '.managed_repos_common[] | [.dest, .repo] | @tsv' "$ALL_CONFIG" 2>/dev/null || true
  yq '.managed_repos[] | [.dest, .repo] | @tsv' "$PROFILE_CONFIG" 2>/dev/null || true
})

# ── CLI tools (formulae) — PATH first, then Homebrew ─────────────────────────
formula_satisfied() {
  local formula=$1
  if command -v "$formula" &>/dev/null; then
    return 0
  fi
  if [[ "$brew_available" == true ]] && printf '%s\n' "$installed_formulae" | grep -qx "$formula"; then
    return 0
  fi
  return 1
}

while IFS= read -r formula; do
  [[ -z "$formula" ]] && continue
  if formula_satisfied "$formula"; then
    ok "$formula"
  elif [[ "$install_packages" == "true" && "$brew_available" == true ]]; then
    miss "$formula" "brew install $formula"
  elif [[ "$install_packages" == "true" ]]; then
    miss "$formula" "not on PATH (run make deps for Homebrew or install manually)"
  else
    miss "$formula" "not on PATH (install manually or via IT)"
  fi
done < <({
  yq '.homebrew_formulae_common[]' "$ALL_CONFIG"
  yq '.homebrew_formulae_profile[]' "$PROFILE_CONFIG" 2>/dev/null || true
})

# ── Go binaries ───────────────────────────────────────────────────────────────
go_count=$(yq '.homebrew_go_binaries | length' "$PROFILE_CONFIG" 2>/dev/null || echo 0)
for ((i = 0; i < go_count; i++)); do
  name=$(yq ".homebrew_go_binaries[$i].name" "$PROFILE_CONFIG")
  module=$(yq ".homebrew_go_binaries[$i].module" "$PROFILE_CONFIG")
  if [[ -x "${brew_prefix}/bin/$name" ]] || command -v "$name" &>/dev/null; then
    ok "$name"
  elif [[ "$install_packages" == "true" ]]; then
    miss "$name" "go install $module"
  else
    miss "$name" "not on PATH (install manually)"
  fi
done

# ── GUI apps (casks) — /Applications first, then Homebrew cask ─────────────────
declare -A app_bundles
while IFS=$'\t' read -r key val; do
  [[ -z "$key" ]] && continue
  app_bundles["$key"]="$val"
done < <({
  yq '.homebrew_cask_app_bundles_common | to_entries[] | [.key, .value] | @tsv' "$ALL_CONFIG" 2>/dev/null || true
  yq '.homebrew_cask_app_bundles | to_entries[] | [.key, .value] | @tsv' "$PROFILE_CONFIG" 2>/dev/null || true
})

cask_satisfied() {
  local cask=$1
  local bundle="${app_bundles[$cask]:-}"
  if [[ -n "$bundle" && -d "/Applications/$bundle" ]]; then
    return 0
  fi
  if [[ "$brew_available" == true ]] && printf '%s\n' "$installed_casks" | grep -qx "$cask"; then
    return 0
  fi
  return 1
}

while IFS= read -r cask; do
  [[ -z "$cask" ]] && continue
  if cask_satisfied "$cask"; then
    ok "$cask"
  elif [[ "$install_packages" == "true" && "$brew_available" == true ]]; then
    miss "$cask" "brew install --cask $cask"
  elif [[ "$install_packages" == "true" ]]; then
    miss "$cask" "app not in /Applications (install manually or run make deps)"
  else
    miss "$cask" "app not in /Applications (install manually or via IT)"
  fi
done < <({
  yq '.homebrew_casks_common[]' "$ALL_CONFIG"
  yq '.homebrew_casks_profile[]' "$PROFILE_CONFIG" 2>/dev/null || true
})

# ── Mac App Store apps (optional per profile) ─────────────────────────────────
mas_count=$(yq '.homebrew_mas_apps | length' "$PROFILE_CONFIG" 2>/dev/null || echo 0)
if [[ "$mas_enabled" != "true" || "$mas_count" -eq 0 ]]; then
  note "MAS: skipped (disabled or none configured for profile)"
elif ! command -v mas &>/dev/null; then
  if [[ "$install_packages" == "true" ]]; then
    miss "mas" "not on PATH (brew install mas after make deps)"
  else
    note "MAS: skipped (mas CLI not installed)"
  fi
else
  mas_signed_in=false
  if mas account &>/dev/null; then
    mas_signed_in=true
  fi
  if [[ "$mas_signed_in" != "true" ]]; then
    note "MAS: skipped (App Store not signed in — expected on managed work Macs)"
  else
    installed_mas=$(mas list 2>/dev/null | awk '{print $1}' || true)
    for ((i = 0; i < mas_count; i++)); do
      id=$(yq ".homebrew_mas_apps[$i].id" "$PROFILE_CONFIG")
      name=$(yq ".homebrew_mas_apps[$i].name" "$PROFILE_CONFIG")
      bundle=$(yq ".homebrew_mas_apps[$i].bundle // \"\"" "$PROFILE_CONFIG")
      if [[ -n "$bundle" && -d "/Applications/$bundle" ]]; then
        ok "$name"
      elif printf '%s\n' "$installed_mas" | grep -qx "$id"; then
        ok "$name"
      else
        miss "$name" "mas install $id"
      fi
    done
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [[ $pending -eq 0 ]]; then
  printf "\033[32m✓ All checks passed — system is up to date\033[0m\n"
  exit 0
else
  printf "\033[33m⚠ %d item(s) pending → run: make apply\033[0m\n" "$pending"
  exit 1
fi
