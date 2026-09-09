extends TestCase
## The accessibility panel, driven through the widgets the player touches.
##
## Every control states its value in words as well as in its switch position, so
## the panel is usable without colour and legible at a glance in a dark room
## (docs/gameplay-pillars.md). That is what most of these check.

const SCRATCH := "user://test_accessibility_panel.json"

var panel: AccessibilityOptions
var settings: AccessibilitySettings

func before_each() -> void:
	settings = AccessibilitySettings.new(SCRATCH)
	settings.clear_saved()
	panel = UiScenes.instantiate(UiScenes.ACCESSIBILITY_OPTIONS) as AccessibilityOptions
	panel.use_settings(settings)
	# This repo's runner executes inside SceneTree._initialize, where the root
	# Window is not itself in the tree yet, so nothing added anywhere gets a
	# SceneTree and _ready never fires on its own. Notifying the node directly
	# runs exactly what the engine runs: the @onready resolution and the _ready
	# body. What CANNOT be checked this way is anything needing a live tree -
	# focus actually landing, and get_tree().paused - and those are named where
	# they come up rather than quietly asserted around.
	panel.notification(Node.NOTIFICATION_READY)

func after_each() -> void:
	if panel != null:
		panel.free()
		panel = null
	settings.clear_saved()

func test_every_option_the_pillars_name_has_a_control_on_screen() -> void:
	for unique_name: String in ["%AimModeButton", "%ReducedShakeCheck", "%ReducedFlashesCheck",
			"%SubtitlesCheck", "%TextScaleSlider"]:
		assert_not_null(panel.get_node(unique_name), "%s is on the panel" % unique_name)

func test_each_switch_says_its_state_in_words_not_only_by_position() -> void:
	assert_true(panel.aim_mode_text().contains("hold"), "aiming reads as hold: '%s'" % panel.aim_mode_text())
	assert_true((panel.get_node("%ReducedShakeCheck") as CheckButton).text.contains("off"),
		"a switch that is off says off")

func test_toggling_aiming_swaps_between_the_two_styles_and_says_which() -> void:
	(panel.get_node("%AimModeButton") as Button).pressed.emit()
	assert_eq(settings.aim_mode_name(), "toggle", "the setting changed")
	assert_true(panel.aim_mode_text().contains("toggle"),
		"and the button says so: '%s'" % panel.aim_mode_text())

func test_a_change_is_written_immediately_so_it_survives_a_crash_not_only_a_clean_exit() -> void:
	(panel.get_node("%ReducedFlashesCheck") as CheckButton).toggled.emit(true)
	var reloaded := AccessibilitySettings.new(SCRATCH)
	assert_true(reloaded.load_saved(), "the file exists as soon as the switch is flipped")
	assert_true(reloaded.reduced_flashes, "and holds the new value")

func test_changing_a_setting_is_announced_so_the_hud_and_dialogue_can_follow() -> void:
	var announced: Array[int] = [0]
	panel.settings_changed.connect(func(_s: AccessibilitySettings) -> void: announced[0] += 1)
	(panel.get_node("%SubtitlesCheck") as CheckButton).toggled.emit(false)
	assert_eq(announced[0], 1, "a setting nobody is told about changes nothing on screen")

func test_the_text_scale_is_shown_as_a_readable_percentage() -> void:
	(panel.get_node("%TextScaleSlider") as HSlider).value_changed.emit(1.5)
	assert_true(panel.text_scale_text().contains("150"),
		"the slider's value is a number a player can read: '%s'" % panel.text_scale_text())

func test_the_sample_line_grows_with_the_setting_so_the_choice_can_be_seen_before_it_is_kept() -> void:
	var sample: Label = panel.get_node("%SampleLabel")
	var before: int = sample.get_theme_font_size("font_size")
	(panel.get_node("%TextScaleSlider") as HSlider).value_changed.emit(2.0)
	assert_true(sample.get_theme_font_size("font_size") > before,
		"the sample really is larger (%d then %d)" % [before, sample.get_theme_font_size("font_size")])

func test_restoring_defaults_returns_the_panel_and_the_file() -> void:
	(panel.get_node("%ReducedShakeCheck") as CheckButton).toggled.emit(true)
	(panel.get_node("%TextScaleSlider") as HSlider).value_changed.emit(2.0)
	panel.restore_defaults()
	assert_false(settings.reduced_shake, "the setting is back")
	assert_true(panel.text_scale_text().contains("100"),
		"and the panel shows it: '%s'" % panel.text_scale_text())
	var reloaded := AccessibilitySettings.new(SCRATCH)
	reloaded.load_saved()
	assert_almost_eq(reloaded.dialogue_text_scale, 1.0, 0.001, "the file is back to defaults too")

func test_the_panel_runs_while_the_game_is_paused_because_that_is_where_it_opens_from() -> void:
	assert_eq(panel.process_mode, Node.PROCESS_MODE_WHEN_PAUSED,
		"accessibility opens over a paused game and has to keep working")

func test_the_panel_does_not_offer_a_switch_it_cannot_honour() -> void:
	# Aim assistance is named in docs/gameplay-pillars.md and is a targeting
	# behaviour with no UI-side meaning. A control that changed nothing would read
	# as a working feature, which is worse than the gap it covers.
	for child: Node in (panel.get_node("%Plate/Rows") as VBoxContainer).get_children():
		if child is Button:
			assert_false((child as Button).text.to_lower().contains("aim assist"),
				"no aim-assistance switch is offered while nothing reads it")
