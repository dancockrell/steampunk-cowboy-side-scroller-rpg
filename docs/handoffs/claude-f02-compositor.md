# Claude brief: F02 world and portrait compositor

Assignment: implement the bounded display scaffold on Godot 4.4.1 stable. This is a ready-to-use future brief; no code task has been launched. Branch from the current verified main when work begins, record its SHA, and use an exclusive checkout.

## Player-visible goal

A low-resolution side-view world remains crisp at integer scale while higher-detail dialogue portraits and text retain their detail. The same scene demonstrates window resizing without hiding the gameplay region. It is a composition test, not a finished game screen.

Read docs/architecture/engine-decision.md, docs/art-direction.md, docs/production/keeper-art-brief.md and docs/decisions.md. Own project.godot, scenes/bootstrap.tscn, scenes/ui/ and a focused src/presentation/ directory if scripts are needed. Add a small test scene and F02 evidence under docs/validation/. Coordinate common root changes before another code task starts.

## Requirements

- Use the pinned editor. Compose a provisional 640×360 SubViewport for world content with nearest output and integer scale; retain aspect ratio with deliberate letterboxing.
- Keep portrait/dialogue UI outside that low-resolution viewport. Use labeled geometric stand-ins or available admitted assets; no new final art.
- Explicitly handle windows smaller than the intended minimum: enforce a sensible minimum or document a deliberate fallback. Never silently crop the critical gameplay region.
- Give the portrait a bounded area; UI cannot obscure required gameplay during combat. Demonstrate safe dialogue composition separately.
- Treat pixel snapping/filtering as presentation. Do not add player motion, weapons, relationships or saves.
- Keep the placeholder label and documentation honest about scope.

## Acceptance

Clean-checkout import and launch with 4.4.1; screenshots at 1280×720 and 1920×1080 plus a non-integer window size; world pixel edges remain consistent; portrait/text retain full-detail rendering; letterboxing and UI bounds are intentional. Record actual output dimensions and known limitations. No requirement to build a generic resolution-management framework.

Return changed files, base/final commit, test commands/results, screenshot paths and decisions needing art review. Codex will assess the composition against recovered originals and admitted assets. A placeholder pass does not approve the visual target.
