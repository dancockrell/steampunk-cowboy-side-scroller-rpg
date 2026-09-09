class_name Hud
extends Control
## Minimal health / ammo / tool HUD, plus the intervention preview.
##
## The HUD is a MIRROR. It reads state and shows it; it never owns health, spends
## ammunition, or decides whether an intervention is allowed. Every value here
## arrives through a public setter called by whoever does own it
## (docs/architecture/engine-decision.md, "Presentation ... does not own extra
## damage or duplicated rewards").
##
## It lives in the FULL-WINDOW UI layer, not inside the 640x360 world
## SubViewport, so its text is not resampled to world pixels
## (docs/architecture/engine-decision.md, "Composition contract").
##
## NO ART EXISTS. Every panel here is a StyleBoxFlat from UiPalette and every
## place a sprite will go is a named empty seam. None of it is approved art.

const NO_TOOL := &""

@onready var _vitals_plate: PanelContainer = %VitalsPlate
@onready var _health_label: Label = %HealthLabel
@onready var _health_pips: Label = %HealthPips
@onready var _ammo_label: Label = %AmmoLabel
@onready var _tool_plate: PanelContainer = %ToolPlate
@onready var _tool_slots: HBoxContainer = %ToolSlots
@onready var _intervention_plate: PanelContainer = %InterventionPlate
@onready var _intervention_seam: TextureRect = %InterventionPreviewSeam
@onready var _intervention_label: Label = %InterventionLabel
@onready var _intervention_preview_label: Label = %InterventionPreviewLabel
@onready var _standing_label: Label = %StandingLabel

var _services: Services
var _equipped: StringName = NO_TOOL
var _ammo: Dictionary = {}
var _slot_labels: Dictionary = {}
var _text_scale: float = 1.0
var _intervention_available: bool = false
var _intervention_reason: String = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style()
	_build_tool_slots()
	set_health(0, 0)
	set_intervention_available(false, "no divine alliance yet")
	_refresh_ammo()
	_refresh_standing()

## Typed hand-down, per docs/architecture/engine-decision.md. There is no
## autoload and no event bus.
func bind(services: Services) -> void:
	_services = services
	if _services == null:
		return
	var book := _services.relationships
	if book == null:
		return
	if not book.arc_changed.is_connected(_on_arc_changed):
		book.arc_changed.connect(_on_arc_changed)
	_refresh_standing()

# --- public API ---------------------------------------------------------------

func set_health(current: int, max_health: int) -> void:
	_health_label.text = HudFormat.health_line(current, max_health)
	_health_pips.text = HudFormat.health_pips(current, max_health)
	var low := max_health > 0 and current * 3 <= max_health
	UiPalette.apply_label_style(_health_label, UiPalette.EMBER if low else UiPalette.BONE,
		_scaled(UiPalette.FONT_SIZE_BODY))
	UiPalette.apply_label_style(_health_pips, UiPalette.EMBER if low else UiPalette.BONE,
		_scaled(UiPalette.FONT_SIZE_BODY))

## `tool_id` is one of Verbs.TOOL_VERB's keys. An unknown id is refused rather
## than displayed, so a typo cannot invent a fifth tool on screen.
func set_ammo(tool_id: StringName, loaded: int, capacity: int) -> void:
	if HudFormat.slot_index(tool_id) < 0:
		push_error("Hud.set_ammo: '%s' is not one of Michael's four tools. Ignored." % tool_id)
		return
	_ammo[tool_id] = {"loaded": loaded, "capacity": capacity}
	if tool_id == _equipped:
		_refresh_ammo()

func set_equipped(tool_id: StringName) -> void:
	if HudFormat.slot_index(tool_id) < 0:
		push_error("Hud.set_equipped: '%s' is not one of Michael's four tools. Ignored." % tool_id)
		return
	_equipped = tool_id
	_refresh_slots()
	_refresh_ammo()

func equipped() -> StringName:
	return _equipped

## docs/relationships.md: "Michael gets a visible preview and clear unavailable
## feedback." Unavailable without a reason still reads as unavailable and says
## the reason is missing, rather than showing nothing.
func set_intervention_available(available: bool, reason: String) -> void:
	_intervention_available = available
	_intervention_reason = reason
	_intervention_label.text = HudFormat.intervention_line(available, reason)
	UiPalette.apply_label_style(_intervention_label,
		UiPalette.VERDIGRIS if available else UiPalette.ASH, _scaled(UiPalette.FONT_SIZE_BODY))
	_intervention_plate.add_theme_stylebox_override("panel",
		UiPalette.plate(UiPalette.VERDIGRIS if available else Color(0.30, 0.28, 0.26), 3 if available else 2))
	# The seam dims with the rest so a future portrait cannot read as ready when
	# the ability is not.
	_intervention_seam.modulate = Color(1, 1, 1, 1.0 if available else 0.45)

