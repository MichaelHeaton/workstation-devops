# Migrating an existing Mac

The playbook only creates buckets and clones for the active profile in **`group_vars/`**. It does not move or delete existing trees under `~/Projects`.

## Layout

Edit profile vars in [group_vars/personal.yml](../group_vars/personal.yml) or [group_vars/work.yml](../group_vars/work.yml):

- **`projects_buckets`** — top-level folders (e.g. `personal`, `workspace`, `adobe`)
- **`managed_repos_common`** (`all.yml`) — workspace, workstation-devops, claude-skills, memex on every machine
- **`managed_repos`** (profile yml) — additional clones per profile (`dest` relative to `projects_root`)

Set profile once: `make profile` (writes `~/.workstation_profile`).

## Steps

1. Edit `group_vars/<profile>.yml` if needed.
2. `make dry-run` then `make apply`.
3. Consolidate legacy `~/Projects/workspaces` (GitHub) into `~/Projects/workspace` (GitLab) when ready — update relative paths in each `.code-workspace` file for the bucket layout.

## Naming

| Path | Remote |
|------|--------|
| `~/Projects/workspace/` | GitLab `workspace` (managed by playbook) |
| `~/Projects/workspaces/` | Legacy GitHub repo — do not merge blindly |
