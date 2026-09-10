class_name DepthCrossing
extends Area2D
## An archway, gap or broken wall the player walks through to change which of
## the room's parallel planes they are standing on.
##
## Deliberately automatic on contact rather than requiring an interact press:
## Dan's direction on the lasso applies here too (organic, not a precision
## check) -- crossing into the background should feel like walking through a
## doorway, not solving a small interaction puzzle to do it.

signal crossed(from_layer: Depth.Layer, to_layer: Depth.Layer)

@export var target_layer: Depth.Layer = Depth.Layer.MID
## Optional. When set, this crossing only works from that specific source
## layer, so a far-plane archway cannot be walked through directly from near.
## Layer.NEAR is never a meaningful "any layer" value here (NEAR is a real
## layer), so an unset requirement is expressed with allow_any_source instead.
@export var required_source_layer: Depth.Layer = Depth.Layer.NEAR
@export var allow_any_source: bool = true

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null:
		return
	if player.current_depth == target_layer:
		return
	if not allow_any_source and player.current_depth != required_source_layer:
		return
	var from_layer := player.current_depth
	player.set_depth(target_layer)
	crossed.emit(from_layer, target_layer)
