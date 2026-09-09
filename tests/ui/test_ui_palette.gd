extends TestCase
## docs/gameplay-pillars.md: play must read "at target scale and dark-room
## lighting" against ornate art. That is a measurable claim, so it is measured
## here rather than asserted in a comment.
##
## The HUD's text sits on UiPalette's plate. The plate is semi-transparent, so
## the worst case is whatever the art behind it happens to be: every text colour
## is checked against the plate composited over a WHITE world and over a BLACK
## world, and must clear the floor in both.

const WHITE_WORLD := Color(1, 1, 1)
const BLACK_WORLD := Color(0, 0, 0)

func test_every_text_colour_stays_readable_whatever_art_is_behind_the_plate() -> void:
	assert_eq(UiPalette.TEXT_COLORS.size(), 5,
		"five text colours are under test; a colour added without being listed here would go unmeasured")
	var over_white := UiPalette.plate_over(WHITE_WORLD)
	var over_black := UiPalette.plate_over(BLACK_WORLD)
	for color: Color in UiPalette.TEXT_COLORS:
		var bright := UiPalette.contrast_ratio(color, over_white)
		var dark := UiPalette.contrast_ratio(color, over_black)
		assert_true(bright >= UiPalette.MIN_CONTRAST,
			"%s stays readable over the brightest art (%.2f:1)" % [color, bright])
		assert_true(dark >= UiPalette.MIN_CONTRAST,
			"%s stays readable in a dark room (%.2f:1)" % [color, dark])

func test_the_contrast_measure_can_report_a_failure() -> void:
	# Without this the test above would pass identically against a broken
	# measure that returned a large number for everything.
	assert_true(UiPalette.contrast_ratio(UiPalette.ASH, UiPalette.ASH) < UiPalette.MIN_CONTRAST,
		"a colour against itself is unreadable, and the measure says so")
	assert_almost_eq(UiPalette.contrast_ratio(Color(0, 0, 0), Color(1, 1, 1)), 21.0, 0.01,
		"black on white is the known maximum of 21:1, so the measure is calibrated")

func test_the_plate_is_opaque_enough_that_the_art_behind_it_barely_shows() -> void:
	var over_white := UiPalette.plate_over(WHITE_WORLD)
	var over_black := UiPalette.plate_over(BLACK_WORLD)
	assert_true(UiPalette.contrast_ratio(over_white, over_black) < 1.5,
		"the plate reads almost the same over the brightest and the darkest art, "
		+ "so HUD legibility does not depend on what the room looks like")

func test_the_equipped_and_danger_colours_are_told_apart_by_value_not_only_hue() -> void:
	# A colour-blind player sees value. Two states signalled by hue alone at the
	# same lightness are the failure docs/gameplay-pillars.md names.
	var brass := UiPalette.relative_luminance(UiPalette.BRASS)
	var ash := UiPalette.relative_luminance(UiPalette.ASH)
	assert_true(absf(brass - ash) > 0.05,
		"equipped (brass) and unequipped (ash) differ in lightness, not just in colour")
