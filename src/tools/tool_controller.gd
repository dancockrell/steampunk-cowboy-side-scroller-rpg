class_name ToolController
extends Node2D
## Turns input into committed tool actions, and committed actions into exactly
## one Hit delivered to exactly one HitReceiver.
##
## The state machine owns WHEN an action commits; this node owns WHAT it lands
## on. Keeping those apart is why the timing rules in docs/weapon-tool-kit.md
## are testable without a physics world.

signal tool_committed(tool_id: StringName, hit: Hit)
signal tool_rejected(tool_id: StringName, reason: String)
signal rope_attached(anchor: HitReceiver)
signal rope_released()
signal equipped_changed(tool_id: StringName)
signal ammo_changed(tool_id: StringName, loaded: int, capacity: int)

## Shape queries return a bounded number of hits. 32 was not enough for a room
## with 146 anchors in it; this is high enough that the cap is a safety net
## rather than a filter, and the query warns when it is reached.
const MAX_ANCHOR_CANDIDATES := 256
## How much facing the wrong way costs an anchor when the rope picks a target.
## 0 is pure nearest-wins, which cannot select a puzzle target in a dense
## anchor field; large values turn the rope into an aim test, which D18 forbids.
const ANCHOR_FACING_BIAS := 0.9

const TOOL_ACTIONS := {
	&"tool_lasso": &"lasso",
	&"tool_pistol": &"pistol",
}

## Depth-aware: every query below reads the CURRENT plane's bits from
## src/world/depth.gd at query time rather than a fixed constant, so a tool
## used while standing on the mid or far plane only ever reaches receivers
## and terrain on that same plane.
func _current_target_layer() -> int:
	return Depth.target_bit(player.current_depth if player != null else Depth.Layer.NEAR)

func _current_terrain_layer() -> int:
	return Depth.terrain_bit(player.current_depth if player != null else Depth.Layer.NEAR)

var services: Services
var player: Player
var machine: ToolStateMachine

var _attached_anchor: HitReceiver = null
var _input_enabled: bool = true

func bind(p_services: Services, p_player: Player) -> void:
	services = p_services
	player = p_player
	machine = ToolStateMachine.new(ToolDefinition.build(p_services.tuning))
	machine.committed.connect(_on_committed)
	machine.rejected.connect(func(id: StringName, reason: String) -> void: tool_rejected.emit(id, reason))
	machine.state_changed.connect(_on_state_changed)
	machine.reload_finished.connect(_emit_ammo)
	machine.request_switch(&"lasso")
	_emit_ammo(&"lasso")

func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled

func step(delta: float) -> void:
	if _input_enabled:
		_read_input()
	machine.step(delta)
	if _attached_anchor != null and not is_instance_valid(_attached_anchor):
		# The anchor was destroyed under us. Release cleanly rather than leaving
		# a rope attached to something that no longer exists.
		release_rope()

func _read_input() -> void:
	for action: StringName in TOOL_ACTIONS:
		if Input.is_action_just_pressed(action):
			machine.request_switch(TOOL_ACTIONS[action])
	if Input.is_action_just_pressed(&"tool_use"):
		machine.request_use()
	if Input.is_action_just_released(&"tool_use"):
		machine.release_use()
	if Input.is_action_just_pressed(&"tool_cancel"):
		release_rope()
	if Input.is_action_just_pressed(&"reload"):
		machine.request_reload()

func _on_state_changed(tool_id: StringName, _state: ToolStateMachine.State) -> void:
	equipped_changed.emit(tool_id)
	_emit_ammo(tool_id)

func _emit_ammo(tool_id: StringName) -> void:
	var def: ToolDefinition = machine.definitions.get(tool_id)
	if def == null:
		return
	ammo_changed.emit(tool_id, machine.loaded(tool_id), def.magazine)

## World-space direction the tool is pointed. Falls back to Michael's facing so
## a gamepad player with no stick input still has a defined aim.
func aim_direction() -> Vector2:
	var viewport := get_viewport()
	if viewport != null:
		var stick := Input.get_vector(&"move_left", &"move_right", &"jump", &"interact")
		var mouse := viewport.get_mouse_position()
		if mouse != Vector2.ZERO:
			var world := get_global_mouse_position()
			var to_mouse := world - global_position
			if to_mouse.length() > 4.0:
				return to_mouse.normalized()
		if stick.length() > 0.3:
			return stick.normalized()
	return Vector2(player.facing if player != null else 1, 0.0)

func _on_committed(tool_id: StringName, definition: ToolDefinition) -> void:
	if tool_id == &"lasso":
		_commit_lasso(definition)
	else:
		_commit_firearm(definition)

func _commit_firearm(definition: ToolDefinition) -> void:
	var direction := aim_direction()
	var hit := Hit.new(definition.id, definition.verb, global_position)
	hit.depth_layer = player.current_depth if player != null else Depth.Layer.NEAR
	hit.direction = direction
	hit.damage = definition.damage
	hit.force = definition.force

	var receiver := _query_receiver(direction, definition)
	tool_committed.emit(definition.id, hit)
	if receiver == null:
		return
	# The receiver owns the verb check; an invalid use is explained there rather
	# than being consumed here.
	if not receiver.receive(hit):
		tool_rejected.emit(definition.id, "wrong tool for %s" % receiver.receiver_id)

