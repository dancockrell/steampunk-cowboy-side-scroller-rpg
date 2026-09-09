# Enemy family: burial-pit assembler

Six prompts. The emergence sheet follows the B0 to B5 table in
[emergence-keyframes.md](../emergence-keyframes.md) exactly, one key per cell in order. The other five sheets complete
the enemy package the pipeline requires. Read [README.md](README.md) first.

**The source prop and the first animation frame are the same export.** Prompt 1 produces `pit_source_v001.png`, the
quiet burial trench, as a single isolated image. That file ships as both the room's pit and as emergence frame 000.
Cell 1 of the emergence sheet is a placement and continuity guide only; at admission, frame 000 is replaced by the
prompt 1 export byte for byte, and the room plate composites the same file.

The pit is drawn as an isolated sprite component, never as background. The emergence brief calls for an explicit
occlusion mask so the same pit lip naturally hides emerging lower limbs. That means the pit is exported twice from the
same generation: once as the whole pit, and once as the foreground lip alone, which is drawn over the crawler. Both
crops come from the prompt 1 image, which is why the prompt below places the lip at a stated pixel range.

Two rules the emergence brief makes non-negotiable, and both are written into the prompts. The crawler has no legs and
never grows them: incomplete legs are intentional throughout, and leg completeness never changes between frames without
an explicit assembly action. And the wrong-skull beat is authored exactly once, in B4, not randomised across a frame
family.

Batch 001's `pit_assembler_emergence_v001` record contains a visible self-correction mid-prompt, which is one reason
the prompts here state the legless rule three times in different words rather than once.

Tone is dry bones, ritual and odd assembly. No blood, no gore, no graphic anatomy. One brief macabre and slightly wry
beat is allowed and it is B4.

Scale used below is a 160 px tall by 256 px long crawler and a 256 px wide pit opening, which is 40 by 64 and 64 world
pixels. No repository document states either; both are listed as unconfirmed in [README.md](README.md).

---

## 1. pit_source_v001.png

Layout S1: 512 x 512, single cell. One isolated burial pit. This is B0.

Two crops are taken from this one export: the whole pit, and the foreground lip alone from the region below the ground
line, which becomes the occlusion mask drawn over the crawler.

Export: `pit_source_v001_000.png`, plus `pit_lip_occluder_v001_000.png` cropped from it.

```
Produce one 2D game sprite image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

This image is one cell. Draw exactly one object in it, centred horizontally, and nothing else.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level, the same flat side view a platformer uses. No perspective, no vanishing point, no top-down tilt and no lens effects.

Subject: one quiet ancient burial trench cut into stone. A rectangular stone-lined opening in the ground with a worn carved rim, a raised near lip of stone in front of it, and a completely dark interior showing nothing inside. A little displaced pale dust lies along the rim. It reads as a real architectural recess a player would walk past, not as a monster in disguise: nothing is moving, nothing is inside, no bones, no hands, no eyes, no glow.

Scale and registration: a horizontal ground line runs 400 px below the top of the image. The pit graphic is exactly 256 px wide, centred horizontally at 256 px from the left edge, and spans vertically from 376 px to 440 px from the top: that is 24 px of rim and near lip standing above the ground line, and 40 px of opening and interior below it.

The near lip, the band of stone in front of the opening that would stand between the viewer and anything inside, must be drawn as a clearly separable shape occupying the region from 400 px to 440 px from the top. It has to work when cut out on its own and laid over a creature, so give it a definite top edge and solid readable material rather than fading into the dark interior.

Do not draw a floor, a wall, a room, other scenery, a creature, bones, dust clouds, glow or a shadow cast onto anything. The pit stands alone.

Containment: no drawn pixel comes within 64 px of any image edge.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the pit, including the area above the ground line to either side of the rim. The dark interior of the pit is drawn as dark stone colour and is NOT magenta and NOT transparent. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the pit: no pit pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra objects, extra characters, motion blur or speed lines.
```

