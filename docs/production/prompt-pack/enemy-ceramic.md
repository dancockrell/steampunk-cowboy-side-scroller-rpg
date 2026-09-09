# Enemy family: ceramic sentinel

Six prompts. The emergence sheet follows the C0 to C5 table in
[emergence-keyframes.md](../emergence-keyframes.md) exactly, one key per cell in order. The other five sheets complete
the enemy package the pipeline requires: disguise prop, tell loop, awakening, emergence, locomotion, attack
anticipation, commit and recovery, stagger and resolved remains. Read [README.md](README.md) first.

**The source prop and the first animation frame are the same export.** The emergence brief is explicit: the jar used in
the background and in the first animation frame must be the same export, not redrawn approximations. So prompt 1
produces `ceramic_jar_source_v001.png` as a single isolated image, and that file is what ships as both the room's jar
and as emergence frame 000. Cell 1 of the emergence sheet is a placement and continuity guide only. At admission,
frame 000 is replaced by the prompt 1 export byte for byte, and the room plate composites the same file. If the
emergence sheet's cell 1 does not match the prompt 1 export closely enough for the substitution to be invisible in
motion, the emergence sheet is regenerated.

**Integration decision made here, flag it for a reviewer.** The C0 row in the keyframe table describes the vessel
resting on a plinth. The plinth is not drawn on the jar sprite. It belongs to the room plate in
[environment.md](environment.md), so that one object has one owner and does not exist twice. If a reviewer wants the
plinth attached to the source sprite instead, change it in one place, not both.

Scale used below is the proposed 76 world px standing height for the sentinel and a 40 by 34 world px jar. No
repository document states either. Both are listed as unconfirmed in [README.md](README.md).

Attack timing is a separate action from emergence. Do not conceal damage in the last emergence frame.

---

## 1. ceramic_jar_source_v001.png

Layout S1: 512 x 512, single cell. One isolated jar. This is C0, the disguised state, and it is also emergence frame
000 and the room's jar.

Export: `ceramic_jar_source_v001_000.png`.

```
Produce one 2D game sprite image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

This image is one cell. Draw exactly one object in it, centred horizontally, and nothing else.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera tilt and no lens effects.

Subject: one intact ancient funerary burial jar, squat and heavy, standing upright and completely closed. Aged terracotta, turquoise geometric bands, stylized cream funerary face, bronze rim. The decoration is ornate, deliberate and dignified. It reads as real temple scenery that a player would walk past, not as a monster in disguise: no eyes that look alive, no cracks, no glow, no visible seam suggesting it opens.

Scale and registration: the jar is exactly 160 px tall and about 136 px wide at its widest. Its base rests on a horizontal foot line 400 px below the top of the image, so its rim sits at 240 px from the top. It is centred horizontally at 256 px from the left edge.

Do not draw a plinth, pedestal, base block, shelf, floor, wall, dust, shadow or any surrounding scenery. The jar stands alone.

Containment: no drawn pixel comes within 64 px of any image edge.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the jar, including any gap under a handle or lip. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the jar: no jar pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra objects, extra characters, motion blur or speed lines.
```

---

## 2. ceramic_sentinel_emergence_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six cells, C0 through C5 in order.

Supply the prompt 1 jar export as the reference image.

Commission order from the emergence brief: C0, C3 and C4 are the continuity test. If a reviewer wants only those three
first, generate this sheet and evaluate cells 1, 4 and 5 before committing to the rest.

