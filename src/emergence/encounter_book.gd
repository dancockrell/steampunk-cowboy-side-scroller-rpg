class_name EncounterBook
extends RefCounted
## Persistent phase and result per authored encounter source ID.
##
## The prop and the creature are two views of ONE encounter (docs/temple-emergence.md).
## Room unload stores the phase here; re-entry reads it back, which is what stops
## a re-entered room duplicating the enemy or re-awarding its result.

enum Phase { DISGUISED, TELL, AWAKENING, EMERGING, ACTIVE, RESOLVED }

const PHASE_NAMES: Array[String] = ["disguised", "tell", "awakening", "emerging", "active", "resolved"]

signal phase_recorded(source_id: StringName, phase: Phase)

var _records: Dictionary = {}

func _record(source_id: StringName) -> Dictionary:
	if not _records.has(source_id):
		_records[source_id] = {"phase": Phase.DISGUISED, "result": ""}
	return _records[source_id]

func phase_of(source_id: StringName) -> Phase:
	return _record(source_id)["phase"] as Phase

func result_of(source_id: StringName) -> String:
	return String(_record(source_id)["result"])

func is_resolved(source_id: StringName) -> bool:
	return phase_of(source_id) == Phase.RESOLVED

## Phase is monotonic within a run. Only a checkpoint rollback moves it backwards,
## and that goes through restore(), never through here.
func record_phase(source_id: StringName, phase: Phase) -> void:
	var rec := _record(source_id)
	if phase < rec["phase"]:
		push_error("EncounterBook: refusing to move '%s' backwards from %s to %s outside a rollback"
			% [source_id, PHASE_NAMES[rec["phase"]], PHASE_NAMES[phase]])
		return
	if rec["phase"] == phase:
		return
	rec["phase"] = phase
	phase_recorded.emit(source_id, phase)

func record_result(source_id: StringName, result: String) -> void:
	var rec := _record(source_id)
	rec["result"] = result
	record_phase(source_id, Phase.RESOLVED)

func known_source_ids() -> Array:
	var ids: Array = _records.keys()
	ids.sort()
	return ids

func serialize() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in _records:
		out[String(id)] = {
			"phase": PHASE_NAMES[_records[id]["phase"]],
			"result": _records[id]["result"],
		}
	return out

func restore(data: Dictionary) -> bool:
	_records.clear()
	for key: String in data:
		var entry: Variant = data[key]
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		var phase_index: int = PHASE_NAMES.find(String((entry as Dictionary).get("phase", "")))
		if phase_index < 0:
			push_error("EncounterBook.restore: unknown phase '%s' for source '%s'"
				% [(entry as Dictionary).get("phase", ""), key])
			return false
		_records[StringName(key)] = {
			"phase": phase_index,
			"result": String((entry as Dictionary).get("result", "")),
		}
	return true
