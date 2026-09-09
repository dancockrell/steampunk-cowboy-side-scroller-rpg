class_name SacredObject
extends ToolTarget
## A funerary vessel that CAN be destroyed and should not be.
##
## Destroying it and preserving it are two distinct authored facts with their own
## event IDs. Neither is inferred from what the rubble looks like at the end of
## the room, which docs/temple-emergence.md rules out explicitly.

signal destroyed()

@export var destroyed_event_id: StringName = &"urn_destroyed"
@export var preserved_event_id: StringName = &"urn_preserved"
## The heroine only reacts to what she witnessed, so the fact carries who saw it.
@export var witnessed_by: StringName = &"keeper_of_the_clay_dead"

var _relationships: RelationshipBook

func bind_relationships(relationships: RelationshipBook) -> void:
	_relationships = relationships

func is_destroyed() -> bool:
	if puzzle_id == &"" or _puzzles == null:
		return false
	return bool(_puzzles.state_of(puzzle_id).get("destroyed", false))

func _default_state() -> Dictionary:
	return {"uses": 0, "broken": false, "destroyed": false}

func _apply_state(state: Dictionary) -> void:
	var gone := bool(state.get("destroyed", false))
	interactive = not gone
	visible = not gone

func _on_hit(hit: Hit) -> bool:
	if is_destroyed():
		return false
	if not super._on_hit(hit):
		return false
	_puzzles.set_field(puzzle_id, &"destroyed", true)
	_report(destroyed_event_id, {"verb": String(hit.verb), "tool": String(hit.tool_id)})
	destroyed.emit()
	return true

## Called by the room when the player leaves having left it standing. Preserving
## something is a fact in its own right, not merely the absence of destroying it.
func report_preserved() -> void:
	if is_destroyed():
		return
	_report(preserved_event_id, {})

func _report(event_id: StringName, context: Dictionary) -> void:
	if event_id == &"":
		return
	# The ledger makes it once-only; the heroine records it as witnessed.
	if _ledger != null and not _ledger.consume(event_id, context):
		return
	if _relationships != null and witnessed_by != &"":
		_relationships.witness(witnessed_by, event_id, context)
