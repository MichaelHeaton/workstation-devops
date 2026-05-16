#!/usr/bin/env bash
# bootstrap-deps.sh — install toolchain required to run ansible-playbook (macOS).
# Invoked by make deps, bootstrap.sh, and after scripts/install.sh clones the repo.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "bootstrap-deps.sh: only macOS is supported today; install ansible manually, then make apply"
  exit 1
fi

if ! xcode-select -p &>/dev/null; then
  echo "→ Installing Xcode Command Line Tools..."
  xcode-select --install
  echo ""
  echo "  Complete the CLT install in the dialog, then press Enter to continue."
  read -r
fi
echo "✓ Xcode CLT"

if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
echo "✓ Homebrew"

if ! command -v ansible-playbook &>/dev/null; then
  echo "→ Installing Ansible..."
  brew install ansible
fi
echo "✓ Ansible"
