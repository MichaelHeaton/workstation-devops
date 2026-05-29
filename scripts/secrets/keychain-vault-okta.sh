#!/usr/bin/env bash
# Create or update the Vault Okta corp-password Keychain item (interactive).
# Password is read from terminal — never written to disk or git.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command security

service="$(resolve_vault_okta_service)"
label="$(resolve_vault_okta_label)"
account="$(resolve_work_username)"

if [[ -z "$account" ]]; then
  read -r -p "Work LDAP username (Keychain account): " account
  account="${account// /}"
fi

if [[ -z "$account" ]]; then
  echo "ERROR: account is required." >&2
  exit 1
fi

echo "Vault Okta Keychain item"
echo "  service (-s):  ${service}   ← Keychain Access “Where”"
echo "  account (-a):  ${account}"
echo "  label (-l):    ${label}     ← Keychain Access display name"
echo

if keychain_item_exists "$service" "$account"; then
  echo "An item already exists for this service/account."
  read -r -p "Update password? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "No changes."
    exit 0
  fi
else
  echo "No existing item — creating new Keychain entry."
fi

read -r -s -p "Corp LDAP / VPN password: " password
echo
if [[ -z "$password" ]]; then
  echo "ERROR: empty password — aborted." >&2
  exit 1
fi

# -U update if duplicate; -T allow security tool to access without prompt where permitted
security add-generic-password \
  -a "$account" \
  -s "$service" \
  -l "$label" \
  -w "$password" \
  -U \
  login.keychain

unset password

echo
echo "✓ Keychain item saved."
echo "Verify (may prompt Touch ID once):"
echo "  security find-generic-password -s ${service} -a ${account} -w >/dev/null && echo ok"
echo "Then: make apply && source ~/.zshrc"
