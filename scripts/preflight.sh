#!/usr/bin/env bash
# Preflight check: reads vars/config.yml and verifies workstation state directly.
# Exits 0 if up to date, 1 if any items are pending.
# Does not rely on Ansible dry-run — checks actual filesystem and tool state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/../vars/config.yml"
PROJECTS_ROOT="$HOME/Projects"

pending=0

ok()   { :; }
miss() { printf "  \033[31m✗\033[0m %s — %s\n" "$1" "$2"; pending=$((pending + 1)); }
hdr()  { :; }

# ── Directories ──────────────────────────────────────────────────────────────
hdr "Directories"
while IFS= read -r name; do
  if [[ -d "$PROJECTS_ROOT/$name" ]]; then
    ok "$name"
  else
    miss "$name" "make apply will create"
  fi
done < <(yq '.projects_buckets[].name' "$CONFIG")

# ── Repos ────────────────────────────────────────────────────────────────────
hdr "Repos"
repo_count=$(yq '.managed_repos | length' "$CONFIG")
for ((i = 0; i < repo_count; i++)); do
  dest=$(yq ".managed_repos[$i].dest" "$CONFIG")
  repo=$(yq ".managed_repos[$i].repo" "$CONFIG")
  if [[ -d "$PROJECTS_ROOT/$dest/.git" ]]; then
    ok "$dest"
  else
    miss "$dest" "not cloned ($repo)"
  fi
done

# ── Homebrew formulae ─────────────────────────────────────────────────────────
hdr "Homebrew formulae"
installed_formulae=$(brew list --formula 2>/dev/null || true)
while IFS= read -r formula; do
  if printf '%s\n' "$installed_formulae" | grep -qx "$formula"; then
    ok "$formula"
  else
    miss "$formula" "brew install $formula"
  fi
done < <(yq '.homebrew_formulae[]' "$CONFIG")

# ── Go binaries ───────────────────────────────────────────────────────────────
hdr "Go binaries"
brew_prefix=$(brew --prefix 2>/dev/null || echo /usr/local)
go_count=$(yq '.homebrew_go_binaries | length' "$CONFIG")
for ((i = 0; i < go_count; i++)); do
  name=$(yq ".homebrew_go_binaries[$i].name" "$CONFIG")
  module=$(yq ".homebrew_go_binaries[$i].module" "$CONFIG")
  if [[ -x "$brew_prefix/bin/$name" ]] || command -v "$name" &>/dev/null; then
    ok "$name"
  else
    miss "$name" "go install $module"
  fi
done

# ── Homebrew casks ────────────────────────────────────────────────────────────
hdr "Homebrew casks"
installed_casks=$(brew list --cask 2>/dev/null || true)

# Some casks are satisfied by a manually installed app bundle — mirror the
# homebrew_cask_app_bundles skip policy from the Ansible role.
declare -A app_bundles
while IFS=$'\t' read -r key val; do
  [[ -z "$key" ]] && continue
  app_bundles["$key"]="$val"
done < <(yq '.homebrew_cask_app_bundles | to_entries[] | [.key, .value] | @tsv' "$CONFIG" 2>/dev/null || true)

while IFS= read -r cask; do
  bundle="${app_bundles[$cask]:-}"
  if [[ -n "$bundle" && -d "/Applications/$bundle" ]]; then
    ok "$cask (app bundle present)"
  elif printf '%s\n' "$installed_casks" | grep -qx "$cask"; then
    ok "$cask"
  else
    miss "$cask" "brew install --cask $cask"
  fi
done < <(yq '.homebrew_casks[]' "$CONFIG")

# ── Mac App Store apps ────────────────────────────────────────────────────────
hdr "Mac App Store apps"
if command -v mas &>/dev/null; then
  installed_mas=$(mas list 2>/dev/null | awk '{print $1}' || true)
  mas_count=$(yq '.homebrew_mas_apps | length' "$CONFIG")
  for ((i = 0; i < mas_count; i++)); do
    id=$(yq ".homebrew_mas_apps[$i].id" "$CONFIG")
    name=$(yq ".homebrew_mas_apps[$i].name" "$CONFIG")
    if printf '%s\n' "$installed_mas" | grep -qx "$id"; then
      ok "$name"
    else
      miss "$name" "mas install $id"
    fi
  done
else
  printf "  \033[90m(skipped — mas not installed yet)\033[0m\n"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [[ $pending -eq 0 ]]; then
  printf "\033[32m✓ All checks passed — system is up to date\033[0m\n"
  exit 0
else
  printf "\033[33m⚠ %d item(s) pending → run: make apply\033[0m\n" "$pending"
fi
