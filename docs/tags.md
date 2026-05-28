# Feature tags

Workstation capabilities use **tags** and an **allowlist** — not the work/personal profile alone.

## Two layers

| Layer | Controls | Example |
|-------|----------|---------|
| **Profile** (`work` / `personal`) | Repos, Homebrew lists, project buckets | `group_vars/work.yml` |
| **Feature tags** | Dotfiles, shell, editors, Vault/KLAM | `workstation_tags_*` in group_vars |

Profile sets sensible **defaults** for tags. You can add or remove tags on any machine without changing profile.

## Default allowlists

Merged in `site.yml`:

```yaml
workstation_tags = baseline + profile + extra   # unique
```

| Source | Tags |
|--------|------|
| `group_vars/all.yml` → `workstation_tags_baseline` | `dotfiles`, `shell`, `editors` |
| `group_vars/work.yml` → `workstation_tags_profile` | `work` |
| `group_vars/personal.yml` → `workstation_tags_profile` | `home` |
| CLI → `workstation_tags_extra` | any (additive) |

### Work machine (default)

`dotfiles`, `shell`, `editors`, `work`

### Personal machine (default)

`dotfiles`, `shell`, `editors`, `home`

## Override examples

**Personal Mac, but want Vault/KLAM/Teleport shell:**

```bash
make apply EXTRA_VARS='-e workstation_tags_extra=[work]'
```

**Work Mac, skip Adobe tooling this run:**

```bash
make apply SKIP_TAGS=work
```

**Only refresh dotfiles:**

```bash
make apply TAGS=dotfiles
```

**Only shell fragments:**

```bash
make apply TAGS=shell
```

## Tag → capability map

| Tag | What runs |
|-----|-----------|
| `dotfiles` | Chezmoi (git, SSH, gh config, zprofile, MCP, Claude merges, Brave, …) |
| `shell` | Common zshrc block (PATH, ai-skills `accounts.shell`) |
| `editors` | Cursor/VS Code settings + extension install script |
| `work` | Work shell, Teleport fzf, kubelogin v0.1.9, GHEC SSH, KLAM, Vault tools, Adobe editor extensions |
| `home` | Personal profile marker (extend with home-only tasks in `roles/personal/`) |

Chezmoi templates read boolean flags from `~/.config/chezmoi/chezmoi.yaml` (`feature_work`, `feature_editors`, …), refreshed on every `make apply`.

## Roles layout

- **`roles/common/`** — imports tagged capabilities (shell, chezmoi, vault, klam, teleport, kubernetes, git_github)
- **`roles/work/`** / **`roles/personal/`** — profile markers; add profile-specific tasks here with `work` / `home` tags

Do not gate shared dotfiles behind the work role — use tags instead.
