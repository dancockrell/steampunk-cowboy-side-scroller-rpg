# Gallery of Vessels: environment prompts

Eleven prompts implementing the layer table in [first-room-staging.md](../first-room-staging.md), plus the 32 px tile
modules from [art-direction.md](../../art-direction.md), the torch loop, and the three camera-matched review plates.
Read [README.md](README.md) first.

This is one calibration room, not a new level. It exists to test Michael, the lasso, jar emergence and ornate temple
readability together.

## Two geometries on this page, and why

Character sheets in this pack are authored at 4 source pixels per world pixel. Room plates are authored at **2 source
pixels per world pixel**: 1280 x 720 for a 640 x 360 world view, downsampled 2:1 at export. A plate at 4x would be
2560 x 1440, which is past what most generators reliably deliver, and a background plate does not need the same
reduction headroom a sprite does. World dimensions are the authority in both cases; the scale factor is just how each
one is drawn.

The tile module sheet is authored at 8x, because a 32 px tile drawn at 2x is 64 px and there is no detail in that.

## The background rule is different here, and that is deliberate

Full-bleed plates fill every pixel and have nothing to key, so they are **not** drawn on magenta: painting a magenta
region into a plate that is supposed to be opaque only invites the extraction step to punch a hole in it. Plates with
holes in them, and every prop, still use the magenta rule from [README.md](README.md). The light and atmosphere overlay
uses pure black because it is composited additively, where magenta would be meaningless.

Each prompt states which rule it uses. Record it in the generation record too, because "which background convention did
this file use" is exactly the question that gets lost.

| Prompt | Background convention |
| --- | --- |
| 1 distant chamber | Full-bleed opaque, no magenta |
| 2 main wall | Full-bleed opaque, no magenta |
| 3 tile modules | Full-bleed opaque per cell, no magenta |
| 4 anchor and counterweight | Magenta key |
| 5 sacred urn | Magenta key |
| 6 foreground occluder | Magenta key |
| 7 light and atmosphere | Pure black, additive |
| 8 torch loop | Magenta key |
| 9, 10, 11 review plates | Full-bleed opaque, no magenta |

## What is not commissioned here, on purpose

The jar source, the mural panel and the burial pit are **not** drawn on any plate in this file. They are exported once
by [enemy-ceramic.md](enemy-ceramic.md), [enemy-mural.md](enemy-mural.md) and [enemy-pit.md](enemy-pit.md) and
composited into the room from those single exports. The plates below reserve space for them at stated coordinates. One
object, one owner. A jar painted into the wall plate and a jar sprite in front of it are two things that will drift.

## Reserved positions in the 640 x 360 world view

These coordinates are used by prompts 2, 6, 9, 10 and 11, and they are choices made here so the plates and the sprites
can be composited without a second round of guessing. A reviewer should confirm them against the first playable layout;
they are not in any repository document.

| Element | World position, x from left and y for the ground line | Source position on a 1280 x 720 plate |
| --- | --- | --- |
| Floor band top surface | y = 296 across the full width | y = 592 |
| Jar source, C0, base centre | x = 232 | x = 464 |
| Mural panel base centre | x = 470 | x = 940 |
| Burial pit centre | x = 552 | x = 1104 |
| Lasso anchor ring centre | x = 396, y = 176 | x = 792, y = 352 |
| Counterweight, hanging, centre | x = 300, y = 150 | x = 600, y = 300 |
| Sacred urn base centre | x = 128 | x = 256 |
| Michael's starting stand | x = 72 | x = 144 |

---

## 1. room_distant_chamber_v001.png

Layout E: 1280 x 720, single full-bleed plate. The furthest parallax layer.

It has to tile horizontally, because parallax needs more width than the camera. Making it seamless is cheaper and more
reliable than asking a generator for an oversized overscan canvas.

Export: `room_distant_chamber_v001.png`, downsampled 2:1 to 640 x 360 for the runtime.

