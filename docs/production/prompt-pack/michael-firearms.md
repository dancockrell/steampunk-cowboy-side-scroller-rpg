# Michael: firearm prompts

Nine prompts covering the Pistol, Shotgun and Rifle rows of the action inventory in
[sprite-animation-pipeline.md](../../sprite-animation-pipeline.md): pistol aim 1, fire 3, recover 2, reload 5;
shotgun aim 1, fire_recoil 5, recover 3, reload 6; rifle aim 2, fire 3, recover 3, reload 6. Read
[README.md](README.md) first.

The three weapons must be distinguishable from silhouette alone. That comes from
[michael-pose-brief.md](../michael-pose-brief.md) and it is written into every prompt below as an explicit stance
instruction rather than left to the weapon shape to carry:

| Weapon | Stance direction the prompt carries |
| --- | --- |
| Pistol | Compact arm extension, quick visible hand kick, short recovery. Feet close together, body narrow, one arm doing the work |
| Shotgun | Broader braced stance, shoulder and torso recoil, deliberate recovery. Feet wide, body square, whole torso absorbing |
| Rifle | Sustained alignment, cheek to shoulder, small precise shot response. Feet in line, body long and still, head committed to the stock |

Two things the batch 001 firearm sheets got wrong and these prompts remove. Muzzle flash is not drawn on any body
sheet; it lives on the three VFX sheets in [ui-and-vfx.md](ui-and-vfx.md) and is composited at the `muzzle` socket, so
a flash can never be the thing that reaches a cell edge. And the reload mechanism is named once per weapon and repeated
identically in each frame description, because the pose brief warns against inventing a mechanism independently in
every frame.

Aim direction is side-view only. Do not commission a directional aim set until the controller establishes the
permitted range and the overlay method.

Weapon identity lines below are quoted from the batch 001 records so the guns do not drift either.

---

## 1. michael_pistol_right_v002_partA.png

Layout S6: 1536 x 1024, 3 columns x 2 rows, cell 512 x 512. Six frames spanning three clips, facing right.

Exports: cell 1 to `michael_pistol_aim_right_v002_000.png`, cells 2 to 4 to `michael_pistol_fire_right_v002_000.png`
through `_002.png`, cells 5 and 6 to `michael_pistol_recover_right_v002_000.png` and `_001.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Divide the image into exactly 3 columns by 2 rows of equal cells: 1536 / 3 = 512 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the same single antique brass-and-dark-steel revolver in all frames, held in the same hand in all frames, drawn at the same size in all frames. Correct hand anatomy on the grip, finger on the trigger only when firing.

Stance identity, and this must survive a silhouette-only comparison against a shotgun sheet and a rifle sheet: this is the PISTOL stance. Feet close together, body narrow and upright, one arm doing all the work, the off hand free. Compact arm extension, a quick visible hand kick on the shot, and a short recovery. Do not brace the shoulder, do not widen the feet, do not bring the head down to the weapon.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells.

No muzzle flash, smoke, sparks, spent casings, tracer, impact or glow are drawn anywhere on this sheet. Those are separate effect art and are added later.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the extended arm and revolver do not fit inside the cell, shorten the arm extension within the cell. Never enlarge a cell, never crop the barrel or the hat, and never shrink Michael to make the revolver fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 aim. Revolver held out at shoulder height toward the right in one straight but not locked arm, head level and sighting along the barrel, off hand relaxed at his side, feet close together, weight even.
2 fire, first frame. The same aim with the trigger pulled and the hammer down, the arm still on line, the body not yet reacting. The pose is almost identical to cell 1 and differs only at the hand and hammer.
3 fire, second frame. The wrist and forearm kick up sharply, the revolver muzzle rising well above the line of the shoulder, elbow bending, shoulder rolling back a little, the rest of the body still.
4 fire, third frame. The kick at its top, muzzle highest, head still level and looking along the original line, off hand come up slightly for balance.
5 recover, first frame. The arm settling back down, muzzle dropping toward the original line, elbow straightening, off hand returning to his side.
6 recover, second frame. Returned to the cell 1 aim posture with the hammer forward and the arm relaxed a fraction lower than in cell 1, ready to fire again or to lower the weapon.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the trigger guard. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 2. michael_pistol_right_v002_partB.png

Layout S6: 1536 x 1024, 3 columns x 2 rows, cell 512 x 512. Six frames, `pistol_reload` clip, facing right.

**Budget change, stated in the open.** The pipeline budgets pistol reload at five frames. Five does not tile onto any
layout in the geometry table, and splitting one clip across two generations risks scale drift between them. This is
commissioned at six, with the sixth frame being the return to the ready position. The pipeline calls those counts
initial budgets rather than mandates, so this is a change made deliberately rather than a violation, but it is a
change and a reviewer may cut cell 6.

Supply part A as the reference image so the revolver does not drift.

Exports: cells 1 to 6 to `michael_pistol_reload_right_v002_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, weapon, palette, style and scale authority for Michael. Do not copy its poses. Draw six new poses.

