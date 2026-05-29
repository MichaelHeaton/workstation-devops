#!/usr/bin/env bash
# Verify Keychain items and local secret files from config/secrets-registry.yml.
# Never prints passwords or tokens.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command security
require_command yq

echo "== workstation-devops secrets check =="
echo "Registry: ${REGISTRY}"
echo

missing=0
ok=0

# --- Keychain: vault Okta ----------------------------------------------------
vault_service="$(resolve_vault_okta_service)"
vault_account="$(resolve_work_username)"
vault_label="$(resolve_vault_okta_label)"

if [[ -z "$vault_account" ]]; then
  echo "✗ vault_okta — account unknown (set work_username in group_vars/work.local.yml)"
  missing=$((missing + 1))
elif keychain_item_exists "$vault_service" "$vault_account"; then
  echo "✓ Keychain vault_okta — service=${vault_service} account=${vault_account} label≈${vault_label}"
  ok=$((ok + 1))
else
  echo "✗ Keychain vault_okta — missing (service=${vault_service} account=${vault_account})"
  echo "  → make secrets-vault-okta"
  missing=$((missing + 1))
fi

# --- Runtime env (presence only) ---------------------------------------------
if [[ -n "${KLAM_ARTIFACTORY_API_KEY:-}" ]]; then
  echo "✓ env KLAM_ARTIFACTORY_API_KEY — set in shell (not verified)"
  ok=$((ok + 1))
else
  echo "○ env KLAM_ARTIFACTORY_API_KEY — not set (optional until KLAM pip install)"
fi

# --- Local files -------------------------------------------------------------
atlassian_path="${HOME}/.mcp/env/atlassian.env"
if [[ -f "$atlassian_path" ]]; then
  if grep -q 'your_token_here' "$atlassian_path" 2>/dev/null; then
    echo "○ ${atlassian_path} — exists but still has placeholder tokens"
  else
    echo "✓ ${atlassian_path} — present"
    ok=$((ok + 1))
  fi
else
  echo "○ ${atlassian_path} — missing (optional for Atlassian MCP)"
  echo "  → make secrets-atlassian-env"
fi

echo
if (( missing > 0 )); then
  echo "Summary: ${ok} ok, ${missing} missing — run make secrets-help"
  exit 1
fi
echo "Summary: ${ok} configured, no required Keychain gaps."
exit 0
