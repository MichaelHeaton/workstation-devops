#!/usr/bin/env bash
# Bootstrap ~/.mcp/env/atlassian.env from the chezmoi example (no tokens in git).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
template="${REPO_ROOT}/dotfiles/dot_mcp/env/atlassian.env.example"
dest="${HOME}/.mcp/env/atlassian.env"
memex_ref="${HOME}/Projects/personal/memex/Raw/Resources/Adobe/workstation-devops/employer-reference.yml"

mkdir -p "$(dirname "$dest")"

if [[ -f "$dest" ]]; then
  echo "${dest} already exists — not overwriting."
  echo "Edit tokens in place; file is gitignored."
  exit 0
fi

if [[ ! -f "$template" ]]; then
  echo "ERROR: template missing: ${template}" >&2
  exit 1
fi

cp "$template" "$dest"
chmod 600 "$dest"

# Optional: fill URLs/username from Memex employer-reference when yq + file exist
if [[ -f "$memex_ref" ]] && command -v yq >/dev/null 2>&1; then
  jira_url="$(yq '.mcp_atlassian.jira_url // ""' "$memex_ref" 2>/dev/null || true)"
  wiki_url="$(yq '.mcp_atlassian.confluence_url // ""' "$memex_ref" 2>/dev/null || true)"
  user="$(yq '.mcp_atlassian.username // ""' "$memex_ref" 2>/dev/null || true)"
  if [[ -n "$jira_url" ]]; then
    sed -i '' "s|^JIRA_URL=.*|JIRA_URL=${jira_url}|" "$dest"
  fi
  if [[ -n "$wiki_url" ]]; then
    sed -i '' "s|^CONFLUENCE_URL=.*|CONFLUENCE_URL=${wiki_url}|" "$dest"
  fi
  if [[ -n "$user" ]]; then
    sed -i '' "s|^JIRA_USERNAME=.*|JIRA_USERNAME=${user}|" "$dest"
    sed -i '' "s|^CONFLUENCE_USERNAME=.*|CONFLUENCE_USERNAME=${user}|" "$dest"
  fi
fi

echo "✓ Created ${dest}"
echo "Next: edit API tokens at https://id.atlassian.com/manage-profile/security/api-tokens"
echo "Then reload MCP / Cursor."
