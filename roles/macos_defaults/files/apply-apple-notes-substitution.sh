#!/usr/bin/env bash
# Apply all Apple Notes substitution keys in one pass. Exits 0 if plist updated or already correct.
set -euo pipefail

plist="${1:?plist path required}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

changed=0
while IFS= read -r line; do
  [[ -z "${line}" || "${line}" =~ ^# ]] && continue
  key="${line%%=*}"
  value="${line#*=}"
  result=$("${script_dir}/set-plist-bool.sh" "${plist}" "${key}" "${value}")
  echo "${result}"
  if [[ "${result}" == "changed" ]]; then
    changed=1
  fi
done <<'EOF'
NSAutomaticQuoteSubstitutionEnabled=false
NSAutomaticDashSubstitutionEnabled=false
EOF

if [[ "${changed}" -eq 1 ]]; then
  echo "summary=changed"
else
  echo "summary=unchanged"
fi