Exports: cell 1 is a guide only and is replaced at admission by `ceramic_jar_source_v001_000.png`. Cells 2 to 6 to
`ceramic_sentinel_emergence_v002_001.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached jar image ONLY as the exact identity, decoration, palette, style and scale authority for the burial jar. The jar in cell 1 must match it as closely as possible.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one subject per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Ancient magical realism, eerie and beautiful, never cute and never gory.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Identity, and the same decoration appears in every cell: aged terracotta, turquoise geometric bands, stylized cream funerary face, bronze rim. The fully emerged ceramic sentinel: same bone skull, terracotta armor with teal geometric bands and cream mask motifs, huge clay fists.

This is ONE object physically transforming across six stages. It is not six different monsters. The jar's decoration must survive onto the creature's body: the same turquoise geometric bands and the same cream funerary face motifs appear on the emerged sentinel's armour plates, so a player can see that the creature is the jar.

Scale and registration, identical in every cell: a horizontal foot line runs 400 px below the top of every cell and everything rests on it. The jar is 160 px tall and 136 px wide. The fully standing sentinel is 304 px tall from foot to skull crown and noticeably broader than a man. The subject is centred horizontally in its cell. Do not resize the jar decoration between cells and do not re-centre a cell on its visible pixels.

No plinth, pedestal, base block, floor, wall, dust cloud, glow, shockwave or surrounding scenery is drawn in any cell.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a raised arm or a flying shard does not fit inside the cell, draw it smaller within the cell. Never enlarge a cell, never crop a limb, and never shrink the sentinel to make a gesture fit.

Facing: the creature faces screen-right in every cell where it has a front.

Stages, one per cell in reading order:
1 disguised. The intact closed burial jar exactly as in the attached image, standing upright on the foot line, no cracks, no movement, no life. It reads as ordinary temple scenery.
2 the tell. The same jar, still closed and still whole, with one hairline crack down its side catching a little warm light, a fine trickle of terracotta dust falling from that crack, and the lid tilted by only a few pixels. Nothing is damaged and nothing has come out. This must be readable as a warning, not as an attack.
3 awakening. The rim parts and the lid lifts to one side. One dark articulated clay hand comes up over the rim and braces against the jar's own shoulder, taking the creature's weight. The origin of the force is unmistakably inside the jar. Nothing unrelated materialises.
4 emergence peak. The body unfolds upward out of the vessel, torso and skull clear of the rim, arms spread. Fragments of the jar are still attached along the back, shoulders and hips as armour, and the turquoise bands and cream face motifs run continuously from those fragments across the body. The lower half is still inside the vessel.
5 active settle. The sentinel is fully out and standing on the foot line at its full 304 px height, feet planted, the shell mass settled onto the shoulders and back, huge clay fists hanging. This is the first stable combat-ready pose, calm and squared up, not attacking.
6 resolved. The creature has come apart. Identifiable decorated fragments lie in a low readable heap on the foot line, still showing the turquoise bands and the cream funerary face, with one small intact bronze-and-cream funerary token sitting clearly on top. Dry, still and dignified. No dust cloud, no bones, no blood.

Change only the stage. Decoration, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including gaps between limbs and between fragments. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated stages, motion blur or speed lines.
```

---

## 3. ceramic_sentinel_tell_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `tell` loop.

C1 is one key in the emergence table. The pipeline asks for a tell *loop*, because the tell is the fairness cue: it has
to be repeatable, non-damaging and readable without sound or colour alone. These four frames are that loop, and they
must return to the first frame cleanly.

Supply the prompt 1 jar export as the reference image.

Exports: cells 1 to 4 to `ceramic_sentinel_tell_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached jar image ONLY as the exact identity, decoration, palette, style and scale authority. The jar must match it in every cell.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one jar per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Subject, identical in all four cells: the same intact ancient funerary burial jar. Aged terracotta, turquoise geometric bands, stylized cream funerary face, bronze rim. It is closed and undamaged in all four cells.

Scale and registration, identical in every cell: the jar is exactly 160 px tall and about 136 px wide, its base resting on a horizontal foot line 400 px below the top of its own cell, centred horizontally in its cell. The jar body does not move position between cells at all. Only the crack light, the falling dust and the lid tremor change.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell and never resize the jar.

Frames, one per cell in reading order. This is a repeating warning cue that must not look like damage. It has to be readable from silhouette and value alone, not only from a colour change:
1 rest. The jar closed and still, one hairline crack visible on its side as a dark line, no dust, lid seated flush.
2 the crack catches light. The same crack now reads as a bright warm line against the terracotta, three or four small dust motes beginning to fall from its lower end, the lid lifted by two or three pixels on one side so a thin dark gap shows under it.
3 tremor. The crack still bright, a short falling trail of fine terracotta dust below it, the lid lifted at its maximum of about six pixels and tilted, the dark gap under the lid clearly visible in silhouette.
4 settle. The lid returning almost flush, the crack dimming back toward a plain dark line, the last few dust motes near the foot line, ready to loop back to cell 1.

Nothing is broken, nothing comes out, and no hand, limb, eye or creature appears in any cell. No plinth, floor, wall, glow cloud, shockwave or scenery is drawn.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the jar or its falling dust. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated frames, motion blur or speed lines.
```

