class_name MovementSolver
extends RefCounted
## Pure movement maths, deliberately free of CharacterBody2D.
##
## Split out so the forgiveness rules in docs/gameplay-pillars.md (buffered jump,
## coyote time) can be asserted headlessly. The node feeds it collision results
## and applies the velocity it returns; it owns no scene state of its own.

var tuning: Tuning

var velocity: Vector2 = Vector2.ZERO
var coyote_timer: float = 0.0
var buffer_timer: float = 0.0
var land_recovery_timer: float = 0.0
var was_on_floor: bool = false
## Set while a jump is rising and the player still holds the button. Releasing
## early cuts the rise, which is what makes jump height expressive.
var rising_from_jump: bool = false

func _init(p_tuning: Tuning = null) -> void:
	tuning = p_tuning if p_tuning != null else Tuning.new()

func reset() -> void:
	velocity = Vector2.ZERO
	coyote_timer = 0.0
	buffer_timer = 0.0
	land_recovery_timer = 0.0
	was_on_floor = false
	rising_from_jump = false

## True when a jump would be permitted right now, whether from the floor or from
## the coyote grace window just after leaving it.
func can_jump(on_floor: bool) -> bool:
	return on_floor or coyote_timer > 0.0

func step(delta: float, move_axis: float, jump_pressed: bool, jump_held: bool, on_floor: bool) -> Vector2:
	if on_floor and not was_on_floor:
		land_recovery_timer = tuning.land_recovery_s
	was_on_floor = on_floor

	coyote_timer = tuning.coyote_time_s if on_floor else maxf(0.0, coyote_timer - delta)
	land_recovery_timer = maxf(0.0, land_recovery_timer - delta)
	buffer_timer = tuning.jump_buffer_s if jump_pressed else maxf(0.0, buffer_timer - delta)

	_step_horizontal(delta, move_axis, on_floor)

	# A buffered jump fires the moment it becomes legal. Landing recovery must
	# not swallow it: docs/production/michael-pose-brief.md is explicit that a
	# short landing recovery cannot block a buffered next jump.
	if buffer_timer > 0.0 and can_jump(on_floor):
		velocity.y = tuning.jump_velocity
		buffer_timer = 0.0
		coyote_timer = 0.0
		rising_from_jump = true
	else:
		_step_vertical(delta, jump_held, on_floor)
	return velocity

func _step_horizontal(delta: float, move_axis: float, on_floor: bool) -> void:
	var target := move_axis * tuning.run_speed
	var accel := tuning.ground_accel if on_floor else tuning.air_accel
	var friction := tuning.ground_friction if on_floor else tuning.air_friction
	if is_zero_approx(move_axis):
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, target, accel * delta)

func _step_vertical(delta: float, jump_held: bool, on_floor: bool) -> void:
	if on_floor:
		rising_from_jump = false
		velocity.y = minf(velocity.y, 0.0)
		return
	if rising_from_jump and velocity.y < 0.0 and not jump_held:
		velocity.y *= tuning.jump_cut_multiplier
		rising_from_jump = false
	if velocity.y >= 0.0:
		rising_from_jump = false
	# Falling is heavier than rising so the arc reads as deliberate weight.
	var g := tuning.gravity * (tuning.fall_gravity_multiplier if velocity.y > 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, tuning.terminal_fall_speed)
