# KLAM AWS credential aliases — workstation-devops (work profile)
# Prerequisite: klam configure-profile for ces_* (see docs/work/klam.md)
# Wiki: KLAM CLI wiki (internal — see docs/work/klam.md)

# pip install --user puts klam on this path (macOS / Linux)
if command -v python3 &>/dev/null; then
  _klam_user_base="$(python3 -m site --user-base 2>/dev/null)"
  if [[ -n "$_klam_user_base" && -d "${_klam_user_base}/bin" ]]; then
    export PATH="${_klam_user_base}/bin:${PATH}"
  fi
  unset _klam_user_base
fi

# AWS CLI v2 pipes some output through less; disable so results go to stdout.
export AWS_PAGER=""

# Terminal cue when switching AWS context (on by default; disable: export CES_KLAM_TERM_BG=0)
# Full tab+background colors: iTerm2 best. Cursor/VS Code: title + OSC background may work; iTerm tab color will not.
[[ -z "${CES_KLAM_TERM_BG:-}" ]] && export CES_KLAM_TERM_BG=1

_ces_klam_term_style() {
  case "$1" in
    sandbox)
      print -n $'\033]0;CES team dev · sandbox (365215803550)\007'
      [[ "${CES_KLAM_TERM_BG}" == 1 ]] || return 0
      # Green — CES Vault team dev (CESSS Security Tooling sandbox)
      [[ "${TERM_PROGRAM:-}" == iTerm.app ]] && print -n $'\033]6;1;bg;green;brightness;200\007'
      print -n $'\033]11;#1a3328\033\\'
      print -n $'\033]10;#e8e8e8\033\\'
      ;;
    dev)
      print -n $'\033]0;Vault shared dev (891377009010)\007'
      [[ "${CES_KLAM_TERM_BG}" == 1 ]] || return 0
      # Gold/yellow — shared Vault dev (other teams; not CES team dev)
      [[ "${TERM_PROGRAM:-}" == iTerm.app ]] && print -n $'\033]6;1;bg;yellow;brightness;255\007'
      print -n $'\033]11;#5c5600\033\\'
      print -n $'\033]10;#f2f0e0\033\\'
      ;;
    prd)
      print -n $'\033]0;CES vault PRD (937224341222)\007'
      [[ "${CES_KLAM_TERM_BG}" == 1 ]] || return 0
      [[ "${TERM_PROGRAM:-}" == iTerm.app ]] && print -n $'\033]6;1;bg;red;brightness;220\007'
      print -n $'\033]11;#3d1f1f\033\\'
      print -n $'\033]10;#e8e8e8\033\\'
      ;;
    off|reset)
      print -n $'\033]0;\007'
      [[ "${CES_KLAM_TERM_BG}" == 1 ]] || return 0
      print -n $'\033]111\033\\\033]110\033\\'
      ;;
    *) return 1 ;;
  esac
}

ces_term_reset() {
  unset AWS_PROFILE
  _ces_klam_term_style reset
}

# Prompt indicator so an active AWS_PROFILE (right or wrong) is always visible,
# not just inferred from terminal bg color. Spliced into the git dirty/clean
# prompt segment (left side, before the "✗") rather than RPROMPT — RPROMPT
# gets overwritten as the typed command line grows and only reappears on the
# next fresh prompt, which defeats the point of an always-visible cue.
# Colored magenta/bold to stand out — safe against the KLAM terminal-bg
# palette (green/yellow/red, see _ces_klam_term_style above) since magenta
# doesn't overlap any of those hues, unlike the vault tier colors that used
# to clash with these same backgrounds.
#
# Rebuilt via a precmd hook rather than embedding a live $(...) call in
# ZSH_THEME_GIT_PROMPT_DIRTY/CLEAN: those vars are only ever *echoed* by the
# theme's own git_prompt_info/parse_git_dirty functions (real code running
# $(git_prompt_info) once from PROMPT, which in turn does plain "$VAR"
# interpolation, not further command substitution) — so a $(...) sequence
# baked into their stored value is never re-evaluated, it just prints
# literally. Recomputing the finished string every precmd sidesteps that.
#
# When Starship owns the prompt (STARSHIP_SHELL set by `starship init zsh`),
# skip this splice — Starship's aws module already shows AWS_PROFILE (see
# dotfiles/dot_config/starship.toml profile_aliases). Terminal bg/tab colors
# from _ces_klam_term_style still apply.
typeset -gA _CES_KLAM_PROMPT_LABEL=(
  ces_sandbox "sandbox (...3550)"
  ces_dev     "dev (...9010)"
  ces_prd     "PROD (...1222)"
)

