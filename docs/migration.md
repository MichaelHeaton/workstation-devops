# Migrating an existing Mac

The playbook only creates buckets and clones listed in **`vars/config.yml`**. It does not move or delete existing trees under `~/Projects`.

## Layout

Edit [vars/config.yml](../vars/config.yml):

- **`projects_buckets`** — top-level folders (e.g. `personal`, `workspace`, `adobe`)
- **`managed_repos`** — git clones (`dest` relative to `projects_root`)

## Steps

1. Edit `vars/config.yml` if needed.
2. `make dry-run` then `make apply`.
3. Consolidate legacy `~/Projects/workspaces` (GitHub) into `~/Projects/workspace` (GitLab) when ready — update relative paths in each `.code-workspace` file for the bucket layout.

## Naming

| Path | Remote |
|------|--------|
| `~/Projects/workspace/` | GitLab `workspace` (managed by playbook) |
| `~/Projects/workspaces/` | Legacy GitHub repo — do not merge blindly |
