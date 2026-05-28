# Work profile — CES Vault team (Adobe)

Adobe **work** machines use `workstation_profile=work` (see `group_vars/work.yml`). This tree holds CES Vault–specific docs and the roadmap for roles under `roles/work/`.

**Source:** Vault Engineer Onboarding wiki (internal) — Vault CLI helpers, Teleport/fzf, KLAM AWS aliases, kubelogin, GHEC SSH.

## Already in workstation-devops

| Area | Location |
|------|----------|
| MCP + Claude security dotfiles | `dotfiles/run_onchange_sync-mcp-servers.sh.tmpl`, `dotfiles/run_onchange_merge-claude-security.sh.tmpl` |
| Adobe cursor rules clone | `group_vars/work.yml` → `adobe/adobe-cursor-rules` |
| Detect-first Homebrew (IT installs apps) | `group_vars/work.yml` |
| Brave work profiles | `dotfiles/brave-profiles/` |
| AI Spend Tracker (public DMG) | `roles/mac_dmg_apps` — [ai-spend-tracker.md](ai-spend-tracker.md) |
| Vault CLI helpers (`vl`, Okta Keychain) | `roles/vault_tools` — [vault-tools.md](vault-tools.md) |
| KLAM CLI + `ces_*` AWS aliases | `roles/klam` — [klam.md](klam.md) |
| Teleport fzf (`t`, `tshl`) | `roles/teleport` — [teleport.md](teleport.md) |
| kubelogin v0.1.9 (Ethos) | `roles/kubernetes` — [kubernetes.md](kubernetes.md) |
| GHEC SSH + gh config | `roles/git_github` + chezmoi — [git-github.md](git-github.md) |
| ADOBENET Keychain rotation | [runbooks/adobenet-keychain-rotation.md](runbooks/adobenet-keychain-rotation.md) |

## Planned (from legacy `workstation-ces_vault`)

Roadmap items from `workstation-ces_vault` are implemented. See [ces-vault-roadmap.md](ces-vault-roadmap.md) for history.

## Manual steps

Steps that cannot be automated: [setup-notes.md](setup-notes.md).

## Legacy repo

`workstation-ces_vault` on GitHub is **deprecated** — content was folded into this repo (MR !18). Do not clone it for new machines; use `make apply` with profile `work`.
