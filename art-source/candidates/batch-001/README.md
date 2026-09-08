# Sprite candidate batch 001

**23 actual PNG sheets: 20 subjects/action families plus 3 correction versions, 43.79 MiB.** Generated 2026-09-08 with the built-in image_gen tool under the user's explicit request to produce many sprite sheets. These are new production candidates derived from the written aesthetic, not recovered original ChatGPT renders and not admitted runtime assets.

Start with the selected candidates below. All raw generations are preserved; filenames ending v002 are targeted revisions, not evidence of final approval. [Generation records and exact prompts](generation-records.json) and [file dimensions, SHA-256 and alpha counts](file-inventory.json) are included.

## Technical status

22 PNGs are 1536×1024. The effects sheet is 1254×1254. All files decoded successfully. Five originals have transparent and partially transparent pixels; the remaining eighteen are opaque magenta-backed sheets. The magenta is NOT exactly #FF00FF at every pixel: extraction needs measured tolerance and edge review, not an exact-color deletion assumption. The alpha-bearing source previews expose shaded RGB data; preserve and inspect their alpha before deciding whether to remove a background. No image processing, slicing, rescaling, alpha cleanup or native animation validation was performed in this batch.

Nominal 4×2 layouts are composition requests, not trustworthy atlas bounds. Several weapons, ropes and gestures cross nominal cell boundaries. Do not blindly slice every sheet into 384×512 cells or claim these are runtime-ready 64×96 sprites. Portraits use a 3×2 layout and VFX a nominal 4×4 layout. Art-source is excluded from Godot import; admit corrected exports separately after review.

## Sheet index

| Sheet | Selected file | Review note |
| --- | --- | --- |
| Michael run, right | [michael_run_right_v002.png](michael_run_right_v002.png) | 8 poses; v001 retained with alpha, v002 opaque magenta. Compare both during extraction. |
| Michael run, left | [michael_run_left_v002.png](michael_run_left_v002.png) | 8 left-facing poses after correction. v001 has mixed directions and is superseded for this use. Handedness still needs review. |
| Michael jump and landing | [michael_jump_right_v001.png](michael_jump_right_v001.png) | 8 poses; foot-origin registration and jump timing pending. |
| Michael lasso | [michael_lasso_right_v001.png](michael_lasso_right_v001.png) | 8 throw/pull/recovery poses; rope crosses nominal cell boundaries in places. Use custom crops, not blind grid slicing. |
| Michael pistol | [michael_pistol_right_v001.png](michael_pistol_right_v001.png) | 8 draw/fire/reload poses; muzzle flash near sheet edge and reload mechanism need review. |
| Michael shotgun | [michael_shotgun_right_v001.png](michael_shotgun_right_v001.png) | 8 aim/fire/reload poses; barrel and muzzle padding need review. |
| Michael rifle | [michael_rifle_right_v001.png](michael_rifle_right_v001.png) | 8 carry/aim/fire/cycle/crouch poses; some long barrels reach beyond nominal cells. |
| Michael interaction | [michael_interact_right_v001.png](michael_interact_right_v001.png) | 8 interaction/idle/hat-tip poses; source-scale consistency pending. |
| Michael hurt and recovery | [michael_hurt_defeat_right_v001.png](michael_hurt_defeat_right_v001.png) | 8 non-graphic hurt/defeat/recovery poses; reclined pose has a different bounding box and needs custom alignment. |
| Ceramic sentinel emergence | [ceramic_sentinel_emergence_v001.png](ceramic_sentinel_emergence_v001.png) | 8 jar-to-creature/resolution stages; cell boundaries and source-to-actor origin pending. |
| Ceramic sentinel combat | [ceramic_sentinel_combat_v001.png](ceramic_sentinel_combat_v001.png) | 8 combat/walk/stagger poses; punch crosses nominal cell boundary. |
| Mural guard emergence | [mural_guard_emergence_v001.png](mural_guard_emergence_v001.png) | 8 transformation stages; has alpha. Separate panel and actor work still needed. |
| Mural guard combat | [mural_guard_combat_right_v001.png](mural_guard_combat_right_v001.png) | 8 free actor poses; extended spear needs custom crop. |
| Burial-pit emergence | [pit_assembler_emergence_v001.png](pit_assembler_emergence_v001.png) | 8 pit stages with alpha. Does not fully detach crawler or complete bone-settling ending; use dedicated crawler sheet for free actor. |
| Free burial crawler | [pit_crawler_combat_right_v001.png](pit_crawler_combat_right_v001.png) | 8 crawl/attack/stagger/defeat poses; detached legless actor supplied. |
| Keeper expressions | [keeper_portrait_expressions_v002.png](keeper_portrait_expressions_v002.png) | 6 portraits; v002 restores crown padding. v001 cropped crown is retained as superseded candidate. |
| Keeper manifestation | [keeper_manifestation_v001.png](keeper_manifestation_v001.png) | 8 arrival/gesture/departure stages; some effect/hand extents near cell edges. |
| Temple puzzle props | [temple_interactable_props_v001.png](temple_interactable_props_v001.png) | 8 props/states; counterweight rope exits top edge, intended attachment must be authored. |
| Weapon and impact effects | [weapon_impact_vfx_v001.png](weapon_impact_vfx_v001.png) | 16 effect cells, actual 1254x1254 image, NOT requested 1024 square; not evenly divisible into 4 integer-width cells. Alpha present. Manual bounds required. |
| Temple torch loop | [temple_torch_flame_v001.png](temple_torch_flame_v001.png) | 8 flame poses with alpha. Torch alignment/loop consistency pending. |

## Illustrated gallery

### Michael run, right

![Michael run, right](michael_run_right_v002.png)

### Michael run, left

![Michael run, left](michael_run_left_v002.png)

### Michael jump and landing

![Michael jump and landing](michael_jump_right_v001.png)

### Michael lasso

![Michael lasso](michael_lasso_right_v001.png)

### Michael pistol

![Michael pistol](michael_pistol_right_v001.png)

### Michael shotgun

![Michael shotgun](michael_shotgun_right_v001.png)

### Michael rifle

![Michael rifle](michael_rifle_right_v001.png)

### Michael interaction

![Michael interaction](michael_interact_right_v001.png)

### Michael hurt and recovery

![Michael hurt and recovery](michael_hurt_defeat_right_v001.png)

### Ceramic sentinel emergence

![Ceramic sentinel emergence](ceramic_sentinel_emergence_v001.png)

### Ceramic sentinel combat

![Ceramic sentinel combat](ceramic_sentinel_combat_v001.png)

### Mural guard emergence

![Mural guard emergence](mural_guard_emergence_v001.png)

### Mural guard combat

![Mural guard combat](mural_guard_combat_right_v001.png)

### Burial-pit emergence

![Burial-pit emergence](pit_assembler_emergence_v001.png)

### Free burial crawler

![Free burial crawler](pit_crawler_combat_right_v001.png)

### Keeper expressions

![Keeper expressions](keeper_portrait_expressions_v002.png)

### Keeper manifestation

![Keeper manifestation](keeper_manifestation_v001.png)

### Temple puzzle props

![Temple puzzle props](temple_interactable_props_v001.png)

### Weapon and impact effects

![Weapon and impact effects](weapon_impact_vfx_v001.png)

### Temple torch loop

![Temple torch loop](temple_torch_flame_v001.png)
