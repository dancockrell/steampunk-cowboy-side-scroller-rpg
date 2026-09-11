# Sprite generation prompt pack

Status: **prompts only. No image in this pack has been generated.** Everything produced from these prompts is a
candidate for review under [asset-handoff.md](../asset-handoff.md), not an admitted runtime asset. F01 reference
recovery is still an open prerequisite: the original approved images have never been inspected
([source context](../../source-context.md)), so identity here rests on the written aesthetic and on the provisional
identity established by [batch 001](../../../art-source/candidates/batch-001/README.md). Nothing in this pack approves
an identity, a palette, a face or a frame count.

This pack does not create a second art direction. It reuses the identity paragraphs already recorded in
[generation-records.json](../../../art-source/candidates/batch-001/generation-records.json) verbatim, and it exists to
make the five defects that batch actually recorded structurally impossible to repeat.

## What batch 001 measured, and what changed here

| Recorded defect | Fix carried in every prompt below |
| --- | --- |
| Requested transparency returned opaque brown; delivered magenta is not exactly `#FF00FF` per pixel | Transparency is never requested. One flat solid magenta is mandated, the subject is forbidden to contain near-magenta, and the extraction tolerance is stated below as a number with a measured-verification step |
| Weapons, ropes, spears and gestures crossed nominal cell boundaries, so sheets could not be grid-sliced | Fixed 64 px clear margin inside every cell edge, an explicit "draw the object smaller, never enlarge the cell and never resize the figure" instruction, and a separate rope overlay sheet for the case where the loop legitimately exceeds the cell |
| VFX sheet came back 1254x1254 instead of 1024 and was not divisible into equal cells | Exact pixel dimensions plus the division arithmetic written into the prompt text, and a hard acceptance gate on the delivered dimensions |
| Nominal 4x2 layouts were composition requests, not trustworthy atlas bounds | No sheet in this pack exceeds 6 cells. Most are 1, 2, 3 or 4 cells |
| Handedness unresolved; asymmetric gear must not be silently mirrored | Every action family has its own left-facing continuity key prompt. No prompt anywhere says "mirror it" |

Measured basis for the canvas choice: of the 23 sheets in batch 001, the 22 that requested 1536x1024 were delivered at
1536x1024, and the single sheet that requested 1024x1024 was delivered at 1254x1254. 1536x1024 is the canvas with a
track record here, so the larger layouts in this pack are built on it. That is a record of what happened 22 times, not a
guarantee about any provider.

## How to use the pack

1. Pick the prompt for the one clip you need. Do not batch several families into one generation. The pipeline is
   explicit that one enormous sheet is the wrong unit of work.
2. Paste the fenced block exactly as written. Each block is self-contained: it repeats the identity, geometry,
   background and negatives so nothing depends on the surrounding document.
3. Where a prompt says to supply a reference image, supply the named earlier export. Where it does not, do not add one.
4. Record provider, model, version, settings and the actual delivered dimensions in the batch's generation record.
   Never invent provider metadata.
5. Run the acceptance checklist below before slicing. A sheet that fails any gate is not sliced; it is regenerated or
   recorded as rejected.
6. Slice, extract, export per-frame PNGs under the naming convention, then follow the review record template in
   [asset-handoff.md](../asset-handoff.md).

## Naming

Frame exports follow the convention in [data-contracts.md](../../data-contracts.md):
`entity_action_facing_vNNN_000.png`, zero-based padded frame index.

Sheets are generation containers, not clips. A sheet is named
`entity_action_facing_vNNN.png`, or `entity_action_facing_vNNN_partX.png` when one action family needs more than one
sheet. Clip boundaries do not have to follow sheet boundaries: several prompts below deliberately put the tail of one
clip and the head of the next on one sheet, because scale consistency inside a single generation is worth more than
tidy grouping. Each prompt states its cell-to-export mapping explicitly.

