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

`~/.claude/settings.json` is **not** fully templated — merge scripts add deny/allow entries and hooks on `make apply`. Do not hand-edit policy expecting it to persist against the next apply.

**To change Claude policy:** edit the `run_onchange_merge-claude-*.sh.tmpl` scripts under `dotfiles/` → branch + PR → re-run the playbook.

**Ownership:** merge scripts manage permissions and hooks. `mcpServers` is merged by `run_onchange_sync-mcp-servers.sh.tmpl` from `~/.mcp/servers.json`. Hook **scripts** (`block-env-read.py`, etc.) live in **ai-skills** (`make install-system`); `run_onchange_merge-claude-hooks.sh.tmpl` registers them in settings.

## Why Claude does things this way

**Deny list:** credential stores (SSH, AWS, GCP, Bitwarden, 1Password, Vault token, package manager auth files), all `.env.*` variants, cert/key material, shell config writes, and `Edit(~/.claude/settings.json)` so Claude cannot rewrite its own policy.

**Hooks:** four Bash PreToolUse hooks guard against recursive delete, direct pushes to main/master, pipe-to-interpreter (`curl | bash`), and `find -exec`. All require `jq` and fail permissively if it's missing.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
