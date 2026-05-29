# Secrets — Keychain and local files

**Public repo rule:** passwords, API tokens, and Artifactory keys **never** go in git, Ansible vars committed to GitHub, or Memex if the vault is synced publicly without encryption.

**Preferred store for corp LDAP password:** macOS **Keychain Access** (login keychain), read at runtime via `security find-generic-password`.

**Registry:** `config/secrets-registry.yml` lists what exists (service names, accounts, docs) — **not** secret values.

**Machine fill-in values:** `group_vars/work.local.yml` (gitignored) + [Memex `work.local.yml`](https://github.com/MichaelHeaton/memex) copy.

## Make helpers

| Command | Purpose |
|---------|---------|
| `make secrets-check` | Verify Keychain items and local secret files (no password output) |
| `make secrets-vault-okta` | Interactive create/update Vault Okta Keychain item |
| `make secrets-atlassian-env` | Create `~/.mcp/env/atlassian.env` from template |
| `make secrets-help` | List all secret setup commands |

## Keychain Access field mapping

When creating an **application password** item manually or via `make secrets-vault-okta`:

| Keychain Access UI | `security` CLI flag | Example |
|--------------------|---------------------|---------|
| **Where** | `-s` (service) | `adobe-vault-okta` |
| **Account** | `-a` (account) | `ult35127` (work LDAP) |
| **Name** (display) | `-l` (label) | `work-vault-okta` |
| **Password** | `-w` (never echo in scripts logged to disk) | corp LDAP |

Ansible `vault_okta_keychain_service` in `work.local.yml` must match **Where / `-s`**, not necessarily the display name.

Verify without printing the password:

```bash
security find-generic-password -s adobe-vault-okta -a YOUR_LDAP >/dev/null && echo ok
```

After Keychain setup: `make apply && source ~/.zshrc` — the vault-tools block exports `VAULT_OKTA_PASSWORD_CMD` when the probe succeeds.

## Configured secrets (this workstation)

Metadata lives in `config/secrets-registry.yml`. Current work-profile setup:

| ID | Store | Service / path | Account | Used by |
|----|-------|----------------|---------|---------|
| `vault_okta` | Keychain | `adobe-vault-okta` | `work_username` | `vl`, `vault_mgmt` |
| `klam_artifactory_api_key` | Shell env | `KLAM_ARTIFACTORY_API_KEY` | — | KLAM pip install |
| `atlassian_mcp` | File | `~/.mcp/env/atlassian.env` | LDAP email in file | Atlassian MCP |

Full values and employer URLs: Memex `Raw/Resources/Adobe/workstation-devops/` (`work.local.yml`, `employer-reference.yml`, `keychain-secrets.yml`).

## What stays out of git

| Secret | Where it lives |
|--------|----------------|
| Corp LDAP / VPN password | Keychain (`make secrets-vault-okta`) |
| Artifactory API key | `export KLAM_ARTIFACTORY_API_KEY=…` at apply time |
| Jira / Confluence tokens | `~/.mcp/env/atlassian.env` |
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

**When Adobe provides org 1Password**, extend the same pattern (see `planned_onepassword` in `config/secrets-registry.yml`):

| Secret | Today | 1Password target |
|--------|--------|------------------|
| Vault Okta LDAP | Keychain or `vault_okta_op_ref` | `op://…` (supported now) |
| KLAM Artifactory API key | `KLAM_ARTIFACTORY_API_KEY` env | `op read` / `op run` at apply time |
| Atlassian MCP tokens | `~/.mcp/env/atlassian.env` | `op inject` or env from `op run` |
| Chezmoi / dotfiles | N/A | optional `op` template provider (heavier; defer) |

**Planned Make targets** (not built yet): `secrets-1p-discover`, `secrets-1p-vault-okta`, `secrets-check` branch that verifies `op` session + item existence.

**Memex:** store real `op://` paths in `keychain-secrets.yml` / `employer-reference.yml` — never in the public repo.

## See also

- [docs/work/vault-tools.md](work/vault-tools.md) — Vault CLI helpers
- [docs/work/klam.md](work/klam.md) — Artifactory API key
- [docs/ai-local-config.md](ai-local-config.md) — ai-skills private JSON