Version numbers continue the series already used in batch 001 rather than restarting. Sheet ids that already exist
there (`michael_run_right`, `michael_lasso_right`, `ceramic_sentinel_emergence` and so on) start at the next free
number in this pack; new ids start at `v001`. The per-prompt headings carry the resolved filename, so no version needs
to be worked out by hand.

## Shared blocks

These are quoted verbatim inside every relevant prompt. They are the anti-drift device. If one of them is wrong, change
it here and regenerate the prompts that carry it. Do not rewrite a character description in fresh words in a single
prompt.

**Style block** (verbatim from `michael_run_right_v001`):

> Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

**Michael identity block** (verbatim from `michael_run_right_v001`):

> Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat with brass goggles pushed up on the band, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt.

**Keeper identity block** (verbatim from `keeper_portrait_expressions_v001`):

> She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

**Ceramic sentinel identity block** (verbatim from `ceramic_sentinel_emergence_v001` and `ceramic_sentinel_combat_v001`):

> Same jar decoration in ALL stages: aged terracotta, turquoise geometric bands, stylized cream funerary face, bronze rim. The fully emerged ceramic sentinel: same bone skull, terracotta armor with teal geometric bands and cream mask motifs, huge clay fists.

**Painted procession guard identity block** (verbatim from `mural_guard_emergence_v001` and `mural_guard_combat_right_v001`):

> Ochre/red/teal pigment, bronze details, dignified skull-like funerary mask. Identity of the fully emerged guard: gold funerary skull mask, red feather crest, teal/gold ceremonial tunic and spear.

**Burial-pit assembler identity block** (verbatim from `pit_assembler_emergence_v001` and `pit_crawler_combat_right_v001`):

> Bone ivory, ancient bronze grave bracelets and scraps of muted teal funerary cloth. Identity: ivory skull/ribcage, two powerful bone arms, bronze bracelets and torn teal funerary cloth. The creature has NO LEGS, just torso and two arms.

**Camera block:**

> Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

**Background block:**

> Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through any rope loop. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

**Negatives block:**

> No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.

## Cell geometry

Every character cell in this pack is 512 px tall. The foot line sits 400 px below the top of its cell in every layout,
so a frame lifted from a 3-cell strip registers against a frame lifted from a 6-cell sheet without rescaling.

| Code | Sheet px | Grid | Cell px | Arithmetic written into the prompt |
| --- | --- | --- | --- | --- |
| S1 | 512 x 512 | 1 col x 1 row | 512 x 512 | 512 / 1 = 512 wide, 512 / 1 = 512 tall |
| S2 | 1024 x 512 | 2 x 1 | 512 x 512 | 1024 / 2 = 512, 512 / 1 = 512 |
| S3 | 1536 x 512 | 3 x 1 | 512 x 512 | 1536 / 3 = 512, 512 / 1 = 512 |
| S4 | 1024 x 1024 | 2 x 2 | 512 x 512 | 1024 / 2 = 512, 1024 / 2 = 512 |
| S6 | 1536 x 1024 | 3 x 2 | 512 x 512 | 1536 / 3 = 512, 1024 / 2 = 512 |
| W4 | 1536 x 1024 | 2 x 2 | 768 x 512 | 1536 / 2 = 768, 1024 / 2 = 512 |
| W6 | 1536 x 1536 | 2 x 3 | 768 x 512 | 1536 / 2 = 768, 1536 / 3 = 512 |
| P | 1024 x 1536 | single image | n/a | portrait master, no grid |
| E | 1280 x 720 | single image | n/a | 2x of the 640x360 world view |
| T | 768 x 512 | 3 x 2 | 256 x 256 | 768 / 3 = 256, 512 / 2 = 256 |
| V | 512 x 512 | 2 x 2 | 256 x 256 | 512 / 2 = 256, 512 / 2 = 256 |

Wide cells (768 px) are used whenever the widest element of any frame in the family exceeds 384 px, which is the usable
width of a 512 px cell after the 64 px margins. Rifles, shotguns held level, spears, hauling poses and reclined bodies
all take wide cells. Narrow cells are used for everything else.