Divide the image into exactly 3 columns by 2 rows of equal cells: 1536 / 3 = 512 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the same single antique brass-and-dark-steel revolver in all frames, held in the same hand in all frames, drawn at the same size in all frames.

Reload mechanism, the same in all six cells: a side loading gate behind the cylinder swings open, and single brass cartridges are pushed in one at a time from a belt loop at his waist. Do not swing the cylinder out to the side, do not use a magazine, a clip, a speedloader or a break action. Whatever the gate looks like in cell 2 it looks the same in cells 3, 4 and 5.

Stance identity: this is the PISTOL family. Feet close together, body narrow and upright, work done at chest height in front of the sternum. Do not brace, do not widen the feet.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

No muzzle flash, smoke, sparks, glow or falling spent casings are drawn anywhere on this sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop the revolver or the hat, and never shrink Michael.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 lower and turn. The revolver comes down from the aim line to chest height and rotates so its left side faces him, muzzle angled down and forward, head dropping to look at the weapon.
2 open the gate. The off hand comes across and thumbs the loading gate open behind the cylinder, both hands now at the weapon, elbows in.
3 take a cartridge. The off hand drops to a brass cartridge in the belt loop at his waist and pinches it out, the revolver held steady at chest height in the weapon hand with the gate still open.
4 seat a cartridge. The off hand brings the cartridge up and presses it into the open gate, thumb behind it, head still down watching the work.
5 index the cylinder. The off hand thumb rolls the cylinder around one chamber, the gate still open, the second cartridge already reaching from the belt. This reads as a repeatable middle of the cycle.
6 close and ready. The gate is pushed shut, the revolver rotates back upright in the weapon hand, the off hand drops away to his side, head lifting toward the right. This pose reads as continuing into the aim pose.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the trigger guard. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 3. michael_shotgun_right_v002_partA.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames spanning two clips, facing right.

Exports: cell 1 to `michael_shotgun_aim_right_v002_000.png`, cells 2 to 6 to
`michael_shotgun_fire_recoil_right_v002_000.png` through `_004.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the identical antique wood, brass and steel short double-barrel shotgun in all frames, held in the same two hands in all frames, drawn at the same length in all frames. The revolver stays in its holster throughout.

Stance identity, and this must survive a silhouette-only comparison against a pistol sheet and a rifle sheet: this is the SHOTGUN stance. Feet planted wide apart, body square and heavy, both hands on the weapon, the butt braced hard into the shoulder pocket. Broad braced stance, the recoil travelling through the shoulder and the whole torso, and a deliberate slow recovery. Do not shoot one-handed and do not go still and long like a rifleman.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells.

No muzzle flash, blast, smoke, sparks, wadding, spent shells, glow or impact are drawn anywhere on this sheet. Those are separate effect art and are added later.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the barrels do not fit inside the cell, angle the weapon further down within the cell. Never enlarge a cell, never crop a barrel or the hat, and never shrink Michael to make the shotgun fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 braced aim. Feet wide with the front boot forward and flat, knees softly bent, both hands on the shotgun, butt into the shoulder, barrels level toward the right, cheek near but not on the stock, head level and forward.
2 fire, first frame. The same braced aim at the instant of the shot, hands and stance unchanged, barrels still level, the only difference at the hammers and the trigger hand.
3 fire, second frame. The barrels lift sharply, the butt drives back into the shoulder, the shoulder rolls up and back, the front elbow rises.
4 fire, third frame. Recoil at its peak. The muzzles are well above the shoulder line, the torso has rotated back, the rear boot has taken most of the weight, the hat brim is pushed up a little by the head tilting back.
5 fire, fourth frame. The torso begins to come forward again against the recoil, barrels starting to drop, weight moving back toward the front boot, the grip unchanged.
6 fire, fifth frame. Barrels dropped to just above the aim line, torso nearly square again, weight resettling wide, the pose reading as continuing into the recover clip rather than as a finished stop.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and between the two barrels. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 4. michael_shotgun_right_v002_partB.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three frames, `shotgun_recover` clip, facing right.

Narrow cells are correct here only because the weapon is lowered and angled down through all three frames. If the
delivered sheet has the barrels level in any cell, it will fail containment and must be regenerated, not re-cropped.

Supply part A as the reference image.

Exports: cells 1 to 3 to `michael_shotgun_recover_right_v002_000.png` through `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, weapon, palette, style and scale authority for Michael. Do not copy its poses. Draw three new poses.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 3 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the identical antique wood, brass and steel short double-barrel shotgun in all frames, held in the same two hands, drawn at the same length. In every cell of this sheet the barrels point DOWN AND FORWARD at roughly forty-five degrees, never level, so the weapon stays inside the cell.

