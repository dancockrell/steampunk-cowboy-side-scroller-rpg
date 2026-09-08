# ADR 001: Native 2D Godot project

Status: selected for the foundation on 2026-09-08. Language: typed GDScript. Rendering baseline: Compatibility. Editor pinned to **4.4.1.stable.official.49a5bc7b6**, with a 4.4 feature baseline. The official Windows editor was obtained separately for setup validation; clean import and headless bootstrap passed. See ../validation/foundation.md. F02 still owns the world/portrait compositor and its visual checks.

Godot's native 2D scene composition suits authored platformer rooms, sprite animation, tile layers, 2D collision and UI. GDScript keeps small behavior scripts directly editable by Claude and Grok without a separate build toolchain. The Compatibility renderer is a conservative initial desktop choice; richer lighting must prove itself in the target room before changing the renderer.

Alternatives considered: Unity offers extensive tooling but adds package/project overhead for this small sprite-led foundation; a browser engine is suitable for prototypes but shifts more editor/content-pipeline work into custom tools. We select Godot to keep the art-to-scene workflow compact, not as a claim that other engines cannot produce a polished platformer.

## Composition contract

Future application root owns a low-resolution world SubViewport and a full-window portrait/dialogue UI. The world uses 640×360 provisional dimensions and integer-scaled nearest output; high-detail divine portraits remain outside that low-resolution viewport. The current bootstrap is only a status screen, not this completed compositor.

Future WorldRoot owns Camera2D, room instances, Michael and encounter controllers. A room composes TileMapLayer nodes for terrain, separable emergence-source scenes, lights and semantic art layers. Michael uses CharacterBody2D with child visual/socket nodes; frame animation is presentation. Input mapping is configured during F03, not faked by unused project actions now.

Use direct typed scene references and local signals initially. No global event bus, entity-component framework, plugin suite or generic RPG service layer is required. Add a small checkpoint owner when its first use exists. Runtime data becomes typed Godot Resources when consumption is implemented; the current Markdown field contracts are authoritative planning interfaces.

## Ownership boundaries

| System | Owns | Does not own |
| --- | --- | --- |
| Player controller | Motion, jump permissions, tool-action priority | Sprite-derived collision truth |
| Tool controller | Committed shot/rope state and costs | Dialogue consequences |
| Encounter controller | Source ID, phase, spawn/result once | Background appearance as persistence |
| Puzzle controller | Mechanism states, reset and checkpoint serialization | Arbitrary physics debris as sole solution state |
| Relationship controller | Authored judgments, choices, alliance/romance state | Automatic consent from score |
| Presentation | Frames, effects, sounds and portraits from state/events | Extra damage or duplicated rewards |

## Sources checked

- [Godot 4.4 TileMapLayer](https://docs.godotengine.org/en/4.4/classes/class_tilemaplayer.html): one node per tile layer; compose layers for room structure.
- [Godot 4.4 multiple resolutions](https://docs.godotengine.org/en/4.4/tutorials/rendering/multiple_resolutions.html): scaling choices inform the world/UI split.
- [Godot CharacterBody2D usage](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html): player-body workflow reference; use the pinned version's documentation during implementation.

## Version and acceptance gate

The foundation records exact editor version, executable provenance, import result and bootstrap run result. F02 must additionally produce world/portrait composition screenshots and rerun those checks on its changes. Do not assume upgrading an editor is harmless; review project-file changes and rerun checks. Export templates, target-machine performance and release signing remain later implementation/release work.
