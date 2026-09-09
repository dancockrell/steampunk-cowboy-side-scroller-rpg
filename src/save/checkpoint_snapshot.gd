class_name CheckpointSnapshot
extends RefCounted
## CheckpointSnapshot version 1. Field list from docs/data-contracts.md.
##
## The snapshot is atomic by construction: every dependent system is captured in
## one pass and restored only after the WHOLE payload validates. A save that
## fails validation leaves the running game untouched rather than half-restored.

const SCHEMA_VERSION := 1

const REQUIRED_FIELDS: Array[String] = [
	"schema_version", "checkpoint_id", "room_id", "player_spawn_id",
	"player_state", "ammo_state", "puzzle_states", "encounter_results",
	"relationship_states", "consumed_event_ids",
]

var data: Dictionary = {}

func _init(payload: Dictionary = {}) -> void:
	data = payload

## Returns "" when the payload is loadable, otherwise a human-readable reason.
## An unloadable save must be explained, not silently ignored.
func validation_error() -> String:
	for field: String in REQUIRED_FIELDS:
		if not data.has(field):
			return "missing required field '%s'" % field
	var version: int = int(data["schema_version"])
	if version != SCHEMA_VERSION:
		return "unsupported schema_version %d (this build reads %d)" % [version, SCHEMA_VERSION]
	for dict_field: String in ["player_state", "ammo_state", "puzzle_states", "encounter_results", "consumed_event_ids"]:
		if typeof(data[dict_field]) != TYPE_DICTIONARY:
			return "field '%s' must be an object" % dict_field
	if typeof(data["relationship_states"]) != TYPE_ARRAY:
		return "field 'relationship_states' must be an array"
	if String(data["checkpoint_id"]) == "":
		return "checkpoint_id is empty"
	if String(data["room_id"]) == "":
		return "room_id is empty"
	return ""

func is_valid() -> bool:
	return validation_error() == ""

func to_json() -> String:
	return JSON.stringify(data, "\t", false)

static func from_json(text: String) -> CheckpointSnapshot:
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return CheckpointSnapshot.new({})
	return CheckpointSnapshot.new(parsed as Dictionary)
