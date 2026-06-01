# Secrets — Keychain and local files

**Public repo rule:** passwords, API tokens, and Artifactory keys **never** go in git, Ansible vars committed to GitHub, or Memex if the vault is synced publicly without encryption.

**Preferred store for all MCP tokens and passwords:** macOS **Keychain Access** (login keychain), read at runtime via `security find-generic-password`. New MCP servers default to Keychain — not env files.

**Registry:** `config/secrets-registry.yml` lists what exists (service names, accounts, docs) — **not** secret values.

**Machine fill-in values:** `group_vars/work.local.yml` (gitignored) + a private Memex copy if you maintain one locally.

## Make helpers

| Command | Purpose |
| --------- | --------- |
| `make secrets-check` | Verify Keychain items and local secret files (no password output) |
| `make secrets-vault-okta` | Interactive create/update Vault Okta Keychain item |
| `make secrets-notion` | Interactive create/update Notion MCP token in Keychain |
| `make secrets-linear` | Interactive create/update Linear MCP API key in Keychain |
| `make secrets-atlassian` | Atlassian MCP: store Jira + Confluence tokens in Keychain and create config file |
| `make secrets-atlassian-env` | Create `~/.mcp/env/atlassian-config.env` from template (config only, no tokens) |
| `make secrets-help` | List all secret setup commands |

## Keychain Access field mapping

When creating an **application password** item manually or via `make secrets-vault-okta`:

| Keychain Access UI | `security` CLI flag | Example |
| -------------------- | --------------------- | --------- |
| **Where** | `-s` (service) | `work-vault-okta` |
| **Account** | `-a` (account) | `YOUR_LDAP` (work LDAP) |
| **Name** (display) | `-l` (label) | `work-vault-okta` |
| **Password** | `-w` (never echo in scripts logged to disk) | corp LDAP |

Ansible `vault_okta_keychain_service` in `work.local.yml` must match **Where / `-s`**. On older machines the service name may differ — set the override in `work.local.yml`, not in this repo.

Verify without printing the password:

```bash
security find-generic-password -s work-vault-okta -a YOUR_LDAP >/dev/null && echo ok
```

After Keychain setup: `make apply && source ~/.zshrc` — the vault-tools block exports `VAULT_OKTA_PASSWORD_CMD` when the probe succeeds.

## Registry summary

Metadata lives in `config/secrets-registry.yml`:

| ID | Store | Service / path | Account | Used by |
| ---- | ------- | ---------------- | --------- | --------- |
| `vault_okta` | Keychain | `work-vault-okta` (override in `work.local.yml`) | `work_username` | `vl`, `vault_mgmt` |
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
| Corp LDAP / VPN password | Keychain (`make secrets-vault-okta`) |
| Notion MCP token | Keychain (`make secrets-notion`) |
| Linear MCP API key | Keychain (`make secrets-linear`) |
| Artifactory API key | `export KLAM_ARTIFACTORY_API_KEY=…` at apply time |
| Jira / Confluence tokens | Keychain (`make secrets-atlassian`) |
| SSH private keys | `~/.ssh/` |
| `group_vars/work.local.yml` | Gitignored clone-local file |
| `~/.config/ai-skills/local.json` | See [ai-local-config.md](ai-local-config.md) |

## Rotation

Corp password rotation: [docs/work/runbooks/corp-password-keychain-rotation.md](work/runbooks/corp-password-keychain-rotation.md) — update Keychain only; no `make apply` required unless service/account names change.

## Planned: 1Password (employer)

**Today:** work Macs use **Keychain** for the corp LDAP password (`make secrets-vault-okta`). **1Password CLI is already wired for Vault only** — set in `group_vars/work.local.yml`:

```yaml
vault_okta_use_password_store: true
vault_okta_keychain_service: ""   # leave empty when using op
vault_okta_op_ref: "op://VAULT/Item Name/password"   # example — use your real op:// path
```

Discover paths: `op item list --categories Login` (requires `op` signed in to the **employer** account).

**When your employer provides org 1Password**, extend the same pattern (see `planned_onepassword` in `config/secrets-registry.yml`):

| Secret | Today | 1Password target |
| -------- | -------- | ------------------ |
| Vault Okta LDAP | Keychain or `vault_okta_op_ref` | `op://…` (supported now) |
| KLAM Artifactory API key | `KLAM_ARTIFACTORY_API_KEY` env | `op read` / `op run` at apply time |
| Atlassian MCP tokens | `~/.mcp/env/atlassian.env` | `op inject` or env from `op run` |
| Chezmoi / dotfiles | N/A | optional `op` template provider (heavier; defer) |

**Planned Make targets** (not built yet): `secrets-1p-discover`, `secrets-1p-vault-okta`, `secrets-check` branch that verifies `op` session + item existence.

**Private notes:** store real `op://` paths in your gitignored `work.local.yml` or private Memex — never in the public repo.

## See also

- [docs/work/vault-tools.md](work/vault-tools.md) — Vault CLI helpers
- [docs/work/klam.md](work/klam.md) — Artifactory API key
- [docs/ai-local-config.md](ai-local-config.md) — ai-skills private JSON
