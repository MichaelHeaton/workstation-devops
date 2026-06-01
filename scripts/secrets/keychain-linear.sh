#!/usr/bin/env bash
# Create or update the Linear MCP API key Keychain item (interactive).
# Key is read from terminal — never written to disk or git.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command security

service="claude-mcp-linear"
account="claude-code"
label="claude-mcp-linear"

echo "Linear MCP Keychain item"
echo "  service (-s):  ${service}   ← Keychain Access \"Where\""
echo "  account (-a):  ${account}"
echo "  label (-l):    ${label}"
echo "  Get key at:    https://linear.app/settings/api"
echo

if keychain_item_exists "$service" "$account"; then
  echo "An item already exists for this service/account."
  read -r -p "Update key? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "No changes."
    exit 0
  fi
else
  echo "No existing item — creating new Keychain entry."
fi

read -r -s -p "Linear Personal API Key: " api_key
echo
if [[ -z "$api_key" ]]; then
  echo "ERROR: empty key — aborted." >&2
  exit 1
fi

security add-generic-password \
  -a "$account" \
  -s "$service" \
  -l "$label" \
  -w "$api_key" \
  -U \
  login.keychain

unset api_key

echo
echo "✓ Keychain item saved."
echo "Verify (may prompt Touch ID once):"
echo "  security find-generic-password -s ${service} -a ${account} -w >/dev/null && echo ok"
echo "Then reload Claude Code to pick up the new MCP server."
