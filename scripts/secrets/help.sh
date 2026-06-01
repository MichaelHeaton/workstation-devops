#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
workstation-devops secrets (never commit passwords or API tokens)

Keychain — default for all MCP tokens and corp passwords:
  make secrets-vault-okta     Corp LDAP password (Vault / vl)
  make secrets-notion         Notion MCP integration token
  make secrets-linear         Linear MCP personal API key
  make secrets-check          Verify all Keychain items + local secret files

Local files (gitignored on disk):
  make secrets-atlassian-env  Create ~/.mcp/env/atlassian.env from template

Runtime env (export in shell, not stored by make):
  export KLAM_ARTIFACTORY_API_KEY=...   # before make apply for KLAM pip install

Registry (metadata only): config/secrets-registry.yml
Private Memex copy:       optional — paths vary; never commit employer values to GitHub
Docs:                     docs/secrets-keychain.md
EOF
