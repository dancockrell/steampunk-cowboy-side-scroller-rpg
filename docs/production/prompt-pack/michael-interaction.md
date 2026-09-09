# Michael: interaction, hurt and defeat prompts

Five prompts covering the Interaction row of the action inventory in
[sprite-animation-pipeline.md](../../sprite-animation-pipeline.md): interact 4, pull 6, hurt 3, defeat 6. Read
[README.md](README.md) first.

Two things carried over from batch 001. The `michael_interact_right_v001` sheet drew short handles and mechanisms so
that a pose would read; that is kept, strictly bounded, because a reach with nothing to reach for is unreadable, but
no full door, lever assembly or crate is drawn. And `michael_hurt_defeat_right_v001` recorded that the reclined pose
has a different bounding box and needs custom alignment; that is fixed here by putting defeat on wide cells and
registering the reclined body against the same foot line rather than re-centring it.

Hurt and defeat are non-graphic throughout: no blood, no wounds, no gore, no death iconography.

---

## 1. michael_interact_right_v002.png

Layout S4: 1024 x 1024, 2 columns x 2 rows, cell 512 x 512. Four frames, `interact` clip, facing right.

Exports: cells 1 to 4 to `michael_interact_right_v002_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 1024 pixels. If you cannot output exactly 1024 x 1024 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1024 / 2 = 512 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Props rule: no door, lever assembly, mechanism, crate, wall, plinth or scenery is drawn. He reaches toward empty background. The only exception is cell 2, where he may hold one small bronze temple object no larger than 60 px across, entirely within his hands.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells and do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a reaching arm does not fit inside the cell, shorten the reach within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is one short forward reach and return, read as approaching something at chest height on his right:
1 approach. Weight settling onto the front boot, torso leaning forward from the hips, the near arm beginning to lift and extend toward the right at chest height, head turned to look at what he is reaching for.
2 examine. The reach completed, hand up at chest height with the fingers turned as though testing a surface, and one small bronze temple object held between the fingers. The other hand rests at his belt. Head tilted slightly down toward his hand.
3 press. The arm straightens fully forward at chest height with the palm flat and the shoulder driving into the movement, the front knee bending, the rear heel lifting, the body committed forward. The small object is gone from his hands.
4 withdraw. The arm folding back to his side, the torso rising back to upright, weight redistributing evenly onto both boots, head lifting toward the right. This reads as continuing into the idle stance.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 2. michael_pull_right_v001.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames, `pull` clip, facing right.

This is the interaction pull, hauling on a fixed handle or lever with both hands. It is not the lasso pull, which lives
in [michael-lasso.md](michael-lasso.md) and has its own rope rule. Keeping the two distinct in silhouette matters: one
is a two-handed grip on a fixed object at chest height, the other is hand-over-hand on a rope.

Exports: cells 1 to 6 to `michael_pull_right_v001_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Props rule: draw ONE short bronze handle bar, roughly 80 px long and 16 px thick, gripped in both his hands. It is the same handle in all six cells and it moves with his hands. Do not draw the lever it belongs to, a mechanism, a base, a wall, a rope, a chain or anything the handle is attached to.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a reaching arm and the handle do not fit inside the cell, shorten the reach within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make the handle fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is one heavy two-handed haul on a handle to his right, and the whole body does the work:
1 take the grip. Both hands close on the handle out at chest height toward the right, arms nearly straight, feet apart with the front boot forward, back straight, head level.
2 set the body. Hips drop and shift backward, knees bend, arms still straight, shoulders pulled back a little, the front boot pressing flat, weight moving onto the rear boot. Nothing has moved yet.
3 first draw. Elbows bend and the handle comes in toward the sternum, torso leaning back, the rear knee taking load, the coat swinging forward off his back.
4 deep haul. The handle drawn back level with his ribs, torso leaning hard backward, hips well behind the heels, both arms fully engaged, the front leg straight and braced. This is the heaviest and most committed pose in the sequence.
5 hold. The same deep position with the arms locked and the shoulders set, a fraction more upright than cell 4, the head turned to look along his arms toward the right. This frame can be held.
6 release and settle. The handle let go, hands opening and coming back toward his sides, torso rising to upright, feet resettling evenly, head up and eyes right. In this cell only, the handle is not drawn.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and between the hands and the handle. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 3. michael_hurt_right_v001.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three frames, `hurt` clip, facing right.

Exports: cells 1 to 3 to `michael_hurt_right_v001_000.png` through `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 3 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Content rule: this is a non-graphic reaction. No blood, no wounds, no torn flesh, no gore, no skull or death iconography, no red spatter of any kind. The costume stays intact. The reaction is carried entirely by posture.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not re-centre him on his visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 3 sprites face screen-right in strict side view. He is struck from the right and moves away to the left, but his face stays turned toward the right in every cell.

Poses, one per cell in reading order:
1 flinch. Shoulders snap back, chest opens, chin lifts, the near arm throwing back and out, both boots still on the foot line but the weight thrown onto the rear boot, hat brim tipping up slightly.
2 cover. The near arm folds hard across the chest and ribs, shoulders round forward, head tucking down behind the raised forearm, torso curling, the front boot lifting a little as the weight goes back.
3 stagger. One backward step: the rear boot slides back along the foot line, the front boot toe still down, torso still curled over the covering arm, knees bent, the coat swinging forward. He stays on his feet. This reads as recovering rather than falling.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 4. michael_defeat_right_v001.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames, `defeat` clip, facing right.

Wide cells, and an explicit registration rule for the reclined pose. Batch 001 recorded that the reclined body has a
different bounding box and needs custom alignment. The rule below removes the need for custom alignment: the lowest
body pixel sits on the same foot line as every standing frame, and the hips stay at the cell's horizontal centre, so a
single pivot serves all six frames.

Exports: cells 1 to 6 to `michael_defeat_right_v001_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name. The hat stays on his head in every cell.

