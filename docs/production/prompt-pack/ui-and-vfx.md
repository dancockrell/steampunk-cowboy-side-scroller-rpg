# HUD, dialogue frame and visual effects

Twelve prompts. Read [README.md](README.md) first.

**This file carries the fix for batch 001's third recorded defect.** `weapon_impact_vfx_v001` asked for a 1024 x 1024
image with sixteen 256 px cells and was delivered at 1254 x 1254, which is not divisible into four equal columns:
1254 / 4 = 313.5. Nothing about the returned file said so, and the sheet cannot be sliced. Three things change here.

1. **One effect per sheet, four frames.** No sixteen-cell atlas. If one effect comes back wrong, one effect is
   regenerated.
2. **512 x 512 with 2 x 2 cells of 256 x 256**, and the arithmetic is written into the prompt text itself, twice.
3. **A hard gate before slicing.** If the delivered image is not exactly 512 x 512, it is not sliced. It is regenerated,
   or rescaled to exactly 512 x 512 with nearest-neighbour and the rescale is recorded. `width % 2` and `height % 2`
   are both reported as numbers.

## Shared VFX geometry

| Property | Value |
| --- | --- |
| Sheet | 512 x 512 |
| Grid | 2 columns x 2 rows |
| Cell | 256 x 256, because 512 / 2 = 256 both ways |
| Frames | 4, read left to right along the top row then the bottom row |
| Scale | 4 source px per world px, matching the character sheets, so a 256 px cell is 64 world px |
| Margin | No drawn pixel within 32 px of any cell edge |
| Registration | Stated per prompt. Muzzle flashes register at the ignition point; impacts and puffs register at the cell centre |

Effects register to sockets, not to a body. A muzzle flash is composited at the `muzzle` socket of the matching fire
frame, which is why no body sheet in this pack draws a flash: an effect that lives on the body sheet is an effect that
can reach a cell edge, which is what happened in batch 001's pistol sheet.

`muzzle_flash`, `rope_attach` and `rope_release` are presentation markers. Aligning an effect to one may not emit a
second authoritative hit or spend ammunition again.

## HUD assumptions, stated because no document sets them

[README.md](README.md) lists HUD content as an open gap. Nothing in the repository says what the health readout counts,
how many ammunition pips a firearm shows, or how large the dialogue frame is in the 640 x 360 world view. The prompts
below make these choices so they can be self-contained, and a reviewer should overrule them freely:

- **Health is drawn as a repeating unit, not a bar.** One ceramic vessel icon per point of health, in four damage
  states, so the same art serves any total the design later picks. A bar would bake the total into the art.
- **Ammunition is drawn as a single pip in four states,** repeated per round, for the same reason. The pistol, shotgun
  and rifle all use it; only the count differs.
- **Icons are 32 world px square,** matching the tile module, authored at 8x.
- **The dialogue frame reserves the lower third of the screen** and a portrait area on the left, per the art
  direction's requirement that portraits live in a separate full-window UI layer.

---

## 1. hud_health_vessel_v001.png

Layout V geometry, icons at 8x rather than 4x: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four damage states of one
32 x 32 world-pixel health unit.

Exports: cells 1 to 4 to `hud_health_vessel_v001_000.png` through `_003.png`, each downsampled 8:1 to 32 x 32.

```
Produce one 2D game user interface icon sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one icon per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, ancient temple materials in ochre, bronze, teal and ivory, warm highlights and deep object shadows. These are interface icons, so silhouettes are simpler and edges are harder than on a background prop.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects.

Subject: one small ceramic funerary vessel, the same vessel in all four cells, shown in four states of damage. Squat, wide-shouldered, cream and ivory glaze with a single band of teal geometric decoration and a bronze rim. It reads instantly as ceramic, at a glance, at small size.

Scale and registration, identical in every cell: the vessel is exactly 176 px tall and 160 px wide, its base resting on a horizontal line 208 px below the top of its own cell, centred horizontally in its cell. The vessel does not move, resize or change its decoration between cells. Only the damage changes.

States, one per cell in reading order:
1 whole. The vessel intact and undamaged, the glaze clean, the teal band unbroken, the bronze rim complete.
2 cracked. The same vessel with two clear dark cracks running down one side from the rim, and one small chip missing from the rim. The silhouette is still complete.
3 badly cracked. The same vessel with the cracks widened into gaps, a piece missing from the shoulder so the silhouette is visibly broken, and the teal band interrupted. Still standing and still recognisable.
4 empty. Only the base of the vessel remains, about a third of its height, cracked open with the broken edge visible, the teal band gone, standing in the same place on the same line.

Readability requirement: these four states must be distinguishable from silhouette alone, in black on white, at 32 pixels square. Do not rely on colour or on fine crack detail to carry the difference.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the icon, including through any crack or gap. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the icon: no icon pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, extra icons or motion blur.
```

