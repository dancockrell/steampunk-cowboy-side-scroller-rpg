extends TestCase
## The rope, as maths. SwingSolver is deliberately free of nodes for the same
## reason MovementSolver is: the headless harness never reaches a physics frame,
## so anything that lives in move_and_collide cannot be asserted here -- but the
## constraint itself can.

const TICK := 1.0 / 60.0

var tuning: Tuning
var swing: SwingSolver

func before_each() -> void:
	tuning = Tuning.new()
	swing = SwingSolver.new(tuning)

func test_a_detached_rope_changes_nothing() -> void:
	var result := swing.step(TICK, Vector2(10, 10), Vector2(5, 0))
	assert_eq(result["position"] as Vector2, Vector2(10, 10), "no rope, no constraint")
	assert_eq(result["velocity"] as Vector2, Vector2(5, 0), "and no acceleration")

func test_attaching_measures_the_rope_from_where_it_was_thrown() -> void:
	swing.attach(Vector2(0, 0), Vector2(0, 200))
	assert_true(swing.attached, "the rope is on")
	assert_almost_eq(swing.length, 200.0, 0.01, "and it is as long as the throw was")

func test_a_very_short_throw_cannot_produce_a_zero_length_rope() -> void:
	# A zero-length rope is a division by zero waiting to happen and a player
	# welded to an anchor; the floor is a tuning value, not an accident.
	swing.attach(Vector2(0, 0), Vector2(0, 2))
	assert_almost_eq(swing.length, tuning.swing_min_length_px, 0.01,
		"the rope is never shorter than its authored minimum")

func test_the_rope_does_not_stretch() -> void:
	swing.attach(Vector2(0, 0), Vector2(0, 200))
	var position := Vector2(0, 200)
	var velocity := Vector2(600, 0)
	for i in 40:
		var result := swing.step(TICK, position, velocity)
		position = result["position"]
		velocity = result["velocity"]
	assert_true(position.distance_to(Vector2.ZERO) <= 200.5,
		"a swung body stays inside the rope, at %.1f px" % position.distance_to(Vector2.ZERO))

func test_a_pendulum_alone_never_climbs() -> void:
	# This is the measured fact the climb exists to answer, asserted as maths so
	# it cannot quietly change: a damped pendulum is a closed system and cannot
	# rise above where it started. 248 real swings agreed -- 5 of 177 movers
	# ended any higher, median gain +3px.
	swing.attach(Vector2(0, 0), Vector2(0, 200))
	var position := Vector2(0, 200)
	var velocity := Vector2(400, 0)
	var highest := position.y
	for i in 400:
		var result := swing.step(TICK, position, velocity)
		position = result["position"]
		velocity = result["velocity"]
		highest = minf(highest, position.y)
	assert_true(highest >= -1.0,
		"without hauling the rope in, the body never gets above the anchor's level")

func test_hauling_the_rope_in_is_what_makes_the_lasso_climb() -> void:
	swing.attach(Vector2(0, 0), Vector2(0, 200))
	var before := swing.length
	swing.climb(TICK * 30.0, 0.0)
	assert_almost_eq(swing.length, before, 0.01, "a zero haul rate changes nothing")
	swing.climb(TICK * 30.0, tuning.swing_climb_speed_px_s)
	assert_true(swing.length < before,
		"the rope shortens: %.1f -> %.1f" % [before, swing.length])
	# The whole point: a shorter rope means the constraint pulls the body up.
	var position := Vector2(0, 200)
	var velocity := Vector2.ZERO
	for i in 60:
		swing.climb(TICK, tuning.swing_climb_speed_px_s)
		var result := swing.step(TICK, position, velocity)
		position = result["position"]
		velocity = result["velocity"]
	assert_true(position.y < 190.0,
		"hauling raises the body toward the anchor, ended at y=%.0f" % position.y)

func test_the_rope_cannot_be_hauled_in_to_nothing() -> void:
	swing.attach(Vector2(0, 0), Vector2(0, 200))
	for i in 600:
		swing.climb(TICK, tuning.swing_climb_speed_px_s)
	assert_almost_eq(swing.length, tuning.swing_min_length_px, 0.01,
		"climbing stops at the same minimum a short throw does")

func test_hauling_a_detached_rope_does_nothing() -> void:
	swing.climb(TICK, tuning.swing_climb_speed_px_s)
	assert_eq(swing.length, 0.0, "there is no rope to shorten")

func test_release_rewards_speed_rather_than_replacing_it() -> void:
	var kept := swing.release_velocity(Vector2(100, -50))
	assert_almost_eq(kept.x, 100.0 * tuning.swing_release_boost, 0.01, "boosted, not invented")
	assert_true(kept.length() > Vector2(100, -50).length(), "a well-timed release pays")

func test_a_throw_beyond_the_rope_is_rejected_rather_than_stretched() -> void:
	assert_true(swing.exceeds_reach(Vector2.ZERO, Vector2(tuning.lasso_range_px + 10.0, 0)),
		"out of reach is refused")
	assert_false(swing.exceeds_reach(Vector2.ZERO, Vector2(tuning.lasso_range_px - 10.0, 0)),
		"and inside it is not")
