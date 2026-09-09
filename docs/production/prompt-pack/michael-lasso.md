# Michael: lasso prompts

Eight prompts covering the Lasso row of the action inventory in
[sprite-animation-pipeline.md](../../sprite-animation-pipeline.md): throw 6, attached_hold 2, pull 6, swing 4,
release 3, miss_recover 3. Read [README.md](README.md) first.

The lasso is the identity tool and gets the highest attention in the pipeline. It is also where batch 001's second
recorded defect landed: rope crossed nominal cell boundaries on `michael_lasso_right_v001`, so the sheet could not be
grid-sliced.

The fix is not to draw a smaller rope on the body sheet. [michael-pose-brief.md](../michael-pose-brief.md) is explicit
that the rope loop is a separate visual element when its arc exceeds the cell, and that Michael is never shrunk to fit a
wide loop. So the body sheets below carry **only the rope that stays in Michael's hands**, and the flying loop lives on
its own overlay sheet, prompt 7, registered to a single fixed grip point that the compositor translates to each frame's
`hand_lasso` socket.

Never bake a successful attachment or a destination into a throw frame. `rope_attach` is emitted by an actual contact
event, not by reaching frame 005.

---

## 1. michael_lasso_throw_right_v002.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames, `lasso_throw` clip, facing right.

Exports: cells 1 to 6 to `michael_lasso_throw_right_v002_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells and do not re-centre him on his visible pixels.

Rope rule, and this is the most important instruction on the sheet: draw ONLY the short length of rope that stays in his hands and on his belt. Do not draw a large flying loop, a rope arc travelling away from him, a target, an anchor or a rope leaving the cell. Any rope drawn must stay within 100 px of his hands. The flying loop is drawn on a separate overlay sheet and composited later.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a coat tail, an outstretched arm or the held rope does not fit inside the cell, draw that element smaller within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael to make the rope fit.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is one lasso throw, and the throwing arm is the same arm in all six cells:
1 set stance. Both boots planted, weight even, head and eyes turned toward the right, the coiled rope gathered at his hip in his off hand, throwing hand resting on the coil. Nothing is in flight.
2 anticipation. Throwing arm drawn back and up behind the shoulder, weight shifted over the rear boot, torso coiled, chest opening toward the right. This must read as a rope windup and not as raising a firearm.
3 loop crest. Throwing arm at the top of its arc above and behind the shoulder, wrist cocked, the short held length of rope rising out of the hand and cut off at the edge of the rope rule above. Weight still rearward.
4 cast. Throwing arm extended forward and slightly down toward the right, hand open at the moment of release, torso uncoiling, front boot taking weight. The rope has left the hand; only a short trailing length remains near the fingers.
5 follow through. Arm continuing forward and down past the cast, body weight fully moved onto the front boot, rear heel lifting, coat swinging forward. Off hand still holds the belt coil.
6 settle. Body returning to a balanced waiting stance with the throwing hand held ready at chest height, eyes still toward the right. This is a neutral hold that can continue into either a taut rope or an empty recovery; it does not show a successful catch.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through any rope coil. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 2. michael_lasso_attached_hold_right_v001.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two frames, `lasso_attached_hold` clip, facing right.

The pose brief is specific that this is two subtle tension poses, not two alternating attachment points.

Exports: cells 1 and 2 to `michael_lasso_attached_hold_right_v001_000.png` and `_001.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 2 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in both cells: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in both cells. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

Rope rule: draw ONLY the short length of rope gripped in his hands, no more than 100 px of it, ending cleanly where it leaves the frame of his grip. Do not draw a rope running away toward a target, an anchor, a taut line crossing the cell, or anything the rope is attached to. The rope beyond his hands is drawn on a separate overlay sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: both sprites face screen-right in strict side view.

Poses, one per cell in reading order. Both are the same held stance under tension, the rope gripped in the same two hands at the same height in both cells. The two cells differ only by a small amount of muscular tension, and both boots stay in exactly the same place:
1 holding, weight settled slightly back, arms firm, shoulders square, rope hands at chest height, a small forward lean of the head as he watches the line.
2 the same hold with a fraction more tension: shoulders drawn a little further back, elbows tucked a little tighter, the coat shifted very slightly, hands in the same position. This must read as breathing under load, not as a different pose.

