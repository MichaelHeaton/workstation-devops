#!/usr/bin/env bash
# Set up Atlassian MCP: create non-secret config file and store tokens in Keychain.
# Tokens are read from terminal — never written to disk or git.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command security

REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
template="${REPO_ROOT}/dotfiles/dot_mcp/env/atlassian.env.example"
config_dest="${HOME}/.mcp/env/atlassian-config.env"
memex_ref="${WORKSTATION_DEVOPS_MEMEX_REF:-}"

# --- 1. Non-secret config file (URLs, usernames — no tokens) -----------------
mkdir -p "$(dirname "$config_dest")"

if [[ -f "$config_dest" ]]; then
  echo "Config file already exists: ${config_dest}"
  echo "Edit manually to update URLs or usernames."
else
  cp "$template" "$config_dest"
  chmod 600 "$config_dest"

  if [[ -n "$memex_ref" && -f "$memex_ref" ]] && command -v yq >/dev/null 2>&1; then
    jira_url="$(yq '.mcp_atlassian.jira_url // ""' "$memex_ref" 2>/dev/null || true)"
    wiki_url="$(yq '.mcp_atlassian.confluence_url // ""' "$memex_ref" 2>/dev/null || true)"
    user="$(yq '.mcp_atlassian.username // ""' "$memex_ref" 2>/dev/null || true)"
    [[ -n "$jira_url" ]] && sed -i '' "s|^JIRA_URL=.*|JIRA_URL=${jira_url}|" "$config_dest"
    [[ -n "$wiki_url" ]] && sed -i '' "s|^CONFLUENCE_URL=.*|CONFLUENCE_URL=${wiki_url}|" "$config_dest"
    if [[ -n "$user" ]]; then
      sed -i '' "s|^JIRA_USERNAME=.*|JIRA_USERNAME=${user}|" "$config_dest"
      sed -i '' "s|^CONFLUENCE_USERNAME=.*|CONFLUENCE_USERNAME=${user}|" "$config_dest"
    fi
  fi

  echo "✓ Created ${config_dest}"
  echo "  Edit JIRA_URL, CONFLUENCE_URL, and usernames if not auto-filled."
fi

echo
echo "Get tokens at: https://id.atlassian.com/manage-profile/security/api-tokens"
echo

# --- 2. Jira API token -------------------------------------------------------
jira_service="claude-mcp-atlassian-jira"
jira_skip=0
if keychain_item_exists "$jira_service" "claude-code"; then
  read -r -p "Jira token already in Keychain. Update? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || jira_skip=1
fi

if (( jira_skip == 0 )); then
  read -r -s -p "Jira Personal API Token: " jira_token
  echo
  if [[ -z "$jira_token" ]]; then
    echo "ERROR: empty token — aborted." >&2
    exit 1
  fi
  security add-generic-password -a "claude-code" -s "$jira_service" -l "$jira_service" \
    -w "$jira_token" -U login.keychain
  unset jira_token
  echo "✓ Jira token saved to Keychain."
fi

# --- 3. Confluence API token -------------------------------------------------
conf_service="claude-mcp-atlassian-confluence"
conf_skip=0
if keychain_item_exists "$conf_service" "claude-code"; then
  read -r -p "Confluence token already in Keychain. Update? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || conf_skip=1
fi

if (( conf_skip == 0 )); then
  read -r -s -p "Confluence Personal API Token: " conf_token
  echo
  if [[ -z "$conf_token" ]]; then
    echo "ERROR: empty token — aborted." >&2
    exit 1
  fi
  security add-generic-password -a "claude-code" -s "$conf_service" -l "$conf_service" \
    -w "$conf_token" -U login.keychain
  unset conf_token
  echo "✓ Confluence token saved to Keychain."
fi

echo
echo "Atlassian MCP setup complete."
echo "Run: chezmoi apply && make secrets-check"
