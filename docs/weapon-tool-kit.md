# Michael's weapon and tool kit

All ranges, speeds, damage, ammunition capacities and animation rates are tuning data. Do not balance them from prose alone. The lasso is the identity tool; firearms have distinct physical verbs.

| Tool | Traversal/puzzle role | Combat role | Cost and readability | First-slice proof |
| --- | --- | --- | --- | --- |
| Lasso | Hook authored anchor, swing, pull counterweight or movable object | Restrain or unbalance eligible enemy | Visible valid target, rope tension, clear release; no ammunition | Swing across pit, then pull a weight while standing safely |
| Pistol | Precise near/mid-range switch or bell | Quick interrupt and exposed weak point hit | Short recovery, small clear muzzle flash, explicit reload | Ring a bell to expose a ceramic sentinel |
| Shotgun | Push marked plugs, fracture authored weak material | Close cone, force and stagger | Strong recoil, limited shells; rubble cannot obstruct required route | Move a stone plug without destroying the sacred urn nearby |
| Rifle | Distant counterweight, seal or weak point | Deliberate aimed shot | Longer aim/recovery; aim must not reveal offscreen hazards unfairly | Release a visible far counterweight to make an anchor accessible |

## Action ownership and conflicts

Tool flow: ready → aim/target → commit → effect → recover → ready. Reload is a separate interruptible state before commitment. Firing commits ammo once and emits one simulation event; animation and sound consume that event. Weapon switching queues during committed recovery and never cancels a spent shot into another free action. Hurt interrupts aiming and reload; damage/recovery priority must be covered by tests.

Lasso flow: ready → throw → attached or miss → pull/swing/hold → release → recover. Anchor metadata declares allowed verbs, attachment point and break behavior. Begin with authored anchor points and one rope segment constraint; arbitrary wrapping and simulated rope knots are deferred. The simulation owns attachment and maximum distance. The drawn rope follows that state, never determines it.

If an anchor is destroyed, a target despawns, the player changes room or a save reloads, release cleanly. An obstructed throw returns to ready; it cannot attach through walls. Pulling objects uses a bounded authored route/constraint, not unconstrained debris physics. A swing cannot clip Michael through a wall. No sticky input after pause or focus loss.

Puzzle targets expose verbs such as `pull`, `precision_hit`, `force_hit`, `long_precision_hit`; cosmetic props do not secretly inherit all verbs. Tool preview and impact feedback explain invalid uses without consuming required puzzle progress. Slice rooms provide replenishment or a reset if the player wastes critical ammo.

## Required animation and VFX events

Use named markers: `tool_commit`, `muzzle_flash`, `rope_attach`, `rope_release`, `reload_commit`, `recovery_end`. Presentation markers may align effects but may not emit a second authoritative hit. See the [animation pipeline](sprite-animation-pipeline.md) for frame families and sockets.