```
Produce one 2D game background plate image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

This is a single full-bleed background plate. There is no cell grid. Every pixel of the image is painted; no part of it is left empty.

Style: richly detailed painted pixel-art background for a side-view temple platformer. Warm restrained painterly material shading, ancient temple materials in ochre, bronze, teal and ivory, warm torchlight cutting into deep shadow. Broad quiet value shapes rather than fine noise: this is the furthest layer and it must never compete with the gameplay foreground.

Camera: Fixed orthographic side view at eye level, straight on. No perspective vanishing point, no tilt, no lens effects.

Subject: the deep interior of an ancient temple chamber seen far behind the play space. A row of massive square stone pillars receding into darkness, a high ceiling lost in shadow above, a distant arched opening near the centre with a faint cool light behind it, and the suggestion of a carved procession band running along the upper wall. Everything is dim, cool and low in contrast, as though several rooms away.

Value discipline: keep the whole plate in the darker half of the value range with no bright highlights. Nothing on this plate may be as light or as saturated as a torch pool or a character will be. Contrast within the plate stays low and detail decreases toward the top of the image.

Seamless tiling: the left edge and the right edge must join perfectly. A feature crossing the right edge continues at the same height and in the same colours at the left edge. Do not place a strong feature such as the arched opening against either edge.

Do not draw any floor, ledge, platform, walkable surface, jar, urn, panel, mural, burial pit, rope, anchor, counterweight, torch, character, creature or foreground pillar. This layer carries no collision and no gameplay target.

Background convention for this prompt: this plate is fully opaque and is NOT keyed. Do NOT use magenta anywhere. Do not use transparency or an alpha channel. Paint every pixel.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, grid lines, arrows, rulers, montage, collage, characters, creatures, user interface elements or motion blur.
```

---

## 2. room_main_wall_v001.png

Layout E: 1280 x 720, single full-bleed plate. The primary painted wall behind the play space.

The critical requirement is reserved source space. The mural panel and the door-like surfaces an enemy uses must remain
separable, so the wall leaves plain areas where those sprites composite in. A mural painted into this plate would be a
second copy of a thing that already has an owner.

Export: `room_main_wall_v001.png`, downsampled 2:1 to 640 x 360 for the runtime.

```
Produce one 2D game background plate image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

This is a single full-bleed background plate. There is no cell grid. Every pixel of the image is painted; no part of it is left empty.

Style: richly detailed painted pixel-art background for a side-view temple platformer. Warm restrained painterly material shading, ancient temple materials in ochre, bronze, teal and ivory, warm torchlight cutting into deep shadow, ornate ancient dignity.

Camera: Fixed orthographic side view at eye level, straight on. No perspective vanishing point, no tilt, no lens effects.

Subject: the primary wall of an ancient funerary gallery, seen straight on. Large dressed stone masonry with carved horizontal banding, worn ochre and teal pigment in the recesses, bronze fittings, and a few shallow empty niches. This is the surface a player sees directly behind the hero, so it uses broader and quieter value shapes than the ornate detail elsewhere in the room.

Reserved areas, and these are the most important instruction on this plate. Three rectangles must be left as plain undecorated dressed masonry with no carving, no pigment, no niche, no fitting and no strong value change, because separate sprites are composited into them later:
- a rectangle 224 px wide and 400 px tall whose base sits at y = 592 and whose horizontal centre is at x = 940;
- a rectangle 300 px wide and 200 px tall whose base sits at y = 592 and whose horizontal centre is at x = 464;
- a rectangle 300 px wide and 100 px tall whose base sits at y = 592 and whose horizontal centre is at x = 1104.
Do not draw a mural, a painted figure, a procession band, a panel, a door, a jar, an urn, a burial pit or an opening inside or overlapping any of those three rectangles.

A horizontal line at y = 592 marks where the floor surface will be. Below that line the wall may darken into shadow, but do not draw a floor, ledge, platform or walkable surface: those are separate tile art.

Do not draw any character, creature, torch, flame, rope, anchor, counterweight, prop or user interface element.

Value discipline: this plate sits behind the hero, so keep it in the middle and lower part of the value range with no highlight as bright as a torch pool. Texture detail decreases in the reserved areas and around where gameplay signals will sit.

Background convention for this prompt: this plate is fully opaque and is NOT keyed. Do NOT use magenta anywhere. Do not use transparency or an alpha channel. Paint every pixel.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, grid lines, arrows, rulers, montage, collage, characters, creatures, user interface elements or motion blur.
```