---

## 2. hud_ammo_pip_v001.png

Layout V geometry at 8x: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four states of one ammunition pip.

Exports: cells 1 to 4 to `hud_ammo_pip_v001_000.png` through `_003.png`, each downsampled 8:1 to 32 x 32.

```
Produce one 2D game user interface icon sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one icon per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm brass and dark steel with ochre and ivory accents, warm highlights and deep object shadows. These are interface icons, so silhouettes are simpler and edges are harder than on a world prop.

Camera: Fixed orthographic straight-on side view of the cartridge, standing upright. No perspective, no tilt, no lens effects.

Subject: one upright antique brass cartridge, the same cartridge in all four cells, shown in four states. Brass case, a slightly wider rim at the base, a rounded lead nose.

Scale and registration, identical in every cell: the cartridge is exactly 176 px tall and 72 px wide, its base resting on a horizontal line 208 px below the top of its own cell, centred horizontally in its cell. It does not move or resize between cells.

States, one per cell in reading order:
1 loaded. A complete unfired cartridge, brass case bright, lead nose intact, standing upright.
2 chambered. The same complete cartridge, drawn a fraction brighter with a small bronze ring around its base to mark it as the next round. The silhouette gains that ring and changes in no other way.
3 spent. The same case with no lead nose, the mouth of the case open and dark, the brass duller and marked. Noticeably shorter in silhouette than cell 1.
4 empty. Only a hollow outline of the cartridge in dark bronze with nothing inside it, the same overall silhouette as cell 1 but read as an empty slot rather than a solid object.

Readability requirement: these four states must be distinguishable from silhouette and value alone, in black on white, at 32 pixels square.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the icon, including inside the hollow outline in cell 4. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the icon: no icon pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, extra icons or motion blur.
```

---

## 3. hud_tool_icons_v001.png

Layout V geometry at 8x: 512 x 512, 2 columns x 2 rows, cell 256 x 256. The four tool icons.

The four tools come from [weapon-tool-kit.md](../../weapon-tool-kit.md) and from the `ToolDefinition` id enum in
[data-contracts.md](../../data-contracts.md): lasso, pistol, shotgun, rifle. The lasso is the identity tool and gets the
first cell.

Exports: cell 1 to `hud_tool_lasso_v001_000.png`, cell 2 to `hud_tool_pistol_v001_000.png`, cell 3 to
`hud_tool_shotgun_v001_000.png`, cell 4 to `hud_tool_rifle_v001_000.png`, each downsampled 8:1 to 32 x 32.

```
Produce one 2D game user interface icon sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one icon per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, warm bronze, brass, aged wood, dark steel and pale hemp, warm highlights and deep object shadows. These are interface icons: simple silhouettes, hard edges, no fine ornament that will disappear at small size.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects. Each object is shown from the angle that makes it most recognisable.

Common treatment: all four icons share one visual weight, one lighting direction from the upper left, and one level of detail, so a row of them reads as one set. Each occupies about 176 px of its 256 px cell and is centred in that cell.

Icons, one per cell in reading order:
1 lasso. A coiled pale hemp lariat seen face on: three or four concentric coils of 14 px thick braided rope with a small honda knot at the lower right and a short tail hanging from it. The open middle of the coil shows background through it, which is what makes the silhouette read.
2 pistol. A single antique brass-and-dark-steel revolver in profile, barrel pointing to the right and angled slightly up, hammer and cylinder clearly visible, grip down and to the left. Compact and short.
3 shotgun. An antique wood, brass and steel short double-barrel shotgun in profile, barrels pointing to the right and angled slightly up, both muzzles clearly visible as two circles at the end, wide stock. Noticeably stubbier and heavier than the rifle.
4 rifle. A long wood and brass antique lever-action rifle in profile, barrel pointing to the right and angled slightly up, the brass finger lever clearly visible below the receiver. Noticeably longer and thinner than the shotgun, and drawn at a slight enough angle that its full length fits the cell.

Readability requirement, and it is the point of this sheet: the three firearms must be distinguishable from each other from silhouette alone, in black on white, at 32 pixels square. Pistol reads short and compact, shotgun reads stubby and thick with two muzzles, rifle reads long and thin with a lever. If two of them would be confused at that size, exaggerate the proportion difference rather than adding detail.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary. If the rifle does not fit, steepen its angle within the cell rather than shrinking it below the shared visual weight.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not an icon, including through the middle of the rope coil, through trigger guards and through the lever loop. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in an icon: no icon pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, characters, creatures, hands, extra icons or motion blur.
```

