class_name Player
extends CharacterBody2D
## Michael. Owns motion, jump permission, health and tool-action priority.
##
## It does NOT own sprite-derived collision truth: the collision shape below is
## authored, and an admitted sprite pack must be fitted to it rather than the
## other way round (docs/architecture/engine-decision.md ownership table).
##
## There is no art. The visual child is an explicitly named graybox placeholder.

signal health_changed(current: int, maximum: int)
signal defeated()
signal hurt(from_direction: Vector2)
signal facing_changed(facing: int)
signal depth_changed(layer: Depth.Layer)

enum TraversalMode { GROUNDED, SWINGING, CLIMBING }

## Authored body box. 64x96 export cell with a visible body near 48x72 and a
## foot pivot at the bottom edge (docs/art-direction.md).
const BODY_WIDTH := 24.0
const BODY_HEIGHT := 64.0

@export var spawn_id: StringName = &"spawn_default"

var services: Services
var tuning: Tuning
var solver: MovementSolver
var swing: SwingSolver
var tools: ToolController

var facing: int = 1
var health: int = 5
var traversal_mode: TraversalMode = TraversalMode.GROUNDED
## Which of the room's up-to-three parallel planes Michael is standing on
## (src/world/depth.gd). Terrain and props on any other plane are genuinely
## not there: this drives the physics collision_mask, not just a visual cue.
var current_depth: Depth.Layer = Depth.Layer.NEAR

## Ladders, trellises and chains currently overlapping Michael. A list rather
## than a flag because two surfaces can overlap at a junction, and leaving one
## of them must not cancel a climb that the other still supports.
var _climb_zones: Array[Climbable] = []
var _invulnerable_s: float = 0.0
var _hurt_stun_s: float = 0.0
var _input_enabled: bool = true
var _sprite: AnimatedSprite2D

func bind(p_services: Services) -> void:
	services = p_services
	tuning = p_services.tuning
	solver = MovementSolver.new(tuning)
	swing = SwingSolver.new(tuning)
	health = tuning.max_health
	tools = get_node_or_null(^"ToolController") as ToolController
	if tools != null:
		tools.bind(p_services, self)
	_sprite = get_node_or_null(^"Sprite") as AnimatedSprite2D
	collision_mask = Depth.terrain_bit(current_depth)
	health_changed.emit(health, tuning.max_health)

## Crosses Michael onto a different depth plane. Idempotent: crossing to the
## plane already standing on is a no-op rather than a spurious signal.
func set_depth(layer: Depth.Layer) -> void:
	if layer == current_depth:
		return
	current_depth = layer
	collision_mask = Depth.terrain_bit(layer)
	depth_changed.emit(layer)

## Dialogue in a safe shrine must not leave Michael taking unseen damage, so a
## conversation disables input rather than leaving the controller live.
func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if not enabled:
		velocity.x = 0.0
		if tools != null:
			tools.cancel_all()

func _physics_process(delta: float) -> void:
	if services == null:
		return
	_invulnerable_s = maxf(0.0, _invulnerable_s - delta)
	_hurt_stun_s = maxf(0.0, _hurt_stun_s - delta)

	match traversal_mode:
		TraversalMode.SWINGING:
			_physics_swinging(delta)
		TraversalMode.CLIMBING:
			_physics_climbing(delta)
		_:
			_physics_grounded(delta)

	if tools != null:
		tools.step(delta)
	_update_presentation()

## Only a right-facing run cycle is admitted (assets/sprites/michael). Left
## movement mirrors it with AnimatedSprite2D.flip_h rather than using the
## batch-001 "run_left" candidate, which was measured against its own file
## (not assumed) to still show Michael facing right despite its name and the
## README's claim otherwise -- see docs/production/asset-handoff.md review
## record. Mirroring an asymmetric-gear character is explicitly flagged as
## UNCONFIRMED pending F01 handedness review (michael-pose-brief.md); this is
## the interim, trivially reversible choice that review anticipates, not a
## final claim about which hand carries what.
func _update_presentation() -> void:
	if _sprite == null:
		return
	_sprite.flip_h = facing < 0
	var moving := absf(velocity.x) > 5.0
	var wanted := &"run" if moving else &"idle"
	if _sprite.animation != wanted:
		_sprite.animation = wanted
		_sprite.play()