---

## 3. temple_tiles_ground_v001.png

Layout T: 768 x 512, 3 columns x 2 rows, cell 256 x 256. Six tile modules, each a 32 x 32 world tile at 8x.

Collision is authored separately from these silhouettes. A tile that looks solid is not thereby solid.

Exports: cells 1 to 6 to `temple_tile_v001_000.png` through `_005.png`, each downsampled 8:1 to 32 x 32.

```
Produce one 2D game tile sheet image, exactly 768 x 512 pixels. If you cannot output exactly 768 x 512 pixels, output nothing.

Divide the image into exactly 3 columns by 2 rows of equal cells: 768 / 3 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one tile per cell, 6 cells in total, read left to right along the top row then the bottom row.

Style: richly detailed painted pixel-art temple stonework. Warm restrained painterly material shading, ancient stone in ochre and warm grey with worn teal pigment in the carved recesses and occasional bronze inlay. Chunky readable forms, crisp pixel clusters, deep shadow in the joints.

Camera: Fixed orthographic side view at eye level, straight on. No perspective, no tilt, no lens effects.

Every cell is painted edge to edge with stone. There is no empty space in any cell and no background shows through anywhere.

Tiling requirement, and it is what makes these usable: each tile must join seamlessly to a copy of itself placed to its left and to its right, and to the other tiles in the set placed above and below where the descriptions say so. A carved band, a mortar joint or a stone edge crossing the right edge of a cell continues at exactly the same height and in the same colours at the left edge of that same cell.

Tiles, one per cell in reading order:
1 floor surface. The top of a walkable stone floor: a worn flat upper band about 48 px deep with a crisp top edge, the block face below it carved with a shallow horizontal groove, mortar joints at the left and right edges that align with copies of itself.
2 floor interior. Solid stone block with mortar joints, no top edge, meant to sit underneath tile 1 and to repeat downward and sideways without a visible top surface anywhere.
3 ledge cap. A narrower stone shelf: the same worn flat top band as tile 1, but the block below it steps back on the lower half so the tile reads as an overhanging edge. Tiles seamlessly sideways with itself.
4 wall fill. Plain dressed masonry for a vertical surface: regular blocks, mortar joints on all four edges aligned so it repeats in every direction, no top surface and no walkable edge.
5 wall trim. A decorated horizontal band for the top of a wall run: a carved repeating geometric motif in worn teal pigment on ochre stone across the full width, with plain stone above and below it, tiling seamlessly sideways.
6 damaged floor. The same worn flat top band as tile 1 but with the surface cracked and one corner chipped away, dust caught in the crack. It must still join seamlessly sideways with tile 1 and with itself, so the top edge stays at the same height across the whole width.

Do not draw any character, creature, prop, jar, urn, torch, rope, plant, bone, coin or user interface element in any cell.

Background convention for this prompt: every cell is fully opaque and is NOT keyed. Do NOT use magenta anywhere. Do not use transparency or an alpha channel.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, grid lines drawn as art, arrows, rulers, montage, collage, characters, creatures or motion blur.
```

---

## 4. prop_lasso_anchor_counterweight_v001.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two props at 4x.

Batch 001 recorded that the counterweight's rope exited the top edge of its cell and that the intended attachment had to
be authored. That is fixed by giving the rope stub an exact endpoint inside the cell, which also gives the runtime a
defined attachment marker instead of a rope that goes nowhere.

These two props must read as different silhouettes from ordinary decoration, because the room's whole job is to teach a
player which things the lasso can act on.

Exports: cell 1 to `prop_lasso_anchor_v001_000.png`, cell 2 to `prop_counterweight_v001_000.png`.

