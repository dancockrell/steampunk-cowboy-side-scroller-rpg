class_name Depth
extends RefCounted
## The 2.5D depth-layer system: rooms can hold up to three parallel planes
## (near/mid/far) sharing one screen and one x/y coordinate space, each with
## its own walkable terrain and interactable props. Crossing between them is
## a real physics-layer swap, not a visual trick: standing on the far layer,
## the near layer's terrain and props genuinely are not there.
##
## Dan's direction, 10 Sep 2026: push verticality further and add 2.5D depth
## layers as another axis of puzzle design, alongside the swing-chain work in
## entry_bridge.tscn. The NEAR layer reuses the terrain/tool_target bits every
## existing room already uses, so nothing built before this needs to know
## depth layers exist at all.

enum Layer { NEAR, MID, FAR }

const LAYER_NAMES: Array[String] = ["near", "mid", "far"]

## Bit values, matching project.godot's [layer_names]. NEAR intentionally
## reuses the original terrain/tool_target bits (1, 8) for backward
## compatibility with every room authored before this system existed.
const TERRAIN_BIT := {
	Layer.NEAR: 1 << 0,   # "terrain"
	Layer.MID: 1 << 6,    # "depth_mid_terrain"
	Layer.FAR: 1 << 7,    # "depth_far_terrain"
}
const TARGET_BIT := {
	Layer.NEAR: 1 << 3,   # "tool_target"
	Layer.MID: 1 << 8,    # "depth_mid_target"
	Layer.FAR: 1 << 9,    # "depth_far_target"
}

## Visual treatment per layer: color a receding plane darker and slightly
## desaturated so depth reads even without true perspective, and scale it
## down a little so a far plane feels literally farther away. Provisional
## numbers, not a claimed final art pass.
const MODULATE := {
	Layer.NEAR: Color(1.0, 1.0, 1.0, 1.0),
	Layer.MID: Color(0.74, 0.72, 0.78, 1.0),
	Layer.FAR: Color(0.5, 0.48, 0.56, 1.0),
}
const PLANE_SCALE := {
	Layer.NEAR: 1.0,
	Layer.MID: 0.94,
	Layer.FAR: 0.88,
}

static func layer_name(layer: Layer) -> String:
	return LAYER_NAMES[layer]

static func from_name(name: String) -> Layer:
	var index := LAYER_NAMES.find(name)
	if index < 0:
		push_error("Depth.from_name: unknown layer '%s'" % name)
		return Layer.NEAR
	return index as Layer

static func terrain_bit(layer: Layer) -> int:
	return TERRAIN_BIT[layer]

static func target_bit(layer: Layer) -> int:
	return TARGET_BIT[layer]

static func modulate_for(layer: Layer) -> Color:
	return MODULATE[layer]

static func scale_for(layer: Layer) -> float:
	return PLANE_SCALE[layer]
