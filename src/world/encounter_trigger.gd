class_name EncounterTrigger
extends Area2D
## Starts an encounter's tell when the player reaches an authored line.
##
## The trigger is placed so the first occurrence teaches its tell in a safe
## framing: Michael must be able to see the warning from outside the creature's
## reach (docs/temple-emergence.md, fairness). Placement is authored, not derived
## from the enemy's attack range at runtime.

@export var encounter_path: NodePath
## Latched. A trigger fires once; walking back and forth cannot re-tell.
var _fired: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _fired or body is not Player:
		return
	var encounter := get_node_or_null(encounter_path) as Encounter
	if encounter == null:
		push_error("EncounterTrigger '%s' points at no Encounter" % name)
		return
	_fired = encounter.trigger()