---

## 4. ceramic_sentinel_walk_right_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `walk` locomotion cycle, facing right.

Supply the emergence sheet as the reference image so the emerged body identity carries.

Exports: cells 1 to 4 to `ceramic_sentinel_walk_right_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, armour decoration, palette, style and scale authority for the fully emerged ceramic sentinel. Do not copy its poses and do not draw any jar or emergence state.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body creature per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Ancient magical realism, eerie and beautiful, never cute and never gory.

Identity, in every cell: the fully emerged ceramic sentinel, same bone skull, terracotta armor with teal geometric bands and cream mask motifs, huge clay fists. The turquoise geometric bands and cream funerary face motifs from the original burial jar run across its armour plates.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: the sentinel is exactly 304 px tall from foot to skull crown when standing, and keeps that size in every cell. The lower of its two feet rests on a horizontal foot line 400 px below the top of its own cell. Its pelvis is centred horizontally in its cell. Do not resize it between cells and do not re-centre a cell on its visible pixels.

No jar, plinth, floor, wall, dust, glow or scenery is drawn in any cell.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a stride or a swinging fist does not fit inside the cell, shorten that stride within the cell. Never enlarge a cell, never crop a limb, and never shrink the sentinel.

Facing: all 4 sprites face screen-right in strict side view.

Frames, one per cell in reading order. This is one slow heavy walk cycle. The mass of the shell armour should be visible in the timing: it strides rather than runs, and the shoulders rock:
1 first contact. The leading foot lands flat and heavy on the foot line, the trailing foot still behind with the heel lifted, the torso rocked slightly back over the hips, the leading fist swung forward and low.
2 passing. The rear leg swings through under the body and passes the planted leg with clear open background between them, the shoulders level for a moment, both fists hanging.
3 second contact. The other foot lands flat on the foot line, the torso rocked slightly back the other way, the other fist swung forward and low, mirroring cell 1 in timing rather than in gear.
4 passing on the other side. The first leg swings through under the body, clear open background between the legs, shoulders level, continuing straight back into cell 1.

Change only the pose. Armour decoration, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs and under the shell plates. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. ceramic_sentinel_combat_right_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames covering neutral, attack anticipation, attack
commit, attack recovery and two stagger frames, facing right.

Batch 001 recorded that the punch crossed a nominal cell boundary on the previous combat sheet. The containment
instruction below names that case directly.

Supply the emergence sheet as the reference image.

Exports: cell 1 to `ceramic_sentinel_neutral_right_v002_000.png`, cell 2 to
`ceramic_sentinel_attack_right_v002_000.png`, cell 3 to `_001.png`, cell 4 to `_002.png`, cells 5 and 6 to
`ceramic_sentinel_stagger_right_v002_000.png` and `_001.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, armour decoration, palette, style and scale authority for the fully emerged ceramic sentinel. Do not copy its poses and do not draw any jar or emergence state.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body creature per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows. Ancient magical realism, eerie and beautiful, never cute and never gory.

Identity, in every cell: the fully emerged ceramic sentinel, same bone skull, terracotta armor with teal geometric bands and cream mask motifs, huge clay fists. The turquoise geometric bands and cream funerary face motifs from the original burial jar run across its armour plates.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: the sentinel is exactly 304 px tall from foot to skull crown when standing, and keeps that size in every cell whatever the pose. Its lowest foot rests on a horizontal foot line 400 px below the top of its own cell. Its pelvis is centred horizontally in its cell. Do not resize it between cells.

No jar, plinth, floor, wall, dust cloud, glow, shockwave, impact effect or scenery is drawn in any cell. Small flying clay chips are allowed only in cells 5 and 6, close to the body.

