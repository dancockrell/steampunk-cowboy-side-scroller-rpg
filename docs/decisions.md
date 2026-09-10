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
| D17 | Revised | Move/jump bindings extended beyond the original "A/D, Space" proposal to also accept arrow keys and W/Up. A/D-only and Space-only excluded whichever convention a player did not happen to use first; both of the common PC schemes are now bound at once, not a swap of one for the other. |
| D18 | Revised, design direction from Dan 10 Sep 2026 | The lasso swing is a central, repeated mechanic, not a single precision check gating one gap per room. Entry Bridge rebuilt as a genuinely tall room (720px, double the fixed 360px world viewport) crossed by a chain of three swing anchors over an open chasm; Burial Works' 128px pit gap (confirmed uncrossable by jump, see gameplay-checks.md) gets two chained anchors instead of one. Lasso range/commit/recovery retuned generous and fast (320px / 110ms / 90ms, from 190px / 240ms / 180ms) so reach is never the bottleneck. Superseded the original "single anchor bridges one gap" pattern used in the first version of every room. |
| D19 | Selected | Rooms can be taller than the fixed 640x360 world viewport on purpose. Every room before this was authored at exactly WORLD_HEIGHT (360), which leaves the camera's vertical clamp permanently equal on both bounds -- zero pan, regardless of content height. A room meant to showcase verticality has to actually exceed 360px tall for the existing camera-clamp code (unchanged) to have anything to reveal. |
| D20 | Selected, design direction from Dan 10 Sep 2026 | 2.5D depth layers: rooms can hold up to three parallel planes (near/mid/far) sharing one screen and one x/y coordinate space. Crossing is a real physics-layer swap (src/world/depth.gd), not a visual trick -- a receiver on a plane the player is not standing on is genuinely untargetable, enforced in TWO places: the physics query that finds candidates, and HitReceiver.receive() itself via a depth_layer stamped on every Hit, so a direct call bypassing the normal query is refused too. NEAR reuses the original terrain/tool_target bits exactly, so every room authored before this system existed is unaffected. First application: a mid-depth alcove in Entry Bridge reachable through an archway, offering a genuine alternate route with its own reward, not just a decorative side room.

## Future decisions in order

F01 resolves exact reference identity, costume, palette and composition. F02 confirms world/portrait compositing on the pinned editor. F03 tunes movement and camera. F04 validates lasso behavior. Later slice playtests tune firearm cadence, encounter timing and intervention cost. Document changed decisions here and revise their owning specification in the same change.

Final art admission requires visual review; unavailable originals remain an explicit reference gap. The user has now authorized candidate sprite production despite that gap. New designs are candidates, not retroactively approved originals. No additional approval is required to generate and save candidates within that request.
