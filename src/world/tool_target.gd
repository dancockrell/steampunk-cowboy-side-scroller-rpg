class_name ToolTarget
extends HitReceiver
## An authored puzzle mechanism. Fields follow the ToolTarget contract in
## docs/data-contracts.md.
##
## Mechanism state lives in the PuzzleBook, never in how the scene happens to
## look, so a checkpoint restores it exactly (engine-decision.md ownership table).

signal state_changed(state: Dictionary)
signal broke()

enum ResetPolicy { NONE, ON_CHECKPOINT, MANUAL }
enum BreakRule { NEVER, ON_PULL, AFTER_USES }

const RESET_POLICY_NAMES: Array[String] = ["none", "on_checkpoint", "manual"]
const BREAK_RULE_NAMES: Array[String] = ["never", "on_pull", "after_uses"]

@export var puzzle_id: StringName
@export var reset_policy: ResetPolicy = ResetPolicy.MANUAL
@export var anchor_break_rule: BreakRule = BreakRule.NEVER
@export var max_uses: int = 0
## Fires exactly once, through the ledger, the first time this target is used.
@export var reward_event_id: StringName = &""

var _puzzles: PuzzleBook
var _ledger: EventLedger

func bind(puzzles: PuzzleBook, ledger: EventLedger) -> void:
	_puzzles = puzzles
	_ledger = ledger
	if puzzle_id == &"":
		return
	_puzzles.declare(puzzle_id, _default_state())
	_apply_state(_puzzles.state_of(puzzle_id))

## Override to add authored fields. "uses" and "broken" are always present.
func _default_state() -> Dictionary:
	return {"uses": 0, "broken": false}

## Override to make the scene match restored state after a checkpoint load.
func _apply_state(state: Dictionary) -> void:
	interactive = not bool(state.get("broken", false))

func refresh_from_book() -> void:
	if puzzle_id != &"" and _puzzles != null:
		_apply_state(_puzzles.state_of(puzzle_id))

func _on_hit(hit: Hit) -> bool:
	if puzzle_id == &"" or _puzzles == null:
		return true
	var state := _puzzles.state_of(puzzle_id)
	if bool(state.get("broken", false)):
		return false
	var uses := int(state.get("uses", 0)) + 1
	_puzzles.set_field(puzzle_id, &"uses", uses)

	if reward_event_id != &"" and _ledger != null:
		_ledger.consume(reward_event_id, {"target": String(receiver_id), "verb": String(hit.verb)})

	if _should_break(hit, uses):
		_puzzles.set_field(puzzle_id, &"broken", true)
		interactive = false
		broke.emit()

	var updated := _puzzles.state_of(puzzle_id)
	_apply_state(updated)
	state_changed.emit(updated)
	return true

func _should_break(hit: Hit, uses: int) -> bool:
	match anchor_break_rule:
		BreakRule.NEVER:
			return false
		BreakRule.ON_PULL:
			return hit.verb == Verbs.PULL
		BreakRule.AFTER_USES:
			return max_uses > 0 and uses >= max_uses
	return false

## Returns a critical mechanism to its authored start. Required ammunition and
## lasso anchors cannot be permanently exhausted (docs/gameplay-pillars.md).
func reset_mechanism() -> void:
	if puzzle_id == &"" or _puzzles == null:
		return
	_puzzles.reset(puzzle_id)
	interactive = true
	_apply_state(_puzzles.state_of(puzzle_id))
	state_changed.emit(_puzzles.state_of(puzzle_id))
