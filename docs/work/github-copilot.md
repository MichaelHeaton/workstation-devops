# GitHub Copilot CLI — work profile

Adobe standardized on GitHub Copilot as the primary coding agent (Claude Code retires 2026-09-27 5pm PT). Automated by `roles/homebrew` on `make apply` when the `work` tag is in the allowlist.

**Source:** [Claude Code to GitHub Copilot CLI Migration Notes](https://wiki.corp.adobe.com/pages/viewpage.action?pageId=4049450115) (internal Adobe wiki).

## What Ansible deploys

| Piece | Location |
| ------- | ---------- |
| `copilot-cli` Homebrew cask | `group_vars/work.yml` → `homebrew_casks_profile` |

Work profile sets `homebrew_install_packages: false` (employer IT installs apps outside Homebrew) — `make apply` **detects** `copilot-cli` and reports it missing rather than installing it, unless you override:

```bash
make apply EXTRA_VARS='-e homebrew_install_packages=true' TAGS=work
```

Or install directly:

```bash
brew install --cask copilot-cli
```

## One-time manual steps (cannot be automated)

1. **Request a license** — Copilot standard tier via the [Adobe ServiceNow catalog item](https://adobe.service-now.com/esc?id=sc_cat_item&sys_id=8d1d8189473a4710d5219c7b116d43c1). Provisioning is not instant; do this first.
2. **Authenticate** — from a trusted project folder:

   ```bash
   copilot
   /login
   ```

   Select `github.com`.
3. **Migrate skills** — Copilot has no auto-invoked skills system. The wiki's stopgap is a manual add + symlink:

   ```bash
   copilot
   /add-dir ~/.claude/skills
   ```

   then symlink `~/.claude/skills` → `~/.copilot/skills` so Copilot can read them (skills become manually invoked, not auto-triggered).
4. **Migrate MCP servers** — ask Copilot directly (`copilot mcp add`); reported to work cleanly for the servers already in `~/.mcp/servers.json`.

## Useful links

- [GitHub Copilot at Adobe](https://github-copilot.adobe.io/)
- [Moving from Claude Code to GitHub Copilot CLI](https://github-copilot.adobe.io/guides/getting-started/claude-code-to-copilot-cli)
- [Claude Code to Copilot CLI comparison migration brief](https://wiki.corp.adobe.com/spaces/Home/pages/4024014112/Claude+Code+to+Copilot+CLI+comparison+migration+brief) — capability gaps (hooks, skills, sub-agent orchestration have no equivalent)
- [GitHub Copilot CLI docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-best-practices)