```
Produce one 2D game prop sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one prop per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, ornate ancient temple materials in ochre, bronze, teal and ivory, warm highlights and deep object shadows.

Camera: Fixed orthographic side view at eye level, straight on. No perspective, no tilt, no lens effects.

Both props must be immediately distinguishable in silhouette from ordinary wall decoration. A player has to be able to tell at a glance that these are things the lasso can act on, so give each a strong simple outline rather than ornate fussiness.

Props, one per cell in reading order:
1 lasso anchor. A heavy bronze ring, 96 px across the outside and 20 px thick, mounted on a carved stone bracket that projects to the left. The bracket's flat mounting face is on the left side of the ring assembly, and the whole prop is 200 px wide and 140 px tall, centred in its cell. The ring hangs clear of the bracket with open background visible all the way through its middle. No rope, no lasso and nothing attached to it.
2 suspended counterweight. A decorated stone block 180 px wide and 220 px tall with a bronze rim and worn teal geometric banding, with a bronze eye bolt on its top face. A short length of pale hemp rope, 20 px thick, rises from that eye and ENDS at a point exactly 256 px from the left edge of the cell and 96 px from the top of the cell. The rope's cut end is drawn cleanly at that point. The rope must not reach, touch or cross the top edge of the cell, and nothing is drawn above that endpoint. The block hangs below with open background all around it.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop a prop, and never lengthen the rope past its stated endpoint.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not a prop, including the whole area inside the bronze ring and all around the hanging block. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the props: no prop pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, extra props or motion blur.
```

---

## 5. prop_sacred_urn_v001.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two states of one prop at 4x.

The sacred urn must be clearly different from the enemy jar while belonging to the same culture. That distinction is a
fairness requirement: destroying it must be a readable choice, not hidden punishment, and a player who cannot tell it
apart from a monster jar has been set up to fail.

Supply `ceramic_jar_source_v001.png` as the reference image, and ask for difference rather than similarity.

Exports: cell 1 to `prop_sacred_urn_v001_000.png`, cell 2 to `prop_sacred_urn_broken_v001_000.png`.

```
Produce one 2D game prop sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

The attached image is the ENEMY burial jar. Use it only to establish the shared culture, the material vocabulary and the drawing style. The urn on this sheet must belong to the same civilisation and must NOT look like that jar. Deliberately differentiate the silhouette, the proportions and the decoration so a player can tell them apart instantly and at a glance across a room.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one prop per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, ornate ancient temple materials in ochre, bronze, teal and ivory, warm highlights and deep object shadows.

Camera: Fixed orthographic side view at eye level, straight on. No perspective, no tilt, no lens effects.

Subject: a sacred funerary urn, tall and narrow where the enemy jar is squat and wide, with a long neck, a flared bronze lip, two small handles at the shoulder, and cream and pale ivory decoration with fine vertical teal lines rather than the enemy jar's broad horizontal bands and large cream face. It reads as venerated and cared for: intact glaze, clean surfaces, no chips.

Scale and registration: in cell 1 the urn is exactly 200 px tall and about 100 px wide, its base resting on a horizontal foot line 400 px below the top of its cell, centred horizontally in its cell.

Props, one per cell in reading order:
1 intact. The urn whole and upright on the foot line, undamaged and dignified.
2 broken. The same urn destroyed. Its base still stands on the foot line at the same position, cracked and open, with the neck and shoulder in six or seven large clearly readable fragments lying around it on the foot line, the decoration still identifiable on the pieces. The same cream, ivory and teal decoration and the same bronze lip appear among the fragments. Dry and still, no dust cloud, no glow, no ash, no contents spilling.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the spread of fragments does not fit, draw them closer together within the cell. Never enlarge a cell and never crop a fragment.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not a prop, including the gaps between fragments and through the handles. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the props: no prop pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, extra props or motion blur.
```

---

## 6. room_foreground_occluder_v001.png

Layout E: 1280 x 720, single plate with magenta key. The foreground pillar and floor lip that frame the route.

The staging brief is explicit that a foreground pillar can frame the route but must not conceal a tell or a jump
landing. The reserved coordinates above are what makes that checkable rather than a hope: this prompt names the columns
the pillar may not occupy.