Stance identity: this is the SHOTGUN family. Feet stay planted wide and the body stays square and heavy through the whole recovery.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

No muzzle flash, smoke, sparks, spent shells or glow are drawn anywhere on this sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the barrels do not fit, angle them further down within the cell. Never enlarge a cell, never crop a barrel or the hat, and never shrink Michael.

Facing: all 3 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is settling after a shot, and it should read as heavy and unhurried:
1 the weight comes down. The butt slides out of the shoulder pocket, both hands lower the shotgun to chest height with the barrels angled down and forward, the shoulders drop, the torso still square, the head turning back toward the right.
2 the stance eases. The shotgun is carried at waist height, barrels angled down and forward, the rear knee straightening, the front boot easing back a short distance so the stance narrows a little, the shoulders rolling back.
3 ready again. The shotgun held low across the body at waist height with the barrels still angled down and forward, both hands in a relaxed carry, feet planted at a comfortable width, head up and eyes right. This reads as continuing into the braced aim rather than as a finished stop.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and between the two barrels. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. michael_shotgun_right_v002_partC.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames, `shotgun_reload` clip, facing right.

Supply part A as the reference image.

Exports: cells 1 to 6 to `michael_shotgun_reload_right_v002_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, weapon, palette, style and scale authority for Michael. Do not copy its poses. Draw six new poses.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the identical antique wood, brass and steel short double-barrel shotgun in all frames, drawn at the same length in all frames.

Reload mechanism, the same in all six cells: the shotgun breaks open at a hinge in front of the trigger guard so the barrels drop, and two brass-based shells are taken from loops on his belt and pushed into the two open breeches. Do not use a pump, a magazine tube, a bolt, or a side gate. The hinge and the belt loops look the same in every cell.

Stance identity: this is the SHOTGUN family. Feet stay wide, body square and heavy, both hands on the work.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

No muzzle flash, smoke, sparks or glow are drawn anywhere on this sheet. Ejected spent shells may be drawn only in cell 2, close to the weapon, and nowhere else.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the dropped barrels do not fit, shorten the break angle within the cell. Never enlarge a cell, never crop a barrel or the hat, and never shrink Michael.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 break open. The shotgun is brought down across the body to waist height, the top lever pushed over and the barrels swinging down and open on the hinge, head dropping to watch, feet wide.
2 clear. The barrels fully open and pointing down and forward, two small spent brass-based shells falling clear just below the breeches, the off hand steadying the fore-end.
3 take shells. The off hand drops to the belt loops at his waist and takes two fresh brass-based shells between the fingers, the broken-open shotgun held steady at waist height in the weapon hand.
4 seat shells. The off hand brings both shells up and pushes them into the two open breeches, thumb behind them, head down and close to the work.
5 close. The off hand swings the barrels back up and the action snaps shut, the shotgun rotating toward horizontal at waist height, head beginning to lift.
6 ready. The closed shotgun held low across the body at waist height with the barrels angled down and forward, both hands in a relaxed carry, feet wide, head up and eyes right. This pose reads as continuing into the braced aim.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and between the two barrels. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. michael_rifle_right_v002_partA.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames spanning three clips, facing right.

Exports: cells 1 and 2 to `michael_rifle_aim_right_v002_000.png` and `_001.png`, cells 3 to 5 to
`michael_rifle_fire_right_v002_000.png` through `_002.png`, cell 6 to `michael_rifle_recover_right_v002_000.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the identical long wood and brass antique lever-action rifle in all frames, held in the same two hands in all frames, drawn at the same length in all frames. The revolver stays in its holster throughout.

