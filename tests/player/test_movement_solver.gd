extends TestCase
## docs/gameplay-pillars.md promises "buffered jump and coyote time" as the
## forgiveness model, and docs/production/michael-pose-brief.md adds that a
## landing recovery must not swallow a buffered next jump. Those are the
## properties asserted here, not the exact numbers, which are tuning.

const TICK := 1.0 / 60.0

var solver: MovementSolver
var tuning: Tuning

func before_each() -> void:
	tuning = Tuning.new()
	solver = MovementSolver.new(tuning)

func _idle(ticks: int, on_floor: bool) -> void:
	for i in ticks:
		solver.step(TICK, 0.0, false, false, on_floor)

func test_standing_still_comes_to_rest() -> void:
	solver.velocity.x = 100.0
	_idle(60, true)
	assert_almost_eq(solver.velocity.x, 0.0, 0.5, "friction brings a standing player to rest")

func test_running_accelerates_towards_the_run_speed_without_exceeding_it() -> void:
	for i in 120:
		solver.step(TICK, 1.0, false, false, true)
	assert_almost_eq(solver.velocity.x, tuning.run_speed, 1.0, "run speed is reached")
	for i in 60:
		solver.step(TICK, 1.0, false, false, true)
	assert_true(solver.velocity.x <= tuning.run_speed + 0.01, "and never exceeded")

func test_jumping_from_the_floor_moves_the_player_upward() -> void:
	var velocity := solver.step(TICK, 0.0, true, true, true)
	assert_true(velocity.y < 0.0, "a jump produces upward velocity (y is negative in 2D)")

func test_coyote_time_allows_a_jump_just_after_leaving_the_ground() -> void:
	solver.step(TICK, 0.0, false, false, true)
	solver.step(TICK, 0.0, false, false, false)
	assert_true(solver.can_jump(false), "a jump is still permitted inside the coyote window")
	var velocity := solver.step(TICK, 0.0, true, true, false)
	assert_true(velocity.y < 0.0, "and it actually fires")

func test_coyote_time_expires() -> void:
	solver.step(TICK, 0.0, false, false, true)
	for i in 30:
		solver.step(TICK, 0.0, false, false, false)
	assert_false(solver.can_jump(false), "the grace window is not indefinite")

func test_a_jump_pressed_just_before_landing_is_buffered_and_fires_on_contact() -> void:
	# Airborne and falling, well outside the coyote window.
	for i in 30:
		solver.step(TICK, 0.0, false, false, false)
	solver.step(TICK, 0.0, true, true, false)
	assert_true(solver.velocity.y > 0.0, "the early press did not produce a mid-air jump")
	var velocity := solver.step(TICK, 0.0, false, true, true)
	assert_true(velocity.y < 0.0, "and it fires the moment the player lands")

func test_the_jump_buffer_expires_rather_than_firing_much_later() -> void:
	for i in 30:
		solver.step(TICK, 0.0, false, false, false)
	solver.step(TICK, 0.0, true, true, false)
	for i in 30:
		solver.step(TICK, 0.0, false, false, false)
	var velocity := solver.step(TICK, 0.0, false, false, true)
	assert_false(velocity.y < 0.0, "a stale press must not fire a surprise jump on landing")

func test_landing_recovery_does_not_swallow_a_buffered_jump() -> void:
	for i in 30:
		solver.step(TICK, 0.0, false, false, false)
	solver.step(TICK, 0.0, false, false, true)
	assert_true(solver.land_recovery_timer > 0.0, "the player is inside landing recovery")
	var velocity := solver.step(TICK, 0.0, true, true, true)
	assert_true(velocity.y < 0.0, "a jump during landing recovery is still permitted")

func test_releasing_the_button_early_cuts_the_jump_short() -> void:
	var held := MovementSolver.new(tuning)
	var tapped := MovementSolver.new(tuning)
	held.step(TICK, 0.0, true, true, true)
	tapped.step(TICK, 0.0, true, true, true)
	for i in 6:
		held.step(TICK, 0.0, false, true, false)
		tapped.step(TICK, 0.0, false, false, false)
	assert_true(tapped.velocity.y > held.velocity.y,
		"the tapped jump is already falling faster than the held one, so height is expressive")

func test_falling_is_capped_at_a_terminal_speed() -> void:
	for i in 600:
		solver.step(TICK, 0.0, false, false, false)
	assert_almost_eq(solver.velocity.y, tuning.terminal_fall_speed, 0.01, "fall speed is capped")

func test_a_grounded_player_does_not_accumulate_downward_velocity() -> void:
	_idle(120, true)
	assert_true(solver.velocity.y <= 0.0, "standing still does not build up fall speed")

func test_reset_clears_transient_state() -> void:
	solver.step(TICK, 1.0, true, true, true)
	solver.reset()
	assert_eq(solver.velocity, Vector2.ZERO, "velocity is cleared")
	assert_eq(solver.buffer_timer, 0.0, "so is a pending jump buffer, which must not survive a respawn")
	assert_false(solver.can_jump(false), "and the coyote window does not carry over")