Containment, and this is the instruction the previous version of this sheet failed: no drawn pixel of any kind comes within 64 px of any cell edge, and no element may cross a cell boundary. A fully extended punching arm is the case that breaks this. If the extended fist does not fit inside the cell with its 64 px margin, shorten the punch within the cell. Never enlarge a cell, never crop the fist, and never shrink the sentinel to make the punch fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 neutral. Standing squared up on the foot line, feet planted at shoulder width, both fists hanging low, skull level and facing right, shell plates settled. Calm and stable. This is the pose the walk cycle returns to.
2 attack anticipation. Weight rocking back onto the rear foot, the striking arm drawn back and low behind the hip, the shoulder coiling, the skull dropping slightly forward, the whole body loaded. Clearly readable as a windup and distinct from the neutral pose in silhouette.
3 attack commit. The fist driven forward at chest height toward the right, the shoulder and hips rotating into it, weight over the front foot, the rear heel lifted. The arm is extended but the fist stays inside the cell margin.
4 attack recovery. The arm folding back in toward the ribs, the shoulder unwinding, weight resettling onto both feet, the skull coming back to level. Heavier and slower than the commit.
5 stagger, first frame. Struck from the right: the torso snapping back and away to the left, one shoulder dropping, the skull tipping back, a foot sliding back along the foot line, two or three small terracotta chips flying off close to the body.
6 stagger, second frame. The deepest point of the stagger, torso bent back and away, both arms loose and swung out for balance, one knee buckling, the shell plates visibly shifted on their mountings. It stays on its feet.

Change only the pose. Armour decoration, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs and under the shell plates. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. ceramic_sentinel_walk_left_v001.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two left-facing continuity keys.

**Continuity key sheet, not a mirror.** The sentinel's shell fragments sit asymmetrically on its body because they came
off one side of a jar. Mirroring would move them, which breaks the "the creature is the jar" reading that the whole
emergence sequence exists to establish. Compare against the right-facing walk sheet and record which side the larger
shell plates are on.

Narrow cells are correct here because a walk contact pose is narrower than a punch.

Exports: cells 1 and 2 to `ceramic_sentinel_walk_left_v001_000.png` and `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, armour decoration, palette, style and scale authority for the fully emerged ceramic sentinel. Do not mirror it. Draw the creature newly, turned to face the other way, with its shell fragments on the same side of its body as on the attached sheet, drawn as seen from this side.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body creature per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Identity, in both cells: the fully emerged ceramic sentinel, same bone skull, terracotta armor with teal geometric bands and cream mask motifs, huge clay fists.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in both cells: the sentinel is exactly 304 px tall from foot to skull crown when standing, and keeps that size in both cells. Its lower foot rests on a horizontal foot line 400 px below the top of its own cell. Its pelvis is centred horizontally in its cell.

No jar, plinth, floor, wall, dust, glow or scenery is drawn.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a stride does not fit, shorten it within the cell. Never enlarge a cell, never crop a limb, and never shrink the sentinel.

Facing: BOTH sprites face screen-LEFT in strict side view. Every skull, jaw and leading foot points left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Frames, one per cell in reading order, both from one slow heavy walk to the left:
1 first contact. The leading foot lands flat and heavy on the foot line toward the left, the trailing foot behind with the heel lifted, the torso rocked slightly back over the hips, the leading fist swung forward and low.
2 second contact. The other foot lands flat on the foot line toward the left, the torso rocked back the other way, the other fist swung forward and low.

Change only the pose and the direction it faces. Armour decoration, palette, lighting direction, scale and camera are identical to the attached sheet. Keep the larger shell fragments on the same side of its body as on the attached sheet rather than swapping them across.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs and under the shell plates. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- **Check the substitution actually happened.** After export, compare the SHA-256 of
  `ceramic_sentinel_emergence_v002_000.png` against `ceramic_jar_source_v001_000.png`. They must be identical. A
  visually similar redrawn jar is exactly the defect the emergence brief warns about, and it is invisible by eye.
- Check the same file is what the room plate composites. One jar, one export, two consumers.
- Layer separation the emergence brief asks for is a slicing task, not a prompt task: intact jar, crack accents,
  lid and rim, unfolding body, movable shell pieces, resolved shards, funerary token. Cut those from the sheets above
  rather than commissioning a second set of generations for them.
- Record the source origin and the active actor origin separately, plus the transfer marker between them. There must be
  no seam jump when the source hands off to the actor, and that is checked in the engine with these same assets, not on
  the sheet.
- The emergence preview target of roughly 1.2 to 1.8 seconds after a distinct tell is provisional and lives in
  `durations_ms`, not in the art.
