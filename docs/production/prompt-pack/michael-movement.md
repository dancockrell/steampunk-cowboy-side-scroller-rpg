# Michael: movement prompts

Six prompts covering the Movement row of the action inventory in
[sprite-animation-pipeline.md](../../sprite-animation-pipeline.md): idle 4, run 8, jump_rise 2, jump_apex 1, fall 2,
land 3. Read [README.md](README.md) first for the geometry table, the extraction rule and the acceptance checklist.

Run is split into a keys sheet and an inbetweens sheet because
[michael-pose-brief.md](../michael-pose-brief.md) says to commission frames 000, 002, 004 and 006 first and approve the
motion intent before filling the loop. Generate part A, review it, and only then generate part B.

Jump, apex, fall and land are split across two sheets by frame count rather than by clip. That is deliberate: keeping
four frames in one generation holds the scale steady, and the per-frame export names below carry the real clip
boundaries.

Every sheet here is a candidate. Nothing in this file approves a frame count, a face or a costume.

---

## 1. michael_idle_right_v001.png

Layout S4: 1024 x 1024, 2 columns x 2 rows, cell 512 x 512. Four frames, `idle` clip, facing right.

Exports: cell 1 to `michael_idle_right_v001_000.png`, cell 2 to `_001.png`, cell 3 to `_002.png`, cell 4 to `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 1024 pixels. If you cannot output exactly 1024 x 1024 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1024 / 2 = 512 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. He is centred horizontally in his cell. Do not resize him between cells and do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a coat tail or a piece of gear does not fit inside the cell, draw it smaller within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make a prop fit.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is one quiet standing breathing loop, both boots planted the whole time, hat and head held steady:
1 settled neutral stance, weight even, hands relaxed at his sides, coat hanging still.
2 chest rises slightly on the intake, shoulders lift a little, coat tails drift a fraction back.
3 chest settles, shoulders drop back to neutral, coat tails swing a fraction forward past rest.
4 coat and shoulders return toward the frame 1 pose so the loop closes without a jump.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell. Boot positions do not move between cells.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 2. michael_run_right_v003_partA.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `run` clip keys, facing right. Wide cells
because the extended stride and trailing coat exceed the usable width of a 512 px cell.

Exports: cell 1 to `michael_run_right_v003_000.png`, cell 2 to `_002.png`, cell 3 to `_004.png`, cell 4 to `_006.png`.
Note the export indices skip; these are the keys, and part B supplies 001, 003, 005 and 007.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. The lower of his two boots rests on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells and do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the stride or a coat tail does not fit inside the cell, shorten that stride within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make the stride fit.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. These are the four key poses of one running cycle, not four separate runs. No weapon is held in either hand; the pistol stays holstered and the lasso stays coiled on the belt:
1 first contact. Leading leg extends forward and the heel meets the foot line, trailing heel lifts clear, torso carries a forward lean, hat and head level.
2 passing pose. The rear leg swings under the body and passes the planted leg, knees clearly separated with open background visible between them, hands swing past each other without touching.
3 second contact. The opposite leg reaches forward to the foot line, torso mass preserved, forward lean matched to cell 1, arm swing reversed from cell 1.
4 passing pose on the other side. The first leg swings under the torso, clear open background between the limbs, hands swing past each other with the opposite arm leading.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell. The coat lags behind the pelvis rather than floating.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 3. michael_run_right_v003_partB.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `run` clip inbetweens, facing right.

Generate this only after part A has been reviewed. Supply the approved part A sheet as the reference image.

Exports: cell 1 to `michael_run_right_v003_001.png`, cell 2 to `_003.png`, cell 3 to `_005.png`, cell 4 to `_007.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, palette, style and scale authority for Michael. Do not copy its poses. Draw four new poses.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell and identical to the attached sheet: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. The lower of his two boots rests on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells and do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the stride or a coat tail does not fit inside the cell, shorten that stride within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make the stride fit.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. These are the four inbetween poses of the same running cycle as the attached sheet. No weapon is held in either hand:
1 compression. Weight settles fully over the planted boot, the supporting knee bends, the whole body sits at its lowest point of the cycle, the coat lags behind the pelvis.
2 push-off. The supporting leg straightens and drives, the body reaches its highest point of the cycle, the coat catches up without floating away from the back.
3 opposite compression. Weight settles over the other boot at the same depth as cell 1, matching amplitude exactly.
4 opposite push-off. The other leg drives, matching the height of cell 2, hat and hip line continuing straight into the first key pose of the attached sheet.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 4. michael_run_left_v003_partA.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `run` clip keys, facing left.

**This is a continuity key sheet, not a mirror.** It exists to answer the handedness question
[michael-pose-brief.md](../michael-pose-brief.md) leaves open. Do not produce it by flipping the right-facing sheet, and
do not accept it if the brass bracer, holster and lasso coil have swapped sides relative to the right-facing sheet
without a stated reason. Acceptance checklist item 11 is the one that matters here.

