#!/usr/bin/env bash
# bootstrap.sh — one-shot new-machine setup for workstation-devops.
# Run this once on a fresh Mac. Safe to re-run; each step is idempotent.
set -euo pipefail

echo "=== Personal workstation bootstrap ==="
echo ""

# ---------------------------------------------------------------------------
# 1. Xcode Command Line Tools (required by Homebrew and git)
# ---------------------------------------------------------------------------
if ! xcode-select -p &>/dev/null; then
  echo "→ Installing Xcode Command Line Tools..."
  xcode-select --install
  echo ""
  echo "  A dialog has opened to install Xcode CLT."
  echo "  Once the installation is complete, press Enter to continue."
  read -r
fi
echo "✓ Xcode CLT"

# ---------------------------------------------------------------------------
# 2. Homebrew
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# 3. Ansible
# ---------------------------------------------------------------------------
if ! command -v ansible-playbook &>/dev/null; then
  echo "→ Installing Ansible..."
  brew install ansible
fi
echo "✓ Ansible"

# ---------------------------------------------------------------------------
# 4. Run playbook
# ---------------------------------------------------------------------------
echo ""
echo "→ Running playbook..."
echo ""
make apply
