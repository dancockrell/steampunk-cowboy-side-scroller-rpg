class_name BurialPitAssembler
extends EnemyActor
## Burial-pit assembler: crawls first, assembles enough body to lunge.
##
## Beats B0-B5 in docs/production/emergence-keyframes.md. Leg completeness never
## changes without an explicit assembly action, so the parts count is authored
## simulation state rather than an animation side effect. The wrong-skull beat
## is authored once and fires once; it is not randomised identity drift.
##
## ART STATUS: GRAYBOX PLACEHOLDER silhouette only. The pit-lip occlusion mask
## that hides the emerging lower limbs is an art deliverable, not a polygon.

## Provisional. Measure in playtest.
const PARTS_REQUIRED := 3
const ASSEMBLE_INTERVAL_S := 0.60
const CRAWL_SPEED_PX_S := 35.0
const LUNGE_SPEED_PX_S := 220.0

signal wrong_skull_adjusted()

var _assembled_parts: int = 0
var _assemble_elapsed_s: float = 0.0
var _wrong_skull_beat_played: bool = false

func family_id() -> StringName:
	return EncounterSource.BURIAL_PIT_ASSEMBLER

func _configure_family() -> void:
	max_health = 3
	move_speed = CRAWL_SPEED_PX_S
	attack_range_px = 46.0
	windup_s = 0.35
	strike_s = 0.20
	recover_s = 0.60
	stagger_s = 0.75

func assembled_parts() -> int:
	return _assembled_parts

func is_assembled() -> bool:
	return _assembled_parts >= PARTS_REQUIRED

## It crawls until it has a body. A crawler cannot lunge, so the lunge is never
## the first thing the player sees.
func is_crawling() -> bool:
	return not is_assembled()

func _can_begin_attack() -> bool:
	return is_assembled()

func _pursue(delta: float) -> void:
	if not is_assembled():
		_assemble_elapsed_s += delta
		if _assemble_elapsed_s >= ASSEMBLE_INTERVAL_S:
			_assemble_elapsed_s = 0.0
			_assembled_parts += 1
			if is_assembled() and not _wrong_skull_beat_played:
				# B4: one authored macabre beat, played once, never randomised.
				_wrong_skull_beat_played = true
				wrong_skull_adjusted.emit()
	velocity.x = _direction_to_target() * (CRAWL_SPEED_PX_S if is_crawling() else move_speed * 1.6)

## The assembled body throws itself forward inside the strike window.
func _strike(_delta: float) -> void:
	velocity.x = _direction_to_target() * LUNGE_SPEED_PX_S

func wrong_skull_beat_played() -> bool:
	return _wrong_skull_beat_played

## Low and wide: hauling itself over a rim, deliberately unlike the sentinel.
func _graybox_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-18, 0), Vector2(16, 0), Vector2(20, -8),
		Vector2(8, -16), Vector2(-6, -14), Vector2(-18, -6),
	])

func _graybox_color() -> Color:
	return Color(0.70, 0.67, 0.55)

func _graybox_extents() -> Vector2:
	return Vector2(19, 8)
