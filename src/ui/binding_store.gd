class_name BindingStore
extends RefCounted
## Reads, writes and restores the player's input bindings.
##
## Kept apart from InputRemap (the screen) because persistence is the half that
## can be proved headlessly, and because a round-trip that "succeeds" while
## saving nothing is exactly the failure a UI test cannot see.
##
## `save_path` is a variable rather than a constant so a test can point the store
## at a scratch file and at a path that cannot be written. A branch nobody can
## reach on purpose is a branch nobody can prove.

const DEFAULT_SAVE_PATH := "user://input_bindings.json"
const SCHEMA_VERSION := 1

signal bindings_changed(action: StringName)

var save_path: String = DEFAULT_SAVE_PATH

## The bindings as the project shipped them, captured before the player has
## changed anything. Restore-defaults replays these; it does not guess.
var _defaults: Dictionary = {}

func _init(path: String = DEFAULT_SAVE_PATH) -> void:
	save_path = path
	capture_defaults()

## Snapshots the current InputMap as the defaults. Call once, at construction,
## before applying anything the player saved.
func capture_defaults() -> void:
	_defaults = encode_actions(GameActions.ALL)

func defaults() -> Dictionary:
	return _defaults.duplicate(true)

# --- encoding -----------------------------------------------------------------

## One InputEvent as plain JSON-safe data. An event type this does not know
## returns an empty dictionary, which callers must treat as "not encodable"
## rather than as an empty binding.
static func encode_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key := event as InputEventKey
		return {
			"type": "key",
			"physical_keycode": int(key.physical_keycode),
			"keycode": int(key.keycode),
		}
	if event is InputEventMouseButton:
		return {"type": "mouse_button", "button_index": int((event as InputEventMouseButton).button_index)}
	if event is InputEventJoypadButton:
		return {"type": "joypad_button", "button_index": int((event as InputEventJoypadButton).button_index)}
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		return {"type": "joypad_motion", "axis": int(motion.axis), "axis_value": float(motion.axis_value)}
	return {}

static func decode_event(data: Dictionary) -> InputEvent:
	match String(data.get("type", "")):
		"key":
			var key := InputEventKey.new()
			key.physical_keycode = int(data.get("physical_keycode", 0))
			key.keycode = int(data.get("keycode", 0))
			if key.physical_keycode == 0 and key.keycode == 0:
				push_warning("BindingStore.decode_event: key entry names no key. Dropped.")
				return null
			return key
		"mouse_button":
			var mouse := InputEventMouseButton.new()
			mouse.button_index = int(data.get("button_index", 0))
			return mouse
		"joypad_button":
			var pad := InputEventJoypadButton.new()
			pad.button_index = int(data.get("button_index", 0))
			return pad
		"joypad_motion":
			var motion := InputEventJoypadMotion.new()
			motion.axis = int(data.get("axis", 0))
			motion.axis_value = float(data.get("axis_value", 0.0))
			return motion
	push_warning("BindingStore.decode_event: unknown event type '%s'. Dropped." % data.get("type", ""))
	return null

## Human-readable, and deliberately NOT built from DisplayServer: the remap
## screen has to name a key the same way in a headless test as on a desktop.
static func describe_event(event: InputEvent) -> String:
	if event is InputEventKey:
		var key := event as InputEventKey
		var code := key.physical_keycode if key.physical_keycode != 0 else key.keycode
		var text := OS.get_keycode_string(code)
		return text if text != "" else "Key %d" % code
	if event is InputEventMouseButton:
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_LEFT: return "Left click"
			MOUSE_BUTTON_RIGHT: return "Right click"
			MOUSE_BUTTON_MIDDLE: return "Middle click"
			_: return "Mouse button %d" % (event as InputEventMouseButton).button_index
	if event is InputEventJoypadButton:
		return "Pad button %d" % (event as InputEventJoypadButton).button_index
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		var direction := "+" if motion.axis_value >= 0.0 else "-"
		return "Pad axis %d%s" % [motion.axis, direction]
	return "unbound"

static func describe_action(action: StringName) -> String:
	if not InputMap.has_action(action):
		return "no such action"
	var parts: PackedStringArray = PackedStringArray()
	for event: InputEvent in InputMap.action_get_events(action):
		parts.append(describe_event(event))
	if parts.is_empty():
		return "unbound"
	return ", ".join(parts)

