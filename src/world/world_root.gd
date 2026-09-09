class_name WorldRoot
extends Node2D
## Owns the camera, the current room, Michael and the checkpoint service.
##
## Services arrive by typed reference from Main and are handed down to the room,
## which hands them to its own children. Nothing here is an autoload.

signal room_loaded(room_id: StringName)
signal checkpoint_reached(checkpoint_id: StringName)
signal player_defeated()

@export var player_scene: PackedScene
## Room bounds are fixed per room (decision D10), so the camera never wanders
## past the authored stage.
@export var camera_lerp: float = 8.0

var services: Services
var room: Room
var player: Player
var camera: Camera2D

var _last_checkpoint: CheckpointSnapshot
var _last_checkpoint_position: Vector2 = Vector2.ZERO

func bind(p_services: Services) -> void:
	services = p_services

func load_room(scene: PackedScene) -> void:
	if services == null:
		push_error("WorldRoot.load_room called before bind()")
		return
	if room != null:
		room.queue_free()
		remove_child(room)
		room = null

	var instance := scene.instantiate()
	room = instance as Room
	if room == null:
		push_error("WorldRoot.load_room: scene root is not a Room")
		instance.queue_free()
		return
	add_child(room)
	room.bind(services)
	room.bind_world(self)

	_ensure_player()
	_ensure_camera()
	room.place_player(player, room.default_spawn_id)
	room_loaded.emit(room.room_id)

func _ensure_player() -> void:
	if player != null and is_instance_valid(player):
		return
	if player_scene == null:
		push_error("WorldRoot: no player_scene assigned")
		return
	player = player_scene.instantiate() as Player
	add_child(player)
	player.bind(services)
	player.defeated.connect(_on_player_defeated)

func _ensure_camera() -> void:
	if camera != null and is_instance_valid(camera):
		return
	camera = Camera2D.new()
	camera.name = "Camera"
	# Whole-pixel camera motion; a subpixel camera shimmers a pixel-art stage.
	camera.position_smoothing_enabled = false
	add_child(camera)

func _process(delta: float) -> void:
	if player == null or camera == null or room == null:
		return
	room.update_target(player.global_position)
	var target := player.global_position
	var bounds := room.camera_bounds()
	if bounds.size != Vector2.ZERO:
		var half := Vector2(Main.WORLD_WIDTH, Main.WORLD_HEIGHT) * 0.5
		target.x = clampf(target.x, bounds.position.x + half.x, bounds.end.x - half.x)
		target.y = clampf(target.y, bounds.position.y + half.y, bounds.end.y - half.y)
	camera.global_position = camera.global_position.lerp(target, clampf(camera_lerp * delta, 0.0, 1.0)).floor()

# --- checkpoints ----------------------------------------------------------

## Called by a safe shrine. Saving is restricted to these, so no transient
## action state ever has to be serialised.
func save_checkpoint(checkpoint_id: StringName, at_position: Vector2) -> void:
	if services == null or player == null or room == null:
		return
	var ammo: Dictionary = {}
	if player.tools != null and player.tools.machine != null:
		ammo = player.tools.machine.serialize_ammo()
	var snapshot := services.capture(checkpoint_id, room.room_id, room.default_spawn_id,
		player.player_state(), ammo)
	if snapshot == null:
		return
	_last_checkpoint = snapshot
	_last_checkpoint_position = at_position
	checkpoint_reached.emit(checkpoint_id)

## Falling or defeat returns to the latest checkpoint snapshot.
func reload_checkpoint() -> bool:
	if _last_checkpoint == null:
		# No checkpoint yet: return to the room's authored start rather than
		# leaving the player dead on the floor with nothing to do.
		if room != null and player != null:
			room.place_player(player, room.default_spawn_id)
			player.heal_to_full()
		return false
	if not services.restore(_last_checkpoint):
		return false
	player.restore_to_safe_idle(_last_checkpoint_position)
	player.restore_player_state(_last_checkpoint.data["player_state"])
	if player.tools != null and player.tools.machine != null:
		player.tools.machine.restore_ammo(_last_checkpoint.data["ammo_state"])
	if room != null:
		room.refresh_from_books()
	return true

func _on_player_defeated() -> void:
	player_defeated.emit()
	reload_checkpoint()
