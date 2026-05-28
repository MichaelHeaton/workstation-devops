# Teleport fzf helpers — work profile

Automated by `roles/teleport` on `make apply` when the `work` tag is in the allowlist.

**Wiki:** [Vault Engineer Onboarding](https://wiki.corp.adobe.com/pages/viewpage.action?pageId=2842250667) → Tips/Shortcuts → Teleport Easy Mode w/Fuzzy Finder (fzf)

## What Ansible deploys

| Helper | Purpose |
|--------|---------|
| `t` | Fuzzy-pick from `tsh ls` (full row) → `tsh ssh` |
| `tshl` | Alias: `tsh ssh $(tsh ls \| cut … \| fzf)` |

Deployed to `~/.config/workstation-devops/teleport_helpers.zsh`, sourced from `~/.zshrc`.

Related (shell role, `work` tag): `TELEPORT_LOGIN`, `vssh` alias — see `roles/shell/templates/shell_work.zsh.j2`.

## Prerequisites

- `tsh` on PATH (Adobe Teleport client)
- `fzf` on PATH — `brew install fzf` if missing
- `TELEPORT_LOGIN` = Adobe LDAP username (not email)
- VPN for corp Teleport clusters

Work profile sets `homebrew_install_packages: false` — Ansible **detects** `fzf` via Homebrew/PATH but does not install it on locked-down work Macs.

## Test

```bash
source ~/.zshrc
tsh status      # logged in
t             # fzf host picker → ssh
tshl          # alternate alias from wiki
```

## Deprecated

Bastion aliases `scb`, `bcp`, `bcp2` — use Teleport instead.
