extends TestCase
## The 2.5D depth-layer system (src/world/depth.gd). NEAR must reuse the
## original terrain/tool_target bits exactly, or every room authored before
## this system existed would silently stop colliding with anything.

func test_near_reuses_the_original_terrain_and_target_bits() -> void:
	assert_eq(Depth.terrain_bit(Depth.Layer.NEAR), 1 << 0,
		"NEAR must be the same bit every pre-existing room's terrain already uses")
	assert_eq(Depth.target_bit(Depth.Layer.NEAR), 1 << 3,
		"NEAR must be the same bit every pre-existing HitReceiver already uses")

func test_the_three_layers_use_three_distinct_terrain_bits() -> void:
	var bits: Array[int] = []
	for layer: Depth.Layer in [Depth.Layer.NEAR, Depth.Layer.MID, Depth.Layer.FAR]:
		var b := Depth.terrain_bit(layer)
		assert_false(bits.has(b), "layer %s does not share a terrain bit with an earlier layer" % layer)
		bits.append(b)

func test_the_three_layers_use_three_distinct_target_bits() -> void:
	var bits: Array[int] = []
	for layer: Depth.Layer in [Depth.Layer.NEAR, Depth.Layer.MID, Depth.Layer.FAR]:
		var b := Depth.target_bit(layer)
		assert_false(bits.has(b), "layer %s does not share a target bit with an earlier layer" % layer)
		bits.append(b)

func test_terrain_bits_and_target_bits_never_collide_with_each_other() -> void:
	# A depth-mid terrain body must never accidentally match a depth-mid
	# tool_target query or vice versa; they are different physics concerns
	# that happen to share a "which plane" axis.
	var terrain_bits: Array[int] = []
	var target_bits: Array[int] = []
	for layer: Depth.Layer in [Depth.Layer.NEAR, Depth.Layer.MID, Depth.Layer.FAR]:
		terrain_bits.append(Depth.terrain_bit(layer))
		target_bits.append(Depth.target_bit(layer))
	for t: int in terrain_bits:
		assert_false(target_bits.has(t), "no terrain bit is also a target bit")

func test_layer_name_round_trips() -> void:
	for layer: Depth.Layer in [Depth.Layer.NEAR, Depth.Layer.MID, Depth.Layer.FAR]:
		assert_eq(Depth.from_name(Depth.layer_name(layer)), layer,
			"layer %s survives a name round trip" % layer)

func test_far_reads_darker_than_near() -> void:
	var near := Depth.modulate_for(Depth.Layer.NEAR)
	var far := Depth.modulate_for(Depth.Layer.FAR)
	assert_true(far.v < near.v, "a receding plane is darker, so depth reads without true perspective")
