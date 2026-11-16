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
  export KLAM_ARTIFACTORY_API_KEY=...   # before make apply, or make install-klam
  export WORK_USERNAME=YOUR_LDAP        # Artifactory LDAP username, needed alongside it

KLAM CLI only (skip the rest of make apply):
  make install-klam          Installs KLAM CLI (pip) + deploys ces_* aliases only

Registry (metadata only): config/secrets-registry.yml
Private Memex copy:       optional — paths vary; never commit employer values to GitHub
Docs:                     docs/secrets-keychain.md
EOF
