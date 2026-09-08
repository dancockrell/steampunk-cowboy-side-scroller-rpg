# Short-task plan for future Claude, Grok and Codex work

This is a plan for future tasks, not a request to start implementation now. Codex primarily owns sprites, visual continuity, art production and game plans. Claude and Grok may receive most code tasks. Assignment is flexible; exclusive file ownership and a reviewable contract matter more than model name.

Each task aims for one independently reviewable result in roughly one working session. Split it further if it cannot finish with useful evidence. Each code task receives the owning specification, input asset contract, failure cases, expected outputs and acceptance check. No assistant should need access to this chat to understand the work.

| ID | Suggested owner | Task and owned paths | Dependencies | Acceptance evidence |
| --- | --- | --- | --- | --- |
| F01 | Codex + original files from user | Recover references, identity/scale sheet; assets/references/, art-source/michael/, docs/art-direction.md | None | Original hashes/provenance and explicit continuity decisions; no substituted approval |
| F02 | Claude or Grok | World/portrait compositor on pinned 4.4.1 editor; project.godot, scenes/bootstrap.tscn, scenes/ui/, docs/architecture/ | None | Clean import/run, native-scale and full-detail portrait test |
| F03 | Claude | Movement/camera graybox; src/player/, scenes/actors/michael/, tests/player/ | F02 | Jump, ledge, landing, pause/focus and collision evidence; provisional tuning recorded |
| F04 | Grok | Lasso prototype in isolated test scene; src/tools/lasso/, scenes/tests/lasso/, tests/lasso/ | F02; integrate after F03 | Miss, attach, pull, swing, release and destroyed-anchor cases |
| F05 | Codex | First Michael movement/lasso pack; art-source/michael/, assets/sprites/michael/ | F01; final timing after F03/F04 | Contact sheet, loop, metadata, continuity and in-engine review |
| F06 | Claude or Grok | Pistol/shotgun/rifle verbs; src/tools/firearms/, tests/tools/ | F03 and tool contract | Costs once, clear differences, blocked shots, reload interruption and recoverable ammo |
| F07 | Codex | Temple room kit + ceramic transition art; art-source/temple/, assets/tiles/, assets/backgrounds/, assets/sprites/enemies/ceramic/ | F01/F02 | Layered room composite and three emergence keyframes with matching seams |
| F08 | Grok or Claude | Ceramic encounter in one test room; src/emergence/, scenes/actors/enemies/, tests/emergence/ | F03; use graybox until F07 | Single spawn/result, blocked spawn, interrupt, pause and reload cases |
| F09 | Codex | Keeper identity/expressions and dialogue beat plan; assets/portraits/, narrative/, art-source/keeper/ | F01 | Adult identity continuity; accept/defer/decline and optional romance script |
| F10 | Claude or Grok | Checkpoint and relationship state; src/save/, src/relationships/, tests/save/, tests/relationships/ | F08/F09 contracts | Atomic snapshot, no duplicate judgments, progression after refusal |
| F11 | Codex | Mural/pit packs and intervention art; relevant art-source/ and assets/ subfolders | F07 review | Two distinct complete transformations, readable intervention |
| F12 | One integrator, Claude or Grok | Compose route/puzzles and aid; levels/, src/puzzles/, scenes/world/ | F04–F11 | Full route and physical alternative, no soft-locks |
| F13 | Codex + code integrator | Visual acceptance and polish report; docs/validation/, fixes in assigned paths | F12 | Native motion, actual room renders, accessibility and measured performance |

## Parallel waves

Wave A: F01 and F02. Wave B: F03 and isolated F04, while F05/F07 art drafts proceed once references permit. Wave C: F06, F08 and F09 with separate file ownership. Wave D: F10 and F11. Wave E: F12 integration, then F13. F05 timing review waits for movement/lasso behavior; graybox code does not certify finished art.

## Shared-file protocol

One integrator owns project.godot, common scene roots and shared contracts at a time. Workers use separate branches/worktrees from a named base commit. A worker that needs a shared interface change proposes it in its handoff; the integrator accepts and updates the authoritative document before dependent work merges. Never have Claude and Grok writing the same active checkout.

## Copyable implementation brief

Use docs/templates/implementation-brief.md. Fill in one TODO ID, base commit, exact owned paths, allowed shared interfaces, scope, examples, exclusions, test command and completion evidence. The implementer returns changed files, assumptions, tests run, screenshots/clips where behavior is visual, commit SHA and unresolved gaps. Codex can review resulting sprite behavior against the admitted art pack.
