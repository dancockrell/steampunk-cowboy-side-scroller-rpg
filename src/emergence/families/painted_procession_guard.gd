class_name PaintedProcessionGuard
extends EnemyActor
## Painted procession guard: steps between wall panels, emerges to thrust, can
## remain partly flat.
##
## Beats M0-M5 in docs/production/emergence-keyframes.md. The signature is the
## mixed anatomy at M3: the upper body gains volume while the trailing leg stays
## flat. So flatness never reaches zero here - a guard that fully solidified
## would just be a skeleton standing in front of a wall, which the art brief
## rules out explicitly.
##
## ART STATUS: GRAYBOX PLACEHOLDER silhouette only. "Painting acquiring volume"
## is a shading and registration problem no polygon can stand in for.

## Provisional. Measure in playtest.
const PANEL_SPACING_PX := 64.0
const PANEL_STEP_S := 0.55
const THRUST_RANGE_PX := 72.0
## The trailing leg never leaves the plaster.
const MIN_FLATNESS := 0.35
const FLATTEN_RATE_PER_S := 0.55

var _flatness: float = 1.0
var _panel_step_elapsed_s: float = 0.0
var _panels_stepped: int = 0

func family_id() -> StringName:
	return EncounterSource.PAINTED_PROCESSION_GUARD

func _configure_family() -> void:
	max_health = 3
	move_speed = 0.0  # It steps between panels; it does not walk.
	attack_range_px = THRUST_RANGE_PX
	windup_s = 0.30
	strike_s = 0.12
	recover_s = 0.50
	stagger_s = 0.70

## How much of the guard is still paint on the wall. 1.0 is the flat mural
## figure at M0; it settles toward MIN_FLATNESS and stops there.
func flatness() -> float:
	return _flatness

func is_partly_flat() -> bool:
	return _flatness > 0.0

func panels_stepped() -> int:
	return _panels_stepped

## The guard cannot thrust while it is still mostly paint. Volume first, then
## the weapon has somewhere to come from.
func _can_begin_attack() -> bool:
	return _flatness <= 0.75

## Discrete panel steps rather than continuous walking, so the guard reads as
## moving through the mural rather than off it.
func _pursue(delta: float) -> void:
	_flatness = maxf(MIN_FLATNESS, _flatness - FLATTEN_RATE_PER_S * delta)
	velocity.x = 0.0
	_panel_step_elapsed_s += delta
	if _panel_step_elapsed_s < PANEL_STEP_S:
		return
	_panel_step_elapsed_s = 0.0
	var direction := _direction_to_target()
	if direction == 0.0 or distance_to_target() <= THRUST_RANGE_PX:
		return
	position.x += direction * PANEL_SPACING_PX
	_panels_stepped += 1

func _on_state_entered(next: State) -> void:
	if next == State.PURSUE:
		_panel_step_elapsed_s = 0.0

## Wide and shallow: a figure that is still half plaster.
func _graybox_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-14, 0), Vector2(14, 0), Vector2(12, -18),
		Vector2(20, -26), Vector2(6, -30), Vector2(-12, -30), Vector2(-14, -14),
	])

func _graybox_color() -> Color:
	return Color(0.63, 0.38, 0.30)

func _graybox_extents() -> Vector2:
	return Vector2(15, 15)