Stance identity, and this must survive a silhouette-only comparison against a pistol sheet and a shotgun sheet: this is the RIFLE stance. Feet close and roughly in line with the direction of fire, body long, narrow and very still, the head brought down so the cheek meets the stock, the butt firmly in the shoulder, front elbow tucked under the fore-end. Sustained alignment and a small precise response to the shot. Do not stand square and wide like a shotgunner and do not shoot one-handed.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells.

No muzzle flash, smoke, sparks, spent casings, tracer, impact or glow are drawn anywhere on this sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the long barrel does not fit inside the cell, angle the rifle slightly downward within the cell. Never enlarge a cell, never crop the barrel or the hat, and never shrink Michael to make the rifle fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 aim, first frame. The rifle coming up to the shoulder, butt reaching the shoulder pocket, head starting to come down toward the stock, barrel rising toward level, feet settling in line.
2 aim, second frame. Full sustained alignment. Cheek on the stock, eye behind the sights, butt seated, front hand well out on the fore-end, body long and completely still, barrel level toward the right.
3 fire, first frame. The same alignment at the instant of the shot, cheek still on the stock, the only visible change at the hammer and trigger hand.
4 fire, second frame. A small precise response. The muzzle rises only slightly, the shoulder absorbs the push, the cheek stays on the stock and the head barely moves.
5 fire, third frame. The muzzle at the top of its small rise, the torso rocked back a fraction over the rear boot, the cheek still on the stock and the eye still behind the sights.
6 recover, first frame. The muzzle settling back toward level, the shoulder easing, the front hand relaxing on the fore-end, the cheek beginning to lift off the stock.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the lever loop. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 7. michael_rifle_right_v002_partB.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two frames, `rifle_recover` clip, facing right.

Narrow cells are correct here only because the rifle is angled steeply down in both frames. A level barrel in either
cell fails containment.

Supply part A as the reference image.

Exports: cells 1 and 2 to `michael_rifle_recover_right_v002_001.png` and `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, weapon, palette, style and scale authority for Michael. Do not copy its poses. Draw two new poses.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the identical long wood and brass antique lever-action rifle in both frames, held in the same two hands, drawn at the same length. In both cells the barrel points DOWN AND FORWARD at roughly fifty degrees, steeply enough that the whole rifle stays inside the cell. Never level.

Stance identity: this is the RIFLE family. Feet stay close and roughly in line, body long and narrow, movements small and controlled.

Scale and registration, identical in both cells: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in both cells. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

No muzzle flash, smoke, sparks, spent casings or glow are drawn anywhere on this sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the barrel does not fit, angle it further down within the cell. Never enlarge a cell, never crop the barrel or the hat, and never shrink Michael.

Facing: both sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 the rifle comes down. The butt leaves the shoulder pocket and the rifle lowers across the front of his body, barrel angled steeply down and forward, head lifting and turning back toward the right, the front hand sliding back along the fore-end.
2 low carry. The rifle held one-handed at the balance point beside his hip with the barrel angled steeply down and forward, the other hand free at his side, feet settled close and in line, head up and eyes right. This pose reads as continuing into the aim clip.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in both cells and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the lever loop. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 8. michael_rifle_right_v002_partC.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames, `rifle_reload` clip, facing right.

Supply part A as the reference image.

Exports: cells 1 to 6 to `michael_rifle_reload_right_v002_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, weapon, palette, style and scale authority for Michael. Do not copy its poses. Draw six new poses.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Weapon: the identical long wood and brass antique lever-action rifle in all frames, drawn at the same length in all frames.

Reload mechanism, the same in all six cells: brass cartridges are pushed one at a time into a loading gate on the right side of the receiver, ahead of the hammer, and the brass finger lever below the trigger guard is cycled to chamber a round. Do not use a magazine, a clip, a bolt, a break action or a stripper. The gate and the lever look the same in every cell.

Stance identity: this is the RIFLE family. Feet close and roughly in line, body long and narrow, work done close to the chest with small controlled movements.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

