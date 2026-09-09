class_name InputRemap
extends Control
## Remapping for the fourteen gameplay actions project.godot defines.
##
## docs/gameplay-pillars.md calls its own binding table "a proposal, not
## configured gameplay" and asks that remapping be offered. The action names come
## from GameActions, which is a mirror of project.godot checked against the live
## InputMap in both directions; this screen never invents an action and never
## edits project.godot.
##
## Persistence and defaults live in BindingStore, not here, so the round-trip can
## be proved without a window. This screen is the widgets and the capture.
##
## Opens over a paused tree, so process_mode is WHEN_PAUSED like the pause menu.

signal closed()
signal bindings_changed()

@onready var _scrim: Panel = %Scrim
@onready var _plate: PanelContainer = %Plate
@onready var _title: Label = %TitleLabel
@onready var _action_rows: VBoxContainer = %ActionRows
@onready var _status: Label = %StatusLabel
@onready var _restore_button: Button = %RestoreDefaultsButton
@onready var _close_button: Button = %CloseButton

var _services: Services
var _store: BindingStore
var _value_labels: Dictionary = {}
var _rebind_buttons: Dictionary = {}
var _capturing: StringName = &""

func _ready() -> void:
	visible = false
	if _store == null:
		# Constructed here so the defaults snapshot is taken from the project's
		# own InputMap BEFORE anything saved is applied over it.
		_store = BindingStore.new()
		_store.load_and_apply()
	_style()
	_build_rows()
	_restore_button.pressed.connect(restore_defaults)
	_close_button.pressed.connect(close)
	_set_status("")

func bind(services: Services) -> void:
	_services = services

## Injection point for tests and for an owner that wants the bindings file
## somewhere else. Must be called before the node enters the tree.
func use_store(store: BindingStore) -> void:
	_store = store

func store() -> BindingStore:
	return _store

# --- public API ---------------------------------------------------------------

func open() -> void:
	visible = true
	_cancel_capture()
	_refresh_all()
	if _restore_button.is_inside_tree():
		_restore_button.grab_focus()

func close() -> void:
	_cancel_capture()
	visible = false
	closed.emit()

func is_open() -> bool:
	return visible

## Binds one action to one event and saves. Refuses an event already used by a
## different action and names that action, rather than leaving two actions on one
## key and letting the player discover it in a fight.
func rebind_action(action: StringName, event: InputEvent) -> bool:
	var clash := _conflicting_action(action, event)
	if clash != &"":
		_set_status("%s is already %s. Choose another." % [
			BindingStore.describe_event(event), GameActions.label_for(clash)])
		return false
	if not _store.rebind(action, event):
		_set_status("That input cannot be saved, so it was not bound.")
		return false
	if not _store.save():
		_set_status("Bound, but the bindings file could not be written.")
	else:
		_set_status("%s is now %s." % [GameActions.label_for(action), BindingStore.describe_event(event)])
	_refresh_all()
	bindings_changed.emit()
	return true

func restore_defaults() -> void:
	_cancel_capture()
	_store.restore_defaults()
	_store.save()
	_set_status("Every binding is back to the project default.")
	_refresh_all()
	bindings_changed.emit()

func binding_text(action: StringName) -> String:
	return BindingStore.describe_action(action)

func status_text() -> String:
	return _status.text

func is_capturing() -> bool:
	return _capturing != &""

func capturing_action() -> StringName:
	return _capturing

## Starts listening for the next input, the same path the row's button takes.
func begin_capture(action: StringName) -> void:
	if not GameActions.ALL.has(action):
		push_error("InputRemap.begin_capture: '%s' is not a remappable game action" % action)
		return
	_capturing = action
	_set_status("Press a key or a pad button for %s. Escape cancels." % GameActions.label_for(action))
	_refresh_row(action)

