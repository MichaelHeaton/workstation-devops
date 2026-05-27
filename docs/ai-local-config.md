# AI local configuration (private answers)

Both **claude-skills** and **workstation-devops** are **public** repositories. Do not store employer-specific metadata in either repo.

## Where answers live

| File | Created by | Committed? |
|------|------------|------------|
| `~/.config/claude-skills/local.json` | `make install` in claude-skills | **Never** |
| `~/.config/claude-skills/accounts.shell` | `make install` (shell/direnv) | **Never** |
| `~/.config/claude-skills/leak-patterns` | optional private pre-commit regexes | **Never** |
| `~/.claude/CLAUDE.local.md` | claude-skills install (optional) | **Never** |

Templates (safe to commit) live in claude-skills:

- `config/local.template.json`
- `config/accounts.shell.template`

## Workstation playbook role

`group_vars/all.yml` clones claude-skills and runs `make install`. That only deploys **templates** and symlinks — not your filled-in answers.

After a playbook run:

1. Edit `~/.config/claude-skills/local.yaml` with Jira base URL, project key, SharePoint deck URL, channel names, repo paths, etc.
2. Edit `~/.config/claude-skills/local.env` for shell scripts (`setup-account.sh`, `SKILLS_WORK_ORGS`).
3. Re-run `direnv allow` in repos that use `.envrc`.

## Optional: backup private config

- Time Machine / workstation backup including `~/.config/claude-skills/`
- Encrypted chezmoi data source (advanced)
- Private git repo (e.g. GitLab private) — **do not** add to public workstation-devops

Chezmoi in this repo ignores MCP secrets under `dot_mcp/secrets/` — treat `local.yaml` the same way: **never** add it under `dotfiles/`.

## See also

- claude-skills: `references/local-config.md`, `docs/multi-ai.md`