## The words that describe what the intervention will do, until preview art
## exists to show it. Owned by the caller: the HUD does not decide the effect.
func set_intervention_preview(summary: String) -> void:
	_intervention_preview_label.text = summary
	_intervention_preview_label.visible = summary.strip_edges() != ""

func intervention_text() -> String:
	return _intervention_label.text

func ammo_text() -> String:
	return _ammo_label.text

func health_text() -> String:
	return _health_label.text

func slot_text(tool_id: StringName) -> String:
	var label: Label = _slot_labels.get(tool_id)
	return label.text if label != null else ""

func standing_text() -> String:
	return _standing_label.text

## Accessibility: the same scale the dialogue uses, applied to HUD type.
func set_text_scale(scale: float) -> void:
	_text_scale = clampf(scale, AccessibilitySettings.TEXT_SCALE_MIN, AccessibilitySettings.TEXT_SCALE_MAX)
	_style()
	_refresh_slots()
	_refresh_ammo()

# --- internals ----------------------------------------------------------------

func _scaled(size: int) -> int:
	return maxi(int(round(float(size) * _text_scale)), 8)

func _style() -> void:
	for plate: PanelContainer in [_vitals_plate, _tool_plate, _intervention_plate]:
		plate.add_theme_stylebox_override("panel", UiPalette.plate())
	UiPalette.apply_label_style(_health_label, UiPalette.BONE, _scaled(UiPalette.FONT_SIZE_BODY))
	UiPalette.apply_label_style(_health_pips, UiPalette.BONE, _scaled(UiPalette.FONT_SIZE_BODY))
	UiPalette.apply_label_style(_ammo_label, UiPalette.BONE, _scaled(UiPalette.FONT_SIZE_BODY))
	UiPalette.apply_label_style(_intervention_label, UiPalette.ASH, _scaled(UiPalette.FONT_SIZE_BODY))
	UiPalette.apply_label_style(_intervention_preview_label, UiPalette.BONE, _scaled(UiPalette.FONT_SIZE_SMALL))
	UiPalette.apply_label_style(_standing_label, UiPalette.BONE, _scaled(UiPalette.FONT_SIZE_SMALL))

## Built from Verbs.TOOL_VERB rather than authored into the scene, so the HUD
## cannot come to disagree with the tool table about how many tools exist.
func _build_tool_slots() -> void:
	for child: Node in _tool_slots.get_children():
		_tool_slots.remove_child(child)
		child.queue_free()
	_slot_labels.clear()
	for tool_id: StringName in HudFormat.slot_order():
		var label := Label.new()
		label.name = "Slot_%s" % tool_id
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_tool_slots.add_child(label)
		_slot_labels[tool_id] = label
	_refresh_slots()

func _refresh_slots() -> void:
	for tool_id: StringName in _slot_labels.keys():
		var label: Label = _slot_labels[tool_id]
		var is_equipped: bool = tool_id == _equipped
		label.text = HudFormat.slot_label(tool_id, is_equipped)
		UiPalette.apply_label_style(label, UiPalette.BRASS if is_equipped else UiPalette.ASH,
			_scaled(UiPalette.FONT_SIZE_BODY))

func _refresh_ammo() -> void:
	if _equipped == NO_TOOL:
		_ammo_label.text = "no tool equipped"
		return
	var entry: Dictionary = _ammo.get(_equipped, {"loaded": 0, "capacity": 0})
	_ammo_label.text = HudFormat.ammo_line(_equipped, int(entry["loaded"]), int(entry["capacity"]))

func _refresh_standing() -> void:
	if _services == null or _services.relationships == null:
		_standing_label.text = ""
		return
	var lines: PackedStringArray = PackedStringArray()
	for heroine_id: StringName in _services.relationships.heroine_ids():
		var state := _services.relationships.state(heroine_id)
		if state == null:
			continue
		var line := HudFormat.alliance_line(state.arc_name(), state.alliance_accepted)
		if line != "":
			lines.append(line)
	_standing_label.text = "\n".join(lines)

func _on_arc_changed(_heroine_id: StringName, _arc: int) -> void:
	_refresh_standing()
