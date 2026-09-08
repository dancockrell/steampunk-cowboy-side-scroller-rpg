# Temple and monster emergence system

Each encounter belongs to an authored scenery source with a stable ID. Doors, ceramic objects, inscriptions, murals and burial pits are supported source types. The slice implements three families; door and inscription variants beyond those are future content, not extra enemies owed by this milestone.

| State | Presentation and transition | Simulation rule |
| --- | --- | --- |
| Disguised | Intact scenery; trigger becomes eligible | No enemy attack or damage volume |
| Tell | Dust, hairline crack, moving paint, hands below rim | Visible/audible warning; activation is latched once |
| Awakening | Surface separates or body assembles | Authored vulnerability windows only |
| Emerging | Before/peak/resolved keyframes bridge scenery and creature | Spawn ownership transfers exactly once; blocked space delays safely |
| Active | Locomotion, attack, stagger | Normal combat state owns hits |
| Resolved | Broken pottery, faded paint, returned bones | Persistent result and reward applied once |

Default flow is disguised → tell → awakening → emerging → active → resolved. An authored interrupt can route awakening/emerging to resolved or staggered active; it cannot silently skip to a damaging attack. Terminal sources stay resolved until a checkpoint rollback explicitly restores an earlier snapshot.

## Three slice families

| Family | Before → peak → resolved art beats | Behavior |
| --- | --- | --- |
| Ceramic sentinel | Grave jar → cracked shell with folded articulated body → shards and intact funerary token | Unfolds upright, short charge and readable heavy strike |
| Painted procession guard | Flat mural figure → painted limb peels away from plaster → pigment returns to wall | Steps between wall panels, emerges to thrust, can remain partly flat |
| Burial-pit assembler | Quiet trench → hands pass mismatched bones upward → bones settle below rim | Crawls first, assembles enough body to lunge; occasional wrong-skull humor |

## Fairness and persistence

Do not trigger unavoidable damage behind the camera. First occurrence teaches the tell in a safe framing; later combinations reuse that language. If the emergence location is blocked, wait or use an explicitly authored safe fallback and repeat a tell. Never teleport an active hitbox into Michael. Camera locks must retain a recoverable exit path.

Room unload stores the encounter's stable phase/result; reentry cannot duplicate the enemy. Checkpoint reload restores the entire room snapshot consistently with Michael, ammo and puzzles. Saving is initially restricted to safe checkpoints, so an animation frame need not be serialized. A mid-emergence pause freezes simulation and presentation together. A skipped animation still completes the single state transition correctly.

An enemy is not merely a prop removed plus a separately spawned actor: both are views of one encounter ID. Source destruction, rewards and goddess judgment use idempotent event IDs. Environmental collateral produces a distinct authored fact, not an inference from final rubble appearance.
