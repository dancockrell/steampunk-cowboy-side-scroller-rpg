class_name Hit
extends RefCounted
## One authoritative interaction, produced by the tool controller at commit.
##
## The simulation emits exactly one Hit per committed action. Animation and
## sound consume that event; replaying a clip cannot spend ammo or deal damage
## twice (docs/weapon-tool-kit.md).

var tool_id: StringName
var verb: StringName
var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var force: float = 0.0
var damage: int = 1
## Stable ID for anything this hit is allowed to award exactly once. Empty means
## the hit awards nothing persistent.
var event_id: StringName = &""
## Which of the room's depth planes (src/world/depth.gd) the tool was used
## from. Carried on the Hit itself, not read separately from the player, so
## HitReceiver.receive() can enforce depth the same way it already enforces
## the verb -- as a property of the interaction, checked in one place that no
## subclass or direct caller can bypass.
var depth_layer: Depth.Layer = Depth.Layer.NEAR

func _init(p_tool_id: StringName = &"", p_verb: StringName = &"", p_origin: Vector2 = Vector2.ZERO) -> void:
	tool_id = p_tool_id
	verb = p_verb
	origin = p_origin

func describe() -> String:
	return "%s/%s from %s" % [tool_id, verb, origin]
