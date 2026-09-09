# Enemy family: painted procession guard

Six prompts. The emergence sheet follows the M0 to M5 table in
[emergence-keyframes.md](../emergence-keyframes.md) exactly, one key per cell in order. The other five sheets complete
the enemy package the pipeline requires. Read [README.md](README.md) first.

**The source prop and the first animation frame are the same export.** Prompt 1 produces
`mural_panel_source_v001.png`, the painted panel with the guard still flat in it, as a single isolated image. That file
ships as both the room's mural panel and as emergence frame 000. Cell 1 of the emergence sheet is a placement and
continuity guide only; at admission, frame 000 is replaced by the prompt 1 export byte for byte, and the room plate
composites the same file. A painted door or panel used by an enemy must exist as a separable source asset and never be
baked only into a background, which is exactly why the panel is generated first and alone.

The hard part of this family is the material logic. The guard must look like a painting acquiring volume, not a
skeleton standing in front of a wall. The mixed flat and solid anatomy in M3 is the signature of the whole family and
the prompts say so explicitly rather than trusting it to emerge.

Panel registration must be preserved exactly. The first five cells use the same panel dimensions in the same place, so
the panel does not appear to move while the guard peels out of it.

Scale used below is a 280 px standing guard and a 320 by 208 px panel, which is 70 and 80 by 52 world pixels. No
repository document states either; both are listed as unconfirmed in [README.md](README.md).

---

## 1. mural_panel_source_v001.png

Layout S1: 512 x 512, single cell. One isolated painted stone panel with the guard flat inside it. This is M0.

Export: `mural_panel_source_v001_000.png`.

```
Produce one 2D game sprite image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

This image is one cell. Draw exactly one object in it, centred horizontally, and nothing else.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level, looking straight at the face of the panel. No perspective, no vanishing point, no camera tilt and no lens effects.

Subject: one upright rectangular ancient stone panel carrying a painted ceremonial procession figure. The panel is carved stone with a plain shallow border and a slightly recessed painted field. The figure inside it is a spear-bearing temple guard, painted completely flat in the manner of an ancient wall procession: no volume, no cast shadow, no modelled highlights on the figure, profile pose, one visible eye, feet turned sideways along a painted ground band.

Identity: Ochre/red/teal pigment, bronze details, dignified skull-like funerary mask. Identity of the fully emerged guard: gold funerary skull mask, red feather crest, teal/gold ceremonial tunic and spear. In this image all of that is pigment on stone rather than a body: the mask, crest, tunic and spear are painted shapes.

Scale and registration: the panel is exactly 320 px tall and 208 px wide. Its base rests on a horizontal foot line 400 px below the top of the image, so its top edge sits at 80 px from the top. It is centred horizontally at 256 px from the left edge. The painted guard stands within the panel, roughly 280 px tall including the crest, with the painted spear running the full height of the painted field.

Do not draw the surrounding wall, the room, a floor, other panels, scenery, dust, glow or a frame around the panel other than its own carved stone border. The panel stands alone.

Containment: no drawn pixel comes within 64 px of any image edge.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the panel. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the panel: no panel pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders other than the panel's own carved stone edge, frames, grid lines, arrows, rulers, montage, collage, extra objects, extra characters, motion blur or speed lines.
```

---

## 2. mural_guard_emergence_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six cells, M0 through M5 in order.

Supply the prompt 1 panel export as the reference image.

