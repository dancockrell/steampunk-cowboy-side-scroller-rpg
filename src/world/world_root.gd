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

## The Keeper's intervention lives here because this is the node that can see
## both the room's encounters and the player. Created when its first use exists,
## as ADR 001 asks, rather than reserved in advance.
var intervention: RecallToClay

var _last_checkpoint: CheckpointSnapshot
var _last_checkpoint_position: Vector2 = Vector2.ZERO

func bind(p_services: Services) -> void:
	services = p_services
	intervention = RecallToClay.new(p_services.tuning, p_services.relationships)

var dialogue_player: DialoguePlayer

func bind_dialogue(p_dialogue_player: DialoguePlayer) -> void:
	dialogue_player = p_dialogue_player
	if room != null:
		room.bind_dialogue(dialogue_player)

## Every room this WorldRoot has ever loaded, so a checkpoint saved in an
## earlier room can be found again by its room_id alone. A checkpoint stores
## room_id, not a scene reference: without this, restoring a checkpoint from a
## different room than the one currently loaded silently applied that room's
## saved state to the WRONG room's live scene tree instead of loading the
## right one first.
var _known_rooms: Dictionary = {}

## `spawn_id` picks which marker in the NEW room Michael lands at; empty means
## that room's own default_spawn_id. A room transition settles the facts about
## what the player did NOT do before it goes: preserving the sacred urn is its
## own fact, not merely the absence of a report, and it has to be recorded
## before the room that owns it is freed, not after.
func load_room(scene: PackedScene, spawn_id: StringName = &"") -> void:
	if not _swap_room(scene, true):
		return
	var target_spawn := spawn_id if spawn_id != &"" else room.default_spawn_id
	room.place_player(player, target_spawn)
	room_loaded.emit(room.room_id)

## Shared by forward progression (load_room) and checkpoint rollback, which
## must NOT report exit facts for a room being undone rather than left.
func _swap_room(scene: PackedScene, report_exit_facts: bool) -> bool:
	if services == null:
		push_error("WorldRoot._swap_room called before bind()")
		return false
	if room != null:
		if report_exit_facts:
			room.report_exit_facts()
		room.queue_free()
		remove_child(room)
		room = null

	var instance := scene.instantiate()
	room = instance as Room
	if room == null:
		push_error("WorldRoot._swap_room: scene root is not a Room")
		instance.queue_free()
		return false
	_known_rooms[room.room_id] = scene
	add_child(room)
	room.bind(services)
	room.bind_world(self)
	if dialogue_player != null:
		room.bind_dialogue(dialogue_player)

	_ensure_player()
	_ensure_camera()
	return true

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
	if intervention != null:
		intervention.step(delta)
	if player == null or camera == null or room == null:
		return
	room.update_target(player.global_position)
	if Input.is_action_just_pressed(&"intervention"):
		use_intervention()
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
	# Charges refresh with ammunition, so the intervention cannot be spent for good.
	if intervention != null:
		intervention.reset_at_checkpoint()
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

	var checkpoint_room_id := StringName(String(_last_checkpoint.data["room_id"]))
	if room == null or room.room_id != checkpoint_room_id:
		var scene: PackedScene = _known_rooms.get(checkpoint_room_id)
		if scene == null:
			push_error("WorldRoot.reload_checkpoint: no known scene for room '%s'; the checkpoint cannot be restored"
				% checkpoint_room_id)
			return false
		# Rolling back, not leaving: the room being replaced does not get its
		# exit facts reported, or a death mid-room would wrongly credit the
		# player with having left it in whatever state it happened to be in.
		if not _swap_room(scene, false):
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

## What the HUD should show about the intervention right now, including the
## reason when it is unavailable.
func intervention_preview() -> Dictionary:
	if intervention == null or room == null:
		return {"available": false, "reason": RecallToClay.REASON_NO_ALLIANCE}
	return intervention.preview(room.encounters())

func use_intervention() -> bool:
	if intervention == null or room == null:
		return false
	var state := intervention.preview(room.encounters())
	if not bool(state.get("available", false)):
		return false
	return intervention.use(state["target"] as Encounter)
