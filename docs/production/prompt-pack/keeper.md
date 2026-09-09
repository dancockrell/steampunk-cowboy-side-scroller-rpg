# Keeper of the Clay Dead

Eight prompts: four portrait expressions, three manifestation sheets and one intervention gesture. These implement
[keeper-art-brief.md](../keeper-art-brief.md) and the goddess package in
[sprite-animation-pipeline.md](../../sprite-animation-pipeline.md). Read [README.md](README.md) first.

**She is an adult woman with adult presentation. That invariant is written into every prompt on this page.** The
`Heroine` contract in [data-contracts.md](../../data-contracts.md) carries `adult: true` as a required field, the art
direction rejects baby-faced divine characters outright, and the brief states it plainly. It is not a note for the
reader; it is a line in the prompt text.

**Portraits are not pixel-constrained.** The pipeline says high-detail portraits may be painted raster art and that
Michael's pixel constraints must not be applied to them blindly. The art direction adds that the portrait layer gets no
forced low-resolution filter and lives in a separate full-window UI layer. So the four portraits below are 1024 x 1536
painted raster masters, not sprites, and they carry no cell grid, no foot line and no 4:1 downsample. The three
manifestation sheets do use the sprite geometry, because they occupy the world beside chunky sprites.

**The crown padding fix.** Batch 001's `keeper_portrait_expressions_v001` cropped the crown, and v002 was a targeted
correction adding at least 35 px above the crown and 20 px at the sides inside 512 px cells. Two things change here.
The four expressions are four separate 1024 x 1536 images rather than six cells on one sheet, which removes the grid
entirely and gives each portrait about six times the pixels. And the padding is stated as a hard minimum in the prompt
rather than left to the composition.

**Camera, crop and lighting are fixed across the four expressions.** Do not regenerate a new character for each mood.
Generate the neutral portrait first, review it, then supply it as the reference image for the other three. Four stable
stills are more useful than unstable pseudo-animation.

No dialogue or relationship state is inferred from an expression filename. Code selects presentation from authored
scene state.

Manifestation scale used below is 304 px, which is 76 world pixels, slightly taller than Michael's 72. No repository
document states it; it is listed as unconfirmed in [README.md](README.md).

---

## 1. keeper_portrait_neutral_v001.png

Layout P: 1024 x 1536, single painted portrait, no grid. This is the identity key for the whole set. Generate and
review it before any of the other three.

Export: `keeper_portrait_neutral_v001_000.png`.

```
Produce one high-detail painted portrait image, exactly 1024 x 1536 pixels. If you cannot output exactly 1024 x 1536 pixels, output nothing.

This is a single portrait, not a sprite sheet. Do not divide it into cells and do not draw a grid.

Style: rich painterly portrait rendering with subtle pixel-textured edges, deliberately higher detail than a gameplay sprite. Warm restrained material shading, ancient temple palette, deep shadow. This image is not pixel-art and must not be reduced to chunky blocks; it will be displayed at full window size beside much lower-resolution sprites.

Subject, and this is the identity that every other portrait in this set must match: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions. Her face reads as a woman in her late thirties or forties: defined bone structure, a mature jaw and brow, the beginnings of expression lines. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions. Her authority comes from her relationship to memory and funerary vessels, not from youth.

Camera and crop, which every portrait in this set must repeat exactly: waist-up, three-quarter view with her body turned to face slightly toward the viewer's left, head level, eyes to camera. The centre of her face sits at 512 px from the left edge and 560 px from the top. Her crown's highest point sits at 160 px from the top. Her shoulders span roughly 620 px. The bottom of the frame cuts at her waist.

Padding, a hard minimum: at least 96 px of plain background above the highest point of the crown, and at least 64 px of plain background to the left and right of her widest point. No part of the crown, hair, collar or gown may touch or approach an image edge.

Lighting, which every portrait in this set must repeat exactly: a single warm key light from the upper left at about forty-five degrees, a cool dim fill from the lower right, deep shadow behind her. No rim light changes, no coloured gels, no lens flare, no bloom.

Expression: composed and assessing. Her gaze is direct and steady, her mouth relaxed and closed, her brow level. She is taking the measure of someone and has not yet decided. Relaxed authority, not warmth and not hostility.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing beyond dignified presence. Sensuality is carried by posture and gaze.

No crown, jewellery, tattoo, staff, vessel or ornament beyond what the identity paragraph names. No wings, halo, aura, floating objects, particles or magical glow.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure, including any gap between an arm and the body and any opening in the crown. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a wall, a room, a throne, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure: no figure pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, montage, collage, extra characters, second figures, mirrored reflections or motion blur.
```