## Scale

Character, creature, prop, icon and effect art is authored at **4 source pixels per world pixel** and downsampled 4:1
at export. That gives clean integer downsampling and matches the pipeline's instruction to draw large for controlled
reduction.

Two deliberate exceptions, both explained where they are used. Room plates in [environment.md](environment.md) are
authored at **2x**, because a 640 x 360 world view at 4x would be 2560 x 1440 and a background plate does not need a
sprite's reduction headroom. The 32 px tile modules and the HUD icons are authored at **8x**, because those subjects
are small enough that 4x leaves no detail to work with. World dimensions are the authority in every case; the scale
factor is only how a given file is drawn.

| Subject | World size | Source size at 4x | Status |
| --- | --- | --- | --- |
| Michael, boot sole to hat crown, standing | 72 px | 288 px | From [art-direction.md](../../art-direction.md): visible body approximately 48x72 |
| Michael, shoulder width envelope | 48 px | 192 px | Same source |
| Tile module | 32 px | 128 px (authored at 256 for detail headroom) | From art-direction.md |
| Ceramic sentinel, standing | 76 px | 304 px | **Proposed, unconfirmed.** No document sets it |
| Funerary jar, C0 | 40 x 34 px | 160 x 136 px | **Proposed, unconfirmed** |
| Painted guard, standing | 70 px | 280 px | **Proposed, unconfirmed** |
| Painted guard's spear | 80 px | 320 px | **Proposed, unconfirmed** |
| Mural panel substrate, M0 | 80 x 52 px | 320 x 208 px | **Proposed, unconfirmed** |
| Burial crawler, at rest | 40 px tall, 64 px long | 160 x 256 px | **Proposed, unconfirmed** |
| Pit mouth, B0 | 64 px wide, 6 px of rim above the ground line and 10 px of opening below it | 256 px wide, spanning 376 to 440 px in a cell | **Proposed, unconfirmed** |
| Keeper manifestation, standing | 76 px | 304 px | **Proposed, unconfirmed** |

The rows marked proposed are choices made here to keep the prompts self-contained. No repository document states an
enemy or goddess height. A reviewer must confirm them against the F02 room composition before a second batch is
ordered, and they are listed again under open gaps at the foot of this file.

Export windowing, for the slicing step rather than for the generator: Michael's logical export cell is 64x96 with the
foot origin at `(32,88)` per [michael-pose-brief.md](../michael-pose-brief.md). At 4x, the export window inside a source
cell is 256 px wide by 384 px tall, positioned so its bottom edge is 32 px below the foot line and its horizontal centre
is the cell's horizontal centre. Downsample that window 4:1 to reach 64x96 with the foot origin at `(32,88)`. Do not
re-centre a frame on its visible pixels; the foot origin is the alignment reference even when Michael is airborne.

## Background and extraction rule

The generator is told to deliver flat magenta. The extraction step is told how to remove it, and how to prove it did.

```
key colour            RGB (255, 0, 255)
transparent band      Euclidean RGB distance <= 40 from the key  -> alpha 0
fringe band           distance > 40 and <= 90                    -> keep opaque, apply despill:
                                                                    clamp red and blue to at most green + 40
subject               distance > 90                              -> untouched
```

Before keying, measure rather than assume. Sample the four 32x32 corner regions of the delivered sheet and record min,
max, mean and standard deviation per channel. Reject the sheet without keying if the mean is more than 40 from
`(255, 0, 255)` in any channel, or if any channel's standard deviation exceeds 12: that is a shaded or textured
background, which is what batch 001 got back when it asked for transparency, and keying it produces a plausible-looking
ruin rather than an error.

