class_name Climbable
extends Area2D
## A ladder, trellis, chain or scaffold: a surface Michael can go up and down
## without the rope.
##
## The lasso is the fast, expressive way to gain height and it asks for timing.
## This is the patient way, and it asks for nothing. A temple that can only be
## climbed by rope punishes a player who is bad at rope, which is the same
## complaint that produced the jump-reachability work -- every vertical section
## wants a slow route as well as a quick one.
##
## Like every other node here it announces itself to the player rather than the
## player polling the world: the same shape as DepthCrossing and Hazard.

signal mounted(player: Player)
signal dismounted(player: Player)

## Which plane this surface exists on. A ladder on the mid plane is not there
## for someone walking past it on the near plane.
@export var depth_layer: Depth.Layer = Depth.Layer.NEAR
## Named so a room can say what it is. Presentation only; the simulation treats
## a vine exactly like an iron ladder.
@export var surface_kind: StringName = &"ladder"

func _ready() -> void:
	build()

## Explicit and idempotent: _ready does not fire in a headless --script run.
func build() -> void:
	collision_layer = 0
	collision_mask = 2
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

## World-space vertical span, so the player can tell whether they are at the top
## of the ladder and should step off onto whatever is up there.
func vertical_span() -> Vector2:
	var shape := get_node_or_null(^"Shape") as CollisionShape2D
	if shape != null and shape.shape is RectangleShape2D:
		var half: float = (shape.shape as RectangleShape2D).size.y * 0.5 * absf(shape.scale.y)
		return Vector2(shape.global_position.y - half, shape.global_position.y + half)
	return Vector2(global_position.y, global_position.y)

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null or player.current_depth != depth_layer:
		return
	player.enter_climb_zone(self)
	mounted.emit(player)

func _on_body_exited(body: Node2D) -> void:
	var player := body as Player
	if player == null:
		return
	player.exit_climb_zone(self)
	dismounted.emit(player)
