# Asset register

The running record of every asset actually admitted into `assets/`, using the
review record template from [asset-handoff.md](asset-handoff.md). An entry
here is the only thing that makes an asset admitted; nothing in `assets/`
became runtime-approved by being copied there without one.

## michael_run_right (v1)

- **Asset/action ID and revision:** `michael_run_right`, v1 (first admission).
- **Original reference IDs and source hashes:** derived from
  `art-source/candidates/batch-001/michael_run_right_v002.png`, sha256
  recorded in `tools/sprite_extract/` output manifests (regenerate with
  `python3 tools/sprite_extract/build_michael_run.py <out_dir>` to reproduce).
  This is a **candidate** sheet per `art-source/candidates/batch-001/README.md`,
  not an F01-recovered original reference. F01 remains open.
- **Tool/model/settings and prompt record:** see
  `art-source/candidates/batch-001/generation-records.json`, entry
  `michael_run_right_v001` (v002 corrected the background only; identity
  prompt unchanged).
- **Source and export paths:** source sheet above; exported frames at
  `assets/sprites/michael/run_right/michael_run_right_{000..007}.png`, packaged
  as `assets/sprites/michael/michael_run_right.tres` (Godot `SpriteFrames`,
  animations `run` 8 frames / `idle` 1 frame).
- **Technical checks performed:** connected-component extraction rather than a
  rigid grid slice (`tools/sprite_extract/extract.py`), so a pose that spills
  past its nominal cell is not clipped -- 0 warnings on this sheet, unlike the
  lasso sheet (see below). Chroma-key + 1px alpha erosion despill removes the
  magenta fringe. Every frame padded to a shared 363x465 canvas, bottom-aligned
  to the same pixel row (measured: row 451 exactly, all 8 frames, not
  assumed) so the foot line does not bob between poses. Verified in the real
  running game (`tests/test_boot_smoke.gd`): 8 real textures load, each with
  matching canvas height, each larger than a 1x1 placeholder.
- **Native-scale visual/motion evidence:** one frame inspected directly
  (`michael_run_right_003.png`) for extraction cleanliness -- no clipping, no
  visible fringe. One in-engine capture with the player actually running
  confirmed the sprite renders at the correct scale and foot position against
  real room geometry, mid-stride. No native-size loop review, no dark-room
  contrast pass, no side-by-side with the counterweight/anchor props at final
  color -- those remain open per docs/sprite-animation-pipeline.md's review
  checklist.
- **Identity/continuity observations:** matches the identity block used
  throughout batch-001 (verbatim in the prompt pack). Goggles are drawn on the
  hat in this sheet; the identity block used by the prompt pack omits them --
  the same open discrepancy already flagged in
  `docs/production/prompt-pack/README.md`, unresolved here too.
- **In-engine timing and socket observations:** `run` animation speed is a
  round-number placeholder (12 fps), not measured against `MovementSolver`'s
  actual stride timing. No sockets (`muzzle`, `hand_lasso`, `feet`) are
  defined; this pack predates the tool/weapon sprite work, so nothing consumes
  them yet.
- **Rights/provenance status:** generated for this project under the user's
  explicit authorization recorded in `docs/decisions.md` D09. No third-party
  reference material.
- **Decision: ADMITTED for graybox replacement.** Distinct from full
  production sign-off: this clears the bar of "usable in place of a flat
  polygon primitive," not the complete checklist in
  docs/sprite-animation-pipeline.md (native-scale dark/light review, in-room
  composite, reviewer sign-off separate from the person who built the
  extraction). Treat as provisional pending that fuller pass.
- **Reviewer, date, unresolved exceptions and next action:** Claude Sonnet 5,
  10 Sep 2026. Unresolved: goggles discrepancy (shared with the prompt pack),
  animation timing unmeasured, no idle/jump/lasso/firearm art yet -- those
  action families remain graybox. Next action: extend the same extraction
  pipeline to the remaining Michael action sheets once the goggles question is
  settled, so new work does not fork from what this sheet already shows.

## michael_run_left -- NOT admitted, recorded as a rejected candidate

`art-source/candidates/batch-001/michael_run_left_v002.png`'s own README entry
claims "8 left-facing poses after correction." **Measured directly against the
file, this is false**: the character faces and runs rightward in every visible
pose, identical in orientation to `michael_run_right_v002.png`. Not used.
Left-facing movement in-engine instead mirrors the admitted right-facing
frames with `AnimatedSprite2D.flip_h` (see `src/player/player.gd`), flagged in
code as an interim, reversible choice pending the handedness review
`michael-pose-brief.md` already calls for -- mirroring an asymmetric-gear
character (mechanical bracer, holster, lasso coil all on one side) risks
silently swapping which side carries what, which that document explicitly
forbids guessing at.

## Everything else in `art-source/candidates/batch-001/`

Not reviewed for admission in this pass. Idle, jump, lasso, firearm and
interaction sheets for Michael; all enemy family sheets; the Keeper's
portraits and manifestation; the temple environment plate; VFX -- all remain
graybox in the running game. This register entry exists so a future pass has
a real methodology and a real example to extend, not a blank page.
