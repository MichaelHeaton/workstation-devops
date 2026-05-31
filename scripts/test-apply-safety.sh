#!/usr/bin/env bash
# Safety checks before/after make apply changes — run in CI and locally: make test
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> log-triage fixture"
TRIAGE_OUT="$(./scripts/log-triage.sh tests/fixtures/apply-with-failure.log)"
echo "$TRIAGE_OUT" | grep -q "ERRORS / FAILURES"

echo "==> personal chezmoi identity regression"
ansible-playbook tests/playbooks/personal-chezmoi-identity.yml

echo "==> shell template render + zsh -n"
if ! command -v zsh >/dev/null 2>&1; then
  echo "skip: zsh not installed" >&2
else
  ansible-playbook tests/playbooks/render-shell-templates.yml
fi

echo "==> site.yml personal dry-run (full playbook, no writes)"
ansible-playbook site.yml \
  -e dry_run=true \
  -e workstation_profile=personal \
  -e skip_profile_prompt=true

echo "==> Makefile recipes"
make -n dry-run >/dev/null
make -n apply 2>&1 | grep -q 'logs/apply-'
make -n triage >/dev/null

echo "All apply-safety checks passed."