---

## 2. keeper_portrait_amused_v001.png

Layout P: 1024 x 1536, single painted portrait. Supply the approved neutral portrait as the reference image.

Export: `keeper_portrait_amused_v001_000.png`.

```
Produce one high-detail painted portrait image, exactly 1024 x 1536 pixels. If you cannot output exactly 1024 x 1536 pixels, output nothing.

Use the attached portrait as the exact and only authority for this woman's face, hair, crown, collar, gown, skin, palette, lighting, camera angle, crop and scale. This is the SAME woman in the SAME position under the SAME light. Change the expression and nothing else. Do not redesign her, do not change her age, do not restyle her hair, do not alter her crown or gown, and do not move the camera.

This is a single portrait, not a sprite sheet. Do not divide it into cells and do not draw a grid.

Style: rich painterly portrait rendering with subtle pixel-textured edges, deliberately higher detail than a gameplay sprite. Not pixel-art and not reduced to chunky blocks.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions, and do not soften her face toward youth to carry the smile.

Camera and crop, identical to the attached portrait: waist-up, three-quarter view with her body turned slightly toward the viewer's left, head level, eyes to camera. The centre of her face sits at 512 px from the left edge and 560 px from the top. Her crown's highest point sits at 160 px from the top.

Padding, a hard minimum: at least 96 px of plain background above the highest point of the crown, and at least 64 px to the left and right of her widest point.

Lighting, identical to the attached portrait: single warm key from the upper left at about forty-five degrees, cool dim fill from the lower right, deep shadow behind her.

Expression: subtly amused. The amusement starts in the eyes and reaches the mouth second: a small asymmetrical lift at one corner of the closed mouth, one brow a fraction higher than the other, the eyes narrowed slightly with warmth. This is a woman who has watched many mortals make the same mistake and finds this one better than most. It is private and controlled, never a broad grin, never laughter, never a wink, never cute.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

No ornament beyond what the identity paragraph names. No wings, halo, aura, floating objects, particles or magical glow.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a wall, a room, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure: no figure pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, montage, collage, extra characters, second figures, mirrored reflections or motion blur.
```

---

## 3. keeper_portrait_displeased_v001.png

Layout P: 1024 x 1536, single painted portrait. Supply the approved neutral portrait as the reference image.

Narrative use, from the brief: needless damage to funerary objects. That is why the displeasure is focused rather than
theatrical. She is not angry at a person, she is looking at a broken thing.

Export: `keeper_portrait_displeased_v001_000.png`.

```
Produce one high-detail painted portrait image, exactly 1024 x 1536 pixels. If you cannot output exactly 1024 x 1536 pixels, output nothing.

Use the attached portrait as the exact and only authority for this woman's face, hair, crown, collar, gown, skin, palette, lighting, camera angle, crop and scale. This is the SAME woman in the SAME position under the SAME light. Change the expression and nothing else. Do not redesign her, do not change her age, do not restyle her hair, do not alter her crown or gown, and do not move the camera.

This is a single portrait, not a sprite sheet. Do not divide it into cells and do not draw a grid.

Style: rich painterly portrait rendering with subtle pixel-textured edges, deliberately higher detail than a gameplay sprite. Not pixel-art and not reduced to chunky blocks.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions.

Camera and crop, identical to the attached portrait: waist-up, three-quarter view with her body turned slightly toward the viewer's left, head level, eyes to camera. The centre of her face sits at 512 px from the left edge and 560 px from the top. Her crown's highest point sits at 160 px from the top.

Padding, a hard minimum: at least 96 px of plain background above the highest point of the crown, and at least 64 px to the left and right of her widest point.

Lighting, identical to the attached portrait: single warm key from the upper left at about forty-five degrees, cool dim fill from the lower right, deep shadow behind her.

Expression: controlled displeasure. The gaze sharpens and holds; the warmth drains out of the eyes without the face moving much. The mouth stays closed and level, the jaw a little firmer, the chin fractionally lowered, one brow drawn slightly down. It reads as cold assessment and withheld judgement. Do NOT draw a sneer, a snarl, bared teeth, a scowl, a raised lip, a furious glare, tears or any caricature of anger. The restraint is the point: she is more frightening for not raising her voice.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

No ornament beyond what the identity paragraph names. No wings, halo, aura, floating objects, particles or magical glow.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a wall, a room, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure: no figure pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, montage, collage, extra characters, second figures, mirrored reflections or motion blur.
```