# --- capture ------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if _capturing == &"":
		return
	if not _is_bindable(event):
		return
	get_viewport().set_input_as_handled()
	if event is InputEventKey and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
		_cancel_capture()
		_set_status("Left unchanged.")
		return
	var action := _capturing
	_capturing = &""
	rebind_action(action, event)

static func _is_bindable(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).pressed
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	if event is InputEventJoypadMotion:
		return absf((event as InputEventJoypadMotion).axis_value) > 0.6
	return false

func _cancel_capture() -> void:
	var was := _capturing
	_capturing = &""
	if was != &"":
		_refresh_row(was)

func _conflicting_action(action: StringName, event: InputEvent) -> StringName:
	for other: StringName in GameActions.ALL:
		if other == action or not InputMap.has_action(other):
			continue
		for existing: InputEvent in InputMap.action_get_events(other):
			if existing.is_match(event, false):
				return other
	return &""

# --- rows ---------------------------------------------------------------------

## Built from GameActions.GROUPS rather than authored into the scene, so an
## action added to the project cannot be silently missing a row.
func _build_rows() -> void:
	for child: Node in _action_rows.get_children():
		_action_rows.remove_child(child)
		child.queue_free()
	_value_labels.clear()
	_rebind_buttons.clear()

	for group: Dictionary in GameActions.GROUPS:
		var heading := Label.new()
		heading.text = String(group["title"])
		UiPalette.apply_label_style(heading, UiPalette.BRASS, UiPalette.FONT_SIZE_BODY)
		_action_rows.add_child(heading)
		for entry: Variant in group["actions"] as Array:
			_add_action_row(StringName(String(entry)))

func _add_action_row(action: StringName) -> void:
	var row := HBoxContainer.new()
	row.name = "Row_%s" % action
	row.add_theme_constant_override("separation", 16)

	var name_label := Label.new()
	name_label.text = GameActions.label_for(action)
	name_label.custom_minimum_size = Vector2(280, 0)
	UiPalette.apply_label_style(name_label, UiPalette.BONE, UiPalette.FONT_SIZE_BODY)
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.name = "Value"
	value_label.custom_minimum_size = Vector2(300, 0)
	UiPalette.apply_label_style(value_label, UiPalette.ASH, UiPalette.FONT_SIZE_BODY)
	row.add_child(value_label)

	var button := Button.new()
	button.name = "Rebind"
	button.text = "Rebind"
	button.focus_mode = Control.FOCUS_ALL
	UiPalette.apply_button_style(button)
	button.pressed.connect(func() -> void: begin_capture(action))
	row.add_child(button)

	_action_rows.add_child(row)
	_value_labels[action] = value_label
	_rebind_buttons[action] = button
	_refresh_row(action)

func _refresh_all() -> void:
	for action: StringName in _value_labels.keys():
		_refresh_row(action)

func _refresh_row(action: StringName) -> void:
	var label: Label = _value_labels.get(action)
	if label == null:
		return
	if _capturing == action:
		label.text = "listening..."
		UiPalette.apply_label_style(label, UiPalette.BRASS, UiPalette.FONT_SIZE_BODY)
		return
	label.text = BindingStore.describe_action(action)
	UiPalette.apply_label_style(label, UiPalette.BONE, UiPalette.FONT_SIZE_BODY)

func _set_status(text: String) -> void:
	_status.text = text
	_status.visible = text != ""

func _style() -> void:
	_scrim.add_theme_stylebox_override("panel", UiPalette.scrim())
	_plate.add_theme_stylebox_override("panel", UiPalette.plate())
	UiPalette.apply_label_style(_title, UiPalette.BRASS, UiPalette.FONT_SIZE_TITLE)
	UiPalette.apply_label_style(_status, UiPalette.BONE, UiPalette.FONT_SIZE_SMALL)
	for button: Button in [_restore_button, _close_button]:
		UiPalette.apply_button_style(button)
		button.focus_mode = Control.FOCUS_ALL
