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

# --- Keychain: Notion MCP ----------------------------------------------------
if keychain_item_exists "claude-mcp-notion" "claude-code"; then
  echo "✓ Keychain notion_mcp — service=claude-mcp-notion account=claude-code"
  ok=$((ok + 1))
else
  echo "○ Keychain notion_mcp — missing (optional; needed for Notion MCP)"
  echo "  → make secrets-notion"
fi

# --- Keychain: Linear MCP ----------------------------------------------------
if keychain_item_exists "claude-mcp-linear" "claude-code"; then
  echo "✓ Keychain linear_mcp — service=claude-mcp-linear account=claude-code"
  ok=$((ok + 1))
else
  echo "○ Keychain linear_mcp — missing (optional; needed for Linear MCP)"
  echo "  → make secrets-linear"
fi

# --- Runtime env (presence only) ---------------------------------------------
if [[ -n "${KLAM_ARTIFACTORY_API_KEY:-}" ]]; then
  echo "✓ env KLAM_ARTIFACTORY_API_KEY — set in shell (not verified)"
  ok=$((ok + 1))
else
  echo "○ env KLAM_ARTIFACTORY_API_KEY — not set (optional until KLAM pip install)"
fi

# --- Keychain: Atlassian MCP -------------------------------------------------
if keychain_item_exists "claude-mcp-atlassian-jira" "claude-code"; then
  echo "✓ Keychain atlassian_mcp_jira — service=claude-mcp-atlassian-jira account=claude-code"
  ok=$((ok + 1))
else
  echo "○ Keychain atlassian_mcp_jira — missing (optional; needed for Atlassian MCP)"
  echo "  → make secrets-atlassian"
fi

if keychain_item_exists "claude-mcp-atlassian-confluence" "claude-code"; then
  echo "✓ Keychain atlassian_mcp_confluence — service=claude-mcp-atlassian-confluence account=claude-code"
  ok=$((ok + 1))
else
  echo "○ Keychain atlassian_mcp_confluence — missing (optional; needed for Atlassian MCP)"
  echo "  → make secrets-atlassian"
fi

# --- Local config files (non-secret) -----------------------------------------
atlassian_config="${HOME}/.mcp/env/atlassian-config.env"
if [[ -f "$atlassian_config" ]]; then
  echo "✓ ${atlassian_config} — present"
  ok=$((ok + 1))
else
  echo "○ ${atlassian_config} — missing (optional; needed for Atlassian MCP)"
  echo "  → make secrets-atlassian"
fi

echo
if (( missing > 0 )); then
  echo "Summary: ${ok} ok, ${missing} missing — run make secrets-help"
  exit 1
fi
echo "Summary: ${ok} configured, no required Keychain gaps."
exit 0
