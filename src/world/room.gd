class_name Room
extends Node2D
## One authored temple room.
##
## Binds services into every mechanism, and re-applies persisted state after a
## checkpoint load so a restored room matches the books rather than however the
## scene happened to be left.

signal room_completed(room_id: StringName)

@export var room_id: StringName
@export var default_spawn_id: StringName = &"spawn_entry"
## Fixed room bounds (decision D10). Zero size means an unbounded camera.
@export var bounds: Rect2 = Rect2()

var services: Services

## Live encounters in this room, so the room can keep them pointed at Michael
## and hand the intervention its candidate list.
var _encounters: Array[Encounter] = []

func bind(p_services: Services) -> void:
	services = p_services
	for node: Node in _descendants(self):
		# Terrain is built first so collision exists before anything is placed
		# into the room or asked whether it is standing on something.
		var terrain := node as GrayboxTerrain
		if terrain != null:
			terrain.build()
		var target := node as ToolTarget
		if target != null:
			target.bind(services.puzzles, services.ledger)
		var sacred := node as SacredObject
		if sacred != null:
			sacred.bind_relationships(services.relationships)
		var gate := node as MechanismGate
		if gate != null:
			gate.bind(services.puzzles)
		var encounter := node as Encounter
		if encounter != null:
			# An encounter with invalid authored content binds inert rather than
			# guessing; bind() reports why.
			encounter.bind(services)
			_encounters.append(encounter)

## Shrines need the WorldRoot to save through, which the room does not own.
func bind_world(world: WorldRoot) -> void:
	for node: Node in _descendants(self):
		var shrine := node as CheckpointShrine
		if shrine != null:
			shrine.bind_world(world)

func bind_dialogue(dialogue_player: DialoguePlayer) -> void:
	for node: Node in _descendants(self):
		var npc := node as HeroineNpc
		if npc != null:
			npc.bind(dialogue_player, services.relationships)

func _descendants(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in node.get_children():
		found.append(child)
		found.append_array(_descendants(child))
	return found

func camera_bounds() -> Rect2:
	return bounds

func spawn_position(spawn_id: StringName) -> Vector2:
	var named := get_node_or_null(NodePath(String(spawn_id))) as Node2D
	if named != null:
		return named.global_position
	push_warning("Room '%s' has no spawn marker '%s'; using room origin" % [room_id, spawn_id])
	return global_position

func place_player(player: Player, spawn_id: StringName) -> void:
	if player == null:
		return
	player.restore_to_safe_idle(spawn_position(spawn_id))

## After a checkpoint restore, every mechanism re-reads the book. Scene state is
## a view of the books, never the other way round.
func refresh_from_books() -> void:
	for node: Node in _descendants(self):
		var target := node as ToolTarget
		if target != null:
			target.refresh_from_book()
		var gate := node as MechanismGate
		if gate != null:
			gate.apply_state(false)

## Leaving the room settles the facts that are about what the player did NOT do.
## Preserving a vessel is its own authored fact, not the absence of breaking one.
func report_exit_facts() -> void:
	for node: Node in _descendants(self):
		var sacred := node as SacredObject
		if sacred != null:
			sacred.report_preserved()
	room_completed.emit(room_id)

func encounters() -> Array[Encounter]:
	return _encounters.duplicate()

## Encounters need to know where Michael is without holding a reference to him,
## so the room forwards it. Called by WorldRoot each frame.
func update_target(position_2d: Vector2) -> void:
	for encounter: Encounter in _encounters:
		encounter.set_target_position(position_2d)