Exports: cell 1 is a guide only and is replaced at admission by `mural_panel_source_v001_000.png`. Cells 2 to 6 to
`mural_guard_emergence_v002_001.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached panel image ONLY as the exact identity, pigment palette, panel dimensions, style and scale authority. The panel in cell 1 must match it as closely as possible.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one subject per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Ancient magical realism, dignified and eerie, never cute and never gory.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Identity, the same in every cell: Ochre/red/teal pigment, bronze details, dignified skull-like funerary mask. Identity of the fully emerged guard: gold funerary skull mask, red feather crest, teal/gold ceremonial tunic and spear.

The material logic is the point of this sequence and must be visible in every cell: this is a PAINTING ACQUIRING VOLUME. Paint lifts off stone and becomes a body. It is not a skeleton standing in front of a wall, not a ghost, not a figure stepping out of a doorway, and not paper or cloth peeling. Where the guard has separated it is solid and modelled; where it has not, it is still perfectly flat pigment with no shading at all. That deliberate mix of flat and solid within one figure is the signature of this creature.

Panel registration: in cells 1, 2, 3, 4 and 5 the stone panel is exactly 320 px tall and 208 px wide, its base on a horizontal foot line 400 px below the top of its own cell, and its centre 260 px from the left edge of its own cell. The panel does not move, rotate, resize or change its border between those five cells. In cell 6 the panel is in the same place and the same size, and it is empty.

Scale and registration: a horizontal foot line runs 400 px below the top of every cell. The freed guard stands 280 px tall including its crest, with its feet on that line, and its spear is 320 px long. Do not resize the guard or the panel between cells and do not re-centre a cell on its visible pixels.

No wall, room, floor, other panels, scenery, dust cloud, glow, shockwave or magic effect is drawn in any cell.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. The long spear is the case that breaks this: if the spear does not fit inside the cell with its 64 px margin, angle the spear more steeply within the cell. Never enlarge a cell, never crop the spear point or butt, and never shrink the guard to make the spear fit.

Facing: the guard faces screen-right in every cell, both while painted and while free.

Stages, one per cell in reading order:
1 disguised. The painted panel exactly as in the attached image. The guard is completely flat pigment in a ceremonial procession band, no volume anywhere, no shading on the figure, no separation, no cast shadow. It reads as ordinary temple decoration.
2 the tell. The same panel, the guard still entirely flat and still entirely inside the painted field, but its painted head has turned a few degrees and the painted spear has shifted its angle slightly within the artwork. The change stays inside the painting: no glow, no light, no part has left the stone. This must be readable as movement in a picture.
3 awakening. The guard's leading hand and the upper part of the spear curl away from the stone like heavy wet paint lifting, gaining a little thickness at the edge. A narrow seam shadow falls ON THE PANEL SURFACE ONLY behind the lifted parts, explaining the separation. Everything else is still flat pigment.
4 emergence peak. The upper body has full volume and modelled shading and stands clear of the panel, while the trailing leg is still completely flat pigment inside the painted field, with a visible pigment ribbon connecting the solid part to the painted part. This deliberately mixed anatomy is the key image of the whole family.
5 active settle. The guard is fully corporeal and standing beside the panel with both feet on the foot line, spear held, the last pigment ribbon retracting into the now-faded painted field. The panel is still in its fixed position and shows a pale ghost of the figure that left it.
6 resolved. The panel alone in its fixed position, the colour drained back into it and re-formed as a damaged, faded ceremonial figure: the same procession pose as cell 1 but worn, cracked and washed out. No free body remains. No dust puff, no bones, no debris.

The active silhouette in cells 4 and 5 must stay related to the painted figure in cell 1, including the spear length and the decorative rhythm of the tunic. Frame-to-frame changes in dimensionality are intentional; changes to the face, mask, crest or outfit are not.

Change only the stage. Pigment palette, mask, crest, tunic, spear, panel, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the panel or the guard, including the gaps between the legs and around the spear. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. The seam shadow in cell 3 falls on the panel surface only and never on the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders other than the panel's own carved stone edge, frames, grid lines, arrows, rulers, montage, collage, extra characters, duplicated stages, motion blur or speed lines.
```

---

## 3. mural_guard_tell_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `tell` loop.

M1 is one key in the emergence table; the pipeline wants a repeatable loop. The emergence brief is explicit that the
tell must not be a glow-only cue, so this loop is carried by shape change inside the painting.

Supply the prompt 1 panel export as the reference image.

Exports: cells 1 to 4 to `mural_guard_tell_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached panel image ONLY as the exact identity, pigment palette, panel dimensions, style and scale authority. The panel must match it in every cell.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one panel per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level, looking straight at the face of the panel. No perspective, no camera movement, no zoom change and no lens effects between cells.

Subject, identical in all four cells: the same upright rectangular painted stone panel. Ochre/red/teal pigment, bronze details, dignified skull-like funerary mask, red feather crest, teal/gold ceremonial tunic and spear, all of it flat pigment on stone. The guard stays completely flat in all four cells: no volume, no modelled shading on the figure, no part lifts off the stone, no seam shadow.

Panel registration, identical in every cell: the panel is exactly 320 px tall and 208 px wide, its base on a horizontal foot line 400 px below the top of its own cell, centred horizontally in its cell. The panel does not move, resize or change between cells.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell and never resize the panel.

Frames, one per cell in reading order. This is a repeating warning cue that stays entirely inside the artwork. It must be readable from shape alone, not from a glow, a light or a colour flash:
1 rest. The painted guard in its neutral procession pose, head in profile facing right, painted spear held upright and vertical.
2 the head turns. The painted head rotates a few degrees so more of the mask faces the viewer, the painted eye shifting position within the mask, the spear still upright. Nothing else changes.
3 the spear shifts. The painted spear tilts by about eight degrees away from vertical within the painted field, the painted hand repositioned along its shaft, the head still turned as in cell 2.
4 settle back. The spear returning most of the way to vertical and the head rotating most of the way back to profile, close to but not identical with cell 1, so the loop closes without a jump.

No glow, light beam, sparkle, aura, dust, crack, smoke or particle appears in any cell. No wall, room, floor, other panels or scenery is drawn.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the panel. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the panel: no panel pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders other than the panel's own carved stone edge, frames, grid lines, arrows, rulers, montage, collage, extra characters, duplicated frames, motion blur or speed lines.
```