## Casts for the first receiver in range. A tool with a spread cone casts several
## rays inside it; every other tool casts one. Rubble and terrain block the shot,
## so a blocked throw or shot cannot reach through a wall.
func _query_receiver(direction: Vector2, definition: ToolDefinition) -> HitReceiver:
	var space := get_world_2d().direct_space_state
	var rays: Array[Vector2] = [direction]
	if definition.cone_degrees > 0.0:
		var half := deg_to_rad(definition.cone_degrees) * 0.5
		rays = [direction.rotated(-half), direction, direction.rotated(half)]

	for ray: Vector2 in rays:
		var query := PhysicsRayQueryParameters2D.create(
			global_position, global_position + ray * definition.range_px,
			_current_target_layer() | _current_terrain_layer())
		query.collide_with_areas = true
		query.collide_with_bodies = true
		if player != null:
			query.exclude = [player.get_rid()]
		var result := space.intersect_ray(query)
		if result.is_empty():
			continue
		var receiver := result["collider"] as HitReceiver
		if receiver != null:
			return receiver
	return null

func _commit_lasso(definition: ToolDefinition) -> void:
	var anchor := _find_lasso_anchor(definition)
	var hit := Hit.new(definition.id, Verbs.PULL, global_position)
	hit.depth_layer = player.current_depth if player != null else Depth.Layer.NEAR
	if anchor == null:
		# A miss finishes with an intelligible recovery, not a snap to an
		# impossible held rope.
		tool_committed.emit(definition.id, hit)
		tool_rejected.emit(definition.id, "no anchor in reach")
		return

	hit.verb = Verbs.SWING if anchor.accepts(Verbs.SWING) else Verbs.PULL
	hit.direction = (anchor.interaction_point() - global_position).normalized()
	tool_committed.emit(definition.id, hit)

	if not anchor.receive(hit):
		tool_rejected.emit(definition.id, "anchor refused")
		return
	if hit.verb == Verbs.SWING:
		_attached_anchor = anchor
		machine.notify_attached()
		if player != null:
			player.begin_swing(anchor.interaction_point())
		rope_attached.emit(anchor)

## What the rope prefers, as pure arithmetic so it can be asserted without a
## physics world: cheaper is better, distance is the base cost, and facing away
## multiplies it. `alignment` is the dot product of the aim and the direction to
## the candidate, so 1 is straight ahead and -1 is directly behind.
static func anchor_score(distance: float, alignment: float) -> float:
	return distance * (1.0 + (1.0 - alignment) * ANCHOR_FACING_BIAS)

## Nearest eligible anchor with clear line of sight. Line of sight is required so
## the rope cannot attach through a wall.
func _find_lasso_anchor(definition: ToolDefinition) -> HitReceiver:
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = definition.range_px
	query.shape = circle
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = _current_target_layer()
	query.collide_with_areas = true
	query.collide_with_bodies = false

	# The cap matters. The Sunken Cistern seeds 146 anchors, and a shape query
	# truncated at 32 results silently omits candidates -- so the winch a player
	# is standing in front of can be absent from the list entirely, and the miss
	# is indistinguishable from there being nothing there.
	var best: HitReceiver = null
	var best_score := INF
	var aim := aim_direction()
	var considered := 0
	for result: Dictionary in space.intersect_shape(query, MAX_ANCHOR_CANDIDATES):
		var receiver := result["collider"] as HitReceiver
		if receiver == null:
			continue
		if not (receiver.accepts(Verbs.PULL) or receiver.accepts(Verbs.SWING)):
			continue
		var point := receiver.interaction_point()
		var distance := global_position.distance_to(point)
		if distance > definition.range_px:
			continue
		if _blocked(space, point):
			continue
		considered += 1
		# Nearest-wins alone cannot express intent. With anchors this dense a
		# puzzle target is almost never the closest thing, so a player facing a
		# winch roped a swing anchor behind their shoulder instead and the
		# mechanism simply never moved. Distance still decides between similar
		# candidates -- D18 asks for the rope to stay organic rather than an aim
		# test -- but something in front of Michael beats something behind him.
		var toward := (point - global_position).normalized()
		var score := anchor_score(distance, aim.dot(toward))
		if score < best_score:
			best = receiver
			best_score = score
	if considered >= MAX_ANCHOR_CANDIDATES:
		push_warning("ToolController: anchor query hit its %d-result cap; a target may have been dropped"
			% MAX_ANCHOR_CANDIDATES)
	return best

func _blocked(space: PhysicsDirectSpaceState2D, point: Vector2) -> bool:
	var ray := PhysicsRayQueryParameters2D.create(global_position, point, _current_terrain_layer())
	ray.collide_with_areas = false
	if player != null:
		ray.exclude = [player.get_rid()]
	return not space.intersect_ray(ray).is_empty()

func release_rope() -> void:
	if _attached_anchor == null:
		return
	_attached_anchor = null
	machine.notify_released()
	if player != null:
		player.end_swing()
	rope_released.emit()

func attached_anchor() -> HitReceiver:
	return _attached_anchor

func on_hurt() -> void:
	machine.interrupt_hurt()
	if _attached_anchor != null:
		release_rope()

## Pause, focus loss, room change and defeat all land here, so no sticky input
## or half-thrown rope survives them.
func cancel_all() -> void:
	if _attached_anchor != null:
		release_rope()
	machine.force_release_to_ready()
