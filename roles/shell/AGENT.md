# AGENT.md — shell

> zshrc fragments for PATH, `mytools`, Starship init, and profile-specific AWS/Teleport exports.
> Repo context: see [root AGENT.md](../../AGENT.md). Prompt: [docs/shell-prompt.md](../../docs/shell-prompt.md).

## Purpose

Deploys Ansible `blockinfile` sections into `~/.zshrc`. Common block always (when `shell` is in the tag allowlist); work and personal blocks are gated by `work` / `home` tags. Does not own the rest of `~/.zshrc` — unmanaged lines (oh-my-zsh, a leftover `starship init`) stay put.

## Inputs / Interface

| Variable | Required | Default | Notes |
| -------- | -------- | ------- | ----- |
| `shell_enabled` | no | `true` | Role-level off switch |
| `personal_aws_profile` / `_region` / `_tf_state_bucket` | personal only | `platform-bootstrap` / `us-west-2` / `mccleaton-tfstate` | `shell_personal.zsh.j2` |
| `personal_vault_cluster` | personal only | `specterrealm` | Sets `VAULT_CLUSTER` only when `VAULT_ADDR` is already set |
| `work_username` | work block | chezmoi identity | `TELEPORT_LOGIN`, `CONFLUENCE_USER` |
| `work_gh_user` | work block | `{{ work_username }}_adobe` | `~/Projects/.envrc` `GH_TOKEN` |

## Key files

| File | What it does |
| ---- | ------------ |
| `tasks/main.yml` | `blockinfile` into `~/.zshrc`; work also writes `~/Projects/.envrc` |
| `templates/shell_common.zsh.j2` | PATH, `mytools`, guarded `starship init` |
| `templates/shell_personal.zsh.j2` | Personal AWS exports + `VAULT_CLUSTER` default |
| `templates/shell_work.zsh.j2` | Teleport/Confluence + `vssh` |

## Conventions

- Markers are `# {mark} ANSIBLE MANAGED - workstation-devops shell-{common,work,personal}`. Do not reuse those strings for other roles (vault/klam/teleport have their own).
- Starship init runs only when `starship` is on PATH **and** `STARSHIP_SHELL` is unset, so an unmanaged init earlier in `~/.zshrc` is not doubled.

## Gotchas

- **Work will not brew-install starship.** `homebrew_install_packages: false` on work. Missing binary → common fragment is a no-op; oh-my-zsh stays in charge.
- **`mytools` is defined in the common fragment**, not in klam/vault roles. Cluster listing reads `VAULT_TOOLS_CLUSTER_*` arrays that vault_tools injects at runtime — if those arrays are missing, it falls back to scanning `vault_*` aliases.