func _physics_grounded(delta: float) -> void:
	var move_axis := 0.0
	var jump_pressed := false
	var jump_held := false
	if _input_enabled and _hurt_stun_s <= 0.0:
		move_axis = Input.get_axis(&"move_left", &"move_right")
		jump_pressed = Input.is_action_just_pressed(&"jump")
		jump_held = Input.is_action_pressed(&"jump")
		# Reaching for a ladder takes precedence over jumping off the floor, or
		# standing at the foot of one and pressing up just hops. HELD rather
		# than just-pressed: a single-frame edge is missed by anyone who was
		# already holding up as they arrived at the ladder, which is most
		# people running at one, and it is how ladders work everywhere else.
		if can_climb() and (jump_held or Input.is_action_pressed(&"move_down")):
			begin_climb()
			return

	velocity = solver.step(delta, move_axis, jump_pressed, jump_held, is_on_floor())
	_update_facing(move_axis)
	move_and_slide()

func _physics_swinging(delta: float) -> void:
	# Holding jump while on the rope hauls it in. Jump is already bound to
	# Space/W/Up, so "press up to go up" is true without a new binding, and it
	# is the only way a swing gains height at all (SwingSolver.climb).
	if _input_enabled and _hurt_stun_s <= 0.0 and Input.is_action_pressed(&"jump"):
		swing.climb(delta, tuning.swing_climb_speed_px_s)
	var result := swing.step(delta, global_position, velocity)
	var target: Vector2 = result["position"]
	var next_velocity: Vector2 = result["velocity"]

	# Move through the collision system rather than teleporting, so a swing can
	# never clip Michael through a wall (docs/weapon-tool-kit.md).
	var motion := target - global_position
	var collision := move_and_collide(motion)
	if collision != null:
		next_velocity = next_velocity.slide(collision.get_normal())
	velocity = next_velocity
	_update_facing(signf(velocity.x))

## True while any ladder, trellis or chain overlaps Michael on his own plane.
func can_climb() -> bool:
	for zone: Climbable in _climb_zones:
		if is_instance_valid(zone):
			return true
	return false

func enter_climb_zone(zone: Climbable) -> void:
	if not _climb_zones.has(zone):
		_climb_zones.append(zone)

func exit_climb_zone(zone: Climbable) -> void:
	_climb_zones.erase(zone)
	if traversal_mode == TraversalMode.CLIMBING and not can_climb():
		end_climb(0.0)

func begin_climb() -> void:
	if traversal_mode == TraversalMode.SWINGING:
		end_swing()
	traversal_mode = TraversalMode.CLIMBING
	velocity = Vector2.ZERO
	solver.velocity = Vector2.ZERO
	solver.rising_from_jump = false

## Leaves the ladder. `push` is a sideways shove so stepping off clears the
## surface instead of re-entering it on the very next frame.
func end_climb(push: float) -> void:
	if traversal_mode != TraversalMode.CLIMBING:
		return
	traversal_mode = TraversalMode.GROUNDED
	velocity.x = push
	solver.velocity = velocity

func _physics_climbing(delta: float) -> void:
	var up := 0.0
	var side := 0.0
	if _input_enabled and _hurt_stun_s <= 0.0:
		up = Input.get_axis(&"jump", &"move_down")
		side = Input.get_axis(&"move_left", &"move_right")

	# Stepping sideways off a ladder is how you dismount, and it is worth more
	# than a dedicated button: the player is already holding the direction they
	# want to end up going.
	if not is_zero_approx(side):
		end_climb(side * tuning.climb_dismount_push_px_s)
		_update_facing(side)
		return

	velocity = Vector2(0.0, up * tuning.climb_speed_px_s)
	move_and_slide()
	# Climbing off the top: floor underfoot AND actually above the ladder.
	# Testing only for floor dismounted him at the FOOT of the ladder, where
	# there is also floor -- so he mounted and stepped off on alternate frames
	# and climbed exactly zero pixels while genuinely being in climbing mode.
	if is_on_floor() and up < 0.0 and global_position.y <= _highest_climb_top() + 8.0:
		end_climb(0.0)