---

## 4. ui_dialogue_frame_v001.png

Single overlay image, 1280 x 720, magenta key. Two source pixels per world pixel, matching the room plates, so it maps
onto the 640 x 360 world view.

The portrait area on the left is left completely empty, because the Keeper portrait is a separate full-window layer at
1024 x 1536 and must not be baked into a frame. Text areas are left empty for the same reason: no text is drawn.

Export: `ui_dialogue_frame_v001.png`, downsampled 2:1 to 640 x 360.

```
Produce one 2D game user interface overlay image, exactly 1280 x 720 pixels. If you cannot output exactly 1280 x 720 pixels, output nothing.

This is a single interface overlay layer, not a background. Most of the image is empty background colour; only the frame elements are painted.

Style: Chunky readable premium pixel-art with rich restrained painterly material shading, crisp pixel clusters, ancient temple materials in aged bronze, dark stone, ochre and ivory, with restrained carved geometric ornament. It must sit over a warm torchlit room without competing with it, so the frame is dark and solid with a warm metal edge rather than bright or glassy.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects.

Elements to draw, and nothing else:
1 A dialogue panel occupying the lower part of the screen: a solid dark stone slab with a cast bronze border about 12 px thick, spanning from x = 40 to x = 1240 and from y = 480 to y = 690. Its corners carry small carved geometric bronze bosses. The slab's interior is a flat dark stone surface with a very slight vertical value change, uniform enough that light text will read clearly on it.
2 An empty portrait recess set into the left end of that panel: a sunken rectangular bronze-edged opening from x = 72 to x = 312 and from y = 432 to y = 672, with a raised bronze lip all the way around and a completely empty interior. The interior of this recess is background colour and nothing is drawn inside it.
3 A small bronze speaker plate above the left end of the panel, from x = 340 to x = 700 and from y = 432 to y = 476: a plain flat bronze bar with a carved lower edge and an empty interior surface.

The interiors of the dialogue slab, the portrait recess and the speaker plate carry no text, no name, no glyph, no placeholder lettering, no lorem ipsum and no scribble. They are surfaces for text the engine draws later.

Do not draw a portrait, a face, a character, a creature, a health readout, an ammunition readout, a tool icon, a button, a cursor, an arrow, a continue prompt, a scroll bar or a room behind the frame.

Containment, which is deliberately different from the sprite sheets in this set: this is a single overlay layer with no cell grid, and the three elements are positioned only by the exact coordinates given above. Do not add a margin, do not recentre them, do not scale them to fit a margin, and do not draw an outer border around the whole image.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not the frame elements, including the entire upper two thirds of the image and the whole interior of the portrait recess. That is most of the image and it is correct. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the frame: no frame pixel may have red above 200 together with blue above 200 and green below 80.

No words, letters, numbers, captions, labels, watermarks, signatures, extra borders, extra frames, grid lines, arrows, rulers, montage, collage, characters, creatures or motion blur.
```

---

## 5. vfx_muzzle_pistol_right_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, right-facing pistol muzzle flash.

Registration: the ignition point is at 64 px from the left edge and 128 px from the top of every cell. That point is
composited onto the `muzzle` socket of the matching pistol fire frame.