Exports: cell 1 to `michael_run_left_v003_000.png`, cell 2 to `_002.png`, cell 3 to `_004.png`, cell 4 to `_006.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, palette, style and scale authority for Michael. Do not mirror it. Draw him newly, turned to face the other way, with his equipment on the anatomically correct side of his body rather than on the mirrored side.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. The lower of his two boots rests on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells and do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the stride or a coat tail does not fit inside the cell, shorten that stride within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make the stride fit.

Facing: ALL 4 sprites face screen-LEFT in strict side view. Every face, nose, hat brim front and leading boot points left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Poses, one per cell in reading order. These are the four key poses of one running cycle, moving left. No weapon is held in either hand:
1 first contact. Leading leg extends toward the left and the heel meets the foot line, trailing heel lifts clear, torso leans left, hat and head level.
2 passing pose. The rear leg swings under the body and passes the planted leg, knees clearly separated with open background visible between them.
3 second contact. The opposite leg reaches leftward to the foot line, torso mass preserved, arm swing reversed from cell 1.
4 passing pose on the other side. The first leg swings under the torso, clear open background between the limbs, opposite arm leading.

Change only the pose and the direction he faces. Face structure, costume, equipment, palette, lighting direction, scale and camera are identical to the attached sheet. Keep the brass mechanical forearm bracer, the pistol holster and the coiled lasso on the same arm and hip they occupy on the attached sheet, drawn as seen from this side, rather than swapping them to the other side of his body.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. michael_jump_right_v002_partA.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames spanning three clips, facing right.

The foot line still applies even though Michael is airborne in three of these four cells. It is the alignment
reference, not a claim that he is standing: real vertical movement belongs to the controller.

Exports: cell 1 to `michael_jump_rise_right_v002_000.png`, cell 2 to `michael_jump_rise_right_v002_001.png`, cell 3 to
`michael_jump_apex_right_v002_000.png`, cell 4 to `michael_fall_right_v002_000.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. A horizontal foot line runs 400 px below the top of every cell. In cell 1 his boots rest on that line. In cells 2, 3 and 4 he is airborne and his boots are drawn above that line, but his body is positioned as if the same line still ran under him: do not raise or lower him in the cell to make the pose look better, and do not re-centre him on his visible pixels. His pelvis is centred horizontally in his cell in every cell.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a coat tail or a raised boot does not fit inside the cell, draw it smaller within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. No weapon is held in either hand:
1 jump rise, compression release. Both boots on the foot line, knees deeply bent, torso folded forward over the thighs, arms swung back behind the hips, the whole body loaded and about to extend.
2 jump rise, elongation. Airborne and rising, body stretched into its longest vertical line, legs trailing below and slightly behind, arms swept up and forward, coat tails streaming down and back, hat firmly seated.
3 apex. Airborne, compact and balanced, knees tucked up toward the chest, arms drawn in close, torso upright, the coat gathered rather than streaming. This is a settled, readable, held pose.
4 fall, first frame. Airborne and descending, knees unfolding, boots swinging forward and down to gather under the centre of mass, arms coming out for balance, coat tails lifting upward behind him.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell. Squash and stretch may alter the silhouette modestly but must not change the hat size, the head size or the identity.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. michael_jump_right_v002_partB.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames spanning two clips, facing right.

Supply the approved part A sheet as the reference image so the airborne scale carries across.

Exports: cell 1 to `michael_fall_right_v002_001.png`, cell 2 to `michael_land_right_v002_000.png`, cell 3 to
`michael_land_right_v002_001.png`, cell 4 to `michael_land_right_v002_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, palette, style and scale authority for Michael. Do not copy its poses. Draw four new poses.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. A horizontal foot line runs 400 px below the top of every cell. In cell 1 he is airborne with his boots above that line but positioned as if the same line still ran under him. In cells 2, 3 and 4 his boots rest on that line. His pelvis is centred horizontally in his cell in every cell. Do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a coat tail or a braced hand does not fit inside the cell, draw it smaller within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. No weapon is held in either hand, and no dust, impact effect or ground is drawn:
1 fall, second frame. Airborne and descending faster, boots gathered directly under the centre of mass and reaching for the ground, knees slightly bent ready to absorb, torso upright, arms low and out, coat tails lifted high behind him.
2 landing contact. Both boots meet the foot line together, legs still nearly straight, torso beginning to travel down, coat tails still lifted from the fall, head level and eyes forward.
3 landing compression. Knees bent deeply, hips low, torso folded forward over the thighs, one hand dropping toward the ground without touching it, coat gathered and hanging, the lowest and heaviest pose of the three.
4 landing recovery. Rising back out of the crouch toward a standing stance, knees half straightened, torso lifting, arms returning to his sides, coat settling. This pose reads as continuing into the idle stance rather than as a finished stop.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- Inspect run, jump, fall, land and run again as one sequence at native scale, not as isolated loops. That is the check
  [michael-pose-brief.md](../michael-pose-brief.md) asks for and it is the one that catches foot skating.
- Do not fix skating by rescaling individual frames. Acceptance checklist item 7 exists to make that visible.
- The 640 ms run loop in the pose brief is a preview proposal, not a controller speed. Timing lives in the
  AnimationClip `durations_ms` field, not in the art.
