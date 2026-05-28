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
roles/common/               ← directories, homebrew, repos, tagged dotfiles/shell/work tools
roles/work/                 ← work profile marker (+ future work-only tasks tagged `work`)
roles/personal/             ← personal profile marker (+ future home-only tasks tagged `home`)
scripts/install.sh          ← remote bootstrap
```

Bootstrap installs the toolchain; Ansible applies layout, packages, and clones per profile.

## Conventions

- Change behavior via **`group_vars/`**, not roles or `site.yml`, unless adding a capability.
- **`vars/config.yml` is deprecated** — do not add new keys there.
- Idempotent roles — safe to re-run `make apply`.
- `install.sh` bootstraps this repo on a new Mac; `managed_repos_common` in `all.yml` also lists it so `make apply` ensures the clone on every profile.
- **Packages are detect-first** — `make check` and the `homebrew` role satisfy tools via PATH or `/Applications` before requiring Homebrew. Work profile sets `homebrew_install_packages: false` (employer IT). MAS is off by default; enable only on `personal` with a signed-in Apple ID. `homebrew_upgrade: true` opts into `brew update && brew upgrade` (default off).
- **GitHub-release DMG apps** — `roles/mac_dmg_apps` installs apps from public release assets (catalog in `group_vars/all.yml`). Independent of Homebrew; see [docs/work/ai-spend-tracker.md](docs/work/ai-spend-tracker.md).
- **Brave profiles** — `dotfiles/brave-profiles/profiles.json` holds icons, colors, and NTP backgrounds. After UI changes: quit Brave, run `./scripts/brave-profiles-export.sh`, commit, then `make apply` on other machines.
- **Apple Notes (code snippets)** — `roles/macos_defaults` uses PlistBuddy on the Notes sandbox plist; `defaults write com.apple.Notes` does not work on modern sandboxed Notes. Apply quits Notes first.
- **Editor extensions** — lists in `dotfiles/editors/*.txt`; installed when `editors` tag is allowed. Work-only extensions require `work` tag. See [docs/editors.md](docs/editors.md).
- **Git / SSH / shell** — chezmoi (`dotfiles` tag) for git/SSH/gh/zprofile; `shell` tag for zshrc fragments. Work tooling (`work` tag): Teleport, kubelogin, KLAM, Vault. See [docs/tags.md](docs/tags.md).

## Key commands

| Command | Purpose |
|---------|---------|
| `make profile` | Detect or change `~/.workstation_profile` |
| `make dry-run` | Preview without writes |
| `make apply` | Apply configuration (respects tag allowlist for profile) |
| `make apply TAGS=dotfiles` | Chezmoi/dotfiles only |
| `make apply SKIP_TAGS=work` | Skip work-tagged tooling |
| `make apply EXTRA_VARS='-e workstation_tags_extra=[work]'` | Add work tools on any profile |
| `make check` | Preflight against active profile |

## Gotchas

- **`make dry-run` must not write** — chezmoi/repos/directories respect `dry_run`.
- **Profile required** — `make apply` passes `-e workstation_profile=…` when `~/.workstation_profile` exists; first run needs `make profile` or an explicit `-e`.
- **Work chezmoi identity** — first work run: `make apply EXTRA_VARS='-e work_username=YOUR_LDAP -e work_email=you@work.example'`. Stored in `~/.config/chezmoi/chezmoi.yaml` and reused on later runs (including `TAGS=shell`). CLI `-e work_username=…` still overrides. Older chezmoi configs with a legacy username key are migrated on read.
- **Work local overrides** — employer URLs/repos in `group_vars/work.local.yml` (gitignored; copy from `work.local.yml.example`).
- **SSH host keys** — `repos` role runs `ssh-keyscan` before cloning.

## Work profile (CES Vault)

- Onboarding wiki: Vault Engineer Onboarding (internal)
- Docs: [docs/work/](docs/work/) — roadmap, manual setup, planned `roles/work/` imports
- **kubelogin v0.1.9 only** (Ethos); bastion aliases `scb`/`bcp`/`bcp2` deprecated — use Teleport
- **KLAM** needs IAM groups before profiles work; **TELEPORT_LOGIN** = LDAP username (not email)
- **Corp VPN** for internal Git/Jenkins/Vault at runtime

## Migration

Legacy `~/Projects` layout: [docs/migration.md](docs/migration.md).  
CES Vault tooling was imported from the deleted `workstation-ces_vault` repo; see [docs/work/ces-vault-roadmap.md](docs/work/ces-vault-roadmap.md) for history.
