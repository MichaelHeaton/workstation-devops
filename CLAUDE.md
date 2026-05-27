# CLAUDE.md — workstation-devops

> Claude Code configuration for workstation-devops.
> For full project context, read [AGENT.md](AGENT.md) first.

## Branch and PR rules

**Never push directly to `main`.** All changes go through a branch and pull request — no exceptions, even for single-file documentation changes.

- Create a feature branch: `git checkout -b <type>/<short-description>`
- Commit, push the branch, open a PR with `gh pr create`
- Remote: `git@github.com-personal:MichaelHeaton/workstation-devops.git` on multi-account Macs
- Do not merge without review

This repo is on GitHub. Homelab repos in `group_vars/personal.yml` may still use GitLab.

## Claude Code settings

`~/.claude/settings.json` is managed as a chezmoi dotfile template. Do not edit it directly — changes are overwritten on the next playbook run.

**To change Claude settings:** edit `dotfiles/dot_claude/settings.json.tmpl` → branch + MR → re-run the playbook.

**Ownership:** the template manages permissions, hooks, model, and theme. `mcpServers` is managed separately by `run_onchange_sync-mcp-servers.sh.tmpl` (sourced from `~/.mcp/servers.json`) — do not add it to the template.

## Why Claude does things this way

**Deny list:** credential stores (SSH, AWS, GCP, Bitwarden, 1Password, Vault token, package manager auth files), all `.env.*` variants, cert/key material, shell config writes, and `Edit(~/.claude/settings.json)` so Claude cannot rewrite its own policy.

**Hooks:** four Bash PreToolUse hooks guard against recursive delete, direct pushes to main/master, pipe-to-interpreter (`curl | bash`), and `find -exec`. All require `jq` and fail permissively if it's missing.