Export: `room_foreground_occluder_v001.png`, downsampled 2:1 to 640 x 360.

```
Produce one 2D game foreground layer image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

This is a single foreground overlay layer, not a full background. Most of the image is empty background colour; only the foreground elements are painted.

Style: richly detailed painted pixel-art temple stonework. Warm restrained painterly material shading, ancient stone in ochre and warm grey with worn teal pigment in the carved recesses and bronze inlay. Darker in value than the main wall behind it, because it is nearer the viewer and mostly out of the torchlight.

Camera: Fixed orthographic side view at eye level, straight on. No perspective, no tilt, no lens effects.

Elements to draw, and nothing else:
1 One massive square carved stone pillar running from the top edge of the image to the bottom edge, exactly 200 px wide, its horizontal centre at x = 100. It is cut off cleanly by the top and bottom edges of the image, which is correct for this layer.
2 A low foreground floor lip running along the bottom of the image: a band of carved stone from y = 640 to y = 720 spanning the full width, with a crisp top edge and a shallow carved groove, meant to sit in front of the walkable floor.

Exclusion zones, and this is the instruction that keeps the room playable. No painted pixel of the pillar may fall in any of these horizontal ranges, because a tell, an emergence or a landing happens there and must stay visible:
- x from 364 to 564;
- x from 828 to 1052;
- x from 1004 to 1204.
The pillar at x = 100 already satisfies this. Do not add a second pillar, a hanging banner, a chain, a vine, a brazier or any other foreground element anywhere in the image.

Do not draw any character, creature, jar, urn, panel, burial pit, rope, anchor, counterweight, torch, flame or user interface element.

Containment, which is deliberately different from the sprite sheets in this set: this is a single overlay layer with no cell grid, and the pillar and the floor lip are MEANT to run off the image edges where the descriptions say so. Do not add a margin around them, do not shrink them to fit inside one, and do not draw a border. The only positional constraints are the pillar's stated width and centre and the three exclusion zones above.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the pillar or the floor lip. That is most of the image and it is correct. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the stonework: no stone pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures or motion blur.
```

---

## 7. room_light_atmosphere_v001.png

Layout E: 1280 x 720, single additive overlay. **Black background, not magenta.**

This layer is composited additively, so black adds nothing and bright areas add light. Keying it on magenta would be
meaningless, which is why the convention differs here. Record that in the generation record so the extraction step does
not run on it by habit.

The staging brief requires readability to be reviewed without motion, and the art direction says atmosphere must be
used sparingly and must not swallow interactable outlines.

Export: `room_light_atmosphere_v001.png`, downsampled 2:1 to 640 x 360, composited with additive blending.

```
Produce one 2D game lighting overlay image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

This image is an ADDITIVE lighting overlay. It will be added on top of a painted room, so pure black areas contribute nothing and bright areas contribute light. Almost all of the image is pure black.

Style: soft warm torchlight and fine airborne dust, painted with restraint. No hard edges, no shapes with outlines, no objects.

Camera: Fixed orthographic side view at eye level, straight on. No perspective, no tilt, no lens effects.

Elements to draw, and nothing else:
1 Three warm amber torch pools. Each is a soft round falloff about 260 px across, brightest at its centre and fading smoothly to pure black at its edge, centred at x = 464 y = 380, at x = 940 y = 340, and at x = 180 y = 400. The one at x = 464 is the brightest, because it frames the room's first point of interest.
2 A very faint cool shaft of light angled down from the upper centre of the image toward the lower right, no more than a quarter as bright as a torch pool, with soft edges.
3 A light scattering of fine warm dust motes across the middle of the image, each only a few pixels across, dim, and denser inside the torch pools than outside them.

Brightness discipline: nothing on this layer may be bright enough to wash out what is under it. The brightest pixel of the brightest torch pool should read as a warm glow, not as white. Keep the falloffs smooth and wide rather than tight and hot. There must be no bright area inside x = 364 to 564 above y = 500, inside x = 828 to 1052 above y = 500, or inside x = 1004 to 1204 above y = 500 that would obscure something happening there.

Do not draw a torch, a bracket, a flame, a lamp, a fixture, a wall, a floor, a character, a creature, a prop or any object at all. There are no objects on this layer, only light and dust.

Background convention for this prompt: the background is PURE BLACK, RGB 0 0 0. Do NOT use magenta anywhere on this image. Do not use transparency or an alpha channel. Everything that is not light or dust is pure black.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, objects or lens flare.
```

