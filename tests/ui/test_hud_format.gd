extends TestCase
## Every HUD string, checked with the colour taken away.
##
## docs/gameplay-pillars.md asks for tells "that do not rely on color alone", so
## the property under test throughout this file is that the plain text alone
## still distinguishes the states. If these pass, the HUD is readable on a
## greyscale screen.

func test_the_hud_slots_are_exactly_the_tools_the_table_names() -> void:
	assert_eq(HudFormat.slot_order().size(), Verbs.TOOL_VERB.size(),
		"the HUD shows one slot per authored tool, neither more nor fewer")
	for tool_id: StringName in HudFormat.slot_order():
		assert_true(Verbs.TOOL_VERB.has(tool_id), "'%s' comes from the canonical tool table" % tool_id)

func test_the_equipped_slot_is_distinguishable_without_any_colour() -> void:
	for tool_id: StringName in HudFormat.slot_order():
		assert_ne(HudFormat.slot_label(tool_id, true), HudFormat.slot_label(tool_id, false),
			"'%s' reads differently when equipped even with every colour removed" % tool_id)

func test_each_tool_shows_its_select_number() -> void:
	assert_true(HudFormat.slot_label(&"lasso", false).contains("1"), "lasso is slot 1")
	assert_true(HudFormat.slot_label(&"pistol", false).contains("2"), "pistol is slot 2")

func test_the_lasso_reads_as_having_no_ammunition_not_as_an_empty_magazine() -> void:
	# docs/weapon-tool-kit.md: the lasso has "no ammunition". An absent magazine
	# and an empty one are different facts and must not render the same.
	var lasso := HudFormat.ammo_line(&"lasso", 0, 0)
	var empty_pistol := HudFormat.ammo_line(&"pistol", 0, 6)
	assert_true(lasso.contains("no ammunition"), "the lasso says it has none: %s" % lasso)
	assert_false(lasso.contains("/"), "and it shows no magazine count at all")
	assert_ne(lasso, empty_pistol, "an empty pistol does not read like a lasso")

func test_an_empty_firearm_says_empty_in_words() -> void:
	var line := HudFormat.ammo_line(&"pistol", 0, 6)
	assert_true(line.contains("EMPTY"), "an empty magazine is stated, not only coloured: %s" % line)
	assert_true(line.contains("reload"), "and it says what to do about it")

func test_a_loaded_firearm_shows_what_is_left_and_the_capacity() -> void:
	assert_eq(HudFormat.ammo_line(&"pistol", 3, 6), "PISTOL  3 / 6", "loaded and capacity are both shown")

func test_ammunition_above_capacity_cannot_be_displayed() -> void:
	assert_eq(HudFormat.ammo_line(&"pistol", 99, 2), "PISTOL  2 / 2",
		"the readout is clamped rather than printing an impossible magazine")

func test_low_health_says_low_in_words() -> void:
	assert_true(HudFormat.health_line(1, 5).contains("LOW"), "a nearly dead player is told in words")
	assert_false(HudFormat.health_line(5, 5).contains("LOW"), "and a healthy one is not")
	assert_true(HudFormat.health_line(0, 5).contains("DOWN"), "zero health is its own state")

func test_health_pips_are_a_value_shape_not_a_colour_bar() -> void:
	assert_eq(HudFormat.health_pips(2, 5), "**...", "filled and empty pips read at any size")
	assert_eq(HudFormat.health_pips(0, 3), "...", "an empty bar still shows its length")

func test_health_with_no_maximum_says_unknown_rather_than_showing_a_full_bar() -> void:
	assert_true(HudFormat.health_line(0, 0).contains("unknown"),
		"an unset maximum is reported, not rendered as a healthy player")

func test_an_available_intervention_reads_as_ready() -> void:
	var line := HudFormat.intervention_line(true, "")
	assert_true(line.contains(HudFormat.INTERVENTION_NAME), "the ability is named")
	assert_true(line.contains("READY"), "and its availability is a word: %s" % line)

func test_an_unavailable_intervention_gives_the_reason() -> void:
	var line := HudFormat.intervention_line(false, "she is not watching this room")
	assert_true(line.contains("UNAVAILABLE"), "the state is stated: %s" % line)
	assert_true(line.contains("she is not watching this room"),
		"docs/relationships.md requires clear unavailable feedback, which means the reason")

func test_an_unavailable_intervention_with_no_reason_still_says_it_is_unavailable() -> void:
	# The three-state rule: available, unavailable, and "the caller did not say
	# why". The third must never collapse into either of the first two.
	var line := HudFormat.intervention_line(false, "   ")
	assert_true(line.contains("UNAVAILABLE"), "a missing reason does not make it look ready")
	assert_true(line.contains(HudFormat.NO_REASON_GIVEN),
		"and the missing reason is named rather than rendered as blank: %s" % line)

func test_the_keepers_standing_is_words_and_never_a_score() -> void:
	# docs/relationships.md: the UI must not expose "a romance optimization
	# spreadsheet".
	var lines: Array[String] = [
		HudFormat.alliance_line("encountered", false),
		HudFormat.alliance_line("tested", false),
		HudFormat.alliance_line("allied", true),
	]
	for line: String in lines:
		assert_ne(line, "", "each stage of the arc has something to say")
		for digit: String in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
			assert_false(line.contains(digit), "no number appears in '%s'" % line)

func test_an_unmet_goddess_says_nothing_at_all() -> void:
	assert_eq(HudFormat.alliance_line("unknown", false), "",
		"a goddess Michael has not met does not appear in the HUD")
