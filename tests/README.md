# Validation plan

## Available foundation check

`./tools/validate-foundation.ps1` validates document links, required foundation files, JSON syntax and basic shell references. `git diff --check` checks whitespace. These are structure checks, not gameplay tests.

## Engine check when the selected editor is available

Record the exact version, then run `godot --headless --path . --editor --quit` and `godot --headless --path . --quit-after 2`. Inspect the visible bootstrap separately. F02 must replace the shell with a tested compositor before gameplay work. Current setup validation evidence is in ../docs/validation/foundation.md.

## Meaningful future tests

| Area | Cases that must prove behavior |
| --- | --- |
| Movement | Buffered jump/ledge grace boundaries, landing, ceiling/wall collisions, input after pause/focus loss |
| Lasso | Occluded target, missed throw, valid attach, pull bounds, swing collision, destroyed anchor, room transition |
| Firearms | One cost/hit per commit, reload interrupt, switch during recovery, blocked shot, scarce puzzle ammo recovery |
| Emergence | Trigger once, blocked spawn, interrupt, animation skip, pause, single reward, consistent reload |
| Relationships | Witnessed facts once, no score-based consent, decline/defer path, non-romantic critical progression |
| Checkpoints | Atomic room/player restore, corrupt/version-mismatch handling, no duplicate rewards or judgments |
| Content | Stable unique IDs, valid references, matching frame dimensions/durations, admitted-asset status |

Choose the smallest test harness needed for the feature; no test framework is installed during setup. Store automated cases under the owning area once implemented. Add real in-engine smoke paths and preserve reproducible evidence for visual features. Automated geometry correctness cannot approve sprite motion, lighting, portraits or scenery transformations.
