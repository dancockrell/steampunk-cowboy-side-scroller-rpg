class_name PuzzleBook
extends RefCounted
## Persistent mechanism state per authored puzzle ID.
##
## Mechanism state is authored data, never inferred from how the rubble happens
## to look (docs/architecture/engine-decision.md ownership table).

signal puzzle_changed(puzzle_id: StringName, state: Dictionary)

var _states: Dictionary = {}
var _defaults: Dictionary = {}

## Declares a puzzle and its reset state. Called by the mechanism on room load.
func declare(puzzle_id: StringName, default_state: Dictionary) -> void:
	_defaults[puzzle_id] = default_state.duplicate(true)
	if not _states.has(puzzle_id):
		_states[puzzle_id] = default_state.duplicate(true)

func state_of(puzzle_id: StringName) -> Dictionary:
	return _states.get(puzzle_id, {})

func set_field(puzzle_id: StringName, field: StringName, value: Variant) -> void:
	if not _states.has(puzzle_id):
		push_error("PuzzleBook.set_field: '%s' was never declared" % puzzle_id)
		return
	_states[puzzle_id][String(field)] = value
	puzzle_changed.emit(puzzle_id, _states[puzzle_id])

func get_field(puzzle_id: StringName, field: StringName, default_value: Variant = null) -> Variant:
	return state_of(puzzle_id).get(String(field), default_value)

## Returns a critical mechanism to its authored start state. Required by
## docs/gameplay-pillars.md: a critical mechanism can always be reset.
func reset(puzzle_id: StringName) -> void:
	if not _defaults.has(puzzle_id):
		push_error("PuzzleBook.reset: '%s' was never declared" % puzzle_id)
		return
	_states[puzzle_id] = _defaults[puzzle_id].duplicate(true)
	puzzle_changed.emit(puzzle_id, _states[puzzle_id])

func known_puzzle_ids() -> Array:
	var ids: Array = _states.keys()
	ids.sort()
	return ids

func serialize() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in _states:
		out[String(id)] = _states[id].duplicate(true)
	return out

func restore(data: Dictionary) -> bool:
	_states.clear()
	for key: String in data:
		if typeof(data[key]) != TYPE_DICTIONARY:
			return false
		_states[StringName(key)] = (data[key] as Dictionary).duplicate(true)
	return true