# --- reading and writing the live InputMap ------------------------------------

static func encode_actions(actions: Array[StringName]) -> Dictionary:
	var out: Dictionary = {}
	for action: StringName in actions:
		if not InputMap.has_action(action):
			continue
		var events: Array = []
		for event: InputEvent in InputMap.action_get_events(action):
			var encoded := encode_event(event)
			if not encoded.is_empty():
				events.append(encoded)
		out[String(action)] = events
	return out

## Current live bindings for every gameplay action.
func snapshot() -> Dictionary:
	return encode_actions(GameActions.ALL)

## Writes `bindings` into the live InputMap. Returns the list of problems it
## refused to act on. An empty array means every named action was applied; a
## non-empty one must be surfaced, never swallowed.
func apply(bindings: Dictionary) -> PackedStringArray:
	var problems: PackedStringArray = PackedStringArray()
	for key: Variant in bindings.keys():
		var action := StringName(String(key))
		if not GameActions.ALL.has(action):
			problems.append("'%s' is not a game action; ignored rather than created" % action)
			continue
		if not InputMap.has_action(action):
			problems.append("'%s' is not in the project's InputMap; ignored" % action)
			continue
		var entries: Variant = bindings[key]
		if typeof(entries) != TYPE_ARRAY:
			problems.append("'%s' has a non-array binding list; left unchanged" % action)
			continue
		var decoded: Array[InputEvent] = []
		for entry: Variant in entries as Array:
			if typeof(entry) != TYPE_DICTIONARY:
				problems.append("'%s' has a non-object event; skipped" % action)
				continue
			var event := decode_event(entry as Dictionary)
			if event == null:
				problems.append("'%s' has an unreadable event; skipped" % action)
				continue
			decoded.append(event)
		InputMap.action_erase_events(action)
		for event: InputEvent in decoded:
			InputMap.action_add_event(action, event)
		bindings_changed.emit(action)
	return problems

## Replaces every event on one action with a single event. Returns false when the
## action is not one of ours, so a typo cannot silently create a binding.
func rebind(action: StringName, event: InputEvent) -> bool:
	if not GameActions.ALL.has(action) or not InputMap.has_action(action):
		push_error("BindingStore.rebind: '%s' is not a remappable game action" % action)
		return false
	if encode_event(event).is_empty():
		push_error("BindingStore.rebind: event type cannot be persisted, so it is refused")
		return false
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	bindings_changed.emit(action)
	return true

func restore_defaults() -> void:
	apply(_defaults)

# --- persistence --------------------------------------------------------------

func save() -> bool:
	var payload := {"schema_version": SCHEMA_VERSION, "bindings": snapshot()}
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("BindingStore.save: cannot write %s (error %d)" % [save_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	return true

## Reads the saved bindings. Returns an empty dictionary when there is nothing
## saved yet, which is a normal first run, and pushes an error for a file that
## exists but cannot be understood. Those are different outcomes and the caller
## can tell them apart by asking `has_saved_bindings()`.
func load_bindings() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_error("BindingStore.load_bindings: cannot read %s" % save_path)
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("BindingStore.load_bindings: %s is not a JSON object. Ignored." % save_path)
		return {}
	var dict: Dictionary = parsed
	if int(dict.get("schema_version", -1)) != SCHEMA_VERSION:
		push_error("BindingStore.load_bindings: %s has schema_version %s, expected %d. Ignored rather than guessed."
			% [save_path, dict.get("schema_version", "missing"), SCHEMA_VERSION])
		return {}
	var bindings: Variant = dict.get("bindings", {})
	if typeof(bindings) != TYPE_DICTIONARY:
		push_error("BindingStore.load_bindings: 'bindings' is not an object. Ignored.")
		return {}
	return bindings

func has_saved_bindings() -> bool:
	return FileAccess.file_exists(save_path)

## Applies whatever was saved. Returns the problems from `apply`, plus nothing at
## all when there is no saved file, so first run and broken file do not look the
## same to the caller.
func load_and_apply() -> PackedStringArray:
	var bindings := load_bindings()
	if bindings.is_empty():
		return PackedStringArray()
	return apply(bindings)

func clear_saved() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
