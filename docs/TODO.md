# First vertical-slice backlog

This checked-in backlog is the initial issue tracker. Items are not started and are not scheduled. Detailed ownership/dependencies live in [the task plan](parallel-task-plan.md).

- [ ] F01 Recover original approved renders; register provenance and lock identity/scale.
- [x] F02 World/portrait compositor implemented and tested. NOT demonstrated on the PINNED 4.4.1 editor; checks ran on 4.7.2 against a copy. See docs/validation/gameplay-checks.md.
- [x] F03 Movement, camera and the 14-action input map. Coyote time, jump buffer and jump cut are tested; input FEEL is unmeasured and the numbers are hypotheses.
- [x] F04 Lasso throw, attach, swing, pull, release, miss and destroyed-anchor cases, integrated with movement rather than isolated.
- [ ] F05 Produce and admit Michael movement/lasso action pack.
- [x] F06 Pistol, shotgun and rifle with distinct verbs, ammo spent once per commit, interruptible reload and queued switching.
- [ ] F07 Produce temple room kit and ceramic emergence art.
- [x] F08 All three families, not just ceramic. Single spawn transfer, blocked spawn, interrupt, pause and reload cases covered.
- [ ] F09 Produce adult Keeper identity/portrait package and branching dialogue plan.
- [x] F10 Atomic checkpoints, no duplicated rewards, and progression that survives refusing both the alliance and the romance.
- [ ] F11 Produce mural/pit enemy packs and Recall to Clay presentation.
- [ ] F12 Integrate the bounded temple route. TWO of five authored beats exist and connect (Gallery of Vessels, Procession Hall); entry bridge, burial works and the shrine/return gate are not built. Cross-room checkpoints, room-scoped exit facts and the room registry are implemented and tested, not just the single room they were first built for.
- [ ] F13 Inspect actual motion/renders; complete accessibility, performance and soft-lock validation.

## What is implemented, and what that does not mean

The simulation for the slice is written and tested: 300 tests, 894 assertions.
Implemented is not the same as finished, so the honest gaps are named on each
line above and in docs/validation/gameplay-checks.md. In particular no check has
run on the pinned editor, no frame time has been measured, no controller has
been used, and there is no admitted art of any kind.

## Setup completion record

Production planning pass: Michael run/lasso pose briefs, three emergence keyframe sequences, Keeper expression/manifestation brief, gallery staging and export handoff are in [docs/production](production/README.md). F02 and F04 have filled Claude/Grok briefs. These planning deliverables do not complete the corresponding art or implementation tasks.

Foundation documentation and engine shell are committed separately from future production. Check docs/validation/foundation.md for checks actually performed. No TODO above becomes complete merely because a folder or a design document exists.
