# Testing workstation-devops

## Quick local check

```bash
make test          # regression + dry-run (no writes to home dir except ~/.cache test artifact)
make lint          # yamllint, ansible-lint, syntax-check
make dry-run       # full personal/work preview (uses ~/.workstation_profile if set)
```

## What `make test` covers

| Check | Why |
| ----- | --- |
| `scripts/log-triage.sh` on fixture | Apply logs remain parseable after failures |
| `tests/playbooks/personal-chezmoi-identity.yml` | Personal profile must not hit undefined `full_name` / `work_email` in `site.yml` identity merge |
| `tests/playbooks/render-shell-templates.yml` | `shell_*.zsh.j2`, `vault_functions.zsh.j2`, and `klam_aliases.zsh` must pass `zsh -n`; generated aliases export `VAULT_CLUSTER`; `starship.toml` parses when starship is installed |
| `site.yml` with `dry_run=true` | End-to-end Jinja evaluation for personal profile |
| `make -n apply` | Apply target tees to `logs/apply-*.log` (survives terminal resets) |

## Apply logging

Every `make apply` writes a timestamped log under `logs/` (gitignored):

```text
logs/apply-YYYYMMDD-HHMMSS.log
```

After a failed or interrupted run (including app restart):

```bash
make triage
make triage LOG=logs/apply-20260530-152200.log
```

## CI

GitLab `.gitlab-ci.yml` runs `scripts/test-apply-safety.sh` after syntax-check and ansible-lint.

## Adding regressions

1. Reproduce the failure (fixture log, playbook task, or template).
2. Add to `scripts/test-apply-safety.sh` or a new file under `tests/playbooks/`.
3. Run `make test` before opening a PR.
