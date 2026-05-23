#!/usr/bin/env bash
# install.sh — minimal remote bootstrap: base Projects dir, clone this repo, make deps apply.
#
# Layout and repo lists live in Ansible group_vars/ (applied via make apply).
#
#   curl -fsSL "https://raw.githubusercontent.com/MichaelHeaton/workstation-devops/main/scripts/install.sh" | bash
#
# Optional env (defaults match group_vars/all.yml):
#   PROJECTS_ROOT              base folder (default: ~/Projects)
#   WORKSTATION_DEVOPS_DEST    full clone path (overrides REL + ROOT)
#   WORKSTATION_DEVOPS_REL_DEST  path under PROJECTS_ROOT (default: personal/workstation-devops)
#   WORKSTATION_DEVOPS_REPO    git URL (SSH)
#   WORKSTATION_DEVOPS_BRANCH  branch (default: main)
set -euo pipefail

PROJECTS_ROOT="${PROJECTS_ROOT:-${HOME}/Projects}"
REL_DEST="${WORKSTATION_DEVOPS_REL_DEST:-personal/workstation-devops}"
DEST="${WORKSTATION_DEVOPS_DEST:-${PROJECTS_ROOT}/${REL_DEST}}"
BRANCH="${WORKSTATION_DEVOPS_BRANCH:-main}"
REPO="${WORKSTATION_DEVOPS_REPO:-git@github.com:MichaelHeaton/workstation-devops.git}"
FALLBACK_REPO="${WORKSTATION_DEVOPS_REPO_HTTPS:-https://github.com/MichaelHeaton/workstation-devops.git}"

echo "=== workstation-devops install (minimal) ==="
echo ""

mkdir -p "${PROJECTS_ROOT}"
mkdir -p "$(dirname "${DEST}")"
echo "✓ ${PROJECTS_ROOT} (top-level buckets are created by Ansible)"

if ! xcode-select -p &>/dev/null; then
  echo "→ Xcode Command Line Tools required for git..."
  xcode-select --install
  echo ""
  echo "  Complete the CLT install in the dialog, then press Enter to continue."
  read -r
fi

if [[ -d "${DEST}/.git" ]]; then
  echo "✓ Repo already at ${DEST}"
else
  echo "→ Cloning ${REPO} (branch ${BRANCH})..."
  if git clone --branch "${BRANCH}" -- "${REPO}" "${DEST}" 2>/dev/null; then
    :
  else
    echo "  SSH clone failed; trying HTTPS..."
    git clone --branch "${BRANCH}" -- "${FALLBACK_REPO}" "${DEST}"
  fi
  echo "✓ Cloned to ${DEST}"
fi

echo ""
echo "→ make deps apply (toolchain + playbook)..."
cd "${DEST}"
make deps apply
