# Vault CLI helpers — work profile

Automated by `roles/vault_tools` on `make apply` when `workstation_profile=work`.

**Auth tool:** [`vl` (adobe-security-tooling/vaultlogin)](https://github.com/adobe-security-tooling/vaultlogin) — OIDC-based, built and maintained by the Vault team. This role installs it and generates per-cluster aliases from `vault_clusters`; it replaces the older onboarding-wiki Okta shell function (Okta login was retired when the team's Vault clusters moved to OIDC).

## What Ansible deploys

| Item | Purpose |
| ---------- | --------- |
| `vl` binary | Installed to `~/.local/bin/vl`, pinned to `vaultlogin_version` |
| `vault_<cluster>` aliases | One per entry in `vault_clusters` (e.g. `vault_test`, `vault_dev_amer`) — sets `VAULT_ADDR`/`VAULT_NAMESPACE`, unsets stale `VAULT_TOKEN`, runs `vl` |
| `vault_local` | Plain `vault login` against a local dev-mode server (`127.0.0.1:8200`) |
| `vault_mgmt` | Teleport app `vault-mgmt-access` → local proxy `:8222`, then `vl` |
| `~/.vault` token helper config | `vl token-helper setup` — caches a separate token per `VAULT_ADDR`/`VAULT_NAMESPACE` in macOS Keychain |

Aliases deployed to `~/.config/workstation-devops/vault_functions.zsh`, sourced from `~/.zshrc`.

## Prerequisites

- `vault` and `tsh` on PATH
- `gh` authenticated (used by this role to pull the `vl` release — private org repo)
- `TELEPORT_LOGIN` set (you may already have this in `~/.zshrc`)
- VPN for corp Vault URLs
- Required IAM/OIDC groups for your Vault clusters (see internal onboarding wiki)

## Cluster list

Configure **`vault_clusters`** in `group_vars/work.local.yml` (see `work.local.yml.example`). The public repo ships an empty list; work machines add employer cluster URLs locally. Each entry generates an alias named `vault_<label lowercased, - → _>` (e.g. `TEST` → `vault_test`). `VAULT_NAMESPACE` defaults to `root`; add a per-entry `namespace:` key to override.

`mytools` lists these aliases in `vault_clusters` order (not alphabetical), colored by an optional per-entry `tier: dev|prod` key (default `dev`) — dev/test clusters print first in cyan, production last in blue. (Not green/red — those hues match the KLAM terminal-background palette, see `klam.md`, and clashed badly whenever a `ces_*` profile was active.) An optional `indent: true` key marks a cluster as a regional mirror of the entry above it (e.g. `PROD-APAC`/`PROD-EMEA` mirroring `PROD-AMER`), indenting it slightly in the listing.

Each alias is also tagged with the KLAM account it actually runs in, e.g. `vault_vii_dev [sandbox]`, `vault_mgmt [prod]`. This defaults from `tier` (dev→`ces_dev`, prod→`ces_prd`) but can be overridden per cluster with `aws_profile: ces_sandbox|ces_dev|ces_prd` — needed for clusters like `VII-DEV`, which is dev-tier but sandbox-hosted. The tag is deliberately plain text, not colored to match the KLAM account — that would reproduce the same green/yellow/red clash for whichever cluster matches your active session.

## Test

```bash
source ~/.zshrc
vault_test     # or whichever cluster alias you need — OIDC browser login
vault_mgmt     # MGMT via Teleport
vl --version   # confirm the pinned version installed
cat ~/.vault   # confirm token_helper points at the installed vl
```

## Bumping the `vl` version

Edit `vaultlogin_version` in `roles/vault_tools/defaults/main.yml` → branch + PR → `make apply` re-installs.

## Not in this role (see roadmap)

- Teleport `tshl` / `t` fzf helpers → [teleport.md](teleport.md) (`roles/teleport`)
- Deprecated bastion `scb` / `bcp` — use Teleport
