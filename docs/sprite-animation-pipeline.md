# Sprite and animation production pipeline

Codex's principal production responsibility is sprites, art direction and game plans. Claude and Grok are expected to take much of the implementation. This pipeline supplies consistent assets and explicit integration contracts to those implementers; it does not assume a shared chat history.

## Stages and deliverables

1. **Recover and register references.** Import originals without alteration; record source, file hash, purpose, approval scope and rights status. Missing references remain missing.
2. **Lock identity and scale.** Build Michael turnaround, two side-view keys, palette swatches, equipment/socket diagram and a room-scale comparison. Confirm the proposed cell dimensions against the approved target.
3. **Plan one action family.** Draw contact, anticipation, peak and recovery poses with fixed pivot/gear continuity. Define required state and event names before animation.
4. **Produce action-sized sequences.** Generate or draw one action at a time using the same reference pack. Do not request one enormous AI sprite sheet. If using video extraction, preserve timestamps and source lineage; extracted frames still require curation and cleanup.
5. **Clean and normalize.** Remove matte contamination, fix anatomy/gear drift, align pivots and contact poses, deduplicate near-identical frames, retain intentional holds. Preserve the editable original separately.
6. **Package.** Export transparent PNG frames or lossless atlas plus metadata, palette, sockets, contact sheet and preview loop. Keep filenames and frame order deterministic.
7. **Inspect in motion and in context.** Review native-size loops, both facings, tool sockets, dark/light backdrops and a temple composite. Check frame timing in-engine before admitting runtime assets.
8. **Admit or reject.** Record status, reviewer, date, evidence and remaining exceptions in the asset register. Keep rejected work labeled and outside runtime assets. Export readiness and aesthetic approval are separate fields.

## Michael action inventory

Counts are initial budgets for handoff, not approved frame mandates. Tune after a movement and scale study. Full-body frame variants are preferred initially; separate weapon overlays only when they preserve silhouette and production simplicity.

| Family | Clips | Initial unique-frame budget | Priority |
| --- | --- | --- | --- |
| Movement | idle, run, jump_rise, jump_apex, fall, land | 4, 8, 2, 1, 2, 3 | Slice first |
| Interaction | interact, pull, hurt, defeat | 4, 6, 3, 6 | Slice first |
| Lasso | throw, attached_hold, pull, swing, release, miss_recover | 6, 2, 6, 4, 3, 3 | Highest tool attention |
| Pistol | aim, fire, recover, reload | 1, 3, 2, 5 | Slice |
| Shotgun | aim, fire_recoil, recover, reload | 1, 5, 3, 6 | Slice |
| Rifle | aim, fire, recover, reload | 2, 3, 3, 6 | Slice |
| Expanded movement | walk, crouch, climb, hang, contextual carry | Budget after level need is demonstrated | Deferred unless slice requires |

Timing proposal: 8–12 fps ambient loops, 12–18 fps expressive actions with individually authored holds; gameplay simulation is independent. Fire frames may be held briefly without extending hit windows. Avoid interpolation that changes a pixel silhouette. Reuse sound recovery poses where motion remains intentional.

## Enemy and goddess packages

Each of three enemy families needs: disguise prop, tell loop, awakening, emergence, locomotion, attack anticipation/commit/recovery, stagger, resolved remains. Specify entry and exit poses so a prop transforms seamlessly into an actor. These transitions deserve more investment than additional attack varieties.

One goddess package: approved identity sheet; neutral, amused, displeased and earnest portrait expressions; manifestation arrival, idle and departure; one intervention gesture. Use adult identity consistently in all views. High-detail portraits may be painted raster art; do not apply Michael's pixel constraints blindly. Large effects must leave Michael and hazards readable.

## File and metadata contract

File convention: `entity_action_facing_vNNN_000.png` with zero-based, padded frame indices. Atlas packing is a later deterministic export step; retain source frames. Transparent padding must protect weapon/coat extremities. Each clip specifies entity ID, action, facing, cell size, pivot, frame durations, loop flag, sockets and event markers. See [data contracts](data-contracts.md).

Every delivered pack includes an integration note naming expected states, unresolved assumptions, known frame defects, exact import/filter settings and evidence paths. Codex reviews asset consistency; Claude/Grok report engine timing and collision mismatches using concrete frames. Implementers must not silently stretch, regenerate or recolor admitted assets to hide an interface mismatch.

## Review checklist

- [ ] Original-reference purpose and lineage present; identity approval distinguished from technical pass.
- [ ] Constant cell/pivot, frame order and transparent edges; no cropped gun barrel or hat.
- [ ] Feet do not skate; gear/handedness and facial identity remain stable.
- [ ] Tell and attack key poses readable without sound or color cues alone.
- [ ] Native-size loop and in-room composition inspected; approved evidence attached.
- [ ] Runtime folder contains only admitted exports; source and rejected work preserved separately.
