#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
workstation-devops secrets (never commit passwords or API tokens)

Keychain — default for all MCP tokens and corp passwords:
  make secrets-atlassian      Atlassian MCP tokens (Jira + Confluence) + config file
  make secrets-check          Verify all Keychain items + local config files

Non-secret config files (URLs, usernames — no tokens):
  make secrets-atlassian-env  Create ~/.mcp/env/atlassian-config.env from template

Runtime env (export in shell, not stored by make):
  export KLAM_ARTIFACTORY_API_KEY=...   # before make apply for KLAM pip install

Registry (metadata only): config/secrets-registry.yml
Private Memex copy:       optional — paths vary; never commit employer values to GitHub
Docs:                     docs/secrets-keychain.md
EOF
