# Enemy scenes: graybox placeholders

Every scene in this directory is a **graybox placeholder**, not an admitted or
approved asset. Each is a bare root node carrying its family script; the
silhouette, the collision box and the hurtbox are built in code by
`EnemyActor._build_graybox()` and are named `Graybox*` so nothing here can be
mistaken for art.

No sprite has been produced. When frames exist they arrive through the
AnimationClip contract in `docs/data-contracts.md` and attach at the
`PlaceholderSpriteSeam` marker each actor creates, replacing `GrayboxBody`
rather than sitting beside it. The keyframe beats these actors have to match are
in `docs/production/emergence-keyframes.md` (C0-C5, M0-M5, B0-B5).

A polygon cannot stand in for the parts of those briefs that are the actual art
problem: the jar decoration surviving across body segments, a painting acquiring
volume against exact wall registration, or the pit-lip occlusion mask. Those
remain outstanding.

| Scene | Family | Silhouette stands in for |
| --- | --- | --- |
| `ceramic_sentinel_graybox.tscn` | ceramic sentinel | Tall shoulder-heavy vessel that unfolded upright |
| `painted_procession_guard_graybox.tscn` | painted procession guard | Wide shallow figure still part plaster |
| `burial_pit_assembler_graybox.tscn` | burial-pit assembler | Low wide crawler hauling over a rim |

Actors are never instantiated directly by a room. An `Encounter`
(`src/emergence/encounter.gd`) owns the source ID and instantiates the family
scene at the single moment spawn ownership transfers.
