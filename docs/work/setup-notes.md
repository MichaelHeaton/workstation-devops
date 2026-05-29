# CES Vault workstation — manual setup

Automated steps run via `make apply` (profile `work`). Complete these **before** expecting KLAM, Vault, or Teleport helpers to work.

## IAM and accounts

1. **AWS IAM groups** — request membership per Vault Engineer Onboarding wiki (internal). KLAM profiles will not authenticate until groups are granted.
2. **HashiCorp support account** — contact your HashiCorp account rep if you need vendor support access.
3. **KLAM CLI profiles** — after IAM groups: KLAM CLI wiki (internal). Profile names like `cstdev` / `cstprd` are safe to reference in automation; credentials are runtime-only.

## Environment

- Set **`TELEPORT_LOGIN`** to your work LDAP username (short name, not full email).
- **Corp VPN** — connect for internal Git, Jenkins, and Vault URLs when using those tools.

## Local overrides (work machines)

Employer-specific URLs and repos live in **`group_vars/work.local.yml`** (gitignored). Copy from `group_vars/work.local.yml.example` and fill in before first apply.

## Chezmoi identity (first work apply)

If `~/.config/chezmoi/chezmoi.yaml` is not seeded:

```bash
make apply EXTRA_VARS='-e work_username=YOUR_LDAP full_name="Your Name" work_email=you@work.example'
```

## Global gitignore

Managed by chezmoi: `dotfiles/dot_gitignore_global` → `~/.gitignore_global` (macOS, Terraform, Ansible, Claude local settings).

## Editor extensions (Cursor + VS Code)

Extension IDs live in `dotfiles/editors/`:

| File | Scope |
| ------ | -------- |
| `extensions-common.txt` | Both editors |
| `extensions-cursor.txt` | Cursor only |
| `extensions-work.txt` | Work profile only (employer extension) |

After adding an extension in the UI: update the list, commit, `make apply`. The install script is idempotent.

Settings templates: `dotfiles/Library/Application Support/Cursor/User/settings.json.tmpl` and `Code/User/settings.json.tmpl`.