---

## 4. keeper_portrait_earnest_v001.png

Layout P: 1024 x 1536, single painted portrait. Supply the approved neutral portrait as the reference image.

Narrative use, from the brief: the champion offer and personal trust. The brief also says the adult identity must stay
stable here, which is the expression where it is most likely to slip toward softness.

Export: `keeper_portrait_earnest_v001_000.png`.

```
Produce one high-detail painted portrait image, exactly 1024 x 1536 pixels. If you cannot output exactly 1024 x 1536 pixels, output nothing.

Use the attached portrait as the exact and only authority for this woman's face, hair, crown, collar, gown, skin, palette, lighting, camera angle, crop and scale. This is the SAME woman in the SAME position under the SAME light. Change the expression and nothing else. Do not redesign her, do not change her age, do not restyle her hair, do not alter her crown or gown, and do not move the camera.

This is a single portrait, not a sprite sheet. Do not divide it into cells and do not draw a grid.

Style: rich painterly portrait rendering with subtle pixel-textured edges, deliberately higher detail than a gameplay sprite. Not pixel-art and not reduced to chunky blocks.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. This instruction matters most in this image: softening the expression must not soften her age, her bone structure or her proportions. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions, and do not enlarge her eyes, shrink her jaw or smooth away her expression lines to carry the warmth.

Camera and crop, identical to the attached portrait: waist-up, three-quarter view with her body turned slightly toward the viewer's left, head level, eyes to camera. The centre of her face sits at 512 px from the left edge and 560 px from the top. Her crown's highest point sits at 160 px from the top.

Padding, a hard minimum: at least 96 px of plain background above the highest point of the crown, and at least 64 px to the left and right of her widest point.

Lighting, identical to the attached portrait: single warm key from the upper left at about forty-five degrees, cool dim fill from the lower right, deep shadow behind her.

Expression: earnest and guarded. The gaze softens and comes closer, the brow lifts very slightly at the inner ends, the mouth stays closed but relaxes, the chin lowers a fraction. There is care in it and there is also caution: she is offering something real and she has not stopped being able to say no. This is a woman capable of refusal choosing not to refuse, not a woman pleading. No tears, no trembling lip, no adoring gaze, no submission.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

No ornament beyond what the identity paragraph names. No wings, halo, aura, floating objects, particles or magical glow.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a wall, a room, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure: no figure pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, montage, collage, extra characters, second figures, mirrored reflections or motion blur.
```

---

## 5. keeper_manifestation_arrival_v002.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, `manifestation_arrival` clip.

This is world art, so it uses the sprite geometry and must stay readable beside chunky sprites. It is still drawn at
higher detail than Michael, per the art direction. Supply the approved neutral portrait as the reference image for
face, crown and gown identity.

The brief's arrival logic: local dust, paint or torch reaction, then the silhouette coheres, then full readable
presence. One focal effect at a time.

