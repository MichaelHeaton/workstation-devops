# AGENT.md — workstation-devops

> Personal + work workstation Ansible repo. See [CLAUDE.md](CLAUDE.md) for Claude Code policy.

## Architecture

```
site.yml                    ← main entry (profile detect + gated roles)
profile_detect.yml          ← profile setup / re-detect only
group_vars/all.yml          ← shared vars
group_vars/work.yml         ← work profile
group_vars/personal.yml     ← personal profile
~/.workstation_profile      ← persisted machine identity (work | personal)
roles/common/               ← directories, homebrew, repos, chezmoi (always)
roles/work/                 ← work-only (vault-tools, teleport — migrate here)
roles/personal/             ← personal-only extensions
scripts/install.sh          ← remote bootstrap
```

Bootstrap installs the toolchain; Ansible applies layout, packages, and clones per profile.

## Conventions

- Change behavior via **`group_vars/`**, not roles or `site.yml`, unless adding a capability.
- **`vars/config.yml` is deprecated** — do not add new keys there.
- Idempotent roles — safe to re-run `make apply`.
- `install.sh` bootstraps this repo on a new Mac; `managed_repos_common` in `all.yml` also lists it so `make apply` ensures the clone on every profile.
- **Packages are detect-first** — `make check` and the `homebrew` role satisfy tools via PATH or `/Applications` before requiring Homebrew. Work profile sets `homebrew_install_packages: false` (Adobe IT). MAS is off by default; enable only on `personal` with a signed-in Apple ID. `homebrew_upgrade: true` opts into `brew update && brew upgrade` (default off).
- **Brave profiles** — `dotfiles/brave-profiles/profiles.json` holds icons, colors, and NTP backgrounds. After UI changes: quit Brave, run `./scripts/brave-profiles-export.sh`, commit, then `make apply` on other machines.

## Key commands

| Command | Purpose |
|---------|---------|
| `make profile` | Detect or change `~/.workstation_profile` |
| `make dry-run` | Preview without writes |
| `make apply` | Apply configuration |
| `make check` | Preflight against active profile |

## Gotchas

- **`make dry-run` must not write** — chezmoi/repos/directories respect `dry_run`.
- **Profile required** — `make apply` passes `-e workstation_profile=…` when `~/.workstation_profile` exists; first run needs `make profile` or an explicit `-e`.
- **Work chezmoi identity** — first work run may need `adobe_username`, `full_name`, `adobe_email` extra-vars (see `group_vars/work.yml`).
- **SSH host keys** — `repos` role runs `ssh-keyscan` before cloning.

## Work profile (CES Vault)

- Onboarding wiki: [Vault Engineer Onboarding](https://wiki.corp.adobe.com/pages/viewpage.action?pageId=2842250667)
- Docs: [docs/work/](docs/work/) — roadmap, manual setup, planned `roles/work/` imports
- **kubelogin v0.1.9 only** (Ethos); bastion aliases `scb`/`bcp`/`bcp2` deprecated — use Teleport
- **KLAM** needs IAM groups before profiles work; **TELEPORT_LOGIN** = LDAP username (not email)
- **Adobe VPN** for corp Git/Jenkins/internal Vault at runtime

## Migration

Legacy `~/Projects` layout: [docs/migration.md](docs/migration.md).  
`workstation-ces_vault` content is folded here; implement remaining roles per [docs/work/ces-vault-roadmap.md](docs/work/ces-vault-roadmap.md).
