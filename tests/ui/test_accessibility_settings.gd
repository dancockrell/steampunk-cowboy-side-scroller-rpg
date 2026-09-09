extends TestCase
## The accessibility options named in docs/gameplay-pillars.md, and whether they
## really survive a restart.

const SCRATCH := "user://test_accessibility.json"

var settings: AccessibilitySettings

func before_each() -> void:
	settings = AccessibilitySettings.new(SCRATCH)
	settings.clear_saved()

func after_each() -> void:
	settings.clear_saved()

func test_every_option_the_pillars_name_has_a_field() -> void:
	# The list is from docs/gameplay-pillars.md: "toggle/hold aiming, readable
	# subtitles, scalable dialogue text, reduced shake/flashes".
	assert_eq(AccessibilitySettings.AIM_MODE_NAMES, ["toggle", "hold"], "both aiming styles exist")
	assert_true(settings.subtitles_enabled, "subtitles are on by default")
	assert_almost_eq(settings.dialogue_text_scale, 1.0, 0.001, "dialogue text starts at its authored size")
	assert_false(settings.reduced_shake, "reduced shake is a choice, off unless asked for")
	assert_false(settings.reduced_flashes, "reduced flashes likewise")

func test_choices_survive_a_save_and_a_reload() -> void:
	settings.set_aim_mode_by_name("toggle")
	settings.set_reduced_shake(true)
	settings.set_reduced_flashes(true)
	settings.set_subtitles_enabled(false)
	settings.set_dialogue_text_scale(1.6)
	assert_true(settings.save(), "the file is written")

	var reloaded := AccessibilitySettings.new(SCRATCH)
	assert_true(reloaded.load_saved(), "and read back")
	assert_eq(reloaded.aim_mode_name(), "toggle", "aiming style persists")
	assert_true(reloaded.reduced_shake, "reduced shake persists")
	assert_true(reloaded.reduced_flashes, "reduced flashes persists")
	assert_false(reloaded.subtitles_enabled, "the subtitle choice persists")
	assert_almost_eq(reloaded.dialogue_text_scale, 1.6, 0.001, "text scale persists")

func test_a_first_run_with_no_file_is_told_apart_from_a_load() -> void:
	assert_false(settings.load_saved(),
		"nothing saved yet returns false, so a caller can tell first run from a load")

func test_a_text_scale_outside_the_range_is_clamped_and_the_clamp_is_reported() -> void:
	var problems := settings.apply_dictionary({
		"schema_version": AccessibilitySettings.SCHEMA_VERSION,
		"dialogue_text_scale": 99.0,
	})
	assert_almost_eq(settings.dialogue_text_scale, AccessibilitySettings.TEXT_SCALE_MAX, 0.001,
		"an absurd scale is clamped rather than making the dialogue unreadable")
	assert_eq(problems.size(), 1, "and the clamp is reported rather than applied in silence")

func test_an_unknown_aim_mode_keeps_the_players_current_choice() -> void:
	settings.set_aim_mode_by_name("toggle")
	var problems := settings.apply_dictionary({
		"schema_version": AccessibilitySettings.SCHEMA_VERSION,
		"aim_mode": "psychic",
	})
	assert_eq(settings.aim_mode_name(), "toggle",
		"an unreadable field leaves the setting alone instead of resetting it")
	assert_eq(problems.size(), 1, "and says so")

func test_a_file_from_another_schema_applies_nothing_at_all() -> void:
	settings.set_reduced_shake(true)
	var problems := settings.apply_dictionary({"schema_version": 99, "reduced_shake": false})
	assert_true(settings.reduced_shake, "a schema this build does not understand changes nothing")
	assert_eq(problems.size(), 1, "and the refusal is reported")

func test_restore_defaults_returns_every_field() -> void:
	settings.set_aim_mode_by_name("toggle")
	settings.set_reduced_shake(true)
	settings.set_subtitles_enabled(false)
	settings.set_dialogue_text_scale(2.0)
	settings.reset_to_defaults()
	assert_eq(settings.aim_mode_name(), "hold", "aiming is back to the default")
	assert_false(settings.reduced_shake, "shake is back")
	assert_true(settings.subtitles_enabled, "subtitles are back")
	assert_almost_eq(settings.dialogue_text_scale, 1.0, 0.001, "text scale is back")

func test_changing_a_setting_announces_it_so_a_consumer_can_react() -> void:
	# An Array, not an int: a GDScript lambda captures a local int by value, so a
	# counter written that way stays at zero and the test would fail for a reason
	# that has nothing to do with the code under test.
	var announcements: Array[int] = [0]
	settings.changed.connect(func() -> void: announcements[0] += 1)
	settings.set_reduced_flashes(true)
	settings.set_dialogue_text_scale(1.25)
	assert_eq(announcements[0], 2, "each change is announced; a setting nobody hears about changes nothing")