## Top edge of the highest ladder currently overlapping, in world space.
func _highest_climb_top() -> float:
	var top := INF
	for zone: Climbable in _climb_zones:
		if is_instance_valid(zone):
			top = minf(top, zone.vertical_span().x)
	return top

func _update_facing(axis: float) -> void:
	if is_zero_approx(axis):
		return
	var next := 1 if axis > 0.0 else -1
	if next != facing:
		facing = next
		facing_changed.emit(facing)

# --- lasso swing ----------------------------------------------------------

func begin_swing(anchor_position: Vector2) -> void:
	# A rope thrown from a standing start was being swallowed by the floor. The
	# pendulum drives through move_and_collide, so with ground underfoot the
	# first step collides and slide() eats most of the velocity: measured, a
	# grounded throw travelled 40px where the same throw made in the air
	# travelled 77px. Decision D18 asks for swinging to be organic rather than a
	# precision check, and "jump first or the rope does nothing" is exactly the
	# precision check it rules out -- so the throw lifts him off the ground
	# itself, which is also what it looks like when a rope goes taut.
	if is_on_floor():
		global_position.y -= tuning.swing_liftoff_px
		velocity.y = minf(velocity.y, -tuning.swing_liftoff_speed)
	swing.attach(anchor_position, global_position)
	traversal_mode = TraversalMode.SWINGING
	solver.rising_from_jump = false

func end_swing() -> void:
	if traversal_mode != TraversalMode.SWINGING:
		return
	velocity = swing.release_velocity(velocity)
	swing.release()
	traversal_mode = TraversalMode.GROUNDED
	solver.velocity = velocity

# --- damage ---------------------------------------------------------------

func is_invulnerable() -> bool:
	return _invulnerable_s > 0.0

func take_damage(amount: int, from_position: Vector2) -> bool:
	if _invulnerable_s > 0.0 or health <= 0:
		return false
	health = maxi(0, health - amount)
	_invulnerable_s = tuning.invulnerable_s
	_hurt_stun_s = tuning.hurt_stun_s

	var away := (global_position - from_position).normalized()
	if away == Vector2.ZERO:
		away = Vector2(-facing, -0.4).normalized()
	velocity = away * tuning.knockback_speed
	if traversal_mode == TraversalMode.SWINGING:
		end_swing()
	# Hurt interrupts aiming and reload, and never refunds a committed shot.
	if tools != null:
		tools.on_hurt()

	hurt.emit(away)
	health_changed.emit(health, tuning.max_health)
	if health <= 0:
		defeated.emit()
	return true

## Restoring a checkpoint returns Michael to a documented safe idle rather than
## to whatever transient action state he was in.
func restore_to_safe_idle(at_position: Vector2) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	traversal_mode = TraversalMode.GROUNDED
	swing.release()
	solver.reset()
	_invulnerable_s = 0.0
	_hurt_stun_s = 0.0
	if tools != null:
		tools.cancel_all()
	# A fresh room, a checkpoint reload or a spawn always starts on the near
	# plane: depth state does not leak between rooms or across a reload.
	set_depth(Depth.Layer.NEAR)

func heal_to_full() -> void:
	health = tuning.max_health
	health_changed.emit(health, tuning.max_health)

# --- persistence ----------------------------------------------------------

func player_state() -> Dictionary:
	return {"health": health, "facing": facing}

func restore_player_state(state: Dictionary) -> void:
	health = clampi(int(state.get("health", tuning.max_health)), 0, tuning.max_health)
	facing = 1 if int(state.get("facing", 1)) >= 0 else -1
	health_changed.emit(health, tuning.max_health)
	facing_changed.emit(facing)
