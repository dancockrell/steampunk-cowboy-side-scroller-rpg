# Michael: Temples, Goddesses, and the Dead

A side-view steampunk-cowboy platformer about entering beautiful, haunted temples, solving their physical mysteries with a lasso and three firearms, and becoming the chosen champion and lover of adult goddesses and nymphs.

**Stage: documentation-first production foundation.** This repository contains design contracts, art-production specifications, a Godot project shell, and a bounded implementation backlog. It contains no playable platformer, approved image files, or completed animation assets yet.

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

From PowerShell, run `./tools/validate-foundation.ps1` to check the documentation foundation. With a selected Godot executable, run `godot --headless --path . --editor --quit` and `godot --headless --path . --quit-after 2`. Engine import/run and real visual QA are separate from the foundation check.

## Repository map

| Path | Ownership |
| --- | --- |
| `src/` | Future movement, tools, combat, emergence, relationships and save code |
| `scenes/` | Bootstrap and future reusable actor, world and UI scenes |
| `levels/` | Hand-authored temple rooms and their composition |
| `assets/sprites/` | Admitted Michael and enemy frame exports |
| `assets/backgrounds/`, `assets/tiles/` | Layered environment exports and reusable tiles |
| `assets/vfx/`, `assets/ui/`, `assets/portraits/` | Effects, interface and divine art |
| `assets/audio/` | Music, ambience, effects and voice |
| `assets/references/` | Approved-reference provenance and recoverable originals |
| `art-source/` | Editable source packs; excluded from Godot import |
| `narrative/`, `data/` | Authored story, character and gameplay records |
| `tools/`, `tests/`, `docs/` | Production utilities, validation contracts and design authority |

## Scope and rights

The first slice is the **Temple of the Clay Dead**, a proposed 20–30 minute route with Michael, one adult goddess, three enemy families, all four core tools and one divine intervention. No campaign, procedural temple generator, multiplayer, follower squad or general-purpose RPG framework is included.

Repository visibility defaults to private. No open-source license is granted at setup. Asset provenance and permission must be recorded before admission; engine licensing does not license project art. See [asset policy](docs/asset-policy.md).
