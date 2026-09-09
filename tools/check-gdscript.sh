#!/usr/bin/env bash
# Parse-check every GDScript file in the project and report a denominator.
#
# Why a copy: the project pins Godot 4.4.1 (.godot-version) and this machine has
# 4.7.2. Opening the real checkout would rewrite project.godot's feature list and
# silently upgrade the pin, so we check a throwaway copy instead and report the
# version actually used. See docs/validation/gdscript-check.md.
set -uo pipefail

GODOT="${GODOT_BIN:-/c/Users/Admin/AppData/Local/Programs/Godot/Standard/Godot_v4.7.2-stable_win64_console.exe}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${CHECK_WORKDIR:-${TMPDIR:-/tmp}/steampunk-cowboy-check}"

if [ ! -x "$GODOT" ]; then
  echo "NOT CHECKED: no Godot binary at $GODOT (set GODOT_BIN)" >&2
  exit 2
fi

rm -rf "$WORK"; mkdir -p "$WORK"
# art-source is excluded from Godot import anyway and is 40 MB of PNG.
(cd "$REPO" && tar -cf - --exclude=.git --exclude=art-source --exclude=.godot .) | (cd "$WORK" && tar -xf -)

# Import once so global class_name registrations resolve during the parse checks.
"$GODOT" --headless --path "$WORK" --import >/dev/null 2>&1

mapfile -t FILES < <(cd "$WORK" && find src scenes levels tests tools -name '*.gd' 2>/dev/null | sort)
TOTAL=${#FILES[@]}

# A filter that empties its input is an error, never a quiet pass.
if [ "$TOTAL" -eq 0 ]; then
  echo "FAIL: found 0 GDScript files to check. The file filter is broken, not the code." >&2
  exit 1
fi
MIN_EXPECTED="${MIN_FILES:-10}"
if [ "$TOTAL" -lt "$MIN_EXPECTED" ]; then
  echo "FAIL: only $TOTAL files found, expected at least $MIN_EXPECTED. Input looks truncated." >&2
  exit 1
fi

FAILED=0
for f in "${FILES[@]}"; do
  OUT="$("$GODOT" --headless --path "$WORK" --check-only --script "res://$f" 2>&1)"
  RC=$?
  if [ $RC -ne 0 ]; then
    FAILED=$((FAILED + 1))
    echo "--- PARSE FAIL: $f"
    echo "$OUT" | grep -iE "error|line [0-9]+" | head -8
  fi
done

echo
echo "checked $TOTAL GDScript files with $("$GODOT" --version), $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
