#!/usr/bin/env bash
# setup.sh — entry point for new-machine setup (wraps bootstrap.sh).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${ROOT}/bootstrap.sh" "$@"
