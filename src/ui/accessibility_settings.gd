class_name AccessibilitySettings
extends RefCounted
## The accessibility options named in docs/gameplay-pillars.md, and their file.
##
## Data and persistence only. AccessibilityOptions owns the widgets; this owns
## what they mean and what survives a restart, so the round-trip can be proved
## without a window.
##
## Aim assistance is listed in the pillars but is NOT here: it is a gameplay
## behaviour the player controller owns, and the UI must not invent a setting the
## simulation does not read. See the report in tests/ui/test_accessibility_settings.gd.

const DEFAULT_SAVE_PATH := "user://accessibility.json"
const SCHEMA_VERSION := 1

## Toggle aiming holds the aim until pressed again; hold aiming aims only while
## the button is down. docs/gameplay-pillars.md asks for both.
enum AimMode { TOGGLE, HOLD }
const AIM_MODE_NAMES: Array[String] = ["toggle", "hold"]

const TEXT_SCALE_MIN := 0.75
const TEXT_SCALE_MAX := 2.5

signal changed()

var save_path: String = DEFAULT_SAVE_PATH

var aim_mode: AimMode = AimMode.HOLD
var reduced_shake: bool = false
var reduced_flashes: bool = false
var subtitles_enabled: bool = true
var dialogue_text_scale: float = 1.0

func _init(path: String = DEFAULT_SAVE_PATH) -> void:
	save_path = path

func aim_mode_name() -> String:
	return AIM_MODE_NAMES[aim_mode]

func set_aim_mode_by_name(mode_name: String) -> bool:
	var index := AIM_MODE_NAMES.find(mode_name)
	if index < 0:
		push_error("AccessibilitySettings: unknown aim mode '%s'. Left unchanged." % mode_name)
		return false
	aim_mode = index as AimMode
	changed.emit()
	return true

func set_dialogue_text_scale(scale: float) -> void:
	dialogue_text_scale = clampf(scale, TEXT_SCALE_MIN, TEXT_SCALE_MAX)
	changed.emit()

func set_reduced_shake(value: bool) -> void:
	reduced_shake = value
	changed.emit()

func set_reduced_flashes(value: bool) -> void:
	reduced_flashes = value
	changed.emit()

func set_subtitles_enabled(value: bool) -> void:
	subtitles_enabled = value
	changed.emit()

func reset_to_defaults() -> void:
	aim_mode = AimMode.HOLD
	reduced_shake = false
	reduced_flashes = false
	subtitles_enabled = true
	dialogue_text_scale = 1.0
	changed.emit()

func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"aim_mode": aim_mode_name(),
		"reduced_shake": reduced_shake,
		"reduced_flashes": reduced_flashes,
		"subtitles_enabled": subtitles_enabled,
		"dialogue_text_scale": dialogue_text_scale,
	}

## Applies a saved payload. An unreadable field leaves its current value alone
## and is reported, rather than silently resetting the player's choice.
func apply_dictionary(data: Dictionary) -> PackedStringArray:
	var problems: PackedStringArray = PackedStringArray()
	if int(data.get("schema_version", -1)) != SCHEMA_VERSION:
		problems.append("schema_version %s is not %d; nothing applied"
			% [data.get("schema_version", "missing"), SCHEMA_VERSION])
		return problems
	if data.has("aim_mode"):
		var index := AIM_MODE_NAMES.find(String(data["aim_mode"]))
		if index < 0:
			problems.append("unknown aim_mode '%s'; kept '%s'" % [data["aim_mode"], aim_mode_name()])
		else:
			aim_mode = index as AimMode
	if data.has("reduced_shake"):
		reduced_shake = bool(data["reduced_shake"])
	if data.has("reduced_flashes"):
		reduced_flashes = bool(data["reduced_flashes"])
	if data.has("subtitles_enabled"):
		subtitles_enabled = bool(data["subtitles_enabled"])
	if data.has("dialogue_text_scale"):
		var scale := float(data["dialogue_text_scale"])
		if scale < TEXT_SCALE_MIN or scale > TEXT_SCALE_MAX:
			problems.append("dialogue_text_scale %f is outside %f..%f; clamped"
				% [scale, TEXT_SCALE_MIN, TEXT_SCALE_MAX])
		dialogue_text_scale = clampf(scale, TEXT_SCALE_MIN, TEXT_SCALE_MAX)
	changed.emit()
	return problems

func save() -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("AccessibilitySettings.save: cannot write %s (error %d)"
			% [save_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(to_dictionary(), "  "))
	file.close()
	return true

## Returns false when nothing was loaded, so first run is distinguishable from a
## load that happened. Problems from the payload are pushed as errors.
func load_saved() -> bool:
	if not FileAccess.file_exists(save_path):
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_error("AccessibilitySettings.load_saved: cannot read %s" % save_path)
		return false
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("AccessibilitySettings.load_saved: %s is not a JSON object. Ignored." % save_path)
		return false
	for problem: String in apply_dictionary(parsed as Dictionary):
		push_error("AccessibilitySettings.load_saved: %s" % problem)
	return true

func clear_saved() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
