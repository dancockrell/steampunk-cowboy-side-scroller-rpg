# Decision and approval ledger

Updated 2026-09-09. Accepted means explicit user direction; selected means a setup decision; provisional means a design hypothesis to validate.

| ID | Status | Decision and consequence |
| --- | --- | --- |
| D01 | Accepted, revised by user | Title: Steampunk Cowboy Side Scroller RPG; repo slug `steampunk-cowboy-side-scroller-rpg`. Former working title: Michael: Temples, Goddesses, and the Dead. |
| D02 | Accepted | 2D steampunk cowboy, lasso/pistol/shotgun/rifle, temples, animate scenery, adult goddess/nymph HaremLit |
| D03 | Accepted, text available | Rich temple art, chunky hero, torchlight/deep shadow, higher-detail divine portraits/manifestations |
| D04 | Unresolved evidence | Original approved renders were not returned by the conversation reader; recover before final art admission |
| D05 | Selected, shell validated | Godot 4.4.1 stable + typed GDScript, native 2D, Compatibility renderer; F02 owns world/portrait composition |
| D06 | Provisional | 640×360 logical world, 32 px tiles, Michael in 64×96 cells; review against originals and in-engine motion |
| D07 | Provisional | Temple of the Clay Dead, 20–30 minutes, three enemy families, one patron and one intervention |
| D08 | Accepted, revised by user | Public repository, explicitly requested by owner; project rights reserved pending owner licensing decision. Supersedes initial private default. |
| D09 | Historical setup scope; expanded for art | Initial foundation included no generated art. The user's later explicit request authorizes producing many candidate sprite sheets from the written direction; gameplay implementation remains outside this task. |
| D10 | Provisional, implemented | Safe-checkpoint saves, fixed room bounds, authored lasso anchors, desktop first |
| D11 | Selected | One ToolStateMachine covers all four tools rather than a firearm version and a lasso version. The rules that matter (ammo spent once, switching queues, hurt interrupts) are identical for every tool and two copies would drift. |
| D12 | Selected | Movement, swing and tool timing are PURE solvers separate from their nodes, so the forgiveness and action-ownership rules can be asserted without a physics world. |
| D13 | Selected | Scene state is a view of the persistence books, never the reverse. A restore re-reads the books and mechanisms re-apply; nothing is inferred from how the scene was left. |
| D14 | Selected | Nodes get explicit idempotent boot()/build()/bind() entry points rather than relying on _ready, which does not fire in a headless --script run and hid two silent initialisation failures. |
| D15 | Corrected | Relationship dimensions clamp to [-5, 10], not [0, 10]. A floor equal to the starting value silently discarded every negative judgment. |
| D16 | Selected | Enum-valued authored fields are StringNames rather than engine enums, because an enum export cannot hold an unrecognised value and the "unknown rule fails validation" contract would be unenforceable. |

## Future decisions in order

F01 resolves exact reference identity, costume, palette and composition. F02 confirms world/portrait compositing on the pinned editor. F03 tunes movement and camera. F04 validates lasso behavior. Later slice playtests tune firearm cadence, encounter timing and intervention cost. Document changed decisions here and revise their owning specification in the same change.

Final art admission requires visual review; unavailable originals remain an explicit reference gap. The user has now authorized candidate sprite production despite that gap. New designs are candidates, not retroactively approved originals. No additional approval is required to generate and save candidates within that request.
