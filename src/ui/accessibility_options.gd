class_name AccessibilityOptions
extends Control
## The accessibility panel: toggle/hold aiming, reduced shake, reduced flashes,
## subtitles and dialogue text scale (docs/gameplay-pillars.md).
##
## The widgets are here; the values and the file are AccessibilitySettings.
##
## WHO READS WHAT, stated plainly so no setting here is a control wired to
## nothing:
##
## - dialogue_text_scale and subtitles_enabled are consumed inside src/ui, by
##   Dialogue.apply_accessibility and Hud.set_text_scale.
## - aim_mode, reduced_shake and reduced_flashes are consumed OUTSIDE src/ui, by
##   the player controller and the camera/VFX, which do not exist yet. This panel
##   stores them and emits `settings_changed`; it does not pretend to apply them.
##   That gap is reported rather than hidden.
##
## Aim assistance is named in the pillars and is deliberately NOT offered here: it
## is a targeting behaviour with no UI-side meaning, and a switch that changes
## nothing is worse than an absent one.
##
## Opens over a paused tree, so process_mode is WHEN_PAUSED like the pause menu.

signal closed()
signal settings_changed(settings: AccessibilitySettings)

@onready var _scrim: Panel = %Scrim
@onready var _plate: PanelContainer = %Plate
@onready var _title: Label = %TitleLabel
@onready var _aim_mode_button: Button = %AimModeButton
@onready var _reduced_shake_check: CheckButton = %ReducedShakeCheck
@onready var _reduced_flashes_check: CheckButton = %ReducedFlashesCheck
@onready var _subtitles_check: CheckButton = %SubtitlesCheck
@onready var _text_scale_slider: HSlider = %TextScaleSlider
@onready var _text_scale_value: Label = %TextScaleValueLabel
@onready var _sample_label: Label = %SampleLabel
@onready var _restore_button: Button = %RestoreDefaultsButton
@onready var _close_button: Button = %CloseButton

var _services: Services
var _settings: AccessibilitySettings
var _updating: bool = false

func _ready() -> void:
	visible = false
	if _settings == null:
		_settings = AccessibilitySettings.new()
		_settings.load_saved()
	_style()
	_text_scale_slider.min_value = AccessibilitySettings.TEXT_SCALE_MIN
	_text_scale_slider.max_value = AccessibilitySettings.TEXT_SCALE_MAX
	_text_scale_slider.step = 0.05

	_aim_mode_button.pressed.connect(_on_aim_mode_pressed)
	_reduced_shake_check.toggled.connect(_on_reduced_shake_toggled)
	_reduced_flashes_check.toggled.connect(_on_reduced_flashes_toggled)
	_subtitles_check.toggled.connect(_on_subtitles_toggled)
	_text_scale_slider.value_changed.connect(_on_text_scale_changed)
	_restore_button.pressed.connect(restore_defaults)
	_close_button.pressed.connect(close)
	_refresh()

func bind(services: Services) -> void:
	_services = services

## Injection point for tests and for an owner that keeps the file elsewhere.
## Must be called before the node enters the tree.
func use_settings(settings: AccessibilitySettings) -> void:
	_settings = settings

func settings() -> AccessibilitySettings:
	return _settings

# --- public API ---------------------------------------------------------------

func open() -> void:
	visible = true
	_refresh()
	if _aim_mode_button.is_inside_tree():
		_aim_mode_button.grab_focus()

func close() -> void:
	visible = false
	closed.emit()

func is_open() -> bool:
	return visible

func restore_defaults() -> void:
	_settings.reset_to_defaults()
	_settings.save()
	_refresh()
	settings_changed.emit(_settings)

func aim_mode_text() -> String:
	return _aim_mode_button.text

func text_scale_text() -> String:
	return _text_scale_value.text

# --- widget handlers ----------------------------------------------------------

func _on_aim_mode_pressed() -> void:
	var next := AccessibilitySettings.AimMode.TOGGLE \
		if _settings.aim_mode == AccessibilitySettings.AimMode.HOLD \
		else AccessibilitySettings.AimMode.HOLD
	_settings.aim_mode = next
	_commit()

func _on_reduced_shake_toggled(value: bool) -> void:
	if _updating:
		return
	_settings.reduced_shake = value
	_commit()

func _on_reduced_flashes_toggled(value: bool) -> void:
	if _updating:
		return
	_settings.reduced_flashes = value
	_commit()

func _on_subtitles_toggled(value: bool) -> void:
	if _updating:
		return
	_settings.subtitles_enabled = value
	_commit()

func _on_text_scale_changed(value: float) -> void:
	if _updating:
		return
	_settings.dialogue_text_scale = clampf(value,
		AccessibilitySettings.TEXT_SCALE_MIN, AccessibilitySettings.TEXT_SCALE_MAX)
	_commit()

func _commit() -> void:
	_settings.save()
	_refresh()
	settings_changed.emit(_settings)

# --- internals ----------------------------------------------------------------

## Every control states its state in words as well as in its switch position, so
## the panel is readable without colour and at a glance in a dark room.
func _refresh() -> void:
	_updating = true
	_aim_mode_button.text = "Aiming: %s" % ("hold the button" \
		if _settings.aim_mode == AccessibilitySettings.AimMode.HOLD else "press to toggle")
	_reduced_shake_check.text = "Reduced screen shake: %s" % _on_off(_settings.reduced_shake)
	_reduced_shake_check.button_pressed = _settings.reduced_shake
	_reduced_flashes_check.text = "Reduced flashes: %s" % _on_off(_settings.reduced_flashes)
	_reduced_flashes_check.button_pressed = _settings.reduced_flashes
	_subtitles_check.text = "Subtitles for sound cues: %s" % _on_off(_settings.subtitles_enabled)
	_subtitles_check.button_pressed = _settings.subtitles_enabled
	_text_scale_slider.value = _settings.dialogue_text_scale
	_text_scale_value.text = "Dialogue text size: %d%%" % int(round(_settings.dialogue_text_scale * 100.0))
	UiPalette.apply_label_style(_sample_label, UiPalette.BONE,
		maxi(int(round(float(UiPalette.FONT_SIZE_BODY) * _settings.dialogue_text_scale)), 8))
	_updating = false

static func _on_off(value: bool) -> String:
	return "on" if value else "off"

func _style() -> void:
	_scrim.add_theme_stylebox_override("panel", UiPalette.scrim())
	_plate.add_theme_stylebox_override("panel", UiPalette.plate())
	UiPalette.apply_label_style(_title, UiPalette.BRASS, UiPalette.FONT_SIZE_TITLE)
	UiPalette.apply_label_style(_text_scale_value, UiPalette.BONE, UiPalette.FONT_SIZE_BODY)
	UiPalette.apply_label_style(_sample_label, UiPalette.BONE, UiPalette.FONT_SIZE_BODY)
	for button: Button in [_aim_mode_button, _reduced_shake_check, _reduced_flashes_check,
			_subtitles_check, _restore_button, _close_button]:
		UiPalette.apply_button_style(button)
		button.focus_mode = Control.FOCUS_ALL
	_text_scale_slider.focus_mode = Control.FOCUS_ALL
