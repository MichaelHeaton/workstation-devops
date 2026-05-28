#!/usr/bin/env bash
# Set a boolean key in a plist (Add or Set). Prints "changed" or "unchanged" on stdout.
# Usage: set-plist-bool.sh <plist-path> <key> <true|false>
set -euo pipefail

plist="${1:?plist path required}"
key="${2:?key required}"
value="${3:?value required}"

if [[ "${value}" != "true" && "${value}" != "false" ]]; then
  echo "error: value must be true or false" >&2
  exit 1
fi

if [[ ! -f "${plist}" ]]; then
  echo "error: plist not found: ${plist}" >&2
  exit 2
fi

buddy=/usr/libexec/PlistBuddy

if "${buddy}" -c "Print :${key}" "${plist}" &>/dev/null; then
  current=$("${buddy}" -c "Print :${key}" "${plist}" 2>/dev/null) || {
    echo "error: PlistBuddy could not read :${key}" >&2
    exit 1
  }
  if [[ "${current}" == "${value}" ]]; then
    echo "unchanged"
    exit 0
  fi
  if ! "${buddy}" -c "Set :${key} ${value}" "${plist}" 2>/dev/null; then
    echo "error: PlistBuddy Set :${key} failed (grant Full Disk Access to your terminal?)" >&2
    exit 1
  fi
else
  if ! "${buddy}" -c "Add :${key} bool ${value}" "${plist}" 2>/dev/null; then
    echo "error: PlistBuddy Add :${key} failed (grant Full Disk Access to your terminal?)" >&2
    exit 1
  fi
fi

# Confirm write succeeded (PlistBuddy can print errors yet exit 0 on sandboxed paths).
verify=$("${buddy}" -c "Print :${key}" "${plist}" 2>/dev/null) || {
  echo "error: could not verify :${key} after write" >&2
  exit 1
}
if [[ "${verify}" != "${value}" ]]; then
  echo "error: :${key} is ${verify}, expected ${value}" >&2
  exit 1
fi

echo "changed"