No muzzle flash, smoke, sparks or glow are drawn anywhere on this sheet. An ejected spent case may be drawn only in cell 5, close to the receiver, and nowhere else.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the rifle does not fit, angle it further down within the cell. Never enlarge a cell, never crop the barrel or the hat, and never shrink Michael.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order:
1 bring it across. The rifle comes down out of the shoulder and rotates across the front of his chest with the receiver toward him and the barrel angled down and forward, the head dropping to watch the receiver.
2 take a cartridge. The off hand drops to a row of brass cartridges in loops on his belt and pinches one out, the rifle held steady across the chest in the weapon hand, barrel still angled down and forward.
3 seat a cartridge. The off hand presses the cartridge into the loading gate on the side of the receiver, thumb behind it, elbows tucked in, head down close to the work.
4 the repeatable middle. A second cartridge already in the off hand and travelling up toward the gate, the rifle held in exactly the same position across the chest. This frame reads as one that can be held or repeated.
5 cycle the lever. The weapon hand swings the brass finger lever down and forward and back, the action open at the top of the receiver, a small spent case clearing beside it, the rifle still across the chest.
6 back to the shoulder. The rifle rotating up and out toward the right, butt travelling to the shoulder pocket, the off hand sliding forward along the fore-end, head beginning to come down toward the stock. This pose reads as continuing into the aim clip.

Change only the pose. Face, costume, equipment, weapon, palette, lighting direction, scale and camera are identical in every cell and match the attached sheet.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the lever loop. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 9. michael_firearm_aim_left_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four left-facing continuity keys, one per weapon plus one
firing key.

**Continuity key sheet, not a mirror.** This is the single most important handedness test in the pack, because a
mirrored firearm sheet silently swaps the canonical weapon hand, which is exactly what
[art-direction.md](../../art-direction.md) forbids. Compare it cell by cell against the right-facing sheets and record
which side the bracer, holster and weapon hand are on. Do not adopt a mirror rule on the strength of this sheet looking
acceptable; record the finding and let a reviewer decide.

Mixing three weapons on one sheet is intentional here. It is a comparison sheet, not a clip.

Exports: cell 1 to `michael_pistol_aim_left_v001_000.png`, cell 2 to `michael_shotgun_aim_left_v001_000.png`, cell 3 to
`michael_rifle_aim_left_v001_000.png`, cell 4 to `michael_pistol_fire_left_v001_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheets ONLY as the identity, costume, weapon, palette, style and scale authority for Michael. Do not mirror them. Draw him newly, turned to face the other way, with his equipment on the anatomically correct side of his body rather than on the mirrored side.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the weapon. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

No muzzle flash, smoke, sparks, spent casings or glow are drawn anywhere on this sheet, including in the firing cell.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a barrel does not fit, angle the weapon downward within the cell. Never enlarge a cell, never crop a barrel or the hat, and never shrink Michael to make a weapon fit.

Facing: ALL 4 sprites face screen-LEFT in strict side view. Every face, nose, hat brim front and muzzle points left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Poses, one per cell in reading order:
1 pistol aim. The same single antique brass-and-dark-steel revolver held out at shoulder height toward the left in one straight arm, feet close together, body narrow and upright, off hand relaxed at his side, head level sighting along the barrel.
2 shotgun braced aim. The identical antique wood, brass and steel short double-barrel shotgun, butt in the shoulder pocket, barrels level toward the left, feet planted wide with the front boot forward, body square and heavy, both hands on the weapon.
3 rifle sustained aim. The identical long wood and brass antique lever-action rifle, butt seated, cheek on the stock, eye behind the sights, barrel level toward the left, feet close and roughly in line, body long, narrow and still.
4 pistol fire, kick frame. The same revolver at the top of its recoil kick, wrist and forearm lifted so the muzzle rises well above the shoulder line, elbow bent, head still level looking along the original line toward the left, feet close together.

Change only the pose, the weapon and the direction he faces. Face structure, costume, equipment, palette, lighting direction, scale and camera are identical to the attached sheets. Keep the brass mechanical forearm bracer, the pistol holster and the coiled lasso on the same arm and hip they occupy on the attached sheets, drawn as seen from this side, rather than swapping them to the other side of his body. Keep each weapon in the same hand it occupies on the attached sheets.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim, between barrels and through trigger guards. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- **The silhouette test is a real test, not a slogan.** Take the aim frame from each of the three families, reduce each
  to a solid black shape on white, place them side by side at native scale, and confirm a reviewer can name each weapon
  with the detail removed. If two of the three cannot be told apart, the pose brief's direction has not landed and the
  sheets should be regenerated rather than accepted with a note.
- The `muzzle` socket must be authored per frame for every fire frame, and something must read it. Once the first fire
  frames exist, `grep -rn "muzzle" src/` and confirm the socket is consumed rather than merely written.
- A replayed fire clip must not spend ammunition or deal damage twice. That is a code property, not an art property,
  but it is the reason `muzzle_flash` is a presentation marker rather than an authoritative event.
