# Migrating an existing Mac

The playbook only creates buckets and clones for the active profile in **`group_vars/`**. It does not move or delete existing trees under `~/Projects`.

## Layout

Edit profile vars in [group_vars/personal.yml](../group_vars/personal.yml) or [group_vars/work.yml](../group_vars/work.yml):

- **`projects_buckets`** — top-level folders (e.g. `personal`, `workspace`, `adobe`)
- **`managed_repos_common`** (`all.yml`) — workspace, workstation-devops, claude-skills, ai-skills, memex on every machine
- **`managed_repos`** (profile yml) — additional clones per profile (`dest` relative to `projects_root`)

Set profile once: `make profile` (writes `~/.workstation_profile`).

## Steps

1. Edit `group_vars/<profile>.yml` if needed.
2. `make dry-run` then `make apply`.
3. If you still have a duplicate tree at `~/Projects/workspaces/`, point `origin` at `git@github.com-personal:MichaelHeaton/workspaces.git` and use a single checkout at `~/Projects/workspace/` (playbook `dest`).
4. Remove `~/Projects/adobe/workstation-ces_vault` if present — superseded by this repo ([docs/work/README.md](work/README.md)).

## Naming

| Path | Remote |
|------|--------|
| `~/Projects/workspace/` | GitHub [MichaelHeaton/workspaces](https://github.com/MichaelHeaton/workspaces) (playbook `dest: workspace`) |
| `~/Projects/personal/workstation-devops/` | GitHub [MichaelHeaton/workstation-devops](https://github.com/MichaelHeaton/workstation-devops) |
