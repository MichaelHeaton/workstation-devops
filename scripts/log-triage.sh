#!/usr/bin/env bash
# Triage an ansible apply log — surfaces errors, warnings, and changed tasks.
# Usage: ./scripts/log-triage.sh [logfile]
#   Defaults to the most recent file in logs/

set -euo pipefail

LOGS_DIR="$(cd "$(dirname "$0")/.." && pwd)/logs"

if [[ $# -ge 1 ]]; then
  LOG="$1"
else
  LOG="$(ls -t "$LOGS_DIR"/apply-*.log 2>/dev/null | head -1)"
  if [[ -z "$LOG" ]]; then
    echo "No log files found in $LOGS_DIR" >&2
    exit 1
  fi
fi

echo "=== Triage: $(basename "$LOG") ==="
echo ""

# --- Errors and fatals ---
ERRORS=$(grep -iE "^(FAILED|fatal|ERROR)" "$LOG" || true)
if [[ -n "$ERRORS" ]]; then
  echo "--- ERRORS / FAILURES ---"
  echo "$ERRORS"
  echo ""
else
  echo "✓ No errors or failures"
  echo ""
fi

# --- Warnings ---
WARNINGS=$(grep -iE "^\[WARNING\]|^WARNING" "$LOG" || true)
if [[ -n "$WARNINGS" ]]; then
  echo "--- WARNINGS ---"
  echo "$WARNINGS"
  echo ""
fi

# --- Changed tasks ---
CHANGED=$(grep -E "changed:" "$LOG" || true)
if [[ -n "$CHANGED" ]]; then
  echo "--- CHANGED TASKS ---"
  echo "$CHANGED"
  echo ""
else
  echo "✓ No tasks changed"
  echo ""
fi

# --- Play recap ---
RECAP=$(grep -A 20 "PLAY RECAP" "$LOG" || true)
if [[ -n "$RECAP" ]]; then
  echo "--- PLAY RECAP ---"
  echo "$RECAP"
fi
