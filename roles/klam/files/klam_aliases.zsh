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
