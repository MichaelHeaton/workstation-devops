# Agent procedure: sync ansible repo layout → Notion

Run after editing `managed_repos` / `managed_repos_common` in workstation-devops.

## 1. Export manifest

```bash
make repos-export REPOS_PROFILE=personal
# JSON only (optional):
./scripts/export-managed-repos.py --profile personal --json
```

Each repo entry: `name`, `slug` (`MichaelHeaton/repo`), `dest`, `clone_scope` (`common` | `personal`).

## 2. Notion data source

- **Collection:** `collection://6f44da4e-bb6b-433a-a9a7-c1a6f9d93579`
- **Properties to set:** `Projects dest` (text), `Clone scope` (select)

## 3. Match rows

For each manifest entry, find the Repositories page where:

- `Name` equals repo `name`, **or**
- `userDefined:URL` contains `github.com/.../name`

Skip Adobe/org repos not in the manifest (leave dest empty or `Clone scope` = `none`).

## 4. Update pages

`notion-update-page` with `command: update_properties`:

```json
{
  "Projects dest": "personal/platform-bootstrap",
  "Clone scope": "personal"
}
```

## 5. platform-bootstrap only repos

Repos in Notion from Terraform but **not** in the ansible manifest should get `Clone scope` = `none` and empty `Projects dest` (unless you add them to `group_vars` later).

## 6. Verify

Spot-check: `workstation-devops` → `personal/workstation-devops`, `memex` → `personal/memex`, `platform-bootstrap` → `personal/platform-bootstrap`.
