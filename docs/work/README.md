# Work profile — CES Vault team

**Work** machines use `workstation_profile=work` (see `group_vars/work.yml`). This tree holds CES Vault–specific docs and the roadmap for roles under `roles/work/`.

**Source:** Vault Engineer Onboarding wiki (internal) — Vault CLI helpers, Teleport/fzf, KLAM AWS aliases, kubelogin, GHEC SSH.

Employer-specific URLs and repos: **`group_vars/work.local.yml`** (gitignored; copy from `work.local.yml.example`).

## Already in workstation-devops

| Area | Location |
| ------ | ---------- |
| MCP + Claude security dotfiles | `dotfiles/run_onchange_sync-mcp-servers.sh.tmpl`, `dotfiles/run_onchange_merge-claude-security.sh.tmpl` |
| Cursor rules clone | `group_vars/work.local.yml` → `work/cursor-rules` |
| Detect-first Homebrew (IT installs apps) | `group_vars/work.yml` |
| Brave work profiles | `dotfiles/brave-profiles/` |
| AI Spend Tracker (public DMG) | `roles/mac_dmg_apps` — [ai-spend-tracker.md](ai-spend-tracker.md) |
| Vault CLI helpers (`vl`, Okta Keychain) | `roles/vault_tools` — [vault-tools.md](vault-tools.md) |
| KLAM CLI + `ces_*` AWS aliases | `roles/klam` — [klam.md](klam.md) |
| Teleport fzf (`t`, `tshl`) | `roles/teleport` — [teleport.md](teleport.md) |
| kubelogin v0.1.9 (Ethos) | `roles/kubernetes` — [kubernetes.md](kubernetes.md) |
| GHEC SSH + gh config | `roles/git_github` + chezmoi — [git-github.md](git-github.md) |
| Corp password Keychain rotation | [runbooks/corp-password-keychain-rotation.md](runbooks/corp-password-keychain-rotation.md) |

## Import history

All roles from the former `workstation-ces_vault` repo are implemented in this tree. See [ces-vault-roadmap.md](ces-vault-roadmap.md) for the original import checklist.

## Manual steps

Steps that cannot be automated: [setup-notes.md](setup-notes.md).

## Former standalone repo

`workstation-ces_vault` was merged into workstation-devops and **deleted** on GitHub. Do not look for it — use `make apply` with profile `work` on this repo.
