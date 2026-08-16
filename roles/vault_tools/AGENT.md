# AGENT.md — vault_tools

> Installs `vl` (OIDC Vault login) and generates per-cluster `vault_*` shell aliases from `vault_clusters`.
> Repo context: see [root AGENT.md](../../AGENT.md). Human docs: [docs/work/vault-tools.md](../../docs/work/vault-tools.md).

## Purpose

Work-tag only. Pins `vl` from the private `adobe-security-tooling/vaultlogin` GitHub release (via `gh`), writes `~/.config/workstation-devops/vault_functions.zsh`, and sources it from `~/.zshrc`. Auth is OIDC through `vl`, not a hand-rolled Okta function. Cluster URLs live in gitignored `group_vars/work.local.yml`.

## Inputs / Interface

| Variable | Required | Default | Notes |
| -------- | -------- | ------- | ----- |
| `vault_tools_enabled` | no | `true` | Role-level off switch |
| `vaultlogin_version` | yes | `1.1.0` | Pin; bump via PR |
| `vaultlogin_github_repo` | yes | `adobe-security-tooling/vaultlogin` | Private — `gh` must be the work account |
| `vault_clusters` | yes on work | `[]` in `work.yml` | Fill in `work.local.yml`. Empty list → no `vault_*` aliases |
| `cluster.label` / `url` | per entry | — | Alias is `vault_<label lowercased, - → _>` unless the label already starts with `vault` |
| `cluster.tier` | no | `dev` | `mytools` color (cyan/blue) and default KLAM account |
| `cluster.aws_profile` | no | `ces_dev` or `ces_prd` from tier | Override when the backing account ≠ tier (e.g. VII-DEV → `ces_sandbox`) |
| `cluster.indent` | no | false | `mytools` treats the row as a regional mirror |

Each generated alias exports `VAULT_ADDR`, `VAULT_NAMESPACE` (default `root`), and `VAULT_CLUSTER=<label>` (Starship prompt), then `unset VAULT_TOKEN` and runs `vl`. `vault_mgmt` sets `VAULT_CLUSTER=mgmt`.

## Key files

| File | What it does |
| ---- | ------------ |
| `tasks/main.yml` | Install/pin `vl`; render functions; `blockinfile` source line |
| `templates/vault_functions.zsh.j2` | Aliases + `VAULT_TOOLS_CLUSTER_*` arrays for `mytools` |
| `templates/vault_tools_zshrc.sh.j2` | One-line source of the generated file |

## Gotchas

- **Jinja whitespace-control on the alias `{% for %}` can comment out the whole block.** A prior bug swallowed every `vault_*` alias. Check the rendered `~/.config/workstation-devops/vault_functions.zsh` before blaming `vault_clusters`.
- **Do not put employer URLs in the public repo.** `work.local.yml.example` has fake hostnames only.
- **`mytools` colors are cyan/blue, not green/red** — those clash with the KLAM terminal-bg palette in `klam_aliases.zsh`.
