# Art direction

## Locked written aesthetic

Richly detailed pixel/painted 2D temples form a layered stage around chunky, readable hero sprites. Warm torchlight cuts into deep shadow. Ceramics, inscriptions, doors and graves carry the potential for movement. Adult goddesses use higher-detail portrait and manifestation art so their divine presence feels categorically distinct. Preserve beauty, sensuality, pulp adventure, ancient dignity and occasional macabre humor.

The original approved images are not present. This document is the written authority, not a claim to have inspected their exact colors or faces. Recover them through F01 before final identity or scene approval. See [source context](source-context.md).

## Scale and composition proposal

Use a 640×360 logical world to test a 16:9 side-view stage. Start with 32×32 tile modules and 64×96 Michael frame cells; the visible body is approximately 48×72 px, with a fixed foot pivot and space for hat/coat motion. Weapons and rope may use separate sockets/overlays. These are provisional production dimensions, not inferred dimensions of the approved images.

Render the pixel world with nearest filtering and integer scaling. Build high-detail portraits in a separate full-window UI layer so they do not collapse to world pixels. Manifestations occupy the world through deliberately authored silhouette and local effects; verify their detail survives compositing. No forced low-resolution filter on the portrait layer. Confirm this composition in F02 before ordering large asset batches.

Michael's silhouette must read in shadow, in front of carved masonry and during a lasso throw. Lock hat profile, face, coat/vest, boots, holster, mechanical details and lasso coil position in a reference turnaround. Do not invent exact costume features from missing images. Verify asymmetrical gear on both facings; mirrored frames must not silently swap the canonical weapon hand.

## Environment construction

Author separate layers: distant architecture, parallax chambers, primary wall, traversable tiles/collision, scenery props, emergence surfaces, breakable elements, foreground occluders, atmosphere and light. Collision is authored separately from texture silhouettes. A painted door used by an enemy must exist as a separable source asset, never only baked into a background.

Torches provide warm focal pools; cooler or neutral recesses preserve deep-space contrast. Michael, interactables and danger tells need distinct value shapes. Use dust, shafts of light and distant processions sparingly. Foreground pillars can frame the route but must not hide a jump landing or attack windup. Texture detail decreases behind small gameplay signals.

## Production anchor register

| Anchor | Purpose | Status |
| --- | --- | --- |
| Approved gameplay screen(s) | Lighting, visual density, framing and hero-to-room scale | Original files missing |
| Michael identity/turnaround | Face, costume, silhouette, facing and equipment continuity | To derive after original recovery |
| Clay temple room plate | Tile/painted-layer compatibility and source-to-monster seams | Planned |
| Three emergence triptychs | Disguise, maximum separation, resolved remains | Planned |
| Adult goddess portrait/manifestation pair | Identity consistency across two detail scales | Planned |

Reject generic tiny retro sprites, uniformly noisy backgrounds, flat even lighting, modern tactical weapons, gratuitous gore, baby-faced divine characters, and portrait identity drift. These rejection rules protect the written target; they do not authorize a replacement style.

## Visual acceptance

Review at native world scale and 2×/3× integer display, plus a full-window portrait pass. Inspect silhouettes, edge stability, animation in motion, foot contact, weapon sockets, seams during emergence, tell visibility and HUD contrast. Capture the same room before tell, at emergence peak and after resolution. Technical import success is not visual approval.
