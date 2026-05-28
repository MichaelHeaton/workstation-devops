# Vault CLI helpers — work profile

Automated by `roles/vault_tools` on `make apply` when `workstation_profile=work`.

**Wiki:** [Vault Engineer Onboarding](https://wiki.corp.adobe.com/pages/viewpage.action?pageId=2842250667) → Tips/Shortcuts → Bash Functions and Aliases

## What Ansible deploys

| Function | Purpose |
|----------|---------|
| `vl` | Numbered cluster picker → `VAULT_ADDR` + Okta login |
| `vault_login` | Alias for `vl` (wiki name) |
| `vault_mgmt` | Teleport app `vault-mgmt-access` → local proxy :8222 + Okta login |

Deployed to `~/.config/workstation-devops/vault_functions.zsh`, sourced from `~/.zshrc`.

**Username:** templated from `adobe_username` in `group_vars/work.yml` (default `ult35127`).

**Okta password store:** Ansible writes `VAULT_OKTA_*` exports into the vault-tools block in `~/.zshrc` from `group_vars/work.yml` — do not edit that block by hand.

## Prerequisites

- `vault` and `tsh` on PATH
- `TELEPORT_LOGIN` set (you may already have this in `~/.zshrc`)
- VPN for corp Vault URLs
- `GRP-CES-Vault-Admins` + `CST_vault_admin` for Okta auth

## Cluster list (`vl`)

Includes **VII-DEV** (`https://vault-vii.dev.adobe.net`) and **VII-DEV-INT** (`https://vault-int-vii.dev.adobe.net`) for the immutable-infra sandbox cluster (AWS1864 / `365215803550`).

## Optional: ADOBENET password from Keychain or 1Password

`vl` and `vault_mgmt` still require **Okta MFA** (Watch push). This only skips typing the ADOBENET password.

**Apple Passwords caveat:** the UI title (e.g. `Adobe: ADOBENET`) is often **not** the Keychain `service` name, and many Apple Passwords entries are **not** visible to `security find-*` from Terminal. If lookup fails, you still get the normal password prompt (no error spam).

### Ansible config (`group_vars/work.yml`)

```yaml
vault_okta_use_password_store: true
vault_okta_keychain_service: adobe-vault-okta   # Keychain "service" name (not Apple Passwords title)
# vault_okta_op_ref: "op://Employee/Adobe ADOBENET/password"   # instead of keychain, if using 1Password CLI
```

`make apply` updates the vault-tools block in `~/.zshrc`. Exports are written **only after** the Keychain item exists (or `vault_okta_op_ref` is set). Until then, `vl` uses the normal password prompt with no warning noise. Set `vault_okta_use_password_store: false` to disable entirely.

### One-time manual step: Keychain Access (not Apple Passwords)

**Important:** entries in the **Passwords** app (System Settings → Passwords) are **not** visible to `security` or Terminal. You must create the item in **Keychain Access** (`/Applications/Utilities/Keychain Access.app`).

1. **Keychain Access** → **File → New Password Item** (not Passwords app → New Password)
2. **Keychain Item Name:** `adobe-vault-okta` — this becomes the **service** name (must match `vault_okta_keychain_service`)
3. **Account Name:** `ult35127` (must match `adobe_username`)
4. **Password:** ADOBENET
5. **Keychain:** login (default)
6. `make apply` → `source ~/.zshrc` → first `vl` → **Touch ID** to allow Terminal

Verify:

```bash
security find-generic-password -s adobe-vault-okta -a ult35127 -w && echo found
```

If you already added `adobe-vault-okta` in the Passwords app, leave it there for autofill in browsers and **duplicate** the password into a Keychain Access item as above (same values).

### 1Password CLI (optional)

Set `vault_okta_op_ref` in `group_vars/work.yml` and leave keychain service unused. Run `op item list --categories Login | grep -i adobe` for the `op://` path.

### Discover an existing Keychain entry (if any)

```bash
security dump-keychain login.keychain-db 2>/dev/null | grep -i adobe | head -20
security find-generic-password -s 'adobe-vault-okta' -g 2>&1 | head -3   # after you create it
```

Do **not** use `YOUR-EXACT-LABEL` from examples literally — that placeholder will always fail.

**Tradeoffs:** password may appear briefly in the process list; failed lookup falls back to the interactive prompt.

**90-day ADOBENET rotation:** when Adobe forces a password change, update the Keychain item — [Runbook: ADOBENET Keychain rotation](runbooks/adobenet-keychain-rotation.md).

## Test

```bash
source ~/.zshrc
vl              # pick cluster, Okta MFA
vault_mgmt      # MGMT via Teleport
```

## Not in this role (see roadmap)

- `vault_heartbeat_env`, `vault_rw_loop` — add later if needed
- Teleport `tshl` / `t` fzf helpers → [teleport.md](teleport.md) (`roles/teleport`)
- Deprecated bastion `scb` / `bcp` — use Teleport
