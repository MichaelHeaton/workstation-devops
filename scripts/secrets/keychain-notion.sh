#!/usr/bin/env bash
# Create or update the Notion MCP API token Keychain item (interactive).
# Token is read from terminal — never written to disk or git.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command security

service="claude-mcp-notion"
account="claude-code"
label="claude-mcp-notion"

echo "Notion MCP Keychain item"
echo "  service (-s):  ${service}   ← Keychain Access \"Where\""
echo "  account (-a):  ${account}"
echo "  label (-l):    ${label}"
echo "  Get token at:  https://www.notion.so/my-integrations"
echo

if keychain_item_exists "$service" "$account"; then
  echo "An item already exists for this service/account."
  read -r -p "Update token? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "No changes."
    exit 0
  fi
else
  echo "No existing item — creating new Keychain entry."
fi

read -r -s -p "Notion Internal Integration Token: " token
echo
if [[ -z "$token" ]]; then
  echo "ERROR: empty token — aborted." >&2
  exit 1
fi

security add-generic-password \
  -a "$account" \
  -s "$service" \
  -l "$label" \
  -w "$token" \
  -U \
  login.keychain

unset token

echo
echo "✓ Keychain item saved."
echo "Verify (may prompt Touch ID once):"
echo "  security find-generic-password -s ${service} -a ${account} -w >/dev/null && echo ok"
echo "Then reload Claude Code to pick up the new MCP server."