Exports: cells 1 to 4 to `keeper_manifestation_arrival_v002_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached portrait ONLY as the exact identity, face, crown, gown, collar, palette and lighting authority. Now draw her as a FULL BODY standing figure rather than a waist-up portrait.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one subject per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: high-detail painted game sprite art with crisp readable edges. More detail than a chunky pixel-art hero sprite, because she is divine and categorically distinct, but still a coherent game sprite that will sit in a pixel world. Warm restrained material shading, ancient temple palette, deep shadow.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions.

Camera: Fixed orthographic side-on world view at eye level, the same flat view a platformer uses. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: standing, she is exactly 304 px from sole to the highest point of her crown. Her feet rest on a horizontal foot line 400 px below the top of her own cell. She is centred horizontally in her cell. Do not resize her between cells and do not re-centre a cell on its visible pixels.

Effect discipline: one focal effect at a time, kept close to her body and never spreading across the cell. The material is fine ivory and pale gold ceramic dust, nothing else. No lightning, no fire, no rays, no lens flare, no shockwave, no expanding ring, no screen-filling glow, no floating debris field. Whatever effect exists must leave her silhouette and the space around her readable, because a player has to see hazards and landing spaces through this.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. The crown and any effect are the cases that break this. If an effect does not fit, draw it smaller within the cell. Never enlarge a cell, never crop the crown, and never shrink her to make an effect fit.

Facing: she faces the viewer in three-quarter view in every cell, body turned slightly toward the viewer's left, the same relationship as the attached portrait.

Frames, one per cell in reading order:
1 the material stirs. No figure at all. A low compact swirl of ivory and pale gold ceramic dust rising off the foot line, about 200 px tall and 120 px wide, centred where she will stand. Nothing human is visible.
2 the silhouette coheres. The dust has gathered into a recognisable full-height female shape at her exact standing height and position, still made of drifting motes: the crown outline, the shoulders and the fall of the gown are readable, the face is not.
3 solid. She is fully present and standing, feet on the foot line, dignified and still, arms at her sides, gown falling clean, crown complete. A thin residue of ivory and gold motes remains close to the hem of the gown and nowhere else. Her face is fully rendered and matches the attached portrait.
4 settled. The same standing figure with the last motes gone, one hand come to rest at her waist, weight shifted very slightly onto one foot, gown settled. This is the pose the idle clip continues from.

Change only the stage. Face, crown, gown, collar, palette, lighting direction, scale and camera are identical in every cell where she appears.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure or her dust, including any gap between an arm and the body and any opening in the crown. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure or the effect: no such pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 6. keeper_manifestation_idle_v002.png

Layout S2: 1024 x 512, 2 columns x 1 row, cell 512 x 512. Two frames, `manifestation_idle` clip.

The brief asks for minimal breath and fabric motion and no distracting perpetual effects. Two frames is the honest
answer to that: a two-frame idle cannot become a light show.

Supply the arrival sheet as the reference image.

Exports: cells 1 and 2 to `keeper_manifestation_idle_v002_000.png` and `_001.png`.

```
Produce one 2D game sprite sheet image, exactly 1024 x 512 pixels. If you cannot output exactly 1024 x 512 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, face, crown, gown, collar, palette, lighting, style and scale authority. Do not copy its poses exactly; draw two new near-identical standing poses.

Divide the image into exactly 2 columns by 1 row of equal cells: 1024 / 2 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one figure per cell, 2 cells in total, read left to right.

Style: high-detail painted game sprite art with crisp readable edges, more detail than a chunky pixel-art hero sprite but still a coherent game sprite in a pixel world.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions.

Camera: Fixed orthographic side-on world view at eye level. No perspective, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in both cells: standing, she is exactly 304 px from sole to the highest point of her crown. Her feet rest on a horizontal foot line 400 px below the top of her own cell, in exactly the same place in both cells. She is centred horizontally in her cell.

No effects of any kind. No dust, motes, glow, aura, sparkle, wind or particles anywhere on this sheet. The brief is explicit that a standing goddess must not carry perpetual effects.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. Never enlarge a cell, never crop the crown, and never resize her.

Facing: she faces the viewer in three-quarter view in both cells, body turned slightly toward the viewer's left.

Frames, one per cell in reading order. The two cells differ only by breath and fabric. Her feet do not move, her crown does not move, her head does not turn:
1 settled. Standing calm and still, one hand resting at her waist, the other loose at her side, weight slightly on one foot, gown hanging clean, gaze level and forward.
2 breath. The same pose with the chest raised very slightly on the intake, the shoulders a fraction higher, and the hem and the outer folds of the gown drifted by a few pixels. Everything else is identical to cell 1.

Change only that. Face, crown, gown, collar, palette, lighting direction, scale, camera, foot position and hand position are identical in both cells.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure, including any gap between an arm and the body and any opening in the crown. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure: no figure pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 7. keeper_manifestation_departure_v002.png

Layout S3: 1536 x 512, 3 columns x 1 row, cell 512 x 512. Three frames, `manifestation_departure` clip.

