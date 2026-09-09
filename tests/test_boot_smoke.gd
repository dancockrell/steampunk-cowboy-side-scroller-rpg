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
	# The UI scenes' @onready lookups need NOTIFICATION_READY, which the same
	# missing-frame problem also withholds. UiScenes-instantiated nodes are not
	# yet in the tree when boot() builds them, so drive it by hand for each.
	for ui_node: Node in [main.hud, main.dialogue, main.pause_menu]:
		if ui_node != null:
			ui_node.notification(Node.NOTIFICATION_READY)
	# Main deliberately defers UI wiring past _ready with call_deferred (see
	# main.gd for why: writing an @onready label before _ready assigns it is a
	# real null-property crash, measured, not merely a headless artefact). This
	# suite never processes a frame, so the deferred queue never flushes on its
	# own. Run the same calls directly, mirroring boot()'s own idiom for the
	# identical underlying problem.
	if main.hud != null:
		main.hud.bind(main.services)
		if main.world_root != null and main.world_root.player != null:
			main._wire_player_to_hud(main.world_root.player)
	if main.dialogue != null:
		main.dialogue.bind(main.services)
	if main.pause_menu != null:
		main.pause_menu.bind(main.services)

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

func test_the_hud_dialogue_and_pause_menu_are_instantiated_in_the_ui_layer() -> void:
	assert_not_null(main.hud, "the HUD is built at boot")
	assert_not_null(main.dialogue, "so is the dialogue layer")
	assert_not_null(main.pause_menu, "and the pause menu")
	assert_true(main.ui_layer.is_ancestor_of(main.hud), "the HUD lives in the full-window UI layer")
	assert_true(main.ui_layer.is_ancestor_of(main.dialogue), "so does dialogue")
	assert_false(main.world_viewport.is_ancestor_of(main.hud),
		"and none of them are inside the low-resolution world viewport")

func test_the_hud_reflects_michaels_starting_health_and_equipped_tool() -> void:
	var player := main.world_root.player
	assert_true(main.hud.health_text().contains(str(player.health)) and main.hud.health_text().contains(str(main.services.tuning.max_health)),
		"the HUD shows the player's real health at boot, not left at the 0/0 placeholder: %s" % main.hud.health_text())
	assert_eq(main.hud.equipped(), &"lasso", "and shows the tool actually equipped")

func test_the_intervention_preview_reaches_the_hud_every_frame() -> void:
	main._process(1.0 / 60.0)
	assert_true(main.hud.intervention_text().contains(RecallToClay.REASON_NO_ALLIANCE),
		"before any alliance the HUD shows the specific reason, not a generic unavailable: %s" % main.hud.intervention_text())
	main.services.relationships.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)
	main._process(1.0 / 60.0)
	assert_ne(main.hud.intervention_text(), RecallToClay.REASON_NO_ALLIANCE,
		"and the reason changes once the alliance exists")

func test_pressing_pause_opens_the_menu() -> void:
	# Measured, not assumed: a node added via root.add_child() inside a
	# --script run does NOT report is_inside_tree() == true until the
	# SceneTree actually processes an iteration, even when a real tree exists
	# and even outside this project's own harness (probed directly against a
	# bare SceneTree). This suite runs entirely inside _initialize() and
	# never iterates, so PauseMenu is never "in tree" from its own point of
	# view here, and get_tree().paused cannot be exercised. That is the exact
	# gap the UI lane already documented; it is not new.
	assert_false(main.pause_menu.is_open(), "starts closed")
	Input.action_press(&"pause")
	main._process(1.0 / 60.0)
	Input.action_release(&"pause")
	assert_true(main.pause_menu.is_open(), "the pause action opens it")

func test_a_menu_that_cannot_reach_the_tree_admits_it_rather_than_lying() -> void:
	# The positive side of the gap above: PauseMenu.open() is documented to
	# return whether the game was ACTUALLY stopped, not whether the menu
	# appeared. In this exact harness state it is not inside a live-iterated
	# tree, so it must say so rather than silently reporting success it did
	# not earn. This is the real, valuable thing that state proves.
	var stopped := main.pause_menu.open()
	assert_true(main.pause_menu.is_open(), "the menu still shows itself")
	assert_false(stopped, "but it never claims to have paused a tree it could not reach")
