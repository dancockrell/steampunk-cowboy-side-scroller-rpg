class_name UiPalette
extends RefCounted
## One place for every UI colour, plate and border in src/ui.
##
## NO ART EXISTS. Everything here is StyleBoxFlat and plain colour, deliberately
## so, and none of it is approved art direction (AGENTS.md: never call a
## placeholder an approved asset).
##
## docs/gameplay-pillars.md asks for play that reads "at target scale and
## dark-room lighting" and for tells "that do not rely on color alone".
## Two consequences, both measured in tests/ui/test_ui_palette.gd rather than
## asserted here in prose:
##
## 1. Readable text never sits directly on the world. It sits on PLATE, an
##    almost-opaque dark backing, so its contrast does not depend on whatever
##    ornate art happens to be behind it. Every text colour is checked against
##    PLATE composited over a WHITE world and over a BLACK world, and must clear
##    MIN_CONTRAST in both.
## 2. Colour is always the SECOND channel. The first is a word or a glyph, which
##    is HudFormat's job.

## WCAG AA for body text. The floor is a measured number, not a taste call.
const MIN_CONTRAST := 4.5

## Backing plate. The alpha is load-bearing: it is what makes the contrast
## figures above independent of the art behind the HUD.
const PLATE_COLOR := Color(0.04, 0.035, 0.03, 0.92)
const PLATE_BORDER := Color(0.52, 0.42, 0.24, 1.0)

## Text and state colours.
const BONE := Color(0.96, 0.93, 0.85)      ## primary readable text
const ASH := Color(0.62, 0.60, 0.56)       ## dimmed / unavailable text
const BRASS := Color(0.86, 0.66, 0.24)     ## equipped, focused, selected
const EMBER := Color(0.95, 0.47, 0.34)     ## danger, low health, refusal
const VERDIGRIS := Color(0.36, 0.72, 0.60)  ## a divine effect is ready

## Every colour used for text. The contrast test iterates THIS list, so a colour
## added above and forgotten here is caught by the count assertion in the test
## rather than shipping unmeasured.
const TEXT_COLORS: Array[Color] = [BONE, ASH, BRASS, EMBER, VERDIGRIS]

const FONT_SIZE_BODY := 18
const FONT_SIZE_TITLE := 26
const FONT_SIZE_SMALL := 14

static func plate(border_color: Color = PLATE_BORDER, border_width: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = PLATE_COLOR
	box.border_color = border_color
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(3)
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 8.0
	box.content_margin_bottom = 8.0
	return box

## A full-window scrim for pause and dialogue. Darker than the plate so the world
## recedes without hiding it entirely.
static func scrim() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.02, 0.018, 0.015, 0.78)
	return box

## Buttons carry their focus state in a heavy border and a value shift, not in
## hue alone, so keyboard and gamepad focus stays visible to a colour-blind
## player and in a dark room.
static func apply_button_style(button: Button) -> void:
	var normal := plate(Color(0.40, 0.33, 0.20), 2)
	var hovered := plate(BRASS, 2)
	hovered.bg_color = Color(0.12, 0.10, 0.07, 0.95)
	var focused := plate(BONE, 4)
	focused.bg_color = Color(0.16, 0.13, 0.09, 0.97)
	var pressed := plate(BONE, 4)
	pressed.bg_color = Color(0.26, 0.21, 0.13, 0.98)
	var disabled := plate(Color(0.28, 0.26, 0.24), 2)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hovered)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", BONE)
	button.add_theme_color_override("font_hover_color", BONE)
	button.add_theme_color_override("font_focus_color", BONE)
	button.add_theme_color_override("font_pressed_color", BRASS)
	button.add_theme_color_override("font_disabled_color", ASH)
	button.add_theme_font_size_override("font_size", FONT_SIZE_BODY)

static func apply_label_style(label: Label, color: Color = BONE, size: int = FONT_SIZE_BODY) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)
	# An outline keeps the glyph edge alive where a plate cannot be used.
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.018, 0.015, 1.0))
	label.add_theme_constant_override("outline_size", 4)

## sRGB relative luminance, per WCAG 2.x.
static func relative_luminance(color: Color) -> float:
	return 0.2126 * _linearize(color.r) + 0.7152 * _linearize(color.g) + 0.0722 * _linearize(color.b)

static func _linearize(channel: float) -> float:
	if channel <= 0.04045:
		return channel / 12.92
	return pow((channel + 0.055) / 1.055, 2.4)

static func contrast_ratio(a: Color, b: Color) -> float:
	var la := relative_luminance(a)
	var lb := relative_luminance(b)
	var lighter := maxf(la, lb)
	var darker := minf(la, lb)
	return (lighter + 0.05) / (darker + 0.05)

## What the plate actually looks like once the world shows through it. The
## argument is the worst case the ornate art can present.
static func plate_over(world: Color) -> Color:
	var a := PLATE_COLOR.a
	return Color(
		PLATE_COLOR.r * a + world.r * (1.0 - a),
		PLATE_COLOR.g * a + world.g * (1.0 - a),
		PLATE_COLOR.b * a + world.b * (1.0 - a),
		1.0)
