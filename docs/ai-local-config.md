# AI local configuration (private answers)

**ai-skills**, **workstation-devops**, and **claude-skills** are **public** repositories. Do not store employer-specific metadata in any of them.

## Where answers live

| File | Created by | Committed? |
|------|------------|------------|
| `~/.config/ai-skills/local.json` | `make install-system` in ai-skills | **Never** |
| `~/.config/ai-skills/accounts.shell` | copy from template (optional) | **Never** |
| `~/.config/ai-skills/leak-patterns` | optional private pre-commit regexes | **Never** |
| `~/.claude/CLAUDE.local.md` | manual (optional) | **Never** |

Templates (safe to commit) live in **ai-skills**:

- `config/local.template.json`
- `config/accounts.shell.template`

## Workstation playbook role

`group_vars/all.yml` clones ai-skills and runs `make install-system`. That deploys **copies** to `~/.claude/` and creates `local.json` from the template if missing — not your filled-in answers.

After a playbook run:

1. Edit `~/.config/ai-skills/local.json` with Jira base URL, project key, channel names, repo paths, etc.
2. Copy `config/accounts.shell.template` → `~/.config/ai-skills/accounts.shell` if you use shell exports.
3. Re-run `direnv allow` in repos that use `.envrc`.

## Migration from `~/.config/claude-skills/`

Copy values into `~/.config/ai-skills/local.json` once, then use the new path only. See ai-skills `docs/guides/local-config.md`.

## Optional: backup private config

- Time Machine / workstation backup including `~/.config/ai-skills/`
- Encrypted chezmoi data source (advanced)
- Private git repo — **do not** add to public workstation-devops

Chezmoi in this repo ignores MCP secrets under `dot_mcp/secrets/` — treat `local.json` the same way: **never** add it under `dotfiles/`.

## See also

- [docs/secrets-keychain.md](secrets-keychain.md) — Keychain + Make setup for passwords/tokens
- ai-skills: `docs/guides/local-config.md`, `docs/multi-ai.md`