---

## 4. mural_guard_walk_right_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `walk` locomotion cycle, facing right.

Supply the emergence sheet as the reference image so the freed guard's identity carries.

Exports: cells 1 to 4 to `mural_guard_walk_right_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, palette, style and scale authority for the fully emerged procession guard. Do not copy its poses. Draw NO panel, NO wall and NO emergence state on this sheet.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body figure per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Ancient magical realism, dignified and eerie, never cute and never gory.

Identity, in every cell: the fully emerged guard, gold funerary skull mask, red feather crest, teal/gold ceremonial tunic and spear, with ochre, red and teal pigment and bronze details. The whole body is solid and modelled in every cell on this sheet: no flat painted areas remain.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: the guard is exactly 280 px tall from foot to crest tip when standing, and keeps that size in every cell. Its spear is exactly 320 px long. The lower of its two feet rests on a horizontal foot line 400 px below the top of its own cell. Its pelvis is centred horizontally in its cell. Do not resize it between cells and do not re-centre a cell on its visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. The spear is the case that breaks this: in every cell of this sheet the spear is carried upright and close to vertical so it stays inside the cell. If it still does not fit, angle it more steeply within the cell. Never enlarge a cell, never crop the spear point or butt, and never shrink the guard to make the spear fit.

Facing: all 4 sprites face screen-right in strict side view.

Frames, one per cell in reading order. This is one measured ceremonial walk, upright and formal rather than a lope. The spear is carried vertically in the same hand throughout and does not swing:
1 first contact. The leading foot lands on the foot line, the trailing foot behind with the heel lifted, the torso upright and tall, the crest steady, the spear vertical beside the body.
2 passing. The rear leg swings through under the body and passes the planted leg with clear open background between them, the tunic hem lifting slightly, the spear still vertical.
3 second contact. The other foot lands on the foot line, the torso still upright, the free arm swung slightly forward, the spear still vertical.
4 passing on the other side. The first leg swings through under the body, clear open background between the legs, tunic hem settling, continuing straight back into cell 1.

Change only the pose. Mask, crest, tunic, spear, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the tunic and beside the spear shaft. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. mural_guard_combat_right_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames covering neutral, attack anticipation, attack
commit, attack recovery and two stagger frames, facing right.

Batch 001 recorded that the extended spear on the previous combat sheet needed a custom crop. The containment
instruction below names that case directly, and the spear length is fixed as a number so a thrust cannot quietly grow.

Supply the emergence sheet as the reference image.

Exports: cell 1 to `mural_guard_neutral_right_v002_000.png`, cells 2 to 4 to
`mural_guard_attack_right_v002_000.png` through `_002.png`, cells 5 and 6 to
`mural_guard_stagger_right_v002_000.png` and `_001.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, palette, style and scale authority for the fully emerged procession guard. Do not copy its poses. Draw NO panel, NO wall and NO emergence state on this sheet.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body figure per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Ancient magical realism, dignified and eerie, never cute and never gory.

Identity, in every cell: the fully emerged guard, gold funerary skull mask, red feather crest, teal/gold ceremonial tunic and spear, with ochre, red and teal pigment and bronze details. The whole body is solid and modelled in every cell.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: the guard is exactly 280 px tall from foot to crest tip when standing, and keeps that size in every cell whatever the pose. Its spear is exactly 320 px long in every cell and never gets longer. Its lowest foot rests on a horizontal foot line 400 px below the top of its own cell. Its pelvis is centred horizontally in its cell. Do not resize it between cells.

