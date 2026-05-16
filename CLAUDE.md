# CLAUDE.md — workstation-devops

> Claude Code configuration for workstation-devops.
> For full project context, read [AGENT.md](AGENT.md) first.

## Branch and MR rules

**Never push directly to `main`.** All changes go through a branch and merge request — no exceptions, even for single-file documentation changes.

- Create a feature branch: `git checkout -b <type>/<short-description>`
- Commit, push the branch, open an MR with `glab mr create`
- Do not merge without review

This is a GitLab repo. The branch + MR rule applies regardless of how small the change feels.

## Claude Code settings

<!-- No hooks or tool overrides configured yet. Add here as the repo grows. -->

## Why Claude does things this way

<!-- Document reasoning behind any Claude-specific config added in future. -->