Exports: cells 1 to 4 to `vfx_muzzle_pistol_right_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art fire built from crisp readable clusters, not a soft airbrushed blur. Warm gold, amber and ivory flame with a little pale grey smoke.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no bloom, no glare, no anamorphic streak.

Subject: a small revolver muzzle flash travelling to the right. Compact and quick, matching a one-handed pistol shot.

Registration, identical in every cell: the ignition point, where the flash leaves the barrel, is at exactly 64 px from the left edge and 128 px from the top of its own cell. The effect grows to the right from that point and never to the left of it by more than 16 px.

Size limit: no frame extends more than 128 px to the right of the ignition point or more than 48 px above or below it.

There is no weapon, no hand, no arm, no character, no target, no wall, no floor and no bullet on this sheet. Draw only the flame, sparks and smoke.

Frames, one per cell in reading order:
1 ignition. A small tight bright ivory core about 24 px across at the ignition point, with four short gold spikes radiating from it.
2 full flame. The flash at its largest: a bright ivory core with an amber star of five uneven flame spikes reaching right, the longest about 100 px, a couple of small sparks thrown ahead of it.
3 shrinking sparks. The core gone dim and small, the spikes broken into six or seven separate amber sparks scattered to the right of the ignition point, still crisp.
4 faint smoke. No flame and no core. Three or four small soft pale grey smoke puffs drifting right and slightly up from the ignition point, dim and thinning.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not flame, spark or smoke, including the gaps between the flame spikes. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary. If a frame does not fit, draw the flame smaller within the cell.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, weapons, hands, characters, creatures, duplicated frames or motion blur.
```

---

## 6. vfx_muzzle_shotgun_right_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, right-facing shotgun blast.

Same registration as prompt 5: ignition at 64 px from the left, 128 px from the top of every cell.

The three muzzle effects must be distinguishable from each other. Pistol is a compact star, shotgun is a broad short
fan, rifle is a long narrow lance. That is the same silhouette discipline the body sheets use, applied to fire.

Exports: cells 1 to 4 to `vfx_muzzle_shotgun_right_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art fire built from crisp readable clusters, not a soft airbrushed blur. Warm gold, amber and ivory flame with pale grey smoke.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no bloom, no glare, no anamorphic streak.

Subject: a broad shotgun blast travelling to the right. Wide, heavy and short-lived, and clearly a different shape from a pistol flash: it spreads sideways far more than it reaches forward.

Registration, identical in every cell: the ignition point is at exactly 64 px from the left edge and 128 px from the top of its own cell. The effect grows to the right from that point and never to the left of it by more than 16 px.

Size limit: no frame extends more than 112 px to the right of the ignition point, but the fan may reach up to 88 px above and below it.

There is no weapon, no hand, no arm, no character, no target, no wall, no floor, no shell and no shot on this sheet. Draw only the flame, embers and smoke.

Frames, one per cell in reading order:
1 compact ignition. A dense bright ivory wedge about 40 px across at the ignition point, already visibly wider vertically than a pistol flash, with a hard leading edge.
2 wide fan. The blast at its largest: a broad amber and ivory fan opening to the right, about 100 px forward and about 170 px tall at its widest, the flame divided into six or seven heavy tongues, brightest at the ignition point.
3 scattered embers. The fan collapsed into a wide spray of twelve or more separate amber embers spread across the same tall fan shape, no continuous flame remaining, the shape still recognisably wide rather than pointed.
4 fading smoke. No flame and no embers. A wide low bank of pale grey smoke drifting right, wider than it is tall, dim and thinning, still centred on the ignition point.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not flame, ember or smoke, including the gaps between the flame tongues. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary. If a frame does not fit, draw the fan smaller within the cell.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, weapons, hands, characters, creatures, duplicated frames or motion blur.
```

---

## 7. vfx_muzzle_rifle_right_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, right-facing rifle muzzle flash.

Same registration: ignition at 64 px from the left, 128 px from the top of every cell.

Exports: cells 1 to 4 to `vfx_muzzle_rifle_right_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art fire built from crisp readable clusters, not a soft airbrushed blur. Warm gold, amber and ivory flame with a thin pale grey smoke.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no bloom, no glare, no anamorphic streak.

Subject: a rifle muzzle flash travelling to the right. Long, narrow and precise, and clearly a different shape from both a pistol flash and a shotgun blast: it reaches much further forward than it spreads.

Registration, identical in every cell: the ignition point is at exactly 64 px from the left edge and 128 px from the top of its own cell. The effect grows to the right from that point and never to the left of it by more than 16 px.

Size limit: no frame extends more than 160 px to the right of the ignition point or more than 32 px above or below it.

There is no weapon, no hand, no arm, no character, no target, no wall, no floor and no bullet on this sheet. Draw only the flame, sparks and smoke.

Frames, one per cell in reading order:
1 ignition. A small hard bright ivory point about 20 px across at the ignition point with a single short gold spike already reaching right.
2 lance. The flash at its largest: one dominant narrow amber and ivory lance reaching about 150 px to the right, no more than 56 px tall at its widest near the ignition point, tapering to a fine point, with two very short spikes at its base.
3 collapse. The lance broken into a line of five or six amber sparks strung out along the same narrow path to the right, brightest near the ignition point.
4 thin smoke. No flame and no sparks. A narrow thread of pale grey smoke drifting right and slightly up along the same path, dim and thinning.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not flame, spark or smoke. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary. If a frame does not fit, draw the lance shorter within the cell.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, weapons, hands, characters, creatures, duplicated frames or motion blur.
```

