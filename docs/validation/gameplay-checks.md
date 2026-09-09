# Gameplay validation: what is actually checked, and how

Companion to [foundation.md](foundation.md), which covers the documentation
shell. This file covers the runtime code. It records **commands you can re-run**
rather than results someone once observed, because a recorded result rots the
moment the code moves and its reader has no way to re-derive it.

Where this page and a command disagree, the command is right and this page is
stale.

## The two instruments

```bash
bash tools/check-gdscript.sh   # every .gd file parses
bash tools/run-tests.sh        # the headless suite
bash tools/run-tests.sh --only=test_room_integration   # one suite
```

Both exit 0 on success and non-zero on failure. Read the exit code **directly**.
Reading it through a pipe (`cmd | tail`) reports the pipe's status, not the
command's, which is how a dead fallback survives unnoticed.

## Editor version: a real and recorded gap

`.godot-version` pins **4.4.1.stable**. That editor is **not installed on the
machine these checks were run on**; what is installed is **4.7.2.stable**.

Both scripts therefore copy the project to a throwaway directory and run there.
Opening the real checkout with 4.7.2 would rewrite `project.godot`'s feature
list and silently upgrade the pin, which ADR 001 requires a recorded validation
pass to do deliberately. The version actually used is printed at the end of
every run, so no result can quietly claim to be a 4.4.1 result.

**Consequence: no check on this page has been run on the pinned editor.** Anyone
with 4.4.1 available should re-run both scripts and record the outcome here.
Set `GODOT_BIN` to point at it.

## What the parse check does NOT catch

Measured, not assumed. Three sabotages were applied to a clean tree:

| Sabotage | Caught |
| --- | --- |
| Syntax error (`func broken(`) | Yes, and it correctly cascades to dependent files |
| Return-type mismatch (`-> int` returning a `String`) | Yes |
| Calling a method that does not exist on a `class_name` | **No** |

The third is why the runtime suite exists and why parse-checking alone is not a
gate. An unknown-method call is only found when the line actually executes, so a
branch with no test is a branch where that error is still waiting.

## Harness guards

The runner refuses to report a pass it did not earn:

- A floor on test files found and assertions made. Below either, it prints
  `HARNESS FAIL` naming the number, because a suite that discovers nothing
  otherwise prints a green zero.
- `tools/run-tests.sh` greps for the runner's own `RESULT:` line and fails if it
  is absent, so a crash before the verdict cannot read as a pass.
- `tools/check-gdscript.sh` aborts if its file filter finds zero (or fewer than
  `MIN_FILES`) scripts. A filter that empties its input is an error, never a
  quiet no-op.

Both guards were tested by making them fire: `MIN_FILES=999` produced
`FAIL: only N files found`, exit 1.

## Sabotage record

A green suite is evidence only if it can go red. Each sabotage below was applied
to a clean tree, the suite was run, the file was restored, and the restored file
was confirmed byte-identical by `md5sum`. The column that matters is *which*
tests went red: a sabotage that fails more than expected means the checks are
entangled and are saying less than they appear to.

| Sabotage | Result |
| --- | --- |
| `EventLedger.consume` always succeeds | 6 assertions red across ledger and checkpoint suites |
| `Services.restore` applies puzzles before validating | 1 red: the partial-restore assertion, and only that |
| `Heroine` `adult: true` check removed | 1 red in the relationship suite |
| Tool switch applies immediately instead of queueing | 2 red in the tool suite |
| Ammo spent again when recovery ends | 1 red: the one-round-per-commit assertion |
| Hurt refunds a committed shot | 1 red |
| Coyote time removed | 2 red in the movement suite |
| Jump buffer removed | 1 red |
| Recall gated on romance as well as alliance | 1 red: the critical-route test, and only that |

## Defects these checks actually found

Recorded because they are the argument for running them, not for trusting them:

- **Relationship dimensions clamped to `[0, 10]` while starting at 0.** Every
  negative judgment clamped away to nothing, so destroying a funerary urn in
  front of the goddess of funerary urns moved her opinion by exactly zero. Found
  by the end-to-end suite; every unit test had passed, because none of them ever
  checked that a negative judgment moves the number.
- **`_ready` does not fire in a `--script` headless run that never reaches a
  frame.** `Main` and `GrayboxTerrain` silently initialised nothing. Both now
  have explicit idempotent `boot()` / `build()` entry points with `_ready` as a
  trampoline. Found by the boot smoke test, which exists precisely because "ran
  headless, exit 0, empty log" is indistinguishable from a scene that loaded
  nothing.
- **`motion_mode` on the player collided with an existing `CharacterBody2D`
  property.** Caught by the parse check.

## What is NOT checked

Listed so a reader does not mistake silence for coverage:

- **Nothing has been run on the pinned 4.4.1 editor.** See above.
- **No input-feel or frame-time measurement.** The tuning numbers in
  `src/core/tuning.gd` are hypotheses. `docs/vertical-slice.md` asks for a
  measured 60 fps on a declared machine; that measurement has not been taken.
- **No visual review at native scale.** One frame of the graybox room has been
  rendered and inspected, which confirms the compositor produces a picture and
  the room lays out. It is not an art review, and there is no admitted art to
  review.
- **Gamepad bindings are declared in `project.godot` and have not been exercised
  on a physical controller.**
- **No accessibility verification beyond the settings round-tripping.** Reduced
  shake, subtitle scaling and toggle aiming are implemented as settings; whether
  they are sufficient has not been reviewed with anyone.
