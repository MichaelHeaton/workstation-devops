# Shell prompt (Starship)

The prompt bar that shows **git branch**, **AWS profile**, **gcloud account**, and **Vault cluster** is [Starship](https://starship.rs/). workstation-devops manages the config and initializes it from the common zshrc fragment.

## What you see

| Segment | Source | When it appears |
| ------- | ------ | --------------- |
| Directory + git | Starship defaults | Inside a git repo |
| AWS (`☁️ profile (region)`) | `AWS_PROFILE` / `AWS_REGION` | Profile is set. Work KLAM names are aliased (`ces_sandbox` → `sandbox (...3550)`). |
| gcloud (`☁️ account`) | active gcloud config | `gcloud` is authenticated |
| Vault (`🔒 CLUSTER`) | `VAULT_CLUSTER` | After a `vault_*` alias (work) or when `VAULT_ADDR` is already set (personal homelab default `specterrealm`) |

Starship 1.26 has no built-in HashiCorp Vault module. The Vault segment is an `env_var` module reading `VAULT_CLUSTER`, not the full `VAULT_ADDR` URL.

Config: `dotfiles/dot_config/starship.toml` → `~/.config/starship.toml` (chezmoi, `dotfiles` tag).
Init: `roles/shell/templates/shell_common.zsh.j2` — `eval "$(starship init zsh)"` only when `starship` is on PATH and `STARSHIP_SHELL` is not already set (so an unmanaged init earlier in `~/.zshrc` is not doubled).

## Install

| Profile | How starship gets there |
| ------- | ----------------------- |
| **personal** | Homebrew formula `starship` in `group_vars/all.yml` — `make apply` installs it |
| **work** | Detect-first. Employer IT sets `homebrew_install_packages: false`, so apply will **not** brew install. Put `starship` on PATH yourself (`brew install starship` if your Homebrew is allowed to install, or [the binary install](https://starship.rs/guide/#installation)), then `make apply TAGS=shell` |

If starship is missing, the rest of the shell still works. Work falls back to oh-my-zsh; the KLAM `[AWS: …]` git-prompt splice stays active. When Starship *does* own the prompt, that splice is skipped so AWS is not shown twice — KLAM terminal background/tab colors still apply.

## Git branch icon looks like a box

Starship's default git symbol needs a [Nerd Font](https://www.nerdfonts.com/). Install one (e.g. `brew install --cask font-meslo-lg-nerd-font`) and set it as the terminal font in iTerm2 / Cursor. The cloud and lock segments use emoji and do not need a Nerd Font.

## Duplicate `eval "$(starship init zsh)"`

Personal `~/.zshrc` may still have an unmanaged init line from before this was managed. The guarded init in the Ansible block skips when `STARSHIP_SHELL` is already set. You can delete the unmanaged line; it is not required.

## Related

- Vault aliases set `VAULT_CLUSTER` — [vault-tools.md](work/vault-tools.md)
- KLAM AWS + terminal colors — [klam.md](work/klam.md)
- Personal AWS defaults — [platform-aws.md](home/platform-aws.md)