---

## 8. vfx_rope_attach_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, the rope attachment and release effect.

This is **not** the rope itself. The rope geometry is `lasso_rope_overlay_right_v001.png` in
[michael-lasso.md](michael-lasso.md) and it is owned there. This sheet is only the small burst that marks the moment the
loop bites, aligned to the `rope_attach` marker, and read in reverse for `rope_release`.

Registration: the contact point is at the cell centre, 128 px from the left and 128 px from the top of every cell.

Exports: cells 1 to 4 to `vfx_rope_attach_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art built from crisp readable clusters. Pale hemp tan, warm ochre and fine grey stone dust. Restrained and physical rather than magical: this is rope biting on stone, not a spell.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no bloom, no glare.

Subject: the small burst at the moment a lasso loop closes hard on an anchor. Rope fibre and a puff of dust knocked loose.

Registration, identical in every cell: the contact point is at exactly 128 px from the left edge and 128 px from the top of its own cell, which is the centre of the cell. The effect radiates from that point.

Size limit: no frame extends more than 88 px from the contact point in any direction.

There is no rope, no loop, no anchor ring, no post, no hand, no character and no creature on this sheet. Draw only the burst: short loose fibre ends and dust. The rope itself is separate art.

Frames, one per cell in reading order:
1 bite. A tight ring of six short pale hemp fibre flicks radiating from the contact point, about 24 px long each, with two grey dust specks.
2 puff. The fibre flicks longer and looser, about 48 px, and a low grey stone dust cloud about 100 px across gathered around the contact point, densest at its centre.
3 disperse. The fibre flicks gone. The dust cloud expanded to about 140 px across, thinner, breaking into separate clusters, drifting slightly downward.
4 settle. Four or five small grey dust specks falling below the contact point, everything else gone.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not fibre or dust, including the gaps between dust clusters. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, rope, anchors, hands, characters, creatures, duplicated frames or motion blur.
```

---

## 9. vfx_impact_stone_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, a bullet impact on stone.

Registration: impact point at the cell centre.

Exports: cells 1 to 4 to `vfx_impact_stone_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art built from crisp readable clusters. Cool grey and warm brown stone chips, pale grey dust, one small ivory and gold spark.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no bloom, no glare.

Subject: a bullet striking dressed temple stone. It reads as chips and dust, not as an explosion.

Registration, identical in every cell: the impact point is at exactly 128 px from the left edge and 128 px from the top of its own cell. The effect radiates from that point.

Size limit: no frame extends more than 96 px from the impact point in any direction.

There is no wall, no floor, no stone surface, no bullet hole, no weapon, no character and no creature on this sheet. Draw only the spark, chips and dust in open space.

Frames, one per cell in reading order:
1 spark. A single small hard bright ivory and gold spark about 20 px across at the impact point, with three very short chip flicks leaving it.
2 chips. The spark dimmed to a small warm point, and eight to ten angular grey and brown stone chips of varying size thrown outward from the impact point to about 80 px, the largest about 14 px across.
3 falling dust. The spark gone, the chips lower and further apart with a slight downward bias, and a soft pale grey dust cloud about 120 px across gathered around the impact point.
4 fading dust. No spark and no chips. A thin pale grey dust cloud drifting downward below the impact point, dim, broken into three or four clusters.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not spark, chip or dust. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, walls, weapons, characters, creatures, duplicated frames or motion blur.
```

---

## 10. vfx_impact_clay_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, a hit on fired clay.

This is the ceramic sentinel's damage effect and it has to be visibly different from the stone impact, because a player
learns from the difference which surface they just hit. Terracotta shards and no spark, against grey chips and a spark.

Registration: impact point at the cell centre.

