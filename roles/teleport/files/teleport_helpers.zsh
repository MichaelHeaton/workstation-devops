# Teleport fzf helpers — workstation-devops (work profile)
# Requires: tsh, fzf on PATH; TELEPORT_LOGIN (shell-work block in ~/.zshrc)
# Wiki: Vault Engineer Onboarding → Teleport Easy Mode w/Fuzzy Finder (fzf)

t() {
  local host
  host=$(tsh ls | tail -n +2 | fzf | awk '{print $1}')
  [[ -n "$host" ]] && tsh ssh "$host"
}

alias tshl='tsh ssh $(tsh ls | cut -d" " -f1 | fzf)'
