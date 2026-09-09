extends TestCase
## Binding persistence, proved by writing a file, reading it back with a fresh
## store, and looking at the live InputMap afterwards.
##
## A save that reports success while writing nothing, and a load that reports
## success while applying nothing, both look exactly like this test passing, so
## nothing here asserts on a return value alone: every case ends by asking
## InputMap what it actually holds.

const SCRATCH := "user://test_input_bindings.json"

var store: BindingStore

func before_each() -> void:
	# Constructed before anything is changed, so its captured defaults really are
	# the project's.
	store = BindingStore.new(SCRATCH)
	store.clear_saved()

func after_each() -> void:
	store.restore_defaults()
	store.clear_saved()

func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	return event

func _bound_physical_keys(action: StringName) -> Array[int]:
	var codes: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			codes.append(int((event as InputEventKey).physical_keycode))
	return codes

func test_the_project_ships_the_bindings_this_test_relies_on() -> void:
	# Positive control. Every other case in this file is meaningless if the
	# starting state is not what it assumes.
	assert_true(_bound_physical_keys(GameActions.JUMP).has(KEY_SPACE),
		"jump starts on Space, so a change away from it is visible")
	assert_true(_bound_physical_keys(GameActions.MOVE_LEFT).has(KEY_A), "move_left starts on A")

func test_a_rebound_action_survives_a_save_and_a_reload() -> void:
	assert_true(store.rebind(GameActions.JUMP, _key(KEY_K)), "the rebind is accepted")
	assert_true(store.save(), "and the file is written")

	store.restore_defaults()
	assert_false(_bound_physical_keys(GameActions.JUMP).has(KEY_K),
		"positive control: the binding really was gone before the reload")

	var reloaded := BindingStore.new(SCRATCH)
	var problems := reloaded.load_and_apply()
	assert_eq(", ".join(problems), "", "the saved file applies cleanly")
	assert_true(_bound_physical_keys(GameActions.JUMP).has(KEY_K),
		"the player's key is in the live InputMap after a restart, not merely in a file")

func test_a_rebind_replaces_the_old_key_rather_than_adding_to_it() -> void:
	store.rebind(GameActions.JUMP, _key(KEY_K))
	assert_false(_bound_physical_keys(GameActions.JUMP).has(KEY_SPACE),
		"the old key is gone; a remap is not an alias")

func test_restoring_defaults_puts_the_project_binding_back() -> void:
	store.rebind(GameActions.JUMP, _key(KEY_K))
	store.restore_defaults()
	assert_true(_bound_physical_keys(GameActions.JUMP).has(KEY_SPACE), "Space is back")
	assert_false(_bound_physical_keys(GameActions.JUMP).has(KEY_K), "and the player's key is gone")

func test_restoring_defaults_restores_a_gamepad_binding_too() -> void:
	# Keys are the easy half. A defaults snapshot that quietly dropped the
	# non-keyboard events would pass every keyboard case above.
	var pad_events: int = 0
	for event: InputEvent in InputMap.action_get_events(GameActions.JUMP):
		if event is InputEventJoypadButton:
			pad_events += 1
	assert_eq(pad_events, 1, "jump ships with a pad button as well as a key")
	store.rebind(GameActions.JUMP, _key(KEY_K))
	store.restore_defaults()
	var restored: int = 0
	for event: InputEvent in InputMap.action_get_events(GameActions.JUMP):
		if event is InputEventJoypadButton:
			restored += 1
	assert_eq(restored, 1, "the pad button comes back with the key")

func test_every_event_type_the_project_uses_round_trips_through_the_file() -> void:
	var samples: Array[InputEvent] = []
	samples.append(_key(KEY_J))
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_RIGHT
	samples.append(mouse)
	var pad := InputEventJoypadButton.new()
	pad.button_index = 3
	samples.append(pad)
	var motion := InputEventJoypadMotion.new()
	motion.axis = 0
	motion.axis_value = -1.0
	samples.append(motion)

	for original: InputEvent in samples:
		var encoded := BindingStore.encode_event(original)
		assert_false(encoded.is_empty(), "%s is encodable" % BindingStore.describe_event(original))
		var text := JSON.stringify(encoded)
		var parsed: Variant = JSON.parse_string(text)
		var decoded := BindingStore.decode_event(parsed as Dictionary)
		assert_not_null(decoded, "%s survives JSON" % BindingStore.describe_event(original))
		assert_eq(BindingStore.encode_event(decoded), encoded,
			"%s comes back identical, not merely non-null" % BindingStore.describe_event(original))

func test_a_saved_file_from_another_schema_is_ignored_rather_than_guessed() -> void:
	var file := FileAccess.open(SCRATCH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": 99, "bindings": {"jump": []}}))
	file.close()
	var loaded := BindingStore.new(SCRATCH)
	loaded.load_and_apply()
	assert_true(_bound_physical_keys(GameActions.JUMP).has(KEY_SPACE),
		"an unreadable save leaves the working bindings alone instead of unbinding jump")

func test_a_saved_file_naming_an_action_the_project_does_not_have_is_refused() -> void:
	var problems := store.apply({"fly": [{"type": "key", "physical_keycode": KEY_F, "keycode": 0}]})
	assert_eq(problems.size(), 1, "the unknown action is reported, not silently created")
	assert_false(InputMap.has_action(&"fly"), "and no action is invented from a save file")

func test_an_unwritable_path_reports_failure_instead_of_reporting_success() -> void:
	var doomed := BindingStore.new("user://no_such_directory_here/bindings.json")
	assert_false(doomed.save(), "a save that could not happen must not return true")

func test_a_binding_the_store_cannot_persist_is_refused_at_the_point_of_binding() -> void:
	# Otherwise it would work until the next restart and then vanish, which is
	# the worst of the three possible outcomes.
	var motion := InputEventMouseMotion.new()
	assert_false(store.rebind(GameActions.JUMP, motion),
		"an event type the file cannot hold is not accepted as a binding")
	assert_true(_bound_physical_keys(GameActions.JUMP).has(KEY_SPACE), "and nothing was changed")

func test_an_action_with_no_events_reads_as_unbound_rather_than_as_blank() -> void:
	InputMap.action_erase_events(GameActions.RELOAD)
	assert_eq(BindingStore.describe_action(GameActions.RELOAD), "unbound",
		"an action with nothing on it says so")