---

## 8. temple_torch_flame_v002.png

Layout S6: 1536 x 1024, 3 columns x 2 rows, cell 512 x 512. Six frames, one wall torch loop.

Batch 001's torch sheet had eight frames and recorded that torch alignment and loop consistency were pending. Six
frames at the pipeline's 8 to 12 fps ambient rate is a 500 to 750 ms loop, which is right for a torch, and it keeps the
sheet inside the six-cell rule. The alignment problem is fixed by fixing the bracket's position as a number: the cup
and bracket do not move by a single pixel between cells.

Exports: cells 1 to 6 to `temple_torch_flame_v002_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Divide the image into exactly 3 columns by 2 rows of equal cells: 1536 / 3 = 512 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one torch per cell, 6 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze and ochre, deep shadows. Pixel-art fire built from readable clusters, not a soft airbrushed blur.

Camera: Fixed orthographic side view at eye level, straight on. No perspective, no camera movement, no zoom change and no lens effects between cells.

Subject, identical in all six cells: one wall-mounted ancient bronze torch. A small carved stone wall bracket, and an ornate bronze cup sitting in it, burning with warm amber and ivory fire.

Fixed geometry, and this is the instruction that makes the loop usable: in every cell the stone bracket and the bronze cup occupy exactly the same pixels. The bracket and cup assembly is 80 px wide and 96 px tall, its base at 400 px below the top of its own cell, centred horizontally at 256 px from the left edge of its own cell. It does not move, rotate, resize, brighten or change in any way between cells. Only the flame, the sparks and a little smoke change.

Flame discipline: the flame rises from the cup and reaches no higher than 144 px below the top of its cell, so it is at most about 160 px tall. It is a readable torch flame with clear tongues and defined clusters. Do not draw an enormous glow cloud, a bloom halo, a light shaft, a lens flare or a soft radial gradient around the flame.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell and never move the bracket.

Frames, one per cell in reading order, forming a loop that returns cleanly to the first:
1 compact. The flame low and gathered, a single main tongue rising straight up, two small sparks near its tip.
2 lean left. The flame leaning left with the main tongue bent over, a thin secondary tongue trailing behind it, one spark drifting up and left.
3 tall. The flame at its full height and nearly vertical, the tongue narrow and reaching, three sparks rising, a thread of smoke at the top.
4 split. The tip of the flame divided into two tongues of unequal height, the body still tall, sparks scattered between them.
5 lean right. The flame leaning right, the main tongue bent over the far side of the cup, a thin trailing tongue behind it, one spark drifting up and right.
6 settle. The flame dropping back toward the compact shape of cell 1 but not quite there, the last spark near the tip, ready to loop.

No wall, room, floor, ground plane, character, creature or prop other than the torch is drawn in any cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the torch, its flame, its sparks or its smoke, including the gap under the bracket and between the flame tongues. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, duplicated frames or motion blur.
```

---

## 9 to 11. The three camera-matched review plates

Layout E: 1280 x 720 each, single full-bleed plate.

These are the before, peak and after plates the staging brief requires. Their entire value depends on the camera, the
crop and the lighting being identical across all three, so a reviewer judges the transformation rather than a changed
composition. Generate the before plate first, then supply it as the reference image for the other two.

**These are not screenshots and must never be presented as one.** They are painted review plates. The originals are
still unrecovered and no final screen render has been produced. A beauty shot at a flattering zoom cannot replace
native-scale review, and neither can these.

Exports: `plate_gallery_before_v001.png`, `plate_gallery_peak_v001.png`, `plate_gallery_after_v001.png`.

