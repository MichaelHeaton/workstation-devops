# workstation-devops

Ansible-based personal workstation setup for DevOps and development work.

Covers shell environment, core CLI tools, language runtimes, and personal project tooling. Public repo — no employer-specific configuration.

## Quick start

```bash
git clone git@gitlab.com:Michael-Heaton/workstation-devops.git ~/Projects/personal/workstation-devops
cd ~/Projects/personal/workstation-devops
./bootstrap.sh
```

`bootstrap.sh` installs Homebrew and Ansible, then runs the playbook. Safe to re-run on a live machine.

## What's included

| Role | What it sets up |
|---|---|
| `homebrew` | Brewfile packages |
| `shell` | oh-my-zsh, robbyrussell theme, zshrc fragments |
| `development` | git, gh CLI, Go, AWS CLI, Azure CLI, Ansible |
| `vscode` | VS Code + extension list |
| `minecraft-tools` | packwiz, Java (for modpack dev) |

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
