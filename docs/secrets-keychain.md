# Secrets — Keychain and local files

**Public repo rule:** passwords, API tokens, and Artifactory keys **never** go in git, Ansible vars committed to GitHub, or Memex if the vault is synced publicly without encryption.

**Preferred store for all MCP tokens and passwords:** macOS **Keychain Access** (login keychain), read at runtime via `security find-generic-password`. New MCP servers default to Keychain — not env files.

**Registry:** `config/secrets-registry.yml` lists what exists (service names, accounts, docs) — **not** secret values.

**Machine fill-in values:** `group_vars/work.local.yml` (gitignored) + a private Memex copy if you maintain one locally.

## Make helpers

| Command | Purpose |
| --------- | --------- |
| `make secrets-check` | Verify Keychain items and local secret files (no password output) |
| `make secrets-notion` | Interactive create/update Notion MCP token in Keychain |
| `make secrets-linear` | Interactive create/update Linear MCP API key in Keychain |
| `make secrets-atlassian` | Atlassian MCP: store Jira + Confluence tokens in Keychain and create config file |
| `make secrets-atlassian-env` | Create `~/.mcp/env/atlassian-config.env` from template (config only, no tokens) |
| `make secrets-help` | List all secret setup commands |

## Registry summary

Metadata lives in `config/secrets-registry.yml`:

| ID | Store | Service / path | Account | Used by |
| ---- | ------- | ---------------- | --------- | --------- |
| `notion_mcp` | Keychain | `claude-mcp-notion` | `claude-code` | Notion MCP |
| `linear_mcp` | Keychain | `claude-mcp-linear` | `claude-code` | Linear MCP |
| `klam_artifactory_api_key` | Shell env | `KLAM_ARTIFACTORY_API_KEY` | — | KLAM pip install |
| `atlassian_mcp_jira` | Keychain | `claude-mcp-atlassian-jira` | `claude-code` | Atlassian MCP |
| `atlassian_mcp_confluence` | Keychain | `claude-mcp-atlassian-confluence` | `claude-code` | Atlassian MCP |
| `atlassian_mcp_config` | Config file | `~/.mcp/env/atlassian-config.env` | — | Atlassian MCP (URLs, usernames only) |

Employer URLs, repo paths, and any legacy Keychain service names belong in **`group_vars/work.local.yml`** or your private Memex copy — not in the public repo.

## What stays out of git

| Secret | Where it lives |
| -------- | ---------------- |
| Notion MCP token | Keychain (`make secrets-notion`) |
| Linear MCP API key | Keychain (`make secrets-linear`) |
| Artifactory API key | `export KLAM_ARTIFACTORY_API_KEY=…` at apply time |
| Jira / Confluence tokens | Keychain (`make secrets-atlassian`) |
| SSH private keys | `~/.ssh/` |
| `group_vars/work.local.yml` | Gitignored clone-local file |
| `~/.config/ai-skills/local.json` | See [ai-local-config.md](ai-local-config.md) |

## Planned: 1Password (employer)

**When your employer provides org 1Password**, extend the registry pattern (see `planned_onepassword` in `config/secrets-registry.yml`):

| Secret | Today | 1Password target |
| -------- | -------- | ------------------ |
| KLAM Artifactory API key | `KLAM_ARTIFACTORY_API_KEY` env | `op read` / `op run` at apply time |
| Atlassian MCP tokens | `~/.mcp/env/atlassian.env` | `op inject` or env from `op run` |
| Chezmoi / dotfiles | N/A | optional `op` template provider (heavier; defer) |

**Planned Make targets** (not built yet): `secrets-1p-discover`, `secrets-check` branch that verifies `op` session + item existence.

**Private notes:** store real `op://` paths in your gitignored `work.local.yml` or private Memex — never in the public repo.

## See also

- [docs/work/vault-tools.md](work/vault-tools.md) — Vault CLI helpers
- [docs/work/klam.md](work/klam.md) — Artifactory API key
- [docs/ai-local-config.md](ai-local-config.md) — ai-skills private JSON
