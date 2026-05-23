#!/usr/bin/env bash
# bootstrap.sh — local entry: install Ansible toolchain, run playbook.
# Prefer ./setup.sh. Layout/repos: edit group_vars/<profile>.yml.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT}"

echo "=== Personal workstation bootstrap ==="
echo ""
make deps apply
