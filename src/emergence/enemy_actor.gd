class_name EnemyActor
extends CharacterBody2D
## The creature view of an encounter. One base, three slice families.
##
## The actor is never created by itself: an Encounter owns it and drives it
## (docs/temple-emergence.md - "an enemy is not merely a prop removed plus a
## separately spawned actor"). Nothing here spawns, resolves or rewards; the
## Encounter owns all of that so there is one owner per responsibility.
##
## Simulation and presentation are separated. advance() is the whole simulation
## and is called by the Encounter, which is what lets a pause freeze both at
## once and lets the headless suite step this actor without a physics frame.
## apply_motion() is the only engine-driven part and is deliberately NOT covered
## by the suite: collision response has to be inspected in a running room.
##
## ART STATUS: every visual below is a GRAYBOX PLACEHOLDER, not an admitted or
## approved asset. Sprite frames arrive later through the AnimationClip contract
## in docs/data-contracts.md and attach at the PlaceholderSpriteSeam marker.

signal defeated()
signal staggered(seconds: float)
signal attack_window_opened()
signal attack_window_closed()

enum State { SETTLING, IDLE, PURSUE, WINDUP, STRIKE, RECOVER, STAGGERED, DEFEATED }

const STATE_NAMES: Array[String] = [
	"settling", "idle", "pursue", "windup", "strike", "recover", "staggered", "defeated",
]

## Every damaging verb plus PULL. PULL does not damage; it staggers, which is
## what makes the lasso a control tool rather than a fifth gun.
const HURTBOX_VERBS: Array[StringName] = [
	Verbs.PULL, Verbs.PRECISION_HIT, Verbs.FORCE_HIT, Verbs.LONG_PRECISION_HIT,
]

## Provisional tuning. These are hypotheses to measure in playtest, not approved
## numbers, and they live per family in _configure_family().
var max_health: int = 3
var move_speed: float = 70.0
var attack_range_px: float = 40.0
var windup_s: float = 0.40
var strike_s: float = 0.15
var recover_s: float = 0.60
## First stable combat pose before any attack is possible. Keyframe C4/M4/B4
## calls for a separate recovery before the attack, so a settle can never be
## skipped into a strike.
var settle_s: float = 0.42
var stagger_s: float = 0.80
var hitstun_s: float = 0.12
var gravity: float = 1400.0

var _health: int = 3
var _state: State = State.SETTLING
var _state_elapsed_s: float = 0.0
var _pending_stagger_s: float = 0.0
var _target_position: Vector2 = Vector2.ZERO
var _has_target: bool = false
var _paused: bool = false
var _configured: bool = false
var _hurtbox: Hurtbox
var _body: Polygon2D

## Called by the owning Encounter immediately after instantiation. One entry
## point, so a family cannot be half-configured.
func bind_tuning(tuning: Tuning) -> void:
	if not _configured:
		_configure_family()
		_configured = true
	if tuning != null:
		settle_s = float(tuning.active_settle_ms) / 1000.0
		gravity = tuning.gravity
	_health = max_health
	_build_graybox()
	_enter_state(State.SETTLING)

# --- simulation ------------------------------------------------------------

## The entire simulation step. Returns without touching anything while paused,
## which freezes presentation too because the graybox is driven from here.
func advance(delta: float) -> void:
	if _paused or _state == State.DEFEATED:
		return
	_state_elapsed_s += delta
	velocity.x = 0.0
	velocity.y += gravity * delta

	match _state:
		State.SETTLING:
			if _state_elapsed_s >= settle_s:
				_enter_state(State.IDLE)
		State.IDLE:
			if _has_target:
				_enter_state(State.PURSUE)
		State.PURSUE:
			_pursue(delta)
			if _has_target and _can_begin_attack() and _in_attack_range():
				_enter_state(State.WINDUP)
			elif not _has_target:
				_enter_state(State.IDLE)
		State.WINDUP:
			if _state_elapsed_s >= windup_s:
				_enter_state(State.STRIKE)
		State.STRIKE:
			_strike(delta)
			if _state_elapsed_s >= strike_s:
				_enter_state(State.RECOVER)
		State.RECOVER:
			if _state_elapsed_s >= recover_s:
				_enter_state(State.IDLE)
		State.STAGGERED:
			if _state_elapsed_s >= _pending_stagger_s:
				# A stagger always resettles. It can never expire straight into a
				# strike, which is what keeps an interrupt off the damage path.
				_enter_state(State.SETTLING)
	_update_graybox()

## The only engine-driven half. Called by the Encounter's physics step, never by
## advance(), so the headless suite never depends on a physics frame.
func apply_motion() -> void:
	if _paused or _state == State.DEFEATED:
		return
	move_and_slide()

## True only inside the authored strike window. Everything else - settling,
## staggered, winding up, recovering - is explicitly non-damaging.
func can_damage() -> bool:
	return _state == State.STRIKE

func state() -> State:
	return _state

func state_name() -> String:
	return STATE_NAMES[_state]

func health() -> int:
	return _health

func is_defeated() -> bool:
	return _state == State.DEFEATED

func is_paused() -> bool:
	return _paused

func set_paused(paused: bool) -> void:
	_paused = paused

