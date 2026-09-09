class_name SwingSolver
extends RefCounted
## Rope-constrained pendulum, kept pure for the same reason as MovementSolver.
##
## docs/weapon-tool-kit.md: "The simulation owns attachment and maximum distance.
## The drawn rope follows that state, never determines it." This class IS that
## simulation; the rope visual reads from it.

var tuning: Tuning

var anchor: Vector2 = Vector2.ZERO
var length: float = 0.0
var attached: bool = false

func _init(p_tuning: Tuning = null) -> void:
	tuning = p_tuning if p_tuning != null else Tuning.new()

func attach(anchor_position: Vector2, body_position: Vector2) -> void:
	anchor = anchor_position
	length = maxf(anchor_position.distance_to(body_position), tuning.swing_min_length_px)
	attached = true

func release() -> void:
	attached = false
	length = 0.0

## Advances the pendulum and returns the new body position. Velocity is updated
## in place. Never called while detached.
func step(delta: float, position: Vector2, velocity: Vector2) -> Dictionary:
	if not attached:
		return {"position": position, "velocity": velocity}

	var v := velocity
	v.y += tuning.swing_gravity * delta
	var next := position + v * delta

	# Constrain to the rope, then project velocity onto the tangent so the swing
	# conserves speed instead of gaining it from the correction.
	var offset := next - anchor
	var distance := offset.length()
	if distance > length and distance > 0.0:
		var direction := offset / distance
		next = anchor + direction * length
		v -= direction * v.dot(direction)
	v *= tuning.swing_damping
	return {"position": next, "velocity": v}

## Speed the player keeps on release. A small boost rewards timing without
## turning the rope into a free accelerator.
func release_velocity(velocity: Vector2) -> Vector2:
	return velocity * tuning.swing_release_boost

## Distance beyond which the rope would have to stretch. Used to reject a throw
## rather than silently extending the rope.
func exceeds_reach(anchor_position: Vector2, body_position: Vector2) -> bool:
	return anchor_position.distance_to(body_position) > tuning.lasso_range_px
