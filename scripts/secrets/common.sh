#!/usr/bin/env bash
# Shared helpers for workstation-devops secrets scripts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REGISTRY="${REPO_ROOT}/config/secrets-registry.yml"
WORK_LOCAL="${REPO_ROOT}/group_vars/work.local.yml"

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: ${cmd} is required." >&2
    exit 1
  }
}

yq_read() {
  local file="$1"
  local expr="$2"
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  yq "$expr" "$file" 2>/dev/null
}

work_local_value() {
  local key="$1"
  yq_read "$WORK_LOCAL" ".${key} // \"\"" || true
}

registry_keychain() {
  local item="$1"
  local field="$2"
  yq_read "$REGISTRY" ".keychain_items.${item}.${field}"
}

keychain_item_exists() {
  local service="$1"
  local account="$2"
  security find-generic-password -s "$service" -a "$account" >/dev/null 2>&1
}

resolve_work_username() {
  local user
  user="$(work_local_value work_username)"
  if [[ -z "$user" ]]; then
    user="$(yq_read "${HOME}/.config/chezmoi/chezmoi.yaml" '.data.work_username // .data.adobe_username // ""' 2>/dev/null || true)"
  fi
  if [[ -z "$user" ]]; then
    user="${WORK_USERNAME:-}"
  fi
  echo "$user"
}

resolve_vault_okta_service() {
  local svc
  svc="$(work_local_value vault_okta_keychain_service)"
  if [[ -z "$svc" ]]; then
    svc="$(registry_keychain vault_okta service)"
  fi
  echo "$svc"
}

resolve_vault_okta_label() {
  local label
  label="$(registry_keychain vault_okta label)"
  echo "${label:-work-vault-okta}"
}