Change only that small tension. Face, costume, equipment, palette, lighting direction, scale, camera, boot positions and hand height are identical in both cells.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 3. michael_lasso_pull_right_v001.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six frames, `lasso_pull` clip, facing right.

Exports: cells 1 to 6 to `michael_lasso_pull_right_v001_000.png` through `_005.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell. Do not resize him between cells.

Rope rule: draw ONLY the short length of rope gripped in his hands, no more than 100 px of it. Do not draw a taut line running to a target, an anchor, a counterweight, or anything being pulled. The rope beyond his hands is drawn on a separate overlay sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a coat tail or an extended arm does not fit inside the cell, draw it smaller within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 6 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is one hand-over-hand haul with both boots planted throughout. The load he is pulling is to the right; his effort travels to the left:
1 braced start. Boots planted wide, front boot forward, both hands gripping the rope out at chest height toward the right, arms nearly straight, hips settled back, back straight.
2 first draw. Rear hand pulls in past the ribs while the front hand still holds out toward the right, elbow driving back, shoulders rotating, weight moving onto the rear boot.
3 hand transfer. The rear hand arrives at the hip and the front hand releases and reaches back out toward the right for a new bite, hips low, knees bent, torso leaning back.
4 deep haul. Both hands drawn well back past the hip, torso leaning hard backward with the hips shifted rearward and the front boot braced flat against the pull, the heaviest and most committed pose in the sequence.
5 recovery step. Torso rising back toward vertical, the front boot repositioning a short distance forward, hands returning out toward the right for the next bite, effort easing.
6 settle. Returned to the braced start posture with the rope held at chest height and the shoulders square, ready to repeat or to release. This reads as a loop boundary back to cell 1.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 4. michael_lasso_swing_right_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `lasso_swing` clip, facing right.

The pose brief calls for four body-angle keys around the same grip socket. The controller sets position and
orientation, so these four cells are body attitudes, not four positions along an arc. Michael's grip hands stay at the
same point in every cell and the body swings under them.

Exports: cells 1 to 4 to `michael_lasso_swing_right_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. In every cell BOTH of his gripping hands are drawn at the same fixed point: 384 px from the left edge of his own cell and 120 px below the top of his own cell. His body hangs below and swings around that fixed grip point. He is airborne in all four cells and his boots do not touch any line.

Rope rule: draw ONLY a short stub of rope gripped in his hands, no more than 60 px of it above the fists, cut off cleanly. Do not draw the rope continuing upward out of the cell, an anchor, a ceiling, or a pivot. The rope above the grip is drawn on a separate overlay sheet.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a swung leg or coat tail does not fit inside the cell, reduce the swing angle within the cell. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 4 sprites face screen-right in strict side view.

Poses, one per cell in reading order. These are four body attitudes hanging from the same grip, not four positions travelling across a room:
1 back of the swing. Body angled so the boots trail well behind him to the left, hips forward under the hands, legs together and slightly tucked, coat streaming toward the left.
2 through the low point. Body hanging nearly straight down beneath the hands, legs together and extended, coat hanging almost vertical, torso long.
3 front of the swing. Body angled so the boots reach forward and up to the right, knees drawing up, hips back to the left, coat streaming toward the right.
4 top of the forward swing. Boots highest and furthest forward to the right, body folded at the hips, knees tucked, the compact pose from which he would release. Coat gathered rather than streaming.

Change only the body angle and leg position. The two gripping hands stay at exactly the same point in all four cells. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 5. michael_lasso_release_right_v001.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three frames, `lasso_release` clip, facing right.

Exports: cells 1 to 3 to `michael_lasso_release_right_v001_000.png` through `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 3 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. A horizontal foot line runs 400 px below the top of every cell; he is airborne in all three cells with his boots above that line, positioned as if the same line still ran under him. His pelvis is centred horizontally in his cell.

Rope rule: no rope is drawn anywhere on this sheet. His hands are empty in all three cells and the belt coil stays on his belt.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 3 sprites face screen-right in strict side view.

Poses, one per cell in reading order. This is letting go of a rope in mid-air and dropping into a fall:
1 the grip opens. Both hands still raised above the head at the height they held the rope, but the fingers are open and the palms are showing, body still hanging long beneath them.
2 arms coming down. Hands dropping past the shoulders, elbows out, the body straightening from the hang, legs beginning to swing down under the hips, coat still lifted.
3 falling. Arms out to the sides for balance at chest height, boots gathered under the centre of mass and reaching down, knees slightly bent, torso upright, coat tails lifted behind him. This pose reads as continuing straight into the fall clip.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat and inside the hat brim. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. michael_lasso_miss_recover_right_v001.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three frames, `lasso_miss_recover` clip, facing right.

The pose brief requires a miss to finish with an intelligible hand and rope recovery rather than snapping to an
impossible held rope. These three cells are the visible answer to a throw that caught nothing.

Exports: cells 1 to 3 to `michael_lasso_miss_recover_right_v001_000.png` through `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 3 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