Containment, and this is the instruction the previous version of this sheet failed: no drawn pixel of any kind comes within 64 px of any cell edge, and no element may cross a cell boundary. A full horizontal spear thrust is the case that breaks it. The cell is 768 px wide, so the usable width is 640 px; a 320 px spear thrust forward from a centred body will not fit horizontally. Therefore in the thrust cell the spear is angled forward and DOWNWARD at about thirty degrees so it stays inside the cell. If it still does not fit, steepen the angle further. Never enlarge a cell, never crop the spear point or butt, never lengthen or shorten the spear between cells, and never shrink the guard to make the thrust fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 neutral. Standing tall and formal on the foot line, feet together, spear held vertical beside the body in one hand, mask facing right, crest steady. Composed and still.
2 attack anticipation. The spear drops from vertical to a two-handed grip at hip height with the point forward, the shoulders coiling back, weight shifting onto the rear foot, the front foot advancing a short step. Clearly readable as a windup and clearly different in silhouette from the neutral pose.
3 attack commit. The spear driven forward and downward at about thirty degrees, both arms extended, the shoulders and hips rotating into the thrust, weight over the front foot, the rear heel lifted, the crest thrown forward. The point stays well inside the cell margin.
4 attack recovery. The spear drawn back to hip height with the point still forward and down, arms folding in, weight resettling onto both feet, the torso rising back toward upright.
5 stagger, first frame. Struck from the right: the torso snapping back and away to the left, the spear swinging out of line, one shoulder dropping, the crest whipping back, a foot sliding back along the foot line. Two or three small flakes of dry pigment come off the tunic close to the body.
6 stagger, second frame. The deepest point of the stagger, torso bent back and away, the spear held loosely and low, one knee buckling, the mask tipped back. It stays on its feet.

Change only the pose. Mask, crest, tunic, spear length, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the tunic and beside the spear shaft. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. mural_guard_walk_left_v001.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two left-facing continuity keys.

**Continuity key sheet, not a mirror.** The spear hand and the crest asymmetry are the things a mirror would silently
swap. Compare against the right-facing walk sheet and record which hand holds the spear.

Narrow cells are correct here only because the spear is carried vertically. Any cell with the spear off vertical will
fail containment.

Exports: cells 1 and 2 to `mural_guard_walk_left_v001_000.png` and `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, palette, style and scale authority for the fully emerged procession guard. Do not mirror it. Draw the guard newly, turned to face the other way, holding the spear in the SAME hand it uses on the attached sheet, drawn as seen from this side.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body figure per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Identity, in both cells: the fully emerged guard, gold funerary skull mask, red feather crest, teal/gold ceremonial tunic and spear, with ochre, red and teal pigment and bronze details. The whole body is solid and modelled.

Camera: Fixed orthographic side view at eye level. No perspective, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in both cells: the guard is exactly 280 px tall from foot to crest tip, its spear exactly 320 px long and carried VERTICAL in both cells so it stays inside the cell. Its lower foot rests on a horizontal foot line 400 px below the top of its own cell. Its pelvis is centred horizontally in its cell.

No panel, wall, floor or scenery is drawn.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop the spear point or butt, and never shrink the guard.

Facing: BOTH sprites face screen-LEFT in strict side view. Every mask, crest front and leading foot points left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Frames, one per cell in reading order, both from one measured ceremonial walk to the left:
1 first contact. The leading foot lands on the foot line toward the left, the trailing foot behind with the heel lifted, the torso upright and tall, the spear vertical beside the body.
2 second contact. The other foot lands on the foot line toward the left, the torso still upright, the free arm swung slightly forward, the spear still vertical.

Change only the pose and the direction it faces. Mask, crest, tunic, spear, palette, lighting direction, scale and camera are identical to the attached sheet. Keep the spear in the same hand and the crest asymmetry on the same side as on the attached sheet rather than swapping them across.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the tunic and beside the spear shaft. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- **Check the substitution actually happened.** Compare the SHA-256 of `mural_guard_emergence_v002_000.png` against
  `mural_panel_source_v001_000.png`. They must be identical, and the room plate must composite the same file.
- **Check the panel did not move.** Crop cells 1 to 5 of the emergence sheet, find the panel's bounding box in each,
  and report five boxes. They must agree to within a pixel or two. A panel that drifts while the guard peels out of it
  destroys the effect and is very hard to see by eye across a large sheet.
- **Check the flat-versus-solid mix survived.** Cell 4 is the whole point of this family. If the trailing leg came back
  modelled rather than flat, the sheet reads as a skeleton walking out from behind a wall and should be regenerated.
  The measurable version: sample the pigment in the trailing leg region and confirm it has near-zero value variation,
  against the torso region which must show real shading.
- Layer separation is a slicing task: wall substrate, fixed border, guard pigment, separation shadow, emerged body,
  remaining pigment and resolved decal. Cut those from the sheets above rather than commissioning more generations.
- Offscreen procession movement can be atmosphere, but an activated damaging guard needs the encounter fairness rules.
  That is an encounter design constraint, not an art one, and it is why the tell loop exists.
