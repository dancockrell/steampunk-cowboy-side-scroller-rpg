class_name RoomExit
extends Area2D
## Carries the player from one authored room into the next.
##
## Gated on a MechanismGate rather than acting as a second source of truth
## about whether the route is open: an exit that tracked its own "unlocked"
## flag could drift from the gate a player actually watched open.

@export var next_room: PackedScene
@export var next_spawn_id: StringName
## Optional. When set, the exit only admits the player once this gate reports
## open, so the exit and the puzzle that unlocks it can never disagree.
@export var required_gate_path: NodePath

var _world: WorldRoot
var _fired: bool = false

func bind_world(world: WorldRoot) -> void:
	_world = world

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func is_open() -> bool:
	if required_gate_path.is_empty():
		return true
	var gate := get_node_or_null(required_gate_path) as MechanismGate
	# A misconfigured or missing gate reference fails closed, not open: an exit
	# that silently ignores its own requirement is worse than one that refuses
	# to admit anyone.
	return gate != null and gate.is_open()

func _on_body_entered(body: Node2D) -> void:
	if _fired or _world == null or body is not Player:
		return
	if not is_open():
		return
	if next_room == null:
		push_error("RoomExit '%s' has no next_room assigned" % name)
		return
	_fired = true
	_world.load_room(next_room, next_spawn_id)