Exports: cells 1 to 4 to `vfx_impact_clay_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art built from crisp readable clusters. Warm ochre and terracotta shards with cream glaze edges and a little teal on the larger pieces, plus fine warm brown dust.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no bloom, no glare.

Subject: a hit on fired decorated clay. It must be clearly distinguishable from a stone impact: warm terracotta rather than grey, flat curved shards rather than angular chips, and no bright spark at any point.

Registration, identical in every cell: the impact point is at exactly 128 px from the left edge and 128 px from the top of its own cell. The effect radiates from that point.

Size limit: no frame extends more than 96 px from the impact point in any direction.

There is no jar, no creature, no armour, no surface, no weapon and no character on this sheet. Draw only the shards and dust in open space.

Frames, one per cell in reading order:
1 fracture. A tight radiating burst of six short terracotta cracks about 24 px long from the impact point, with two small shards just beginning to lift free. No spark and no flame.
2 shards. Seven or eight flat curved terracotta shards thrown outward to about 80 px, the largest about 20 px across, several showing a cream glazed face and one carrying a fragment of teal geometric band, tumbling outward.
3 falling chips. The large shards further out and lower, and a scattering of ten or more much smaller terracotta chips around the impact point, with a soft warm brown dust cloud about 110 px across.
4 settled pieces. No dust cloud. Five or six small terracotta pieces low and below the impact point, still and dry, plus a few last warm brown specks. Nothing bright, nothing glowing.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not shard or dust. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, jars, creatures, weapons, characters, duplicated frames or motion blur.
```

---

## 11. vfx_dust_puff_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, a ground dust puff for landings and heavy steps.

Registration: contact point at the bottom centre of the cell, 128 px from the left and 208 px from the top, so the puff
sits on a surface rather than floating.

Exports: cells 1 to 4 to `vfx_dust_puff_v001_000.png` through `_003.png`.

```
Produce one 2D game visual-effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one effect per cell, 4 cells in total, read left to right along the top row then the bottom row.

Style: Chunky controlled pixel-art built from crisp readable clusters, not a soft airbrushed blur. Warm pale ochre and grey temple floor dust, low in contrast and restrained.

Camera: Fixed orthographic side view at eye level, as if seen along the floor. No perspective, no tilt, no lens effects, no bloom, no glare.

Subject: a small puff of floor dust thrown up where a boot or a heavy body meets stone. Modest and quick. It exists to sell weight, not to draw attention.

Registration, identical in every cell: the contact point is at exactly 128 px from the left edge and 208 px from the top of its own cell, and the dust sits on an implied horizontal surface running through that point. Nothing is drawn below that line by more than 8 px.

Size limit: no frame extends more than 96 px to either side of the contact point, and no higher than 96 px above it.

There is no floor, no ground plane, no boot, no character, no creature and no surface drawn on this sheet. Only the dust.

Frames, one per cell in reading order:
1 kick. Two small tight clusters of pale ochre dust either side of the contact point, low and wide, about 40 px across in total, with a few grains lifting.
2 bloom. The dust at its largest: two low curling clusters spreading outward and upward to about 150 px wide and 60 px tall in total, still hugging the surface line, with six or seven separate grains above them.
3 drift. The clusters thinner and further apart, drifting outward and slightly up to about 180 px wide, breaking into loose separate puffs, the grains higher and more scattered.
4 fade. Three or four faint dust specks close to the surface line and one or two grains still hanging above, everything dim and nearly gone.

Background is one flat solid magenta, RGB 255 0 255, filling every pixel that is not dust, including the gap between the two clusters. Do not use transparency, an alpha channel, a checkerboard, a gradient, a vignette, a texture, a floor, a ground plane, a drop shadow or any glow spilling onto the background. No magenta and no near-magenta anywhere in the effect: no effect pixel may have red above 200 together with blue above 200 and green below 80.

Containment: no drawn pixel of any kind comes within 32 px of any cell edge. No element may cross a cell boundary.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, boots, characters, creatures, duplicated frames or motion blur.
```

---

## 12. vfx_torch_glow_v001.png

Layout V: 512 x 512, 2 columns x 2 rows, cell 256 x 256. Four frames, the warm glow that surrounds a torch.
**Black background, not magenta.**

This is the one effect on this page composited additively, for the same reason as the room's light and atmosphere
layer: a soft glow has no hard edge to key against, and a magenta key would chew a ragged hole out of it. Black adds
nothing under additive blending, so black is the correct empty value. Record the convention in the generation record so
the extraction step skips this file.

