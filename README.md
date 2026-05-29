# workstation-devops

Single Ansible workstation bootstrap for **personal** and **work** machines. Profile gates what gets installed; shared tooling always runs.

**Edit configuration in `group_vars/`** — not roles or `site.yml`.

| File | Purpose |
| ------ | --------- |
| `group_vars/all.yml` | Shared packages, paths, `managed_repos_common` (workspace, devops, claude-skills, ai-skills, memex) |
| `group_vars/personal.yml` | Homelab repos, gaming, personal buckets |
| `group_vars/work.yml` | Work layout, CES Vault tooling, work identity |
| `group_vars/work.local.yml.example` | Template for gitignored employer-specific URLs/repos |

Machine identity is stored in **`~/.workstation_profile`** (`work` or `personal`).

## Quick start (new Mac)

```bash
curl -fsSL "https://raw.githubusercontent.com/MichaelHeaton/workstation-devops/main/scripts/install.sh" | bash
```

Creates `~/Projects`, clones this repo, installs Ansible (`make deps`), detects profile, runs the playbook (`make apply`).

Or manually:

```bash
mkdir -p ~/Projects/personal
git clone git@github.com-personal:MichaelHeaton/workstation-devops.git ~/Projects/personal/workstation-devops
cd ~/Projects/personal/workstation-devops
./setup.sh
```

```bash
make profile    # first-time or change work | personal
make check      # detect-first preflight (PATH, /Applications, then Homebrew)
make dry-run    # preview changes
make apply      # apply (installs missing items only when profile allows)
```

## Profiles

| Profile | Typical machine | Extra installs |
| --------- | ----------------- | ---------------- |
| `personal` | Your Mac | Homelab repos, Steam; Homebrew installs + optional MAS (Slack) |
| `work` | Work laptop | Detect-only packages (IT installs); no MAS; CES Vault docs + MCP dotfiles — [docs/work/](docs/work/) |

**Override for one run:** `ansible-playbook site.yml -e workstation_profile=work`

**Extra vars via Make:** `make apply EXTRA_VARS='-e homebrew_upgrade=true'` (`-e` after `make apply` is not forwarded to Ansible)

**Re-detect:** `make profile` or `ansible-playbook profile_detect.yml -e force_reprofile=true`

**Non-interactive (CI / no TTY):** `-e skip_profile_prompt=true -e workstation_profile=personal`

## Layout

```
site.yml                 # main entry (profile detect + apply)
profile_detect.yml       # profile only
group_vars/all.yml       # shared
group_vars/work.yml      # work overrides
group_vars/personal.yml  # personal overrides
roles/common/            # always: directories, homebrew, repos, chezmoi
roles/work/              # work-only (extend with vault-tools, etc.)
roles/personal/          # personal-only hooks
```

**Every profile** clones `managed_repos_common` from `all.yml` (multi-domain Cursor workspaces, skills, memex, this repo). Profile vars add the rest (homelab vs work tooling).

- **`workspace`** — Cursor `.code-workspace` files (multi-domain)
- **`personal/ai-skills`** — portable AI workspace (`make install-system` + `make hooks-install` on clone and re-apply)
- **`personal/claude-skills`** — legacy mirror (clone only; deploy from ai-skills)
- **`personal/memex`** — knowledge vault

## Work profile (CES Vault)

Automates tooling described in the Vault Engineer Onboarding wiki (internal). Vault, Teleport, KLAM, and related roles live in this repo — see [docs/work/](docs/work/) and [docs/work/ces-vault-roadmap.md](docs/work/ces-vault-roadmap.md) for import history.

The former standalone `workstation-ces_vault` repo was merged here and **deleted**; use this repo only.

## Migrating an existing Mac

See [docs/migration.md](docs/migration.md) for `~/Projects` layout changes.

## Secrets

Passwords and API tokens stay in **Keychain** or gitignored local files — see [docs/secrets-keychain.md](docs/secrets-keychain.md). Quick check: `make secrets-check`.

## For agents

See [AGENT.md](AGENT.md).
