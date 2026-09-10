extends TestCase
## project.godot's [input] section is engine config, not GDScript, so
## check-gdscript.sh cannot see a malformed or missing binding in it. This is
## the check for that: it reads the real InputMap the engine actually loaded,
## not the text of the file, so a typo'd keycode or a binding that silently
## failed to parse shows up here rather than only at a controller in someone's
## hands.
##
## docs/gameplay-pillars.md's input contract originally proposed "A/D, Space"
## alone and says so is provisional. Arrow keys and W/Up are added because
## A/D-only movement and Space-only jump exclude players who expect either of
## the two most common PC control conventions; shipping only one is not
## "ordinary controls".

func _physical_keycodes(action: StringName) -> Array[int]:
	var codes: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(action):
		var key := event as InputEventKey
		if key != null:
			codes.append(key.physical_keycode)
	return codes

func test_move_left_answers_to_both_a_and_the_left_arrow() -> void:
	var codes := _physical_keycodes(&"move_left")
	assert_true(codes.has(KEY_A), "the WASD convention still works")
	assert_true(codes.has(KEY_LEFT), "and so does the arrow-key convention")

func test_move_right_answers_to_both_d_and_the_right_arrow() -> void:
	var codes := _physical_keycodes(&"move_right")
	assert_true(codes.has(KEY_D), "the WASD convention still works")
	assert_true(codes.has(KEY_RIGHT), "and so does the arrow-key convention")

func test_jump_answers_to_space_w_and_the_up_arrow() -> void:
	var codes := _physical_keycodes(&"jump")
	assert_true(codes.has(KEY_SPACE), "the original binding still works")
	assert_true(codes.has(KEY_W), "so does jumping with W, the common WASD-platformer convention")
	assert_true(codes.has(KEY_UP), "and jumping with the up arrow, the common arrow-key convention")

func test_every_project_action_still_has_at_least_one_binding() -> void:
	# A catch-all so a future edit to this section cannot silently orphan an
	# action by leaving its "events" array empty.
	var checked := 0
	for action: StringName in InputMap.get_actions():
		if String(action).begins_with("ui_"):
			continue # Godot's built-in editor/UI actions, not ours.
		checked += 1
		assert_false(InputMap.action_get_events(action).is_empty(),
			"action '%s' has at least one bound input" % action)
	assert_true(checked >= 12, "the project's own 12 authored actions were all checked, found %d" % checked)
