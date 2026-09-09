extends TestCase
## Boots the real main scene and asserts the tree actually came up.
##
## Written because "ran headless, exit 0, empty log" is indistinguishable from a
## scene that silently failed to load anything. This is the check that can tell
## those apart: it names the nodes that must exist and fails if they do not.

var main: Main

func before_each() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		return
	main = packed.instantiate() as Main
	if main == null or tree == null:
		return
	tree.root.add_child(main)
	# _ready does not fire in a --script run that never reaches a frame, so the
	# explicit entry point is called directly. boot() is idempotent.
	main.boot()

func after_each() -> void:
	if main != null and is_instance_valid(main):
		tree.root.remove_child(main)
		main.free()
	main = null

func test_the_main_scene_instantiates() -> void:
	assert_not_null(main, "scenes/main.tscn loads and its root is a Main")

func test_services_exist_and_carry_the_authored_keeper() -> void:
	assert_not_null(main.services, "Main creates its Services")
	assert_not_null(main.services.relationships.heroine(&"keeper_of_the_clay_dead"),
		"the authored Keeper record is registered at boot, not lazily on first use")

func test_the_world_viewport_is_the_authored_low_resolution_size() -> void:
	assert_not_null(main.world_viewport, "the world SubViewport exists")
	assert_eq(main.world_viewport.size, Vector2i(Main.WORLD_WIDTH, Main.WORLD_HEIGHT),
		"the pixel world runs at the authored 640x360")

func test_the_world_viewport_uses_nearest_filtering() -> void:
	assert_eq(main.world_viewport.canvas_item_default_texture_filter,
		Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
		"a pixel world must not be smoothed by the default linear filter")

func test_the_portrait_layer_is_separate_from_the_pixel_world() -> void:
	assert_not_null(main.ui_layer, "a full-window UI layer exists")
	assert_false(main.ui_layer.is_ancestor_of(main.world_viewport),
		"the UI layer is NOT inside the low-resolution viewport, so portraits keep their detail")

func test_the_starting_room_loads_with_its_authored_id() -> void:
	assert_not_null(main.world_root, "WorldRoot exists")
	assert_not_null(main.world_root.room, "a room was loaded at boot")
	assert_eq(main.world_root.room.room_id, &"gallery_of_vessels", "it is the authored first room")

func test_michael_exists_and_stands_at_the_authored_spawn() -> void:
	var player := main.world_root.player
	assert_not_null(player, "the player was instantiated")
	var spawn := main.world_root.room.spawn_position(&"spawn_entry")
	assert_almost_eq(player.global_position.x, spawn.x, 1.0, "spawned at the authored marker")
	assert_not_null(player.tools, "the tool controller is attached and bound")
	assert_eq(player.tools.machine.equipped_id, &"lasso", "the identity tool is equipped first")

func test_the_graybox_terrain_built_real_collision() -> void:
	var terrain := main.world_root.room.get_node_or_null(^"Terrain")
	assert_not_null(terrain, "the room has a terrain node")
	var bodies := 0
	for child: Node in terrain.get_children():
		if child is StaticBody2D:
			bodies += 1
	assert_true(bodies >= 4, "every authored platform produced a collision body, got %d" % bodies)

func test_every_tool_target_in_the_room_declares_at_least_one_verb() -> void:
	var checked := 0
	for node: Node in _all(main.world_root.room):
		var target := node as ToolTarget
		if target == null:
			continue
		checked += 1
		assert_false(target.allowed_verbs.is_empty(),
			"target '%s' declares the verbs it accepts" % target.receiver_id)
		for verb: StringName in target.allowed_verbs:
			assert_true(Verbs.is_known(verb),
				"target '%s' uses a known verb, not an invented one: %s" % [target.receiver_id, verb])
	# The denominator: if the room stopped containing targets this test would
	# otherwise pass by checking nothing at all.
	assert_true(checked >= 5, "the room contains its authored tool targets, found %d" % checked)

func test_the_four_tools_each_have_a_target_in_the_first_room() -> void:
	var verbs_present: Array[StringName] = []
	for node: Node in _all(main.world_root.room):
		var target := node as ToolTarget
		if target == null:
			continue
		for verb: StringName in target.allowed_verbs:
			if not verbs_present.has(verb):
				verbs_present.append(verb)
	for verb: StringName in [Verbs.PRECISION_HIT, Verbs.FORCE_HIT, Verbs.LONG_PRECISION_HIT, Verbs.PULL, Verbs.SWING]:
		assert_true(verbs_present.has(verb),
			"the room gives verb '%s' something to act on, so every tool has a use here" % verb)

func _all(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in node.get_children():
		found.append(child)
		found.append_array(_all(child))
	return found

func test_the_world_is_scaled_by_a_whole_number_only() -> void:
	var container := main.get_node_or_null(^"WorldViewportContainer") as SubViewportContainer
	assert_not_null(container, "the world container exists")
	var scale := container.scale.x
	assert_true(scale >= 1.0, "the world is never scaled below 1x")
	assert_almost_eq(scale, floorf(scale), 0.001,
		"a fractional scale puts uneven pixel widths on a pixel-art stage, got %f" % scale)
	assert_almost_eq(container.scale.y, container.scale.x, 0.001, "and the scale is square")

func test_the_scale_tracks_the_window_rather_than_sticking_at_its_boot_value() -> void:
	# Regression: boot can run before the window has settled, and the world then
	# stayed at whatever scale it was first given. Caught by rendering a frame
	# and seeing a 640x360 image in a 1280x720 window, not by any test.
	var container := main.get_node_or_null(^"WorldViewportContainer") as SubViewportContainer
	container.scale = Vector2(1, 1)
	main._last_window_size = Vector2i.ZERO
	main._apply_integer_scale()
	var window := main.get_window()
	if window == null:
		return
	var expected := maxi(1, int(floor(minf(
		float(window.size.x) / float(Main.WORLD_WIDTH),
		float(window.size.y) / float(Main.WORLD_HEIGHT)))))
	assert_eq(int(container.scale.x), expected,
		"the scale is recomputed from the current window size, not left at its old value")