---

## 2. pit_assembler_emergence_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six cells, B0 through B5 in order.

Supply the prompt 1 pit export as the reference image.

Exports: cell 1 is a guide only and is replaced at admission by `pit_source_v001_000.png`. Cells 2 to 6 to
`pit_assembler_emergence_v002_001.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached pit image ONLY as the exact identity, stone material, palette, dimensions, style and scale authority for the burial pit. The pit in cell 1 must match it as closely as possible, and the pit must be identical in every cell where it appears.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one subject per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Eerie, dry and slightly wry ancient magical realism. Dry bones only, no blood, no gore, no graphic anatomy, no organs, no flesh.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Creature identity, the same in every cell where it appears: Bone ivory, ancient bronze grave bracelets and scraps of muted teal funerary cloth. Identity: ivory skull/ribcage, two powerful bone arms, bronze bracelets and torn teal funerary cloth. The creature has NO LEGS, just torso and two arms.

The legless rule is absolute and applies to every cell: this creature never has legs, never grows legs, never has stumps that are becoming legs, and never changes how complete its lower body is between cells. It moves on its two arms. If a pose seems to need legs, change the pose.

Pit registration: in every cell the pit is exactly 256 px wide, centred 260 px from the left edge of its own cell, and spans from 376 px to 440 px below the top of its own cell, with a horizontal ground line at 400 px. The pit does not move, resize or change between cells.

Scale and registration for the creature: the crawler is 160 px tall from ground line to skull crown when supported on its arms, and about 256 px long from the front of its skull to the back of its ribcage. It rests on the ground line at 400 px below the top of its own cell. Do not resize it between cells and do not re-centre a cell on its visible pixels.

No floor, wall, room, other scenery, dust cloud, glow, shockwave or magic effect is drawn in any cell. Small falling dust along the pit rim is allowed in cell 2 only.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. A forward arm lunge is the case that breaks this. If the reaching arm does not fit inside the cell with its 64 px margin, shorten the reach within the cell. Never enlarge a cell, never crop an arm or a skull, and never shrink the creature to make a reach fit.

Facing: where the creature has a front, it faces screen-right.

Stages, one per cell in reading order:
1 disguised. The quiet burial trench exactly as in the attached image, empty and still, dark interior, a little displaced dust on the rim. Nothing inside, nothing moving.
2 the tell. The same pit, still apparently empty, with two sets of pale skeletal fingertips hooked over the near lip from inside and a thin trail of dust rolling down toward the opening. No arm, body or skull is visible yet, only fingertips and dust. This must be readable as movement before a body appears.
3 awakening. Two powerful bone arms reach up out of the opening, bronze bracelets at the wrists, passing a skull and a set of shoulder bones upward from inside the pit. The physical causality is clear and the skull is the focal point. No torso is over the rim yet.
4 emergence peak. An incomplete torso hauls itself over the rim on both arms: ribcage, shoulders, scraps of torn teal funerary cloth, bronze bracelets. Below the ribcage there is nothing, and the near lip of the pit passes in front of the lower body so the transition is hidden by the stone rather than explained. The crawling silhouette is deliberately low and long, nothing like a standing skeleton.
5 active settle. The crawler is clear of the pit and out on the ground line beside it, supported on both arms, ribcage low, torn teal cloth hanging. It is reaching up with one hand to adjust a skull that is slightly the wrong size for its neck, and the fit is visibly imperfect. This is the one dry, faintly funny beat in the sequence and it is authored here and nowhere else. Hold it as a settled readable pose.
6 resolved. The creature has come apart and the bones are falling back down through the same pit opening: a skull, ribs and one bracelet mid-fall between the rim and the dark interior, the near lip still passing in front of them, a scrap of teal cloth caught on the rim. The pit is otherwise as it was in cell 1. No dust cloud, no debris pile outside the pit, no blood.

Change only the stage. Bone colour, bracelets, cloth, pit stone, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the pit or the creature, including the gaps between the ribs and under the arms. The dark interior of the pit is drawn as dark stone colour and is NOT magenta and NOT transparent. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated stages, motion blur or speed lines.
```

