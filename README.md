# workstation-devops

Ansible-based personal workstation setup for DevOps and development work.

Covers shell environment, core CLI tools, language runtimes, and personal project tooling. Public repo — no employer-specific configuration.

## Quick start

```bash
git clone git@gitlab.com:Michael-Heaton/workstation-devops.git ~/Projects/personal/workstation-devops
cd ~/Projects/personal/workstation-devops
```

**Prerequisites:** Ansible and Homebrew must be installed.

```bash
brew install ansible
```

### Dry run first (safe — no changes written)

```bash
make dry-run
# or: ansible-playbook playbook.yml -e dry_run=true
```

Then apply:

```bash
make apply
# or: ansible-playbook playbook.yml
```

## What's included

| Role | What it sets up |
|---|---|
| `homebrew` | `gh`, `glab` (formulae); GitHub Desktop, VS Code, Claude, 1Password (casks) |
| `chezmoi` | Deploys dotfiles — currently the Claude Code security merge script |
| `shell` | oh-my-zsh, robbyrussell theme, zshrc fragments |
| `development` | git, Go, AWS CLI, Azure CLI, Ansible |
| `minecraft-tools` | packwiz, Java (for modpack dev) |

Roles listed without a ✓ are planned but not yet implemented.

## Global gitignore

Set up a global gitignore to exclude OS and editor noise from every repo on the machine:

```bash
cat > ~/.gitignore_global << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Terraform
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl

# Ansible
*.retry
vault_pass.txt

# Python
__pycache__/
*.pyc
.venv/
EOF
git config --global core.excludesfile ~/.gitignore_global
```

## For AI agents

See [AGENT.md](AGENT.md) for full architecture, conventions, gotchas, and security notes.
