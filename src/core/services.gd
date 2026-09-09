class_name Services
extends Node
## The small owned service set. Created by Main and handed down by typed
## reference: WorldRoot to Room to actors.
##
## Deliberately not an autoload event bus. docs/architecture/engine-decision.md
## asks for direct typed references and a checkpoint owner that exists only
## because something uses it.

signal checkpoint_saved(checkpoint_id: StringName)
signal checkpoint_restored(checkpoint_id: StringName)
signal restore_failed(reason: String)

var tuning: Tuning
var ledger: EventLedger
var encounters: EncounterBook
var puzzles: PuzzleBook
var relationships: RelationshipBook

## Last snapshot that loaded cleanly. A failed load keeps this one, which is what
## "keep the previous valid save" means in practice.
var last_valid_snapshot: CheckpointSnapshot

func _init(tuning_resource: Tuning = null) -> void:
	tuning = tuning_resource if tuning_resource != null else Tuning.new()
	ledger = EventLedger.new()
	encounters = EncounterBook.new()
	puzzles = PuzzleBook.new()
	relationships = RelationshipBook.new()

func capture(checkpoint_id: StringName, room_id: StringName, player_spawn_id: StringName,
		player_state: Dictionary, ammo_state: Dictionary) -> CheckpointSnapshot:
	var snapshot := CheckpointSnapshot.new({
		"schema_version": CheckpointSnapshot.SCHEMA_VERSION,
		"checkpoint_id": String(checkpoint_id),
		"room_id": String(room_id),
		"player_spawn_id": String(player_spawn_id),
		"player_state": player_state.duplicate(true),
		"ammo_state": ammo_state.duplicate(true),
		"puzzle_states": puzzles.serialize(),
		"encounter_results": encounters.serialize(),
		"relationship_states": relationships.serialize(),
		"consumed_event_ids": ledger.serialize(),
	})
	var error := snapshot.validation_error()
	if error != "":
		push_error("Services.capture produced an invalid snapshot: %s" % error)
		return null
	last_valid_snapshot = snapshot
	checkpoint_saved.emit(checkpoint_id)
	return snapshot

## Atomic restore. Everything is validated into staging copies first; the live
## books are only touched once the entire payload is known good.
func restore(snapshot: CheckpointSnapshot) -> bool:
	if snapshot == null:
		_fail_restore("no snapshot supplied")
		return false
	var error := snapshot.validation_error()
	if error != "":
		_fail_restore(error)
		return false

	var staging_encounters := EncounterBook.new()
	if not staging_encounters.restore(snapshot.data["encounter_results"]):
		_fail_restore("encounter_results did not validate")
		return false
	var staging_puzzles := PuzzleBook.new()
	if not staging_puzzles.restore(snapshot.data["puzzle_states"]):
		_fail_restore("puzzle_states did not validate")
		return false
	var relationship_error := _validate_relationships(snapshot.data["relationship_states"])
	if relationship_error != "":
		_fail_restore(relationship_error)
		return false

	# Past this line nothing can fail, so the game can never be half-restored.
	encounters.restore(snapshot.data["encounter_results"])
	puzzles.restore(snapshot.data["puzzle_states"])
	relationships.restore(snapshot.data["relationship_states"])
	ledger.restore(snapshot.data["consumed_event_ids"])
	last_valid_snapshot = snapshot
	checkpoint_restored.emit(StringName(String(snapshot.data["checkpoint_id"])))
	return true

func _validate_relationships(entries: Array) -> String:
	for entry: Variant in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			return "relationship_states contains a non-object entry"
		var dict: Dictionary = entry
		var heroine_id := StringName(String(dict.get("heroine_id", "")))
		if relationships.heroine(heroine_id) == null:
			return "save names unknown heroine '%s'" % heroine_id
		if RelationshipState.ARC_NAMES.find(String(dict.get("arc_state", ""))) < 0:
			return "unknown arc_state '%s'" % dict.get("arc_state", "")
		if RelationshipState.ROMANCE_NAMES.find(String(dict.get("romance_state", ""))) < 0:
			return "unknown romance_state '%s'" % dict.get("romance_state", "")
	return ""

func _fail_restore(reason: String) -> void:
	push_warning("Checkpoint restore refused: %s. Previous valid save kept." % reason)
	restore_failed.emit(reason)
