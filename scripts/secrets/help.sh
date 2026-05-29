#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
workstation-devops secrets (never commit passwords or API tokens)

Keychain — preferred for corp LDAP password used by vl / vault_mgmt:
  make secrets-vault-okta     Interactive add/update Keychain item
  make secrets-check          Verify Keychain + local secret files

Local files (gitignored on disk):
  make secrets-atlassian-env  Create ~/.mcp/env/atlassian.env from template

Runtime env (export in shell, not stored by make):
  export KLAM_ARTIFACTORY_API_KEY=...   # before make apply for KLAM pip install

Registry (metadata only): config/secrets-registry.yml
Memex source of truth:    ~/Projects/personal/memex/Raw/Resources/Adobe/workstation-devops/
Docs:                     docs/secrets-keychain.md
EOF