Rope rule: draw ONLY the short slack length of rope he is gathering back in, no more than 100 px of it, held close to his body. Do not draw a rope running out of the cell, a target, an anchor, or a taut line.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If the gathered rope does not fit, draw a smaller gathered length. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: all 3 sprites face screen-right in strict side view.

Poses, one per cell in reading order. The throw caught nothing and he is taking the rope back in. This should read as competent and unhurried, not as embarrassment or comedy:
1 the slack arrives. Throwing arm still forward and low from the cast, wrist turning over, a short length of loose rope falling toward his hand, weight still on the front boot, head turned toward the right.
2 gathering. Both hands working at waist height, one drawing the rope in past the other, elbows close to the body, weight settling back onto both boots, chin dropping slightly to watch his hands.
3 re-coiled and ready. The rope gathered back into a coil held at his hip in the off hand, throwing hand free at chest height, weight even on both boots, head lifted and eyes forward toward the right. This pose reads as returning to the throw-ready stance.

Change only the pose. Face, costume, equipment, palette, lighting direction, scale and camera are identical in every cell.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the rope coil. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 7. lasso_rope_overlay_right_v001.png

Layout W6: 1536 x 1536, 2 columns x 3 rows, cell 768 x 512. Six rope shapes, no character.

**This is the sheet that fixes batch 001's boundary-crossing defect.** The rope that would have crossed a cell boundary
on the body sheet is drawn here instead, alone, on its own cells, registered to a fixed grip point. Michael is never
shrunk to fit a wide loop; the loop is simply not on his sheet.

Compositing rule for the runtime, stated here so it does not have to be reconstructed later: each overlay frame is
positioned by translating its registration point onto the matching body frame's `hand_lasso` socket. The registration
point is 384 px from the left edge of the cell and 200 px below the top of the cell in every cell of this sheet, and it
is where the rope enters the hand. The rope's grip end must touch that point exactly in all six cells.

Exports: cells 1 to 6 to `lasso_rope_overlay_right_v001_000.png` through `_005.png`, pairing frame for frame with
`michael_lasso_throw_right_v002`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 1536 x 1536 pixels. If you cannot output exactly 1536 x 1536 pixels, output nothing.

Divide the image into exactly 2 columns by 3 rows of equal cells: 1536 / 2 = 768 px wide and 1536 / 3 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one rope shape per cell, 6 cells in total, read left to right along the top row, then the middle row, then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Subject: ONE braided hemp cowboy lariat, the same rope in all six cells. Warm pale tan and ochre fibre with a visible twist, a slightly darker worn honda knot where the loop closes, roughly 10 px thick throughout. Nothing else exists on this sheet.

There is NO character on this sheet. Do not draw a person, a hand, an arm, a glove, a fist, a belt, a target, an anchor, a post, a hook, a creature, a wall or a floor. Draw the rope alone.

Registration, identical in every cell: the rope's grip end starts at exactly 384 px from the left edge of its own cell and 200 px below the top of its own cell, and the first 20 px of rope leaves that point travelling toward the lower left. That point is the same in all six cells and is where the rope would sit in a hand.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No rope may cross a cell boundary. If a loop is too large to fit inside its cell with that margin, draw the loop smaller within the cell. Never enlarge a cell and never move the registration point.

Rope shapes, one per cell in reading order, forming one throw travelling toward the right:
1 slack. A short loose length hanging down and to the left from the registration point, with two soft coils resting low, the loop closed and small.
2 windup. The rope pulled back and up so it arcs behind and above the registration point toward the upper left, the open loop hanging at the top of that arc.
3 crest. The open loop at its largest, riding high above and slightly behind the registration point, the rope running down from the loop to the registration point in a long clean curve.
4 cast. The open loop launched forward toward the upper right, the rope stretched from the registration point out toward it in a shallow rising curve, the loop tilted as it travels.
5 flight. The loop further right and beginning to descend, the rope from the registration point now a long low curve with a slight sag near the middle.
6 taut. The rope drawn as a nearly straight tensioned line from the registration point toward the right and slightly downward, ending in a small closed loop, with one small kink to show it is rope and not wire.

