# roles/work — CES Vault (Adobe work profile)

Runs when `workstation_profile == 'work'` (see `site.yml`).

**Docs:** [docs/work/README.md](../../docs/work/README.md) · **Roadmap:** [docs/work/ces-vault-roadmap.md](../../docs/work/ces-vault-roadmap.md)

## Current behavior

`tasks/main.yml` only sets a fact marker today. Dotfiles (MCP, Claude security, Brave) are applied by `roles/common` → `chezmoi`.

## Adding a role

1. Create `roles/work/<name>/tasks/main.yml` (+ `files/` for shell fragments).
2. Add `import_role` entries to `tasks/main.yml` (see roadmap doc).
3. Run `make dry-run` with `-e workstation_profile=work`.

Planned role names: `shell`, `vault-tools`, `teleport`, `klam`, `kubernetes`, `git-github`.
