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
# not just inferred from terminal bg color. Appended to PROMPT (left side, after
# the theme's own git-branch segment) rather than RPROMPT — RPROMPT gets
# overwritten as the typed command line grows and only reappears on the next
# fresh prompt, which defeats the point of an always-visible warning cue.
# Plain/bold — relies on the default foreground _ces_klam_term_style already
# sets per-profile for contrast, rather than picking its own color (which is
# how the vault tier colors ended up clashing with these same backgrounds).
typeset -gA _CES_KLAM_PROMPT_LABEL=(
  ces_sandbox "sandbox (...3550)"
  ces_dev     "dev (...9010)"
  ces_prd     "PROD (...1222)"
)

# One-time migration: drop the old RPROMPT-based hook and its output if this
# file is being re-sourced in a shell that loaded a previous version.
if (( $+functions[_ces_klam_update_prompt] )); then
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd _ces_klam_update_prompt 2>/dev/null
  unfunction _ces_klam_update_prompt
  RPROMPT=""
fi

_ces_klam_prompt_segment() {
  [[ -n "${AWS_PROFILE:-}" ]] || return 0
  print -n "%B [AWS: ${_CES_KLAM_PROMPT_LABEL[$AWS_PROFILE]:-$AWS_PROFILE}]%b"
}

# Idempotent: appends once even if this file is re-sourced (new shell, make apply).
[[ "$PROMPT" == *_ces_klam_prompt_segment* ]] || PROMPT="${PROMPT}"'$(_ces_klam_prompt_segment)'

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
