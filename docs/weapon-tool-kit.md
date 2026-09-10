# Michael's weapon and tool kit

All ranges, speeds, damage, ammunition capacities and animation rates are tuning data. Do not balance them from prose alone.

**The kit is two tools (D21): the lasso and the pistol.** The shotgun and rifle were cut on 10 Sep 2026 and are not coming back behind a flag. The lasso is the identity tool and the only control tool: it swings, it grabs, it hauls, and against a creature it staggers rather than damages. The pistol is the only damaging verb in the game. That division is the point -- every encounter is meant to be a physical problem you solve with rope and one accurate shot, not a damage check.

| Tool | Traversal/puzzle role | Combat role | Cost and readability | First-slice proof |
| --- | --- | --- | --- | --- |
| Lasso | Hook authored anchor, swing, haul a counterweight, plug or movable object | Restrain, unbalance or reposition an eligible enemy; staggers, never damages | Visible valid target, rope tension, clear release; no ammunition | Swing across pit, then pull a weight while standing safely |
| Pistol | Precise near/mid-range switch, bell, or a counterweight too far to rope | Quick interrupt and exposed weak point hit; the only damaging verb | Short recovery, small clear muzzle flash, explicit reload | Ring a bell to expose a ceramic sentinel |

## Action ownership and conflicts

Tool flow: ready → aim/target → commit → effect → recover → ready. Reload is a separate interruptible state before commitment. Firing commits ammo once and emits one simulation event; animation and sound consume that event. Weapon switching queues during committed recovery and never cancels a spent shot into another free action. Hurt interrupts aiming and reload; damage/recovery priority must be covered by tests.

Lasso flow: ready → throw → attached or miss → pull/swing/hold → release → recover. Anchor metadata declares allowed verbs, attachment point and break behavior. Begin with authored anchor points and one rope segment constraint; arbitrary wrapping and simulated rope knots are deferred. The simulation owns attachment and maximum distance. The drawn rope follows that state, never determines it.

If an anchor is destroyed, a target despawns, the player changes room or a save reloads, release cleanly. An obstructed throw returns to ready; it cannot attach through walls. Pulling objects uses a bounded authored route/constraint, not unconstrained debris physics. A swing cannot clip Michael through a wall. No sticky input after pause or focus loss.

The verb set is closed at three: `pull` and `swing` (lasso, chosen by what it catches) and `precision_hit` (pistol). Cosmetic props do not secretly inherit all verbs. Tool preview and impact feedback explain invalid uses without consuming required puzzle progress. Slice rooms provide replenishment or a reset if the player wastes critical ammo.

## Required animation and VFX events

Use named markers: `tool_commit`, `muzzle_flash`, `rope_attach`, `rope_release`, `reload_commit`, `recovery_end`. Presentation markers may align effects but may not emit a second authoritative hit. See the [animation pipeline](sprite-animation-pipeline.md) for frame families and sockets.
