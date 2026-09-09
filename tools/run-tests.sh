#!/usr/bin/env bash
# Run the headless test suite against a throwaway copy of the project.
#
# The copy exists because the project pins Godot 4.4.1 (.godot-version) and this
# machine has 4.7.2: opening the real checkout would rewrite project.godot and
# silently upgrade the pin. The version actually used is printed in the result.
set -uo pipefail

GODOT="${GODOT_BIN:-/c/Users/Admin/AppData/Local/Programs/Godot/Standard/Godot_v4.7.2-stable_win64_console.exe}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${TEST_WORKDIR:-${TMPDIR:-/tmp}/steampunk-cowboy-tests}"

if [ ! -x "$GODOT" ]; then
  echo "NOT CHECKED: no Godot binary at $GODOT (set GODOT_BIN). The suite did NOT run." >&2
  exit 2
fi

rm -rf "$WORK"; mkdir -p "$WORK"
(cd "$REPO" && tar -cf - --exclude=.git --exclude=art-source --exclude=.godot .) | (cd "$WORK" && tar -xf -)
"$GODOT" --headless --path "$WORK" --import >/dev/null 2>&1

OUT="$WORK/result.txt"
"$GODOT" --headless --path "$WORK" --script res://tests/run_tests.gd -- "$@" >"$OUT" 2>&1
RC=$?

grep -vE "^(Godot Engine|Compatibility - |OpenGL API|Please include|--- Debug)" "$OUT" | sed '/^$/N;/^\n$/D'

# The runner owns the verdict. A crash before it prints one must not read as a pass.
if ! grep -qE "^RESULT: (PASSED|FAILED)" "$OUT"; then
  echo "HARNESS FAIL: the runner produced no RESULT line (exit $RC). It crashed rather than passing." >&2
  exit 1
fi
echo "godot: $("$GODOT" --version)"
exit $RC
