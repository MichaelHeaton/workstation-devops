# GHEC SSH + gh — work profile

Automated by `roles/git_github` on `make apply` when the `work` tag is in the allowlist.

**Source:** Vault Engineer Onboarding wiki (internal) → GHEC Clone

## What Ansible deploys

| Piece | Location | Tag |
| ------- | ---------- | ----- |
| GHEC `Host github.com` block | `~/.ssh/config` via chezmoi (`feature_work`) | `dotfiles` + `work` |
| `ghec_ssh_key` in chezmoi data | `~/.config/chezmoi/chezmoi.yaml` | refreshed on `make apply` |
| `gh` preferences | `~/.config/gh/config.yml` via chezmoi | `dotfiles` |

This role (`work` tag) verifies the GHEC key exists and reminds you to run `TAGS=dotfiles,work` after key changes.

- `AddKeysToAgent yes`
- `UseKeychain yes`
- `IdentityFile ~/.ssh/<ghec_ssh_key>`

Default key basename: **`id_ed25519_github`** (`group_vars/work.yml`). Keys are **never** committed.

## One-time manual steps

1. Generate a dedicated GHEC key (if you do not already have one):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "you@work.example"
   ```

2. Upload `~/.ssh/id_ed25519_github.pub` to [GitHub SSH keys](https://github.com/settings/keys) (authorize for employer enterprise SSO).

3. Run playbook:

   ```bash
   make apply TAGS=dotfiles,work
   ```

   Or full `make apply` on a work machine.

4. Test:

   ```bash
   ssh -T git@github.com
   git ls-remote git@github.com:YOUR_ORG/cursor-rules.git HEAD
   ```

   HTTPS equivalent (the default transport — see "SSH vs HTTPS" below):

   ```bash
   git ls-remote https://github.com/YOUR_ORG/cursor-rules.git HEAD
   ```

   Set `YOUR_ORG/cursor-rules` in `managed_repos_local` inside `group_vars/work.local.yml`. Entries should use `https://` URLs per `group_vars/work.local.yml.example`.

## SSH vs HTTPS

**HTTPS + `gh auth git-credential` is the default transport** for GHEC repo clone/fetch/push. It works around corporate port-22 blocks that cause `kex_exchange_identification: read: Operation timed out` errors on networks where outbound SSH is filtered. `dotfiles/dot_gitconfig.tmpl` rewrites `git@github.com:` and `git@gitlab.com:` URLs to their HTTPS equivalents via `insteadOf`, so most repos work over HTTPS even if you type or copy an SSH-style URL.

The SSH key setup described above remains useful for:

- Verifying connectivity with `ssh -T git@github.com`
- Any host that genuinely requires literal SSH (e.g. legacy internal corp git, see "Internal corp Git" below)

## Multi-account layout

| Remote host alias | Use for |
| ------------------- | --------- |
| `github.com` | GHEC (work org repos) |
| `github.com-personal` | Personal GitHub (`git@github.com-personal:MichaelHeaton/...`) |

Personal-only machines (no `work` tag) use `github.com` → personal key in chezmoi; GHEC fragment is not deployed.

## Override key path

```bash
make apply EXTRA_VARS='-e ghec_ssh_key=ghec_do_not_rotate_personal'
```

Use the wiki naming if you already created that key — basename only, not full path.

## Internal corp Git

Legacy Vault repos on the employer **internal Git host** are separate from GHEC. Prefer **`gh repo clone`** when possible; corp SSH for internal Git is not automated here.
