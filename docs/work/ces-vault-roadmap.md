# CES Vault roles — import roadmap

Imported from `workstation-ces_vault` README/AGENT (2026-05). Dotfiles and common roles already live in workstation-devops.

**Implemented:** `vault-tools`, `klam`, `shell`, `teleport`, `kubernetes`, `git-github` (tagged in `roles/common/`). Docs: [vault-tools.md](vault-tools.md), [klam.md](klam.md), [teleport.md](teleport.md), [kubernetes.md](kubernetes.md), [git-github.md](git-github.md), [tags.md](../tags.md).

| Role | Target | Notes |
|------|--------|-------|
| ~~`shell`~~ | ~~oh-my-zsh, zshrc fragments~~ | **Done** — `roles/shell/` (`shell` + `work` tags) |
| ~~`teleport`~~ | ~~fzf, `t()`, `tshl`~~ | **Done** — `roles/teleport/` (`work` tag) |
| ~~`kubernetes`~~ | ~~kubelogin **v0.1.9 only**~~ | **Done** — `roles/kubernetes/` (`work` tag) |
| ~~`git-github`~~ | ~~GHEC SSH + gh~~ | **Done** — `roles/git_github/` + chezmoi gh config (`work` / `dotfiles`) |

## Wiring when a role is ready

1. Add `roles/work/<role>/tasks/main.yml` (idempotent; use `stat` / `when` guards).
2. Import from `roles/work/tasks/main.yml`:

   ```yaml
   - name: Import vault-tools role
     ansible.builtin.import_role:
       name: vault_tools
   ```

   (Use the correct role path/name for your layout.)

3. Extend `make check` / preflight if the role adds binaries to detect-first lists in `group_vars/all.yml`.

## Gotchas (carry forward)

- **kubelogin v0.1.9** — do not upgrade via Homebrew.
- **Bastion aliases** `scb`, `bcp`, `bcp2` — deprecated; use Teleport.
- **KLAM** — CLI can be installed before IAM group membership; profiles fail until groups are granted.
- **Adobe VPN** — required at runtime for corp Git, Jenkins, internal Vault URLs.
- **`TELEPORT_LOGIN`** — Adobe LDAP username only (not full email).

## External references

- [Vault Engineer Onboarding wiki](https://wiki.corp.adobe.com/pages/viewpage.action?pageId=2842250667)
- [KLAM CLI wiki](https://wiki.corp.adobe.com/display/spartans/KLAM+Command+Line+Interface)
