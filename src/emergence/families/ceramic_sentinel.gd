class_name CeramicSentinel
extends EnemyActor
## Ceramic sentinel: unfolds upright, short charge, readable heavy strike.
##
## Beats C0-C5 in docs/production/emergence-keyframes.md. The charge is short
## and rests between bursts so the approach is readable, and the heavy strike
## keeps a long windup: fairness in this family comes from being able to see the
## blow coming, not from it being weak.
##
## ART STATUS: GRAYBOX PLACEHOLDER silhouette only. The jar decoration that must
## survive across body segments (C3) is an art requirement, not something a
## polygon can stand in for.

## Provisional. Measure in playtest.
const CHARGE_SPEED_PX_S := 190.0
const CHARGE_BURST_S := 0.45
const CHARGE_REST_S := 0.35

var _charge_elapsed_s: float = 0.0
var _charging: bool = true

func family_id() -> StringName:
	return EncounterSource.CERAMIC_SENTINEL

func _configure_family() -> void:
	max_health = 4
	move_speed = 70.0
	attack_range_px = 40.0
	windup_s = 0.55
	strike_s = 0.18
	recover_s = 0.70
	stagger_s = 0.85

## Short charge, then a rest. The rest is the readable half: a sentinel that
## charged continuously would be a chase, not a telegraph.
func _pursue(delta: float) -> void:
	_charge_elapsed_s += delta
	if _charging and _charge_elapsed_s >= CHARGE_BURST_S:
		_charging = false
		_charge_elapsed_s = 0.0
	elif not _charging and _charge_elapsed_s >= CHARGE_REST_S:
		_charging = true
		_charge_elapsed_s = 0.0
	velocity.x = _direction_to_target() * (CHARGE_SPEED_PX_S if _charging else 0.0)

func is_charging() -> bool:
	return _charging

func _on_state_entered(next: State) -> void:
	if next == State.PURSUE:
		_charging = true
		_charge_elapsed_s = 0.0

## Tall, narrow, shoulder-heavy: an upright vessel that unfolded.
func _graybox_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-7, 0), Vector2(7, 0), Vector2(10, -20),
		Vector2(9, -34), Vector2(-9, -34), Vector2(-10, -20),
	])

func _graybox_color() -> Color:
	return Color(0.82, 0.72, 0.56)

func _graybox_extents() -> Vector2:
	return Vector2(10, 17)