### 9. plate_gallery_before_v001.png

```
Produce one 2D painted game scene image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

This is a single full-bleed painted scene. There is no cell grid. Every pixel is painted.

Style: richly detailed painted pixel-art for a side-view temple platformer. Warm restrained painterly material shading, ancient temple materials in ochre, bronze, teal and ivory, warm torchlight cutting into deep shadow. Chunky readable hero and creature forms against a layered ornate stage.

Camera, and this must be repeated exactly in the two companion images: fixed orthographic side view at eye level, straight on, the whole 1280 x 720 frame showing one room. No perspective vanishing point, no tilt, no zoom change, no camera movement, no lens effects.

Scene: the Gallery of Vessels, an ancient funerary chamber. A walkable stone floor runs across the frame with its top surface at y = 592. A deep dim chamber of square pillars recedes behind. The main wall is dressed masonry with carved banding and worn pigment. A massive foreground pillar 200 px wide stands at the far left, centred at x = 100, running the full height of the frame.

Fixed contents at fixed positions, which must be identical in all three plates:
- an intact decorated funerary burial jar, aged terracotta with turquoise geometric bands, a stylized cream funerary face and a bronze rim, 80 px tall, standing on the floor with its base centred at x = 464;
- a tall narrow sacred urn with a long neck, flared bronze lip and fine vertical teal lines, clearly a different shape from the burial jar, 100 px tall, standing on the floor with its base centred at x = 256;
- a heavy bronze lasso anchor ring on a carved stone bracket, 100 px across, centred at x = 792 and y = 352;
- a decorated stone counterweight hanging on a hemp rope, 90 px wide, centred at x = 600 and y = 300;
- three warm torch pools lighting the room, the brightest of them falling on the burial jar;
- Michael, an adult charismatic steampunk cowboy temple adventurer, 36 px tall in this frame, standing calmly on the floor at x = 144 facing right.

Michael's design: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt.

Readability requirements: the route from Michael to the anchor must be visible and unobstructed. The foreground pillar must not overlap the jar, the anchor, the counterweight or the floor between them. The sacred urn must be visibly outside any line of fire toward the rest of the room. Deep shadow is present but no interactable outline is swallowed by it.

State of the scene: everything is at rest. The jar is intact and closed with no crack, no dust and no movement. No creature is present anywhere. Michael is standing at rest with no weapon drawn.

Background convention for this prompt: this plate is fully opaque and is NOT keyed. Do NOT use magenta anywhere. Do not use transparency or an alpha channel. Paint every pixel.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, grid lines, arrows, rulers, montage, collage, user interface elements, health bars, health hearts or motion blur.
```

### 10. plate_gallery_peak_v001.png

```
Produce one 2D painted game scene image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

Use the attached image as the exact and only authority for the room, the camera, the crop, the lighting, the palette, the architecture, the prop positions and Michael's identity and scale. This is the SAME room from the SAME camera under the SAME light. Do not move the camera, do not change the zoom, do not relight the scene, do not redesign the architecture and do not move any prop.

This is a single full-bleed painted scene. There is no cell grid. Every pixel is painted.

Style: identical to the attached image.

Camera, which must match the attached image exactly: fixed orthographic side view at eye level, straight on, the whole 1280 x 720 frame showing one room. No perspective vanishing point, no tilt, no zoom change, no camera movement, no lens effects.

Everything that is unchanged from the attached image: the floor at y = 592, the pillars behind, the main wall, the foreground pillar 200 px wide centred at x = 100, the sacred urn 100 px tall centred at x = 256, the bronze anchor ring centred at x = 792 and y = 352, the stone counterweight centred at x = 600 and y = 300, and the three torch pools with the brightest on the jar position.

What changes, and only this:
- The burial jar at x = 464 is halfway through unfolding into a creature. Its rim has parted, fragments of the decorated vessel are still attached along the emerging body as armour, and the same turquoise geometric bands and cream funerary face motifs run continuously from those fragments across a bone skull and terracotta clay body. The lower half is still inside the vessel. The creature is about 60 px tall at this stage.
- Michael, 36 px tall, has moved to x = 300 and is in a lasso anticipation pose: throwing arm drawn back and up behind the shoulder, weight over the rear boot, torso coiled, facing right toward the jar. He is drawn at exactly the same size as in the attached image.

Readability requirements, and they are the reason this plate exists: nothing may overlap the emerging body. Michael must not stand in front of it, the foreground pillar must not reach it, and the torch pool must not wash it out. A reviewer has to be able to see the whole transformation and Michael's windup at the same time, and to see where the floor is under both of them.

Background convention for this prompt: this plate is fully opaque and is NOT keyed. Do NOT use magenta anywhere. Do not use transparency or an alpha channel. Paint every pixel.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, grid lines, arrows, rulers, montage, collage, user interface elements, health bars or motion blur.
```