func set_target_position(position_2d: Vector2) -> void:
	_target_position = position_2d
	_has_target = true

func clear_target() -> void:
	_has_target = false

func target_position() -> Vector2:
	return _target_position

func has_target() -> bool:
	return _has_target

func distance_to_target() -> float:
	return global_position.distance_to(_target_position) if _has_target else INF

## A skipped or fast-forwarded settle still completes the same single transition
## it would have completed by waiting.
func finish_settle() -> void:
	if _state == State.SETTLING:
		_enter_state(State.IDLE)

func stagger(seconds: float) -> void:
	if _state == State.DEFEATED:
		return
	_pending_stagger_s = maxf(seconds, 0.0)
	_enter_state(State.STAGGERED)
	staggered.emit(_pending_stagger_s)

## Applied by the hurtbox. Returns false when the hit could not land at all.
func take_hit(hit: Hit) -> bool:
	if _state == State.DEFEATED:
		return false
	if hit.verb == Verbs.PULL:
		stagger(stagger_s)
		return true
	_health -= maxi(1, hit.damage)
	if _health <= 0:
		_health = 0
		_enter_state(State.DEFEATED)
		defeated.emit()
		return true
	stagger(hitstun_s)
	return true

func hurtbox() -> Hurtbox:
	return _hurtbox

func _enter_state(next: State) -> void:
	if _state == State.STRIKE and next != State.STRIKE:
		attack_window_closed.emit()
	_state = next
	_state_elapsed_s = 0.0
	if next == State.STRIKE:
		attack_window_opened.emit()
	_on_state_entered(next)

func _in_attack_range() -> bool:
	return _has_target and distance_to_target() <= attack_range_px

func _direction_to_target() -> float:
	if not _has_target:
		return 0.0
	return signf(_target_position.x - global_position.x)

# --- family overrides ------------------------------------------------------

## Set the family's tuning here. Called exactly once, from bind_tuning().
func _configure_family() -> void:
	pass

func family_id() -> StringName:
	return &"unnamed_family"

## Extra gate before an attack may begin, e.g. the assembler needing a body.
func _can_begin_attack() -> bool:
	return true

## Locomotion while pursuing. The base walks flatly toward the target.
func _pursue(_delta: float) -> void:
	velocity.x = _direction_to_target() * move_speed

## Motion during the strike window, e.g. a lunge.
func _strike(_delta: float) -> void:
	pass

func _on_state_entered(_next: State) -> void:
	pass

# --- graybox placeholder presentation --------------------------------------

## Distinct silhouette per family. PLACEHOLDER GEOMETRY, not art.
func _graybox_points() -> PackedVector2Array:
	return PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(8, -24), Vector2(-8, -24)])

func _graybox_color() -> Color:
	return Color(0.75, 0.75, 0.78)

func _graybox_extents() -> Vector2:
	return Vector2(10, 14)

func _build_graybox() -> void:
	if _body != null:
		return

	_body = Polygon2D.new()
	_body.name = "GrayboxBody"
	_body.polygon = _graybox_points()
	_body.color = _graybox_color()
	add_child(_body)

	# SEAM: an AnimationClip-driven AnimatedSprite2D attaches here once frames
	# exist. It replaces GrayboxBody; it does not sit beside it.
	var seam := Marker2D.new()
	seam.name = "PlaceholderSpriteSeam"
	add_child(seam)

	var shape := RectangleShape2D.new()
	shape.size = _graybox_extents() * 2.0
	var collision := CollisionShape2D.new()
	collision.name = "GrayboxCollision"
	collision.shape = shape
	collision.position = Vector2(0, -_graybox_extents().y)
	add_child(collision)

	_hurtbox = Hurtbox.new()
	_hurtbox.name = "GrayboxHurtbox"
	_hurtbox.actor = self
	_hurtbox.receiver_id = StringName("%s_hurtbox" % family_id())
	_hurtbox.allowed_verbs = HURTBOX_VERBS.duplicate()
	var hurt_shape := RectangleShape2D.new()
	hurt_shape.size = _graybox_extents() * 2.0
	var hurt_collision := CollisionShape2D.new()
	hurt_collision.name = "GrayboxHurtboxCollision"
	hurt_collision.shape = hurt_shape
	hurt_collision.position = Vector2(0, -_graybox_extents().y)
	_hurtbox.add_child(hurt_collision)
	add_child(_hurtbox)

## Placeholder readability only: the windup and strike windows must be visible
## in a graybox build so fairness can be judged before art exists.
func _update_graybox() -> void:
	if _body == null:
		return
	match _state:
		State.WINDUP:
			_body.color = _graybox_color().lightened(0.35)
		State.STRIKE:
			_body.color = Color(1.0, 0.45, 0.35)
		State.STAGGERED:
			_body.color = _graybox_color().darkened(0.45)
		State.DEFEATED:
			_body.color = _graybox_color().darkened(0.7)
		_:
			_body.color = _graybox_color()

## The creature's hurtbox. Declares its verbs like any other receiver, so it
## cannot silently inherit interactions it was never authored to accept.
class Hurtbox extends HitReceiver:
	var actor: EnemyActor

	func _on_hit(hit: Hit) -> bool:
		if actor == null:
			return false
		return actor.take_hit(hit)
