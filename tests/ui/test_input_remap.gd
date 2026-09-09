extends TestCase
## The remap screen, driven through the same calls its buttons make.
##
## Every case ends by asking the live InputMap or a freshly constructed store,
## never by trusting the screen's own label: a row that displays a new key while
## the InputMap still holds the old one is precisely the failure worth catching.

const SCRATCH := "user://test_remap_bindings.json"

var screen: InputRemap
var store: BindingStore

func before_each() -> void:
	# Constructed before anything is rebound, so its defaults are the project's.
	store = BindingStore.new(SCRATCH)
	store.clear_saved()
	screen = UiScenes.instantiate(UiScenes.INPUT_REMAP) as InputRemap
	screen.use_store(store)
	# This repo's runner executes inside SceneTree._initialize, where the root
	# Window is not itself in the tree yet, so nothing added anywhere gets a
	# SceneTree and _ready never fires on its own. Notifying the node directly
	# runs exactly what the engine runs: the @onready resolution and the _ready
	# body. What CANNOT be checked this way is anything needing a live tree -
	# focus actually landing, and get_tree().paused - and those are named where
	# they come up rather than quietly asserted around.
	screen.notification(Node.NOTIFICATION_READY)

func after_each() -> void:
	if screen != null:
		screen.free()
		screen = null
	store.restore_defaults()
	store.clear_saved()

func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	return event

func _row_names() -> Array[String]:
	var names: Array[String] = []
	for child: Node in (screen.get_node("%ActionRows") as VBoxContainer).get_children():
		if String(child.name).begins_with("Row_"):
			names.append(String(child.name).substr(4))
	names.sort()
	return names

func test_every_action_the_project_defines_gets_a_row() -> void:
	var expected: Array[String] = []
	for action: StringName in GameActions.ALL:
		expected.append(String(action))
	expected.sort()
	assert_eq(_row_names(), expected,
		"all fourteen actions are remappable; none is quietly left out of the screen")

func test_each_row_shows_what_the_action_is_currently_bound_to() -> void:
	assert_true(screen.binding_text(GameActions.JUMP).contains("Space"),
		"jump reads as Space: '%s'" % screen.binding_text(GameActions.JUMP))

func test_rebinding_changes_the_live_input_map_not_only_the_label() -> void:
	assert_true(screen.rebind_action(GameActions.JUMP, _key(KEY_K)), "the rebind is accepted")
	var codes: Array[int] = []
	for event: InputEvent in InputMap.action_get_events(GameActions.JUMP):
		if event is InputEventKey:
			codes.append(int((event as InputEventKey).physical_keycode))
	assert_true(codes.has(KEY_K), "the game really would read K for jump now")
	assert_false(codes.has(KEY_SPACE), "and no longer reads Space")

func test_a_rebind_is_written_to_disk_so_it_survives_a_restart() -> void:
	screen.rebind_action(GameActions.JUMP, _key(KEY_K))
	store.restore_defaults()
	assert_true(BindingStore.describe_action(GameActions.JUMP).contains("Space"),
		"positive control: the change really was undone before the reload")
	var fresh := BindingStore.new(SCRATCH)
	fresh.load_and_apply()
	assert_true(BindingStore.describe_action(GameActions.JUMP).contains("K"),
		"the player's key comes back from the file, not from memory")

func test_a_key_another_action_already_uses_is_refused_and_that_action_is_named() -> void:
	# Two actions on one key is discovered in a fight, not in a menu, so it is
	# refused rather than reported afterwards.
	assert_false(screen.rebind_action(GameActions.JUMP, _key(KEY_A)),
		"A already moves left, so it cannot also jump")
	assert_true(screen.status_text().contains(GameActions.label_for(GameActions.MOVE_LEFT)),
		"and the screen says which action holds it: '%s'" % screen.status_text())
	assert_true(BindingStore.describe_action(GameActions.JUMP).contains("Space"),
		"nothing was changed by the refused rebind")

func test_restoring_defaults_puts_every_binding_back_at_once() -> void:
	screen.rebind_action(GameActions.JUMP, _key(KEY_K))
	screen.rebind_action(GameActions.INTERACT, _key(KEY_L))
	screen.restore_defaults()
	assert_true(BindingStore.describe_action(GameActions.JUMP).contains("Space"), "jump is back")
	assert_true(BindingStore.describe_action(GameActions.INTERACT).contains("E"), "interact is back")

func test_a_restart_after_restoring_defaults_does_not_resurrect_the_old_remap() -> void:
	screen.rebind_action(GameActions.JUMP, _key(KEY_K))
	screen.restore_defaults()
	var fresh := BindingStore.new(SCRATCH)
	fresh.load_and_apply()
	assert_true(BindingStore.describe_action(GameActions.JUMP).contains("Space"),
		"a restart after restoring defaults does not resurrect the old remap")

func test_capture_says_which_action_it_is_listening_for() -> void:
	screen.begin_capture(GameActions.RELOAD)
	assert_true(screen.is_capturing(), "the screen is listening")
	assert_eq(String(screen.capturing_action()), "reload", "for the action whose button was pressed")
	assert_true(screen.status_text().contains(GameActions.label_for(GameActions.RELOAD)),
		"and it says so: '%s'" % screen.status_text())

func test_capture_cannot_be_started_for_an_action_the_project_does_not_have() -> void:
	screen.begin_capture(&"fly")
	assert_false(screen.is_capturing(), "an invented action name does not open a capture")

func test_closing_the_screen_stops_any_capture_in_progress() -> void:
	screen.begin_capture(GameActions.RELOAD)
	screen.close()
	assert_false(screen.is_capturing(),
		"a capture left listening would swallow the next key press elsewhere")

func test_the_screen_runs_while_the_game_is_paused_because_that_is_where_it_opens_from() -> void:
	assert_eq(screen.process_mode, Node.PROCESS_MODE_WHEN_PAUSED,
		"the controls screen opens over a paused game and has to keep working")
