# AGENT.md — atlassian_cli

> Clones and builds `jira` and `confluence` (jira-cli / confluence-cli) from source.
> Repo context: see [root AGENT.md](../../AGENT.md). Human docs: [docs/work/atlassian-cli.md](../../docs/work/atlassian-cli.md).

## Purpose

Work-tag only. These Go CLIs replace the Atlassian MCP server's `jira_*`/`confluence_*`
tools for Claude Code with lower per-turn token cost (help text loaded on demand
instead of MCP tool schemas on every turn). Forked by Blake Garner from the
`Adobe-AIFoundations` org; this role tracks the fork (`blake_adobe/jira-cli`,
`blake_adobe/confluence-cli`), not upstream.

Unlike `vault_tools` (which pulls a pre-built release tarball via `gh release
download`), this role clones the actual source into a visible working tree under
`~/Projects/adobe/` and runs `go build` — so local edits or PRs back to the fork
use the same checkout Ansible manages, and there's no dependency on either repo
publishing release binaries.

## Inputs / Interface

| Variable | Required | Default | Notes |
| -------- | -------- | ------- | ----- |
| `atlassian_cli_enabled` | no | `true` | Role-level off switch |
| `atlassian_cli_tools` | yes | see `defaults/main.yml` | List of `{name, repo, dest, version}` — pin bumped via PR |
| `atlassian_cli_install_dir` | no | `~/.local/bin` | Must be on `$PATH` (already true via `vault_tools`/`vl`) |

## Key files

| File | What it does |
| ---- | ------------ |
| `tasks/main.yml` | Clone-or-pull each repo (ff-only, skips dirty trees), `go build` into `atlassian_cli_install_dir`, verify `--help` runs |

## What this role does NOT do

- **No credential setup.** Jira PAT (Keychain) and Confluence PAT (credential
  helper) are one-time manual steps — see docs/work/atlassian-cli.md. Matches
  the `vault_tools` precedent: install/build is automated, auth is not.
- **No Claude skill deployment.** The two skill files that ship with the
  upstream setup guide (`jira-skill.md`, `confluence-skill.md`) are not wired
  into `ai-skills` by this change — that's a separate decision.

## Gotchas

- **Private repos** — clone requires git/gh auth already configured for
  `github.com` (the same credential helper used for any other GitHub HTTPS
  clone on this machine). Clone/pull failures warn and continue rather than
  failing `make apply` — these are optional dev tools, not core workstation setup.
- **`go` on `$PATH`** — `homebrew_formulae_common` lists `go`, but work profile
  is detect-only (`homebrew_install_packages: false`); if `go` isn't already
  present on a given work machine, the build step fails loudly with the
  `go build` stderr in the task output.
- **Dirty working tree blocks pull, not build** — if you're mid-edit in either
  fork, `make apply` skips the `git pull` (warns) but still rebuilds from
  whatever's currently checked out.