Every cell shows the same rope with the same thickness, twist and colour. Only the shape changes.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the rope, including the whole area inside every loop and between every coil. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the rope: no rope pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated shapes, motion blur or speed lines.
```

---

## 8. michael_lasso_throw_left_v001.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three left-facing continuity keys.

**Continuity key sheet, not a mirror.** These are throw frames 001, 003 and 005 drawn facing left so the asymmetric
gear can be compared against the right-facing sheet. Narrow cells are correct here because the rope stays in his hands.

Exports: cell 1 to `michael_lasso_throw_left_v001_001.png`, cell 2 to `_003.png`, cell 3 to `_005.png`. The gaps are
intentional; the intervening frames are not commissioned until handedness is settled.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Use the attached sheet ONLY as the identity, costume, palette, style and scale authority for Michael. Do not mirror it. Draw him newly, turned to face the other way, with his equipment on the anatomically correct side of his body rather than on the mirrored side.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one full-body sprite per cell, 3 cells in total, read left to right.

Style: Chunky readable premium pixel-art sprites with rich restrained painterly material shading, crisp pixel clusters, warm bronze leather ochre accents and deep shadows.

Camera: Fixed orthographic side view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Character: Michael, an adult charismatic steampunk cowboy temple adventurer. Consistent design in every cell: mature rugged face, dark swept hair, brown broad-brim cowboy hat, short brown leather duster with split tails, ivory shirt, dark teal waistcoat, brass mechanical forearm bracer, dark trousers, brown boots, pistol holster, coiled lasso on belt. Draw no equipment that this list does not name.

Scale and registration, identical in every cell: Michael measures exactly 288 px from boot sole to hat crown standing at rest, and keeps that size in every cell whatever the pose. His boot soles rest on a horizontal foot line 400 px below the top of his own cell. His pelvis is centred horizontally in his cell.

Rope rule: draw ONLY the short length of rope that stays in his hands and on his belt, no more than 100 px from his hands. Do not draw a flying loop, a rope arc, a target or an anchor.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. Never enlarge a cell, never crop an extremity, and never shrink Michael.

Facing: ALL 3 sprites face screen-LEFT in strict side view. Every face, nose, hat brim front and throwing direction points left. There is no right-facing sprite anywhere on this sheet and this is not a two-direction sheet.

Poses, one per cell in reading order. These are three keys of one lasso throw aimed to the left, the throwing arm being the same arm in all three cells:
1 anticipation. Throwing arm drawn back and up behind the shoulder, weight shifted over the rear boot, torso coiled, chest opening toward the left. This must read as a rope windup and not as raising a firearm.
2 cast. Throwing arm extended forward and slightly down toward the left, hand open at the moment of release, torso uncoiling, front boot taking weight, a short trailing length of rope near the fingers.
3 settle. Balanced waiting stance with the throwing hand held ready at chest height, eyes toward the left. It does not show a successful catch.

Change only the pose and the direction he faces. Face structure, costume, equipment, palette, lighting direction, scale and camera are identical to the attached sheet. Keep the brass mechanical forearm bracer, the pistol holster and the coiled lasso on the same arm and hip they occupy on the attached sheet, drawn as seen from this side, rather than swapping them to the other side of his body.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the subject, including the gaps between the legs, under the coat, inside the hat brim and through the rope coil. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the subject: no subject pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, alternate costumes, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- The rope overlay is only useful if something composites it. After the first overlay export exists, grep the runtime
  for the socket name that consumes it: `grep -rn "hand_lasso" src/`. A socket authored and never read is the same
  absence with more steps.
- Check that no body sheet in this file contains a rope more than 100 px from a hand before slicing. That is the
  boundary defect and it is cheap to measure: crop each cell, mask the rope colour, and report the furthest rope pixel
  from the hand socket per cell.
- `rope_attach` must not be authored into frame 005 of the throw. Confirm the export metadata carries no attachment
  event on that frame.
