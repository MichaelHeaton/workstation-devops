# Work profile role

Runs when `workstation_profile == 'work'` (see `site.yml`).

Work-tagged capabilities (shell work fragment, KLAM, Vault tools) are imported from **`roles/common/`** when `work` is in the tag allowlist — see [docs/tags.md](../tags.md).

This role is a profile marker; add work-only Ansible tasks here with `tags: [work]`.

## Adding work-only automation

1. Create or extend a role under `roles/`.
2. Import from `roles/common/tasks/main.yml` with `when: "'work' in workstation_tags"` and `tags: [work]`, **or** add tasks here with the same tag/when guards.
3. `make dry-run` with `-e workstation_profile=work`.
