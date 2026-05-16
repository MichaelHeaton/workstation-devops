# workstation-devops

Personal Ansible workstation bootstrap — fast setup across your machines.

**Edit [vars/config.yml](vars/config.yml)** for paths, project buckets, and git clones.
**Do not** scatter changes across roles or `playbook.yml`.

## Configuration

| Variable | Purpose |
|----------|---------|
| `projects_root` | Base directory (default `~/Projects`) |
| `projects_buckets` | Top-level folders to create |
| `managed_repos` | Repos to clone (`dest` relative to `projects_root`) |
| `git_ssh_hosts` | Hosts added to `~/.ssh/known_hosts` before clone |
| `workstation_devops_*` | Clone URL/path for `scripts/install.sh` |

Content lives in separate repos (cloned via `managed_repos`):

- **`workspace`** — Cursor `.code-workspace` files
- **`personal/claude-skills`** — IA rules (`install.sh` after clone)

## Quick start (new Mac)

```bash
curl -fsSL "https://gitlab.com/Michael-Heaton/workstation-devops/-/raw/main/scripts/install.sh" | bash
```

Creates `projects_root`, clones this repo, installs Ansible (`make deps`), runs the playbook (`make apply`).

Or manually:

```bash
mkdir -p ~/Projects/personal
git clone git@gitlab.com:Michael-Heaton/workstation-devops.git ~/Projects/personal/workstation-devops
cd ~/Projects/personal/workstation-devops
./setup.sh
```

```bash
make dry-run   # preview changes
make apply     # apply
```

Existing repos elsewhere under `~/Projects` are untouched. See [docs/migration.md](docs/migration.md) if you are moving off an older layout.

## Roles

| Role | What it does |
|------|----------------|
| `directories` | Creates `projects_buckets` under `projects_root` |
| `homebrew` | `gh`, `glab`; GitHub Desktop, VS Code, Claude, 1Password |
| `repos` | SSH known_hosts + clones `managed_repos` |
| `chezmoi` | Claude Code security dotfiles |

See [AGENT.md](AGENT.md) for agent context.
