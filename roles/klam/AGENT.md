# AGENT.md — klam

> Installs the KLAM CLI from employer Artifactory and deploys `ces_*` AWS credential aliases.
> Repo context: see [root AGENT.md](../../AGENT.md). Human docs: [docs/work/klam.md](../../docs/work/klam.md).

## Purpose

Work-tag only. Pip-installs `klam` when it is missing **and** an Artifactory API key is passed at apply time. Always deploys `klam_aliases.zsh` (`ces_sandbox` / `ces_dev` / `ces_prd`, terminal bg/tab colors, optional oh-my-zsh AWS prompt splice). IAM group membership is a runtime prerequisite — install can succeed while `klam login` still fails.

## Inputs / Interface

| Variable | Required | Default | Notes |
| -------- | -------- | ------- | ----- |
| `klam_enabled` | no | `true` | Role-level off switch |
| `klam_artifactory_host` | yes for install | `""` | Set in gitignored `group_vars/work.local.yml` |
| `klam_artifactory_api_key` | yes for first install | env `KLAM_ARTIFACTORY_API_KEY` | Never commit. Aliases still deploy without it |
| `klam_artifactory_username` | for pip index | `work_username` | Override with `WORK_USERNAME` if macOS login ≠ LDAP |
| `klam_pip_break_system_packages` | no | `true` | Homebrew Python PEP 668 |

## Key files

| File | What it does |
| ---- | ------------ |
| `tasks/main.yml` | Detect-then-pip; copy aliases; `blockinfile` source line in `~/.zshrc` |
| `files/klam_aliases.zsh` | `ces_*` functions, OSC term colors, Starship-aware prompt splice |

## Gotchas

- **`ZSH_THEME_GIT_PROMPT_DIRTY` cannot embed `$(...)`.** oh-my-zsh echoes that string; it does not re-evaluate it. The AWS badge is rebuilt in a `precmd` hook. Do not "simplify" back to a live command substitution inside those theme vars.
- **Skip the oh-my-zsh splice when `STARSHIP_SHELL` is set.** Starship's aws module already shows `AWS_PROFILE` (`dotfiles/dot_config/starship.toml` `profile_aliases`). Terminal bg/tab colors from `_ces_klam_term_style` still apply.
- **Prompt magenta, not green/yellow/red.** Those hues are the KLAM terminal-background palette and clash when a `ces_*` session is active.
- **Artifactory user is LDAP, not the macOS account.** The role warns when they match; pass `WORK_USERNAME` / `work_username`.
