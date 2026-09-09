class_name CheckpointShrine
extends Area2D
## A safe shrine. The only place the game saves.
##
## Restricting saves to these is what lets the snapshot skip transient action
## state entirely: there is no mid-throw or mid-reload to serialise, because the
## shrine resets the player to a documented safe idle first
## (docs/data-contracts.md, docs/gameplay-pillars.md).

signal activated(checkpoint_id: StringName)

@export var checkpoint_id: StringName
## Required ammunition cannot be permanently exhausted, so a shrine tops the
## tools back up. This is what stops a wasted critical shot soft-locking a room.
@export var replenishes_ammo: bool = true
@export var heals: bool = true

var _world: WorldRoot

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func bind_world(world: WorldRoot) -> void:
	_world = world

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null or _world == null:
		return
	if checkpoint_id == &"":
		push_error("CheckpointShrine has no checkpoint_id; refusing to save an unnamed checkpoint")
		return

	# Reset to safe idle BEFORE capturing, so what is written is a state the
	# game can be resumed from rather than a snapshot of mid-action.
	if player.tools != null:
		player.tools.cancel_all()
		if replenishes_ammo and player.tools.machine != null:
			player.tools.machine.replenish_all()
	if heals:
		player.heal_to_full()

	_world.save_checkpoint(checkpoint_id, global_position)
	activated.emit(checkpoint_id)