The brief requires the departure to reverse the material logic without implying she died. That is written into the
prompt directly, because a dissolve is exactly the effect that reads as death if nobody says otherwise.

Supply the arrival sheet as the reference image.

Exports: cells 1 to 3 to `keeper_manifestation_departure_v002_000.png` through `_002.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 512 pixels. If you cannot output exactly 1536 x 512 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, face, crown, gown, collar, palette, lighting, style and scale authority.

Divide the image into exactly 3 columns by 1 row of equal cells: 1536 / 3 = 512 px wide and 512 / 1 = 512 px tall, so every cell is exactly 512 x 512 px and the grid divides evenly with no remainder. Draw exactly one subject per cell, 3 cells in total, read left to right.

Style: high-detail painted game sprite art with crisp readable edges, more detail than a chunky pixel-art hero sprite but still a coherent game sprite in a pixel world.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions.

Camera: Fixed orthographic side-on world view at eye level. No perspective, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: standing, she is exactly 304 px from sole to the highest point of her crown. Her feet rest on a horizontal foot line 400 px below the top of her own cell. She is centred horizontally in her cell.

Tone rule, and it matters more than any other instruction here: this is a goddess leaving, not a goddess dying. She departs deliberately and under her own control. Her posture stays upright and composed throughout, her head stays level, her expression stays calm. Do not draw her collapsing, sagging, fading downward, kneeling, closing her eyes in distress, breaking apart, cracking, shattering, burning, or reaching out. Nothing about the sequence should read as loss.

Effect discipline: one focal effect at a time, close to her body. The material is fine ivory and pale gold ceramic dust and motes, nothing else. No lightning, fire, rays, flare, shockwave, expanding ring or screen-filling glow.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. Never enlarge a cell, never crop the crown, and never resize her.

Facing: she faces the viewer in three-quarter view in every cell where she appears, body turned slightly toward the viewer's left.

Frames, one per cell in reading order, reversing the arrival:
1 composed and going. Standing at full height and fully solid, feet on the foot line, chin level, both hands come to rest together at her waist. The lowest few inches of the gown have begun to break into ivory and gold motes rising upward, and nothing above the knee has changed.
2 dispersing upward. Her form has become drifting ivory and gold motes from the hem to the shoulders while the crown, the head and the face are still solid and still level. The silhouette is unmistakably hers and she is unmistakably composed. Motes travel upward, never falling.
3 gone. No figure. A low compact swirl of ivory and pale gold motes rising off the foot line, about 200 px tall and 120 px wide, centred where she stood, thinning at the top. The same material she arrived in, going back the way it came.

She is fully clothed in every cell where she has a body. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure or her motes. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure or the effect: no such pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## 8. keeper_intervention_recall_v001.png

Layout W4: 1536 x 1024, 2 columns x 2 rows, cell 768 x 512. Four frames, the `intervention` gesture: Recall to Clay.

This is her one intervention. The brief's sequence is: attention shifts to an eligible dead creature, one readable hand
gesture, the creature returns to its vessel, effects settle. The art commissioned here is only her half of it. The
creature's return is animated by that creature's own resolved state, which already exists on its emergence sheet, so
nothing here draws a monster. That keeps one event owned in one place.

The intervention must preserve the player's view of Michael, of enemy intent and of landing spaces. That is why the
gesture is compact and the effect stays near her hands.

Supply the arrival sheet as the reference image.

Exports: cells 1 to 4 to `keeper_intervention_recall_v001_000.png` through `_003.png`.

```
Produce one 2D game sprite sheet image, exactly 1536 x 1024 pixels. If you cannot output exactly 1536 x 1024 pixels, output nothing.

Use the attached sheet ONLY as the exact identity, face, crown, gown, collar, palette, lighting, style and scale authority.

Divide the image into exactly 2 columns by 2 rows of equal cells: 1536 / 2 = 768 px wide and 1024 / 2 = 512 px tall, so every cell is exactly 768 x 512 px and the grid divides evenly with no remainder. Draw exactly one figure per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: high-detail painted game sprite art with crisp readable edges, more detail than a chunky pixel-art hero sprite but still a coherent game sprite in a pixel world.

