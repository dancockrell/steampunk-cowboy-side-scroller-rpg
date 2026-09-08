# Grok brief: F04 isolated lasso behavior prototype

Assignment: implement an isolated lasso test after F02's shared interfaces are available. This is a future brief, not a launched code task. Use a dedicated branch/worktree from the agreed main commit; record base SHA. Final Michael integration follows F03.

## Player-visible goal

One room demonstrates an intentional throw, a readable miss, an attachment, a constrained pull, a swing and a voluntary release. The lasso feels like Michael's principal tool. It must not attach through walls or leave the player trapped when an anchor disappears.

Read docs/weapon-tool-kit.md, docs/data-contracts.md, docs/production/michael-pose-brief.md and docs/parallel-task-plan.md. Own src/tools/lasso/, scenes/tests/lasso/ and tests/lasso/. Do not edit the production Michael controller or project root without the designated integrator. A small private test body is acceptable inside the lasso scene; it is not a replacement movement system.

## Contract

States are ready → throw → attached/miss → pull/swing/hold → release → recover. Simulation owns throw travel, obstruction checks, attachment point, maximum distance and release. A rope line renders those values; it cannot decide hit or attachment state from its drawn shape.

Start with one straight rope segment and authored anchor points. Anchor metadata declares permitted verb, attachment position and break rule. Support a bounded pull target and a fixed swing anchor. Rope wrapping, knots, arbitrary rigid-body chains, enemy disarming and full combat are excluded.

The sprite brief's frame markers are timing guidance: actual attachment follows contact, never a hardcoded animation frame. Use labeled placeholders until the art pack exists. An interface can expose state changes and socket/world endpoints without requiring final sprites.

## Failure cases and acceptance

- An intervening wall prevents attachment; miss returns to ready without stale input.
- Destroyed/despawned anchor releases safely; a room teardown clears references.
- Pull respects authored bounds; it cannot jam a required mechanism beyond reset.
- Swing respects solid collision; it cannot pull the test body through the floor or wall.
- Pause freezes behavior consistently; focus loss cannot leave a held action latched.
- Voluntary release preserves an intelligible motion transition and permits later rethrow.

Provide a short repeatable interaction sequence, relevant automated boundary checks where practical and an actual motion recording or inspectable native scene. Document provisional tuning and interface assumptions. Return base/final commit, changed paths, validation evidence and integration notes for F03. Do not report finished sprite behavior from geometric stand-ins.
