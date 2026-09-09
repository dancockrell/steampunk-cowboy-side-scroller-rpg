class_name MechanismGate
extends StaticBody2D
## A blocking element that moves when a watched puzzle field becomes true.
##
## It reads the PuzzleBook rather than listening for a one-off signal, so a
## checkpoint restore puts it in the right place with no replay of the event that
## opened it.

@export var watched_puzzle_id: StringName
@export var watched_field: StringName = &"released"
@export var open_offset: Vector2 = Vector2(0, -96)
@export var open_seconds: float = 0.6

var _puzzles: PuzzleBook
var _closed_position: Vector2
var _open_position: Vector2

func bind(puzzles: PuzzleBook) -> void:
	_puzzles = puzzles
	_closed_position = position
	_open_position = position + open_offset
	_puzzles.puzzle_changed.connect(_on_puzzle_changed)
	apply_state(false)

func is_open() -> bool:
	if _puzzles == null or watched_puzzle_id == &"":
		return false
	return bool(_puzzles.get_field(watched_puzzle_id, watched_field, false))

func _on_puzzle_changed(puzzle_id: StringName, _state: Dictionary) -> void:
	if puzzle_id == watched_puzzle_id:
		apply_state(true)

## `animate` false snaps into place, which is what a checkpoint load needs: the
## gate should already be where the restored state says, not slide there.
func apply_state(animate: bool) -> void:
	var target := _open_position if is_open() else _closed_position
	if not animate or open_seconds <= 0.0:
		position = target
		return
	var tween := create_tween()
	tween.tween_property(self, ^"position", target, open_seconds)