The thresholds 40, 90 and 12 are proposed starting values. They were chosen because batch 001 recorded that the
delivered magenta is not exactly `#FF00FF` at every pixel; they have **not** been measured against a delivered sheet
from this pack, because no sheet from this pack exists. The extraction step must record the measured corner statistics
next to whichever thresholds it actually used, so the next reader can re-derive the decision instead of inheriting a
number.

**Four files in this pack are not keyed at all, and running the keyer over them would produce a file that looks fine in
a viewer and composites as garbage.** Full-bleed opaque plates have nothing to key, and two additive lighting layers use
a pure black background because a soft glow has no hard edge to key against and black adds nothing under additive
blending. The convention belongs in each file's generation record, not in anyone's memory:

| File | Convention |
| --- | --- |
| `room_distant_chamber_v001`, `room_main_wall_v001`, `temple_tiles_ground_v001`, the three `plate_gallery_*` plates | Full-bleed opaque, no key, no magenta anywhere |
| `room_light_atmosphere_v001`, `vfx_torch_glow_v001` | Pure black background, composited additively, never keyed |
| Everything else in the pack | Flat magenta, keyed as above |

Two counting checks, because a keyer that removed nothing and a keyer that never ran produce identical clean logs:

- Report the transparent pixel count per sheet. A count of zero is a failure, not a pass.
- Run a positive control on a pixel known to be subject, for example the centre of the ivory shirt or the cream mask
  motif, and confirm it survived. Report the coordinate sampled. If the control was not sampled, the run reports
  `not checked`, never `passed`.
- Report the count of subject pixels that fell inside the transparent band. A non-zero count fails the sheet: the
  costume has picked up the key colour and holes will appear inside the character.

## Per-sheet acceptance checklist

Run all of it before slicing. Each line records a number, not a verdict, so a broken check cannot read as a pass.

1. **Delivered dimensions equal the requested dimensions exactly.** Record the actual width and height. If they differ,
   do not slice. Regenerate, or rescale to the exact requested size with nearest-neighbour and record that a rescale
   happened and why. A delivered image at the right aspect ratio but the wrong size is the 1254x1254 defect.
2. **Grid divides evenly.** `width % columns == 0` and `height % rows == 0`. Record both remainders.
3. **Background flatness.** Corner statistics recorded per the rule above; flatness gate passed or the sheet rejected.
4. **Key contamination.** Count of subject pixels inside the transparent band, which must be zero.
5. **Cell containment.** For every cell, compute the bounding box of non-background pixels and record it. Every box
   must sit at least 64 px inside every cell edge. Any box touching a boundary fails the sheet; do not fix it by
   widening the slice.
6. **Foot line.** For every standing cell, the lowest boot pixel is within 4 px of 400 px below that cell's top edge.
   Record the measured offset per cell.
7. **Figure scale.** Boot sole to hat crown within 6 px of the size stated in the prompt. Record the measured height
   per cell. This is the check that catches a sheet where the figure was shrunk to fit a prop.
8. **Cell count and distinctness.** The number of occupied cells equals the number of frames the prompt asked for, and
   no two cells are near-identical. Record a pairwise difference figure, not an impression.
9. **Identity.** Walk the identity block item by item against every cell. Michael's block names twelve items; record
   twelve results per cell, including the ones that passed. An identity check that only lists failures cannot be
   distinguished from one that ran on nothing.
10. **Facing.** Every cell faces the direction the prompt asked for. Record the count of cells facing each way. The
    `michael_run_left_v001` defect was four cells facing the wrong way on an otherwise correct sheet.
11. **Handedness.** For a left-facing sheet, confirm the brass forearm bracer, holster and lasso coil are on the
    anatomically correct side rather than mirrored. Record which side each is on. This is a comparison against the
    right-facing sheet, not a judgement call from the left-facing sheet alone.
12. **Transparent pixel count and positive control** per the extraction rule above.

A sheet that passes all twelve is a reviewed candidate. It is still not an admitted asset; admission needs the
native-scale motion review and the room-composite review in [art-direction.md](../../art-direction.md).

## Prompt index

