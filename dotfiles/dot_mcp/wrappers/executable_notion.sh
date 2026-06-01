#!/bin/bash
NOTION_API_TOKEN=$(security find-generic-password -s "claude-mcp-notion" -a "claude-code" -w 2>/dev/null)
if [[ -z "$NOTION_API_TOKEN" ]]; then
  echo "ERROR: Notion token not found in Keychain (service: claude-mcp-notion, account: claude-code)" >&2
  exit 1
fi
export NOTION_API_TOKEN
exec /opt/homebrew/bin/uvx --from notion-mcp-server notion-mcp