# One-time migration: drop the old RPROMPT-based hook/output and the
# PROMPT-appended version if this file is being re-sourced in a shell that
# loaded an earlier version.
if (( $+functions[_ces_klam_update_prompt] )); then
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd _ces_klam_update_prompt 2>/dev/null
  unfunction _ces_klam_update_prompt
  RPROMPT=""
fi
if [[ "$PROMPT" == *_ces_klam_prompt_segment* ]]; then
  PROMPT="${PROMPT/'$(_ces_klam_prompt_segment)'/}"
fi

_ces_klam_prompt_segment() {
  [[ -n "${AWS_PROFILE:-}" ]] || return
  print -n "%F{magenta}%B[AWS: ${_CES_KLAM_PROMPT_LABEL[$AWS_PROFILE]:-$AWS_PROFILE}]%b%f "
}

if [[ -n "${STARSHIP_SHELL:-}" ]]; then
  if (( $+functions[_ces_klam_refresh_git_prompt_vars] )); then
    autoload -Uz add-zsh-hook
    add-zsh-hook -d precmd _ces_klam_refresh_git_prompt_vars 2>/dev/null
    unfunction _ces_klam_refresh_git_prompt_vars
  fi
elif (( $+parameters[ZSH_THEME_GIT_PROMPT_DIRTY] )) && [[ "$ZSH_THEME_GIT_PROMPT_DIRTY" == *'%1{✗'* ]]; then
  # Capture the pristine templates once (guard so re-sourcing this file
  # doesn't capture an already-modified value as if it were the original).
  if [[ -z "${_CES_KLAM_DIRTY_BEFORE:-}" ]]; then
    typeset -g _CES_KLAM_DIRTY_BEFORE="${ZSH_THEME_GIT_PROMPT_DIRTY%%'%1{✗'*}"
    typeset -g _CES_KLAM_DIRTY_AFTER="${ZSH_THEME_GIT_PROMPT_DIRTY:${#_CES_KLAM_DIRTY_BEFORE}}"
    typeset -g _CES_KLAM_CLEAN_BEFORE="$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  _ces_klam_refresh_git_prompt_vars() {
    local segment="$(_ces_klam_prompt_segment)"
    ZSH_THEME_GIT_PROMPT_DIRTY="${_CES_KLAM_DIRTY_BEFORE}${segment}${_CES_KLAM_DIRTY_AFTER}"
    ZSH_THEME_GIT_PROMPT_CLEAN="${_CES_KLAM_CLEAN_BEFORE}${segment}"
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _ces_klam_refresh_git_prompt_vars
  _ces_klam_refresh_git_prompt_vars
elif [[ "$PROMPT" != *_ces_klam_prompt_segment* ]]; then
  # Fallback for themes that don't expose ZSH_THEME_GIT_PROMPT_DIRTY/CLEAN
  # in this exact shape — a single-level $(...) directly in PROMPT is fine,
  # it's only the double-indirection above that command substitution can't
  # see through.
  PROMPT="${PROMPT}"'$(_ces_klam_prompt_segment)'
fi

# CES Vault KLAM profiles (legacy team docs used cstdev/cstprd — use ces_*)
# Drop legacy alias definitions if this file was re-sourced after an older deploy.
unalias ces_sandbox ces_dev ces_prd 2>/dev/null

ces_sandbox() {
  klam login && klam credentials --profile ces_sandbox --configure || return $?
  export AWS_PROFILE=ces_sandbox
  _ces_klam_term_style sandbox
}

ces_dev() {
  klam login && klam credentials --profile ces_dev --configure || return $?
  export AWS_PROFILE=ces_dev
  _ces_klam_term_style dev
}

ces_prd() {
  klam login && klam credentials --profile ces_prd --configure || return $?
  export AWS_PROFILE=ces_prd
  _ces_klam_term_style prd
}