---

## 3. pit_assembler_tell_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `tell` loop.

Supply the prompt 1 pit export as the reference image.

Exports: cells 1 to 4 to `pit_assembler_tell_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached pit image ONLY as the exact identity, stone material, palette, dimensions, style and scale authority. The pit must match it in every cell and must not change between cells.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one pit per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no camera movement, no zoom change and no lens effects between cells.

Subject, identical in all four cells: the same ancient stone burial trench with its worn carved rim, raised near lip and completely dark interior.

Pit registration, identical in every cell: the pit is exactly 256 px wide, centred horizontally in its cell, spanning from 376 px to 440 px below the top of its own cell, with a horizontal ground line at 400 px. The pit does not move, resize or change between cells.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell and never resize the pit.

Frames, one per cell in reading order. This is a repeating warning cue that must be readable from shape alone rather than from a glow or a colour flash. Nothing comes out and nothing is damaged:
1 rest. The pit still and empty, a little pale dust lying along the rim, dark interior showing nothing.
2 first contact. Two pale skeletal fingertips press up over the near lip from inside, no more than eight pixels of bone visible, and a few dust grains begin to roll from the rim toward the opening.
3 press. The fingertips at their furthest, about sixteen pixels of bone over the lip, knuckles just breaking the line, a short trail of dust rolling down into the dark. No wrist, arm, bracelet or skull is visible.
4 withdraw. The fingertips sinking back below the lip until only a few pixels show, the last dust grains settling, returning toward cell 1 so the loop closes without a jump.

No arm, wrist, bracelet, skull, ribcage, cloth or creature body appears in any cell. No glow, light beam, sparkle, aura, smoke or particle effect. No floor, wall, room or scenery.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the pit or its dust. The dark interior of the pit is drawn as dark stone colour and is NOT magenta and NOT transparent. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated frames, motion blur or speed lines.
```

---

## 4. pit_crawler_crawl_right_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `crawl` locomotion cycle, facing right.

Supply the emergence sheet as the reference image.

Exports: cells 1 to 4 to `pit_crawler_crawl_right_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, bone colour, bracelet, cloth, palette, style and scale authority for the free crawler. Do not copy its poses. Draw NO pit, NO stone rim, NO lip and NO emergence state on this sheet: only the free creature.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one creature per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Eerie, dry and slightly wry ancient magical realism. Dry bones only, no blood, no gore, no graphic anatomy.

Identity, in every cell: Bone ivory, ancient bronze grave bracelets and scraps of muted teal funerary cloth. Identity: ivory skull/ribcage, two powerful bone arms, bronze bracelets and torn teal funerary cloth. The creature has NO LEGS, just torso and two arms.

The legless rule is absolute and applies to every cell: no legs, no hips below the ribcage, no stumps becoming legs, and no change in lower-body completeness between cells. All movement is done by the two arms dragging the torso.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: the crawler is 160 px tall from ground line to skull crown when supported on its arms, and about 256 px long from the front of its skull to the back of its ribcage. Its supporting hand or hands rest on a horizontal ground line 400 px below the top of its own cell, and the trailing end of the ribcage also touches that line. The middle of the ribcage is centred horizontally in its cell. Do not resize it between cells and do not re-centre a cell on its visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. The forward arm reach is the case that breaks this. If the reach does not fit inside the cell, shorten it within the cell. Never enlarge a cell, never crop an arm or a skull, and never shrink the creature.

Facing: all 4 sprites face screen-right in strict side view, and the direction of travel is to the right.

Frames, one per cell in reading order. This is one arm-over-arm drag cycle, low and heavy, deliberately unlike a walk:
1 both planted. Both hands flat on the ground line beneath the shoulders, the ribcage low and level, the skull raised and looking forward to the right, torn teal cloth hanging.
2 near arm reaches. The near arm extends forward to the right and its hand plants on the ground line ahead, the far arm still supporting behind, the ribcage tipping forward, the skull dipping.
3 haul. Both arms drive and the ribcage drags forward along the ground line, shoulders high and elbows bent, the trailing end of the ribcage scraping, the skull low between the shoulders.
4 far arm reaches. The far arm swings forward past the near one and plants, the near arm now behind and supporting, the ribcage levelling out again, the skull rising, continuing straight back into cell 1.

Change only the pose. Bone colour, bracelets, cloth, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the creature, including the gaps between the ribs, under the arms and through the torn cloth. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. pit_crawler_combat_right_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames covering neutral, attack anticipation, attack
commit, attack recovery and two stagger frames, facing right.

Supply the emergence sheet as the reference image.

Exports: cell 1 to `pit_crawler_neutral_right_v002_000.png`, cells 2 to 4 to
`pit_crawler_attack_right_v002_000.png` through `_002.png`, cells 5 and 6 to
`pit_crawler_stagger_right_v002_000.png` and `_001.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, bone colour, bracelet, cloth, palette, style and scale authority for the free crawler. Do not copy its poses. Draw NO pit, NO stone rim, NO lip and NO emergence state on this sheet: only the free creature.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one creature per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Eerie, dry and slightly wry ancient magical realism. Dry bones only, no blood, no gore, no graphic anatomy.