77 prompts across ten files.

| File | Prompts | Covers |
| --- | --- | --- |
| [michael-movement.md](michael-movement.md) | 6 | idle, run right keys and inbetweens, run left continuity keys, jump rise, apex, fall, land |
| [michael-lasso.md](michael-lasso.md) | 8 | throw, attached_hold, pull, swing, release, miss_recover, the separate rope overlay sheet, left continuity keys |
| [michael-firearms.md](michael-firearms.md) | 9 | pistol, shotgun and rifle aim, fire, recover and reload, plus a left-facing firearm continuity sheet |
| [michael-interaction.md](michael-interaction.md) | 5 | interact, pull, hurt, defeat, left continuity keys |
| [enemy-ceramic.md](enemy-ceramic.md) | 6 | jar source export, C0 to C5 emergence, tell loop, walk, combat, left continuity keys |
| [enemy-mural.md](enemy-mural.md) | 6 | panel source export, M0 to M5 emergence, tell loop, walk, combat, left continuity keys |
| [enemy-pit.md](enemy-pit.md) | 6 | pit source export, B0 to B5 emergence, tell loop, crawl, combat, left continuity keys |
| [keeper.md](keeper.md) | 8 | four portrait expressions at fixed camera, manifestation arrival, idle and departure, Recall to Clay intervention |
| [environment.md](environment.md) | 11 | Gallery of Vessels layer plates, 32 px tile modules, torch loop, three camera-matched review plates |
| [ui-and-vfx.md](ui-and-vfx.md) | 12 | HUD health, ammo and four tool icons, dialogue frame, three muzzle flashes, rope, impacts, dust, torch glow |

## Open specification gaps

These need a human decision. None of them is resolved by anything in the repository, and none has been guessed at
silently inside a prompt.

1. **The goggles.** The identity block quoted above, from `michael_run_right_v001`, does not mention goggles. Eighteen
   later prompts in the same batch say "brown hat with brass goggles". Both descriptions produced sheets that are now
   candidates. This pack uses the identity block verbatim, which means it does not request goggles, and every prompt
   carries an explicit line forbidding gear not named in the block. If goggles are canonical, the identity block must be
   amended in batch 001's record and in this file, in one edit, before any sheet is generated. Check:
   `grep -c goggles art-source/candidates/batch-001/generation-records.json`.
2. **Enemy and Keeper world heights.** The nine rows marked proposed in the scale table are choices made here so the
   prompts could be self-contained. No document states them. They need confirming against the F02 room composition.
3. **Handedness.** Still unresolved, exactly as [michael-pose-brief.md](../michael-pose-brief.md) says. This pack
   commissions left-facing keys so the question can be answered from evidence; it does not answer it, and no prompt
   here permits a mirror.
4. **HUD content.** No document specifies what the health readout counts, how many ammunition pips each firearm shows,
   or the dialogue frame's dimensions in the 640x360 world view. The prompts in
   [ui-and-vfx.md](ui-and-vfx.md) state the assumptions they make inline, at the point of use.
5. **One frame budget change.** `pistol_reload` is commissioned at six frames where
   [sprite-animation-pipeline.md](../../sprite-animation-pipeline.md) budgets five, because five does not tile onto any
   sheet in the geometry table and splitting one clip across two generations risks scale drift between them. The sixth
   frame is the return to the ready position and it is specified concretely in the prompt. The pipeline calls those
   counts initial budgets rather than mandates, so this is a change made in the open rather than a violation, but it is
   a change and a reviewer may cut the frame. Every other clip in the pack matches its budget exactly. The torch loop
   is commissioned at six frames against batch 001's eight; the pipeline sets no budget for it, and six at the stated
   8 to 12 fps ambient rate is a 500 to 750 ms loop.
6. **F01.** Reference recovery has not happened. Everything here is derived from written direction plus batch 001's
   provisional identity. If the originals are recovered, the identity blocks are the single place that has to change.
