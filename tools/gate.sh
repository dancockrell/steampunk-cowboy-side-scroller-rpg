#!/usr/bin/env bash
# The one command to run before handing work over.
#
# Runs every gameplay check in dependency order and prints a single verdict that
# distinguishes three states, not two: passed, failed, and NOT CHECKED. Folding
# "could not determine" into either of the other two is where a false all-clear
# gets in, so a skipped check is carried all the way down to the summary line.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

FAILED=0
SKIPPED=0
SKIPPED_NAMES=""

run_step() {
  local name="$1"; shift
  echo
  echo "=== $name ==="
  "$@"
  local rc=$?
  case $rc in
    0) echo "[ok] $name" ;;
    2) echo "[NOT CHECKED] $name"; SKIPPED=$((SKIPPED + 1)); SKIPPED_NAMES="$SKIPPED_NAMES $name" ;;
    *) echo "[FAILED] $name (exit $rc)"; FAILED=$((FAILED + 1)) ;;
  esac
}

run_step "gdscript parse check" bash tools/check-gdscript.sh
run_step "headless test suite" bash tools/run-tests.sh

echo
echo "======================================"
if [ "$FAILED" -gt 0 ]; then
  echo "RESULT: FAILED ($FAILED failing, $SKIPPED not checked)"
  exit 1
fi
if [ "$SKIPPED" -gt 0 ]; then
  # Never "all passed" when something did not run. The summary is the only line
  # most readers read, so the skip has to survive into it.
  echo "RESULT: no failures, but $SKIPPED NOT CHECKED:$SKIPPED_NAMES"
  exit 2
fi
echo "RESULT: all checks passed"