Identity, in every cell: Bone ivory, ancient bronze grave bracelets and scraps of muted teal funerary cloth. Identity: ivory skull/ribcage, two powerful bone arms, bronze bracelets and torn teal funerary cloth. The creature has NO LEGS, just torso and two arms.

The legless rule is absolute and applies to every cell: no legs, no hips below the ribcage, no stumps becoming legs, and no change in lower-body completeness between cells.

The skull is the same skull in all six cells, the slightly mismatched one it fitted during emergence. Do not swap it, resize it or replace it between cells.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: the crawler is 160 px tall from ground line to skull crown when supported on its arms, and about 256 px long. Its supporting hand or hands rest on a horizontal ground line 400 px below the top of its own cell. The middle of the ribcage is centred horizontally in its cell. Do not resize it between cells.

No pit, floor, wall, dust cloud, glow, shockwave, impact effect or scenery is drawn in any cell. A few small falling bone chips are allowed in cells 5 and 6, close to the body.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. The raised and lunging arm is the case that breaks this. If it does not fit inside the cell with its 64 px margin, shorten the reach within the cell. Never enlarge a cell, never crop an arm or a skull, and never shrink the creature to make a lunge fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 neutral. Both hands planted flat on the ground line beneath the shoulders, ribcage low and level, skull raised and looking right, torn teal cloth hanging still. Settled and stable. This is the pose the crawl cycle returns to.
2 attack anticipation. Weight shifted back onto the rear arm, the near arm lifted high and drawn back with the fingers spread and the bracelet slipping down the forearm, the ribcage rearing up off the ground line, the skull tipping back. Clearly readable as a windup and clearly different in silhouette from the neutral pose.
3 attack commit. The raised arm slams forward and down toward the right, the whole ribcage lurching after it, the supporting arm straightening, the skull thrust forward and low. The striking hand stays inside the cell margin.
4 attack recovery. The striking arm folding back under the shoulder, the ribcage settling back toward the ground line, both hands returning to support, the skull dropping between the shoulders. Slower and heavier than the commit.
5 stagger, first frame. Struck from the right: the skull and ribcage snapped back and away to the left, one supporting arm skidding back along the ground line, the other flung out, torn cloth thrown forward, two or three small bone chips flying close to the body.
6 stagger, second frame. The deepest point of the stagger, ribcage rolled onto its far side, both arms splayed and taking weight badly, the skull tipped back and visibly loose on the neck. It does not come apart; that is the resolved state and it belongs to the emergence sheet.

