# Repository registry (Notion + ansible)

## Ownership

| Field | Writer | Source |
| ------ | ------ | ------ |
| Name, URL, Description, Visibility, Status | **platform-bootstrap** (Terraform apply → Notion sync) | `terraform/managed.auto.tfvars` |
| Ticket System, Linear Project, Domain, Notes | **Human / agents** | Notion Repositories DB |
| **Projects dest**, **Clone scope** | **workstation-devops** (one-way export) | `group_vars/all.yml` + `group_vars/<profile>.yml` |

Notion **Repositories** (`collection://6f44da4e-bb6b-433a-a9a7-c1a6f9d93579`) is the cross-tool catalog. Ansible remains authoritative for clone layout on each Mac profile.

## Paths

- **Projects dest** — Relative path under `~/Projects` (ansible `dest`), e.g. `personal/memex`, `specterrealm/homelab/homelab-core`.
- **Clone scope** — `common` (every profile, `managed_repos_common`), `personal` / `work` (profile `managed_repos`), or `none` (exists in GitHub but not cloned by this playbook).

## Refresh dest + clone scope in Notion

After changing `managed_repos` or `managed_repos_common`:

```bash
cd ~/Projects/personal/workstation-devops
make repos-export          # uses ~/.workstation_profile or personal
make repos-sync-notion     # export + reminder to run Notion MCP sync
```

Then either:

1. **Cursor / Claude with Notion MCP** — After `make repos-sync-notion`, follow `scripts/sync-notion-repo-layout.md` (or ask to “sync repo dests to Notion”).
2. **Manual** — Paste `Projects dest` and `Clone scope` from the export into each Repositories row.

Work-profile clones in private `group_vars/work.local.yml` are **not** exported by default (not in git).

## Related

- [migration.md](migration.md) — `projects_buckets` and `managed_repos` layout
- Memex `Agents/24-task-routing-stack.md` — ticket routing from the same Notion DB
- ai-skills `docs/guides/repo-routing-cache.md` — optional `~/.config/ai-skills/repo-routing.json` cache
