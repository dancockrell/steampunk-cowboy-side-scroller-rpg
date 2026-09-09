extends TestCase
## Pause stops the world, and lets go of whatever was being held while it does.
##
## The second half is the one that bites: docs/weapon-tool-kit.md says "No sticky
## input after pause or focus loss", and a key held at the moment of pausing stays
## pressed on its own. Nothing on screen shows it. The only way to see it is to
## hold an action, pause, and ask Input - which is exactly what happens below.
##
## WHAT IS NOT CHECKED HERE, said plainly rather than asserted around: that
## `get_tree().paused` actually flips. This repo's runner executes inside
## SceneTree._initialize, where the root Window is not yet in the tree, so NO
## node in this suite can have a SceneTree. `PauseMenu._set_tree_paused` is the
## single line that would do it. What IS checked is that the menu refuses to
## report success when it could not pause, which is the property that stops a
## menu appearing over a game that is still running.

var menu: PauseMenu

func before_each() -> void:
	menu = UiScenes.instantiate(UiScenes.PAUSE_MENU) as PauseMenu
	menu.notification(Node.NOTIFICATION_READY)

func after_each() -> void:
	if menu != null:
		menu.free()
		menu = null
	GameActions.release_all()

func test_the_menu_starts_closed() -> void:
	assert_false(menu.is_open(), "pause is not on screen until it is asked for")

func test_the_menu_keeps_running_while_everything_else_is_stopped() -> void:
	assert_eq(menu.process_mode, Node.PROCESS_MODE_WHEN_PAUSED,
		"a pause menu that paused with the game could never be dismissed")

func test_opening_shows_the_menu() -> void:
	menu.open()
	assert_true(menu.is_open(), "the menu is on screen")
	assert_true(menu.visible, "and visible")

func test_closing_hides_it_again() -> void:
	menu.open()
	menu.close()
	assert_false(menu.is_open(), "the menu is gone")

func test_a_menu_that_could_not_stop_the_game_does_not_report_that_it_did() -> void:
	# Without a SceneTree the world cannot be stopped. A menu drawn over a
	# running game is the bug; reporting success for it is how that bug hides.
	assert_false(menu.is_inside_tree(), "positive control: there really is no tree here")
	assert_false(menu.open(), "open() reports that the game was NOT paused")
	assert_true(menu.visible, "even though the menu itself is up, which is the point")

func test_a_held_action_is_let_go_of_when_the_menu_opens() -> void:
	Input.action_press(GameActions.TOOL_USE)
	assert_true(Input.is_action_pressed(GameActions.TOOL_USE),
		"positive control: the trigger really was held before pausing")
	menu.open()
	assert_false(Input.is_action_pressed(GameActions.TOOL_USE),
		"no sticky input: a held shot does not survive the pause and fire on resume")

func test_a_held_action_is_let_go_of_when_the_menu_closes_too() -> void:
	menu.open()
	Input.action_press(GameActions.JUMP)
	menu.close()
	assert_false(Input.is_action_pressed(GameActions.JUMP),
		"what was held over the menu does not arrive as a press on the first unpaused frame")

func test_a_held_action_is_let_go_of_when_the_window_loses_focus() -> void:
	# The other half of the same requirement. A player who alt-tabs never sends
	# the release for the key they let go of outside the window.
	Input.action_press(GameActions.MOVE_RIGHT)
	menu.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_false(Input.is_action_pressed(GameActions.MOVE_RIGHT),
		"focus loss releases held actions, so Michael does not keep walking")

func test_focus_loss_releases_every_action_not_only_movement() -> void:
	for action: StringName in GameActions.ALL:
		Input.action_press(action)
	menu.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	var still_held: PackedStringArray = PackedStringArray()
	for action: StringName in GameActions.ALL:
		if Input.is_action_pressed(action):
			still_held.append(String(action))
	assert_eq(", ".join(still_held), "", "nothing is left pressed after the window goes away")

func test_resuming_is_announced_once_so_the_owner_can_restore_play() -> void:
	var resumes: Array[int] = [0]
	menu.resumed.connect(func() -> void: resumes[0] += 1)
	menu.open()
	menu.close()
	menu.close()
	assert_eq(resumes[0], 1, "closing an already-closed menu does not resume twice")

func test_pausing_is_announced_once() -> void:
	var pauses: Array[int] = [0]
	menu.paused.connect(func() -> void: pauses[0] += 1)
	menu.open()
	menu.open()
	assert_eq(pauses[0], 1, "opening an already-open menu does not pause twice")

func test_the_options_buttons_ask_for_the_two_panels_by_name() -> void:
	var requested: Array[String] = []
	menu.options_requested.connect(func(panel: StringName) -> void: requested.append(String(panel)))
	(menu.get_node("%ControlsButton") as Button).pressed.emit()
	(menu.get_node("%AccessibilityButton") as Button).pressed.emit()
	assert_eq(requested, ["input_remap", "accessibility"],
		"the menu asks for a panel by name; it does not own those screens")

func test_the_resume_button_pressing_closes_the_menu() -> void:
	menu.open()
	(menu.get_node("%ResumeButton") as Button).pressed.emit()
	assert_false(menu.is_open(), "the button the player lands on first puts them back in the game")

func test_every_menu_button_can_be_reached_without_a_mouse() -> void:
	# That focus actually LANDS is not provable headlessly. That every button
	# accepts focus is, and it is what keyboard and gamepad navigation walks.
	for unique_name: String in ["%ResumeButton", "%ControlsButton", "%AccessibilityButton", "%QuitButton"]:
		var button: Button = menu.get_node(unique_name)
		assert_eq(button.focus_mode, Control.FOCUS_ALL,
			"%s is reachable by keyboard and gamepad" % unique_name)