Change only the pose. Bone colour, bracelets, cloth, skull, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the creature, including the gaps between the ribs, under the arms and through the torn cloth. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. pit_crawler_crawl_left_v001.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two left-facing continuity keys.

**Continuity key sheet, not a mirror.** The bracelets and the torn cloth sit asymmetrically, and the crawler's near and
far arms read differently because one is in front of the ribcage and one behind it. A mirror swaps that depth
relationship silently. Compare against the right-facing crawl sheet and record which arm is drawn in front.

Exports: cells 1 and 2 to `pit_crawler_crawl_left_v001_000.png` and `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, bone colour, bracelet, cloth, palette, style and scale authority for the free crawler. Do not mirror it. Draw the creature newly, turned to face the other way, with its bracelets and torn cloth on the same limbs and the same side of the body as on the attached sheet, drawn as seen from this side.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one creature per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Dry bones only, no blood, no gore.

Identity, in both cells: Bone ivory, ancient bronze grave bracelets and scraps of muted teal funerary cloth. Identity: ivory skull/ribcage, two powerful bone arms, bronze bracelets and torn teal funerary cloth. The creature has NO LEGS, just torso and two arms. No legs, no hips below the ribcage, no stumps.

Camera: Fixed orthographic side view at eye level. No perspective, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in both cells: the crawler is 160 px tall from ground line to skull crown, about 256 px long, its supporting hands on a horizontal ground line 400 px below the top of its own cell, the middle of the ribcage centred horizontally in its cell.

No pit, floor, wall or scenery is drawn.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the forward reach does not fit, shorten it within the cell. Never enlarge a cell, never crop an arm or a skull, and never shrink the creature.

Facing: BOTH sprites face screen-LEFT in strict side view. Both skulls point left and the direction of travel is to the left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Frames, one per cell in reading order, both from one arm-over-arm drag to the left:
1 both planted. Both hands flat on the ground line beneath the shoulders, the ribcage low and level, the skull raised and looking forward to the left.
2 haul. Both arms driving and the ribcage dragging forward along the ground line toward the left, shoulders high and elbows bent, the trailing end of the ribcage scraping, the skull low between the shoulders.

Change only the pose and the direction it faces. Bone colour, bracelets, cloth, palette, lighting direction, scale and camera are identical to the attached sheet. Keep each bracelet on the same arm and the torn cloth on the same side of the ribcage as on the attached sheet rather than swapping them across, and keep the same arm drawn in front of the ribcage.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the creature, including the gaps between the ribs, under the arms and through the torn cloth. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- **Check the substitution actually happened.** Compare the SHA-256 of `pit_assembler_emergence_v002_000.png` against
  `pit_source_v001_000.png`. They must be identical, and the room plate must composite the same file.
- **Check the occluder crop.** `pit_lip_occluder_v001_000.png` is cut from the 400 to 440 px band of the prompt 1
  image. Composite it over the crawler at emergence peak and confirm the lower body is genuinely hidden by stone rather
  than fading out. If the lip has no solid top edge, the crop will not read and prompt 1 should be regenerated.
- **Count the legs.** Across all sheets in this family, every cell must show zero legs. That is a countable check and
  worth running as one: crop every cell, review them in a contact sheet, and record the count per cell rather than a
  general impression. Leg completeness changing between frames is the single defect the emergence brief calls out by
  name for this family, and batch 001's prompt shows the author catching themselves mid-sentence over it.
- **The wrong-skull beat exists once.** Confirm it appears in emergence cell 5 and nowhere else. It is a single
  authored moment, not identity drift, and if it turns up in the crawl or combat sheets those sheets are wrong.
- Layer separation is a slicing task: pit rim and foreground lip, dark interior, reaching hands, passed bones, the
  assembled crawler, settling bones. Cut those from the sheets above.
- In the engine, inspect occupied-spawn delay, pause and interrupted emergence with these same assets. There must be
  no seam jump when the source hands off to the actor.
