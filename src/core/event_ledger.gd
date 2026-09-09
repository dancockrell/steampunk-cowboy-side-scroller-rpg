class_name EventLedger
extends RefCounted
## Idempotent record of consumed simulation events.
##
## Rewards, judgments and source destruction all route through here so a reload,
## a replayed animation or a re-entered room cannot award the same fact twice
## (docs/temple-emergence.md, docs/gameplay-pillars.md).

signal event_consumed(event_id: StringName, context: Dictionary)

var _consumed: Dictionary = {}

## Returns true exactly once per event_id. Every later call returns false.
func consume(event_id: StringName, context: Dictionary = {}) -> bool:
	if event_id == &"":
		push_error("EventLedger.consume called with an empty event id")
		return false
	if _consumed.has(event_id):
		return false
	_consumed[event_id] = context.duplicate(true)
	event_consumed.emit(event_id, context)
	return true

func has_consumed(event_id: StringName) -> bool:
	return _consumed.has(event_id)

func context_for(event_id: StringName) -> Dictionary:
	return _consumed.get(event_id, {})

func consumed_ids() -> Array:
	var ids: Array = _consumed.keys()
	ids.sort()
	return ids

func count() -> int:
	return _consumed.size()

func serialize() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in _consumed:
		out[String(id)] = _consumed[id]
	return out

func restore(data: Dictionary) -> void:
	_consumed.clear()
	for key: String in data:
		_consumed[StringName(key)] = data[key]