Subject: She is the Keeper of the Clay Dead: visibly mature woman around 35-45 in appearance, warm bronze skin, dignified strong face, dark wavy hair, ancient turquoise and gold funerary crown, elegant ivory and deep teal draped gown covering breasts, bronze collar with ceramic inlay. Beautiful sensual and commanding, agency and intelligence, not youthful/cute.

She is an adult woman with an adult appearance and adult proportions, reading as late thirties to forties. Do not draw a young girl, a teenager, a doll, a chibi or any child-coded proportions.

Camera: Fixed orthographic side-on world view at eye level. No perspective, no vanishing point, no camera movement, no zoom change and no lens effects between cells.

Scale and registration, identical in every cell: standing, she is exactly 304 px from sole to the highest point of her crown. Her feet rest on a horizontal foot line 400 px below the top of her own cell and do not move between cells. She is centred horizontally in her cell.

There is no creature, no jar, no vessel, no enemy, no wall and no scenery anywhere on this sheet. She is alone. She directs the gesture toward empty background on her left.

Effect discipline, and this is a gameplay requirement rather than a taste one: the effect must stay within roughly 120 px of her hands and must never spread across the cell or behind her body. A player has to keep seeing the hero, the enemy's intent and where it is safe to land while this plays. One focal effect at a time. The material is ivory and pale gold ceramic dust drawn as fine spiral traces. No lightning, fire, beams, rays, flare, shockwave, expanding ring or screen-filling glow.

Containment: no drawn pixel of any kind comes within 64 px of any cell edge. No element may cross a cell boundary. If a spiral does not fit, draw it smaller within the cell. Never enlarge a cell, never crop the crown, and never resize her.

Facing: she faces the viewer in three-quarter view in every cell, body turned slightly toward the viewer's left, and the gesture is directed toward the viewer's left.

Frames, one per cell in reading order:
1 attention. Standing settled, her head turning toward the viewer's left and her gaze fixing on something off to that side, the near hand lifting a little from her waist. No effect yet. This frame exists so a player can see the intervention coming.
2 the gesture rises. Both hands come up in front of her at chest height, palms turned inward toward each other and slightly downward, elbows in, shoulders square. Two small ivory and gold spiral traces begin between and just beyond her palms. Her body is still and her feet have not moved.
3 the gesture commits. Her hands draw inward and downward toward each other in a single readable closing motion, and the spirals tighten and travel inward with them, brightest at this moment and still contained within about 120 px of her hands. Her expression is composed and certain. This is the frame the recall event is aligned to.
4 settle. Her hands lower back toward her waist, the last few motes dropping and fading close to them, her head turning back to level and forward. The pose returns to the idle stance.

Change only the pose and the effect. Face, crown, gown, collar, palette, lighting direction, scale and camera are identical in every cell.

She is fully clothed. The gown covers her breasts. No nudity, no sexual act, no suggestive posing.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the figure or the effect. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the figure or the effect: no such pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, extra characters, duplicated poses, motion blur or speed lines.
```

---

## Review notes for this file

- **The four portraits are one set or they are nothing.** Lay them side by side at full size and check face structure,
  hair silhouette, crown position, collar landmarks, lighting direction and crop against each other. If the eye line or
  the crown height moves between them, the set will flicker when dialogue switches expression, which is worse than
  having one expression.
- **Measure the crown padding rather than eyeballing it.** Find the topmost non-background pixel in each portrait and
  report its y coordinate. All four must be at or below 96, and all four should agree closely. That is the batch 001
  defect and it is trivially measurable.
- **Two scales, one identity.** The brief requires face structure, hair silhouette and major costume landmarks to stay
  consistent between the portrait and the world manifestation, and warns against compensating for a mismatched face
  with heavier glow. Put a portrait and a manifestation frame side by side at their real display sizes, not zoomed to
  match, and check that a player would read them as the same person.
- **Keying a painterly edge is harder than keying a pixel edge.** The extraction thresholds in
  [README.md](README.md) were chosen with sprite edges in mind. Measure the fringe band on the first portrait
  specifically and record what it actually needed, rather than assuming the sprite numbers transfer. Hair against
  magenta is the worst case; check it before checking anything else.
- The runtime pack is admitted only after face and costume continuity and full-window and world-scale composition are
  reviewed. Technical readiness does not promote these to visual approval.