The flame itself is drawn on `temple_torch_flame_v002.png` in [environment.md](environment.md) with a magenta key. This
sheet is only the light around it, and the two are composited together at the same point.

Registration: the glow centre is at the cell centre, and it aligns with the flame's base on the torch sheet.

Exports: cells 1 to 4 to `vfx_torch_glow_v001_000.png` through `_003.png`, composited with additive blending.

```
Produce one 2D game lighting effect sprite sheet image, exactly 512 x 512 pixels. If you cannot output exactly 512 x 512 pixels, output nothing.

Divide the image into exactly 2 columns by 2 rows of equal cells: 512 / 2 = 256 px wide and 512 / 2 = 256 px tall, so every cell is exactly 256 x 256 px and the grid divides evenly with no remainder. Draw exactly one glow per cell, 4 cells in total, read left to right along the top row then the bottom row.

This sheet is an ADDITIVE lighting effect. It will be added on top of a room, so pure black contributes nothing and bright areas contribute light.

Style: soft warm amber light with a smooth falloff. This is the one piece of art in this set that is not chunky pixel clusters: it is a light, and it must not band or dither into visible steps.

Camera: Fixed orthographic straight-on view. No perspective, no tilt, no lens effects, no lens flare, no starburst, no anamorphic streak, no visible rays.

Subject: the warm pool of light cast around a burning torch, in four frames of a gentle flicker that loops back to the first.

Registration, identical in every cell: the glow is centred at exactly 128 px from the left edge and 128 px from the top of its own cell, and its centre stays at that point in all four cells. Only its size and brightness change.

There is no torch, no bracket, no cup, no flame, no wall, no character and no object on this sheet. Draw only light.

Frames, one per cell in reading order:
1 steady. A round amber glow about 176 px across, brightest at the centre and falling smoothly to pure black by its edge.
2 rise. The same glow about 192 px across and slightly brighter at the centre, the same smooth falloff.
3 peak. The glow at its largest, about 200 px across, warmest and brightest at the centre, still falling to pure black well inside the cell edge.
4 dip. The glow reduced to about 168 px across and slightly dimmer than cell 1, ready to loop back to it.

Brightness discipline: the centre reads as a warm amber glow, not as white. Do not let any frame reach pure white.

Containment: the glow must fall to pure black at least 32 px inside every cell edge in every frame. No glow may cross a cell boundary or touch a cell edge. If a frame does not fit, draw the glow smaller within the cell.

Background convention for this prompt: the background is PURE BLACK, RGB 0 0 0. Do NOT use magenta anywhere on this image. Do not use transparency or an alpha channel. Everything that is not glow is pure black.

No words, letters, numbers, captions, labels, watermarks, signatures, borders, frames, panels, grid lines, arrows, rulers, montage, collage, torches, flames, objects, characters, creatures, duplicated frames or lens flare.
```

---

## Review notes for this file

- **Run the dimension gate first, on every one of these twelve.** Report the actual width and height and the two
  remainders. That is the whole of the batch 001 VFX defect, and it takes one command per file:
  `python -c "from PIL import Image; im=Image.open(p); print(im.size, im.size[0]%2, im.size[1]%2)"`. A file that comes
  back 1254 x 1254 fails here and never reaches the slicer.
- **Check the three muzzle flashes against each other, not one at a time.** Put the second frame of each side by side
  at native scale. Compact star, wide fan, long lance. If two of them look the same, a player cannot tell which weapon
  fired without reading the HUD, which defeats the point of giving the three weapons distinct verbs.
- **Check stone and clay impacts against each other the same way.** Grey and angular against terracotta and curved.
- **Check the icon set at 32 px, not at 256 px.** Downsample first and look at what survives. An icon that reads
  beautifully at source scale and turns to mush at display scale is the commonest failure in this category, and it is
  invisible until you actually reduce it.
- **Two files on this page do not get keyed.** `vfx_torch_glow_v001` and, in the environment file,
  `room_light_atmosphere_v001` are black-background additive layers. Running the magenta extraction over them would
  produce a file that looks fine in a viewer and composites as garbage. Record the convention per file in the
  generation record rather than relying on someone remembering.
- **Grep the consuming side.** Once the sockets exist, confirm something reads them:
  `grep -rn "muzzle\|rope_attach\|rope_release" src/`. An effect authored and never composited is the same absence with
  more steps.
