#!/bin/bash
CONFIG="${HOME}/.mcp/env/atlassian-config.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: Atlassian config not found: ${CONFIG}" >&2
  echo "  Run: make secrets-atlassian" >&2
  exit 1
fi

# Load non-secret config (JIRA_URL, CONFLUENCE_URL, JIRA_USERNAME, CONFLUENCE_USERNAME)
# shellcheck source=/dev/null
source "$CONFIG"

JIRA_PERSONAL_TOKEN=$(security find-generic-password -s "claude-mcp-atlassian-jira" -a "claude-code" -w 2>/dev/null)
CONFLUENCE_PERSONAL_TOKEN=$(security find-generic-password -s "claude-mcp-atlassian-confluence" -a "claude-code" -w 2>/dev/null)

if [[ -z "$JIRA_PERSONAL_TOKEN" || -z "$CONFLUENCE_PERSONAL_TOKEN" ]]; then
  echo "ERROR: Atlassian tokens not found in Keychain. Run: make secrets-atlassian" >&2
  exit 1
fi

export JIRA_URL CONFLUENCE_URL JIRA_USERNAME CONFLUENCE_USERNAME
export JIRA_PERSONAL_TOKEN CONFLUENCE_PERSONAL_TOKEN

exec /opt/homebrew/bin/uvx mcp-atlassian