Content rule: this is a non-graphic collapse. No blood, no wounds, no gore, no skull or death iconography, no red spatter, no torn costume. It reads as exhaustion and loss of strength, not injury detail.

Scale and registration, and this is the instruction that matters most on this sheet: Michael is drawn at exactly the same size in all six cells, measuring 288 px from boot sole to hat crown when he is standing. A horizontal foot line runs 400 px below the top of every cell. In every cell, whatever the pose, his lowest body pixel rests on that line and his hips sit at the horizontal centre of his cell. In the cells where he is lying down, his body extends sideways from those hips along that line. Do not scale him down to make a lying pose fit, do not raise or lower him in the cell, and do not re-centre any cell on its visible pixels.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If an extended arm or leg does not fit inside the cell, draw that limb more folded within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make a lying pose fit.

Facing: all 6 sprites face screen-right in strict side view. His head is toward the right in every cell, including the lying cells.

Poses, one per cell in reading order:
1 give way. Standing but folding, knees buckling inward, torso dropping and curling forward over them, both arms hanging, head down, hat brim low.
2 to one knee. The rear knee reaches the foot line, the front boot still planted flat, torso bent forward over the front thigh, one forearm across the ribs, head hanging.
3 brace. Both knees down, the near hand reaching forward and pressing flat onto the foot line, arm straight and taking weight, torso low and long, head down between the shoulders.
4 slump sitting. Sitting on the foot line with the hips centred, knees drawn up loosely in front, the near arm propped behind on the line for support, torso rounded, chin near the chest.
5 reclined. Lying on his side along the foot line, hips at the cell centre, head to the right resting near his own outstretched near arm, knees loosely bent toward the left, coat spread on the line behind him, hat still on. The body is still and unconscious rather than contorted.
6 push up. Beginning to recover: still low but with the near hand planted flat on the foot line, one knee gathered under the hips at the cell centre, torso lifting, head starting to rise toward the right.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs and arms, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. michael_interaction_left_v001.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three left-facing continuity keys, one from each of three
clips.

**Continuity key sheet, not a mirror.** Interaction poses are where a mirrored sheet is hardest to catch, because a
reach reads plausibly from either side. Compare cell by cell against the right-facing sheets and record which side the
bracer, holster and reaching arm are on.

Exports: cell 1 to `michael_interact_left_v001_002.png`, cell 2 to `michael_pull_left_v001_003.png`, cell 3 to
`michael_hurt_left_v001_001.png`. The frame indices match the corresponding right-facing frames so the pair can be
compared directly.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Use the attached sheets ONLY as the identity, costume, palette, style and scale authority for Michael. Do not mirror them. Draw him newly, turned to face the other way, with his equipment on the anatomically correct side of his body rather than on the mirrored side.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 3 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: ALL 3 sprites face screen-LEFT in strict side view. Every face, nose, hat brim front and reaching direction points left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Poses, one per cell in reading order:
1 press. The arm straightened fully forward at chest height toward the left with the palm flat and the shoulder driving into the movement, the front knee bending, the rear heel lifting, the body committed forward. No door, mechanism or scenery is drawn.
2 deep haul. Both hands gripping one short bronze handle bar roughly 80 px long and 16 px thick, drawn back level with his ribs, torso leaning hard backward with the hips well behind the heels, the front leg straight and braced toward the left. Only the handle is drawn, nothing it is attached to.
3 cover. The near arm folded hard across the chest and ribs, shoulders rounded forward, head tucked behind the raised forearm, torso curling, weight thrown back away from the left. No blood, wounds or gore.

Change only the pose and the direction he faces. Face structure, costume, equipment, palette, lighting direction, scale and camera are identical to the attached sheets. Keep the brass mechanical forearm bracer, the pistol holster and the coiled lasso on the same arm and hip they occupy on the attached sheets, drawn as seen from this side, rather than swapping them to the other side of his body.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and between the hands and the handle. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- The defeat sheet's registration rule is the thing to measure first. Crop each cell, find the lowest non-background
  pixel and the horizontal centre of the hips, and report both numbers per cell. If cell 5 disagrees with cells 1 to 4,
  the sheet has the batch 001 defect again and re-cropping will not fix it.
- Hurt must interrupt aiming and reload in code. That is covered by tests in
  [weapon-tool-kit.md](../../weapon-tool-kit.md), not by these frames, but the frames need to read as an interruption
  rather than as a separate idle.
- Recovery from defeat is authored here as frame 005. Whether the game actually uses a recovery, or respawns at a
  checkpoint, is a design decision that has not been made. The frame exists so the option is not foreclosed by missing
  art.
