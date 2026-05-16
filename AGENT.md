# AGENT.md — workstation-devops

> AI agent context document. Read this before working in this repository.
> Provider-specific configuration: see [CLAUDE.md](CLAUDE.md).

## What this is

Ansible-based personal workstation setup for DevOps and development work.
Covers shell environment, core CLI tools, and language runtimes.
Public repo — contains no Adobe-proprietary content, credentials, or internal URLs.

## Architecture

```
bootstrap.sh         ← run this first on a new machine
playbook.yml         ← main Ansible playbook
inventory/local      ← localhost inventory
roles/
  homebrew/          ← Brewfile and package installs
  shell/             ← oh-my-zsh, zshrc, theme (robbyrussell)
  development/       ← git, gh CLI, Go, AWS CLI, Azure CLI, Ansible
  vscode/            ← VS Code + extension list
  minecraft-tools/   ← packwiz, Java (for modpack dev)
docs/
  README.md
```

Entry point is `bootstrap.sh`: installs Homebrew, then Ansible via brew, then
runs `playbook.yml`. The playbook is idempotent — safe to re-run on a live machine.

## Getting started

```bash
git clone git@gitlab.com:Michael-Heaton/workstation-devops.git ~/Projects/personal/workstation-devops
cd ~/Projects/personal/workstation-devops
./bootstrap.sh
```

## Conventions

- Idempotent roles only — safe to re-run on a live machine without breaking anything.
- **Hard boundary**: nothing Adobe-specific goes here. No KLAM, no internal URLs, no Adobe account identifiers, no Vault-specific tooling.
- Shell fragments sourced from `.zshrc`, not written directly to it.
- Generic DevOps tooling only — if it's specific to one employer, it belongs in a private work repo instead.

## Key files

| File | What it does |
|---|---|
| `bootstrap.sh` | First-run entry point: Homebrew + Ansible + runs playbook |
| `playbook.yml` | Orchestrates all roles in order |
| `roles/homebrew/files/Brewfile` | Declarative package list |
| `roles/minecraft-tools/tasks/main.yml` | packwiz + Java install for modpack dev |

## Security

Public repo. Hard rules:
- No tokens, credentials, or secrets of any kind.
- No Adobe-internal URLs, account IDs, or tool configurations.
- No KLAM, no Vault-specific aliases, no Adobe AWS account references.
- SSH key paths are placeholders — users supply their own at apply time.

## Gotchas

- **bootstrap.sh must install Ansible before running the playbook** — Ansible is not present on a clean macOS install. The script installs Homebrew first, then Ansible via brew, then runs the playbook.
- **packwiz lives in minecraft-tools role** — it's a personal project tool, not standard DevOps tooling. Kept in its own role so it can be skipped or excluded cleanly.

## What's not documented here

- Adobe-specific workstation setup → private repo `workstation-ces_vault`
- Vault team tooling (KLAM, Vault CLI functions, Teleport config) → `workstation-ces_vault`
