# AGENT.md — workstation-devops

> Personal workstation Ansible repo. See [CLAUDE.md](CLAUDE.md) for Claude Code policy.

## Architecture

```
playbook.yml              ← immutable role list only
vars/config.yml           ← all machine config (paths, buckets, clones)
scripts/install.sh        ← remote bootstrap: mkdir, clone, make deps apply
scripts/bootstrap-deps.sh ← CLT + Homebrew + Ansible
setup.sh / bootstrap.sh   ← local: make deps apply
roles/ directories | homebrew | repos | chezmoi
```

Bootstrap installs the toolchain; Ansible applies layout and clones. Content repos:

- `workspace` — Cursor workspace files (GitLab)
- `personal/claude-skills` — skills (`install.sh` after clone)

## Conventions

- Change behavior via **`vars/config.yml`**, not roles or `playbook.yml`, unless adding a new capability.
- Idempotent roles — safe to re-run `make apply`.
- `workstation-devops` is cloned by `install.sh` / manually; it is not in `managed_repos`.

## Key files

| File | Purpose |
|------|---------|
| `vars/config.yml` | Single source of configuration |
| `scripts/install.sh` | curl \| bash entry point |
| `Makefile` | `deps`, `dry-run`, `apply` |

## Gotchas

- **`make dry-run` must not write** — chezmoi/repos/directories roles respect `dry_run`.
- **SSH host keys** — `repos` role runs `ssh-keyscan` for `git_ssh_hosts` before cloning.
- **Workspace paths** — `.code-workspace` files use paths relative to each file; must match bucket layout under `projects_root`.

## Migration

Legacy `~/Projects` layout: [docs/migration.md](docs/migration.md).
