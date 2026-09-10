class_name Hazard
extends Area2D
## Spikes, a kiln vent, a drop onto broken pottery. Damages the player on
## contact and keeps damaging while they stay in it.
##
## The repeat is deliberately governed by the player's own invulnerability
## window rather than a timer of this node's own: take_damage() already refuses
## while _invulnerable_s is running, so standing in a fire hurts at exactly the
## rate every other damage source does, and a second hazard overlapping the
## first cannot stack two hits into one frame.

signal harmed(player: Player)

@export var damage: int = 1
## Which plane this hazard is dangerous on. A trap on the mid plane cannot
## touch a player walking past it on the near plane.
@export var depth_layer: Depth.Layer = Depth.Layer.NEAR

var _bodies: Array[Player] = []

func _ready() -> void:
	build()

## Explicit and idempotent, like every other node here: _ready does not fire in
## a headless --script run that never reaches a frame.
func build() -> void:
	collision_layer = 16
	collision_mask = 2
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null:
		return
	if not _bodies.has(player):
		_bodies.append(player)
	_touch(player)

func _on_body_exited(body: Node2D) -> void:
	var player := body as Player
	if player != null:
		_bodies.erase(player)

func _physics_process(_delta: float) -> void:
	for player: Player in _bodies:
		if is_instance_valid(player):
			_touch(player)

## Separated so a test can drive one contact without a physics frame, which the
## headless harness cannot produce.
func _touch(player: Player) -> void:
	if player.current_depth != depth_layer:
		return
	if player.take_damage(damage, global_position):
		harmed.emit(player)
