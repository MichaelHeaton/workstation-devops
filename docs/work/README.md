# Work profile — CES Vault team (Adobe)

Adobe **work** machines use `workstation_profile=work` (see `group_vars/work.yml`). This tree holds CES Vault–specific docs and the roadmap for roles under `roles/work/`.

**Source of truth for onboarding:** [Vault Engineer Onboarding wiki](https://wiki.corp.adobe.com/pages/viewpage.action?pageId=2842250667) — Vault CLI helpers, Teleport/fzf, KLAM AWS aliases, kubelogin, GHEC SSH.

## Already in workstation-devops

| Area | Location |
|------|----------|
| MCP + Claude security dotfiles | `dotfiles/run_onchange_sync-mcp-servers.sh.tmpl`, `dotfiles/run_onchange_merge-claude-security.sh.tmpl` |
| Adobe cursor rules clone | `group_vars/work.yml` → `adobe/adobe-cursor-rules` |
| Detect-first Homebrew (IT installs apps) | `group_vars/work.yml` |
| Brave work profiles | `dotfiles/brave-profiles/` |

## Planned (from legacy `workstation-ces_vault`)

See [ces-vault-roadmap.md](ces-vault-roadmap.md). Implement as Ansible roles under `roles/work/` and wire them in `roles/work/tasks/main.yml`.

## Manual steps

Steps that cannot be automated: [setup-notes.md](setup-notes.md).

## Legacy repo

`workstation-ces_vault` on GitHub is **deprecated** — content was folded into this repo (MR !18). Do not clone it for new machines; use `make apply` with profile `work`.
