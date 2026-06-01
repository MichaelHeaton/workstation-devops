#!/bin/bash
LINEAR_API_KEY=$(security find-generic-password -s "claude-mcp-linear" -a "claude-code" -w 2>/dev/null)
if [[ -z "$LINEAR_API_KEY" ]]; then
  echo "ERROR: Linear API key not found in Keychain (service: claude-mcp-linear, account: claude-code)" >&2
  exit 1
fi
export LINEAR_API_KEY
exec /opt/homebrew/bin/uvx linear-mcp --team_name SpecterRealm
