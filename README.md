# Steampunk Cowboy Side Scroller RPG

A side-view steampunk-cowboy platformer about entering beautiful, haunted temples, solving their physical mysteries with a lasso and three firearms, and becoming the chosen champion and lover of adult goddesses and nymphs.

**Stage: the full vertical-slice route is playable, no admitted art.** All five authored beats exist and connect end to end: Entry Bridge, Gallery of Vessels, Procession Hall, Burial Works, and the Keeper's Shrine and Return Gate. Movement, all four tools, all three emergence families, checkpoints scoped correctly across rooms, the relationship arc, the Keeper's dialogue and her intervention are implemented and tested. Reaching the return gate completes the route.

Everything you see is a **placeholder**. Every character, creature and prop is a flat coloured polygon. The 23 sheets in [art-source/candidates/batch-001](art-source/candidates/batch-001/README.md) are saved candidates, not admitted runtime assets, and [F01 reference recovery](docs/decisions.md) is still open. No sprite has been admitted, nothing here is approved art, and the graybox is not a style.

The [sprite prompt pack](docs/production/prompt-pack/README.md) contains 77 ready-to-use generation prompts for the art that would replace it.

**Working division:** Codex primarily handles sprites, visual continuity and game plans. Much of the gameplay code is intended for Claude and Grok through the bounded implementation briefs in this repository.

## The visual promise

Rich pixel/painted temple environments; a chunky, instantly readable Michael; warm torchlight against deep shadow; ceramics, inscriptions, doors and burial pits becoming monsters; and higher-detail divine portraits and manifestations. The tone is sensual, strange, adventurous, beautiful, occasionally macabre and funny. The dead are characters, not interchangeable gore.

The user approved this direction in **Plan 2D Platformer Animations**. Its written context is preserved in [source context](docs/source-context.md). Original screenshot attachments were unavailable during setup; [the reference register](assets/references/reference-register.json) explicitly records that gap. Do not replace that approval with newly generated lookalikes.

## Start here

1. Read the [vision](docs/game-vision.md), [pillars](docs/gameplay-pillars.md) and [decision ledger](docs/decisions.md).
2. Use [art direction](docs/art-direction.md) and the [animation pipeline](docs/sprite-animation-pipeline.md) for asset work.
3. Use the [weapon/tool kit](docs/weapon-tool-kit.md), [emergence system](docs/temple-emergence.md), [relationships](docs/relationships.md) and [data contracts](docs/data-contracts.md) for design and implementation.
4. Build only the [vertical slice](docs/vertical-slice.md), following the [roadmap](docs/implementation-roadmap.md) and [short-task plan](docs/parallel-task-plan.md).
5. Track work in [TODO](docs/TODO.md); check the [validation plan](tests/README.md) and [contribution rules](CONTRIBUTING.md) before handing off.
6. For current art work, use the [first sprite-production batch](docs/production/README.md). Ready-to-use future briefs are available for [Claude's compositor](docs/handoffs/claude-f02-compositor.md) and [Grok's lasso test](docs/handoffs/grok-f04-lasso.md).

## Engine and opening the project

Godot **4.4.1 stable**, typed GDScript, native 2D scenes, Compatibility renderer. The [engine decision](docs/architecture/engine-decision.md) explains ownership, resolution and version policy. This editor version passed the foundation import and headless bootstrap checks. F02 still owns the future world/portrait compositor.

Import `project.godot` in Godot 4.4.1 stable. Press F6 on `scenes/bootstrap.tscn` or F5 for the configured main scene. It displays a foundation-status label only. No plugins, paid services, or export templates are required to inspect the shell. Editor upgrades require a recorded validation pass.

## Running it and checking it

```bash
bash tools/gate.sh              # every check, one verdict
bash tools/run-tests.sh         # the headless suite
bash tools/check-gdscript.sh    # every .gd file parses
```

`tools/gate.sh` reports three states, not two: passed, failed, and NOT CHECKED. A run that skipped something never prints "all passed".

To play it, open `project.godot` and press F5. `scenes/main.tscn` is the main scene. A/D move, Space jumps, 1-4 select lasso/pistol/shotgun/rifle, left mouse uses the equipped tool, right mouse releases the rope, E interacts, R reloads, Q calls the intervention, Escape pauses.

**The checks in this repository have not been run on the pinned 4.4.1 editor**, which is not installed on the machine they were run on. They ran on 4.7.2 against a throwaway copy so the pin was not silently upgraded, and every run prints the version it used. See [gameplay checks](docs/validation/gameplay-checks.md) for what is verified, what each instrument cannot catch, and what is not checked at all.

From PowerShell, `./tools/validate-foundation.ps1` still checks the documentation foundation.

## Repository map

| Path | Ownership |
| --- | --- |
| `src/` | Movement, tools, emergence, puzzles, relationships, save and UI code |
| `scenes/` | Main compositor, Michael, enemy grayboxes and UI scenes |
| `levels/` | Hand-authored temple rooms and their composition |
| `assets/sprites/` | Admitted Michael and enemy frame exports (still empty: none admitted) |
| `assets/backgrounds/`, `assets/tiles/` | Layered environment exports and reusable tiles |
| `assets/vfx/`, `assets/ui/`, `assets/portraits/` | Effects, interface and divine art |
| `assets/audio/` | Music, ambience, effects and voice |
| `assets/references/` | Approved-reference provenance and recoverable originals |
| `art-source/` | Editable source packs; excluded from Godot import |
| `narrative/`, `data/` | Authored story, character and gameplay records |
| `tools/`, `tests/`, `docs/` | Check scripts, the headless suite and design authority |

## Scope and rights

The first slice is the **Temple of the Clay Dead**, a proposed 20–30 minute route with Michael, one adult goddess, three enemy families, all four core tools and one divine intervention. No campaign, procedural temple generator, multiplayer, follower squad or general-purpose RPG framework is included.

The repository is public at [dancockrell/steampunk-cowboy-side-scroller-rpg](https://github.com/dancockrell/steampunk-cowboy-side-scroller-rpg), as requested by the owner. Public visibility does not grant an open-source license; project rights remain reserved pending a licensing decision. Asset provenance and permission must be recorded before admission; engine licensing does not license project art. See [asset policy](docs/asset-policy.md).