### 11. plate_gallery_after_v001.png

```
Produce one 2D painted game scene image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

Use the attached image as the exact and only authority for the room, the camera, the crop, the lighting, the palette, the architecture, the prop positions and Michael's identity and scale. This is the SAME room from the SAME camera under the SAME light. Do not move the camera, do not change the zoom, do not relight the scene, do not redesign the architecture and do not move any prop.

This is a single full-bleed painted scene. There is no cell grid. Every pixel is painted.

Style: identical to the attached image.

Camera, which must match the attached image exactly: fixed orthographic side view at eye level, straight on, the whole 1280 x 720 frame showing one room. No perspective vanishing point, no tilt, no zoom change, no camera movement, no lens effects.

Everything that is unchanged from the attached image: the floor at y = 592, the pillars behind, the main wall, the foreground pillar 200 px wide centred at x = 100, the sacred urn 100 px tall centred at x = 256 and still intact, the bronze anchor ring centred at x = 792 and y = 352, the stone counterweight centred at x = 600 and y = 300, and the three torch pools with the brightest still falling on the jar position.

What changes, and only this:
- At x = 464 the creature has been resolved. A low readable heap of identifiable decorated fragments lies on the floor, still showing the turquoise geometric bands and the cream funerary face, with one small intact bronze and cream funerary token clearly visible on top. The location is unmistakably where the jar stood: the remains sit in the same torch pool, in the same footprint.
- Michael, 36 px tall, stands at x = 380 on the floor in a settled stance facing right, drawn at exactly the same size as in the attached image.

Readability requirements: the required route from Michael to the anchor must still be visible and unobstructed. The remains must not spread across the floor in a way that hides where a player can walk or land. The jar's original position must remain recognisable, which is what makes this plate worth comparing against the before plate.

Background convention for this prompt: this plate is fully opaque and is NOT keyed. Do NOT use magenta anywhere. Do not use transparency or an alpha channel. Paint every pixel.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, grid lines, arrows, rulers, montage, collage, user interface elements, health bars or motion blur.
```

---

## Review notes for this file

- **Check the three plates are actually camera-matched.** Diff them pairwise and look at where the differences fall. If
  the architecture, the floor line, the foreground pillar or the two unchanged props differ by more than a few pixels
  between plates, the set is not a comparison and should be regenerated. Eyeballing three large images does not catch a
  four-pixel floor shift, and a four-pixel floor shift makes the peak plate useless as evidence.
- **Check the reserved rectangles are genuinely plain.** Crop the three reserved regions from the main wall plate and
  look at each on its own. Any carving, pigment or niche inside them will show through around a composited sprite.
- **Check the exclusion zones on the occluder.** Mask the non-magenta pixels and report whether any fall inside the
  three named x ranges. That is a one-command check and it is the difference between a pillar that frames the route and
  a pillar that hides a jump landing.
- **Check tiling by tiling.** Lay each tile module three across and three down and look at the joins. A tile that
  almost tiles produces a visible seam grid across a whole floor, and it is invisible in a single cell.
- **The review plates are painted, not captured.** They must never be filed as screenshots, presented as the approved
  visual target, or registered as a recovered original. F01 is still open.
- Once the room exists, review every candidate sprite against the same room plate at native scale. That is what the
  plates are for.
