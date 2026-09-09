class_name Encounter
extends Node2D
## One authored encounter: the prop and the creature are two views of it.
##
## docs/temple-emergence.md is the specification. The six phases are
## disguised -> tell -> awakening -> emerging -> active -> resolved, and this
## node owns all of them, both child views, and the single moment where spawn
## ownership transfers from the scenery to the actor. "An enemy is not merely a
## prop removed plus a separately spawned actor": there is no second owner here
## to disagree with this one.
##
## Simulation is separated from presentation on purpose. advance() is the whole
## simulation and is called from _process in a running room and directly by the
## suite. Nothing here reads the scene's appearance to decide what happened, so
## a collateral kill is an authored fact rather than something inferred from
## what the rubble looks like.
##
## The player is referenced only as a position, pushed in by the room through
## set_target_position. This node deliberately does not know the player's type.
##
## ART STATUS: every visual here is a GRAYBOX PLACEHOLDER, never an admitted or
## approved asset. Real keyframes arrive through the AnimationClip contract.

signal phase_changed(phase: EncounterBook.Phase)
signal tell_started()
## Emitted when a blocked spawn makes the encounter repeat its warning, which
## the fairness rule requires rather than a silent wait.
signal tell_repeated(reason: StringName)
signal spawn_ownership_transferred(actor: EnemyActor)
signal spawn_blocked(blocked_position: Vector2, policy: StringName)
signal interrupt_refused(reason: String)
signal resolved(result: String)
## Authored data or staging is wrong. Always accompanied by push_error: a
## content error is never a silent fallthrough.
signal content_error(message: String)

const RESULT_DEFEATED := "defeated"
const RESULT_INTERRUPTED := "interrupted"
## Michael destroyed the source itself instead of fighting what was inside it.
const RESULT_COLLATERAL := "collateral_destroyed"
## The Keeper sent a weakened creature back to its vessel rather than letting it
## be finished. Its own authored fact, because she has opinions about which of
## these happened (docs/relationships.md).
const RESULT_RECALLED := "recalled"

@export var source: EncounterSource
## Where the actor takes over from the scenery. Defaults to this node's own
## position, which is the source's own place.
@export var spawn_point_path: NodePath
## The explicitly authored safe marker required by blocked_spawn_policy
## "authored_fallback". Its absence is a content error, not a fallthrough.
@export var fallback_spawn_path: NodePath
## No active hitbox may appear this close to the target, whatever a room's own
## clearance query says. Provisional; belongs in Tuning once that file's owner
## adds an emergence clearance field.
@export var min_spawn_clearance_px: float = 44.0
## Authored verbs that can destroy the disguised source. A source that accepts
## none simply cannot be destroyed collaterally.
@export var source_allowed_verbs: Array[StringName] = [Verbs.FORCE_HIT]
@export var source_prop_health: int = 1

var _services: Services
var _phase: EncounterBook.Phase = EncounterBook.Phase.DISGUISED
var _phase_elapsed_ms: float = 0.0
var _presentation_clock_ms: float = 0.0
var _paused: bool = false
var _trigger_latched: bool = false
var _content_valid: bool = false
var _content_errors: PackedStringArray = PackedStringArray()
var _result: String = ""

var _actor: EnemyActor
var _source_view: SourcePropView
var _resolved_view: Polygon2D

var _blocked: bool = false
var _blocked_retry_elapsed_ms: float = 0.0
var _blocked_retell_elapsed_ms: float = 0.0
var _tell_repeat_count: int = 0
var _pending_stagger_on_spawn: bool = false
## Set when another live Encounter already owns this source ID. This node then
## presents nothing and spawns nothing rather than duplicating the enemy.
var _forfeited: bool = false

var _target_position: Vector2 = Vector2.ZERO
var _has_target: bool = false
var _clearance_query: Callable = Callable()

# --- lifecycle -------------------------------------------------------------

## Called by the room after this node is in the tree. Returns false when the
## authored content is invalid, in which case the encounter stays inert: it
## never spawns, never damages and never resolves.
func bind(services: Services) -> bool:
	_services = services
	if source == null:
		_fail_content("Encounter '%s' has no EncounterSource assigned" % name, true)
		return false
	var error := source.validation_error()
	if error != "":
		_fail_content(error, true)
		return false
	_content_valid = true

	if source.blocked_spawn_policy_index() == EncounterSource.BlockedSpawnPolicy.AUTHORED_FALLBACK \
			and not has_authored_fallback():
		# Reported at bind, which is the earliest point it can be known, rather
		# than at the moment a blocked spawn would otherwise quietly wait.
		_fail_content("source '%s' uses blocked_spawn_policy 'authored_fallback' but no valid safe marker is authored at '%s'"
			% [source.id, fallback_spawn_path])

	_build_views()
	_adopt_recorded_phase()
	return _content_valid

func _process(delta: float) -> void:
	advance(delta)

## The engine-driven half. Kept out of advance() so the headless suite never
## depends on a physics frame; collision response is inspected in a room.
func _physics_process(_delta: float) -> void:
	if _paused or _actor == null:
		return
	_actor.apply_motion()

## Room re-entry and checkpoint reload both land here: the book is the truth
## about this source, and this node conforms to it rather than restarting.
func _adopt_recorded_phase() -> void:
	var recorded := _services.encounters.phase_of(source.id)
	if recorded == EncounterBook.Phase.DISGUISED:
		return
	_result = _services.encounters.result_of(source.id)
	_trigger_latched = true
	_phase = recorded
	_phase_elapsed_ms = 0.0
	if recorded == EncounterBook.Phase.ACTIVE:
		# Restoring the one actor this encounter already owns. This is NOT a
		# transfer: the transfer happened once, before the room unloaded, and
		# the ledger still records it.
		_restore_actor()
	_apply_view_visibility()
	phase_changed.emit(_phase)

# --- public control --------------------------------------------------------

## Called by the authored trigger volume. Latched once: a trigger that fires
## every time Michael crosses it cannot restart or duplicate the encounter.
func trigger() -> bool:
	if not _content_valid or _forfeited:
		return false
	if _trigger_latched or _phase != EncounterBook.Phase.DISGUISED:
		return false
	_trigger_latched = true
	_enter_phase(EncounterBook.Phase.TELL)
	tell_started.emit()
	return true

## The whole simulation step.
func advance(delta: float) -> void:
	if _paused or not _content_valid or _forfeited:
		return
	if _phase == EncounterBook.Phase.RESOLVED or _phase == EncounterBook.Phase.DISGUISED:
		return
	var delta_ms := delta * 1000.0
	_presentation_clock_ms += delta_ms
	_phase_elapsed_ms += delta_ms

	match _phase:
		EncounterBook.Phase.TELL:
			if _phase_elapsed_ms >= _tuning().tell_duration_ms:
				_enter_phase(EncounterBook.Phase.AWAKENING)
		EncounterBook.Phase.AWAKENING:
			if _phase_elapsed_ms >= _tuning().awakening_duration_ms:
				_enter_phase(EncounterBook.Phase.EMERGING)
		EncounterBook.Phase.EMERGING:
			_tick_emerging(delta_ms)
		EncounterBook.Phase.ACTIVE:
			if _actor != null:
				_actor.advance(delta)
				if _actor.is_defeated():
					_resolve(RESULT_DEFEATED, &"", {"by": "combat"})
	_update_presentation()

## A skipped or fast-forwarded animation still completes exactly ONE state
## transition - the same one waiting would have completed, no more.
func skip_current_beat() -> void:
	if _paused or not _content_valid or _forfeited:
		return
	match _phase:
		EncounterBook.Phase.TELL:
			_enter_phase(EncounterBook.Phase.AWAKENING)
		EncounterBook.Phase.AWAKENING:
			_enter_phase(EncounterBook.Phase.EMERGING)
		EncounterBook.Phase.EMERGING:
			# Completes emergence if the space allows it. A skipped animation
			# does not buy the right to land a hitbox in a blocked space.
			_attempt_spawn_transfer()
		EncounterBook.Phase.ACTIVE:
			if _actor != null:
				_actor.finish_settle()
	_update_presentation()

## Freezes simulation and presentation together: advance() stops, the actor
## stops, and the presentation clock stops with them.
func set_paused(paused: bool) -> void:
	_paused = paused
	if _actor != null:
		_actor.set_paused(paused)

func is_paused() -> bool:
	return _paused

## An authored interrupt may route awakening/emerging to resolved or to a
## staggered active state. It can never reach a damaging attack, and an
## unrecognised rule refuses loudly instead of defaulting to one.
func apply_interrupt(reason: StringName = &"authored") -> bool:
	if _forfeited or source == null:
		return false
	if _phase != EncounterBook.Phase.AWAKENING and _phase != EncounterBook.Phase.EMERGING:
		interrupt_refused.emit("interrupt is authored for awakening and emerging only; '%s' is %s"
			% [source.id, _phase_name()])
		return false

	match source.interrupt_rule_index():
		EncounterSource.InterruptRule.TO_RESOLVED:
			return _resolve(RESULT_INTERRUPTED, &"", {"reason": String(reason)})
		EncounterSource.InterruptRule.TO_STAGGERED_ACTIVE:
			# The actor arrives staggered. A stagger always resettles before it
			# can strike, so this route cannot become an attack on this frame or
			# the next one.
			_pending_stagger_on_spawn = true
			_attempt_spawn_transfer()
			return true
		EncounterSource.InterruptRule.NONE:
			interrupt_refused.emit("source '%s' authors no interrupt" % source.id)
			return false
		_:
			_fail_content("source '%s' has an unrecognised interrupt_rule '%s'; refusing the interrupt. An unknown rule must never default to a damaging attack."
				% [source.id, source.interrupt_rule])
			return false

## Michael destroyed the source itself rather than fighting what was inside it.
## A distinct authored result and a distinct ledger fact, recorded here at the
## moment it happens.
func resolve_by_collateral(agent: StringName = &"player") -> bool:
	if not _content_valid or _forfeited:
		return false
	if _phase == EncounterBook.Phase.RESOLVED or _phase == EncounterBook.Phase.ACTIVE:
		return false
	return _resolve(RESULT_COLLATERAL, source.collateral_event_id(), {"agent": String(agent)})

## Called by RecallToClay (src/relationships/intervention_recall.gd). Returning
## false must have no side effect at all: that caller reads a false as "the
## creature is still there" and declines to charge a use for it.
##
## Eligibility (weakened, active, alive) belongs to the intervention and is not
## re-litigated here; what this owns is that only a live creature this encounter
## actually holds can be sent home.
func resolve_by_recall(heroine_id: StringName) -> bool:
	if not _content_valid or _forfeited:
		return false
	if _phase != EncounterBook.Phase.ACTIVE or _actor == null or _actor.is_defeated():
		return false
	return _resolve(RESULT_RECALLED, &"", {"heroine": String(heroine_id)})

func set_target_position(position_2d: Vector2) -> void:
	_target_position = position_2d
	_has_target = true
	if _actor != null:
		_actor.set_target_position(position_2d)

## Optional room-supplied test for whether a world position is free. It can only
## ever make a spawn MORE restricted: the minimum clearance from the target is
## applied first and cannot be overridden by a room.
func set_spawn_clearance_query(query: Callable) -> void:
	_clearance_query = query

# --- readable state --------------------------------------------------------

func phase() -> EncounterBook.Phase:
	return _phase

func result() -> String:
	return _result

func actor() -> EnemyActor:
	return _actor

## Counts the actual child actors rather than a bookkeeping integer, so a
## duplicate would show up here even if the counter were wrong.
func actor_count() -> int:
	var found := 0
	for child: Node in get_children():
		if child is EnemyActor:
			found += 1
	return found

func is_spawn_blocked() -> bool:
	return _blocked

func tell_repeat_count() -> int:
	return _tell_repeat_count

func is_content_valid() -> bool:
	return _content_valid

func content_errors() -> PackedStringArray:
	return _content_errors.duplicate()

func has_forfeited_ownership() -> bool:
	return _forfeited

## Exactly one of "source", "actor", "resolved" or "none". The two views are
## swapped, never mixed, so nothing downstream has to read appearance to know
## which half of the encounter is live.
func visible_view() -> StringName:
	if _forfeited:
		return &"none"
	match _phase:
		EncounterBook.Phase.RESOLVED:
			return &"resolved"
		EncounterBook.Phase.ACTIVE:
			return &"actor" if _actor != null else &"source"
		_:
			return &"source"

## Which authored clip the presentation is showing for this phase.
func presentation_clip() -> StringName:
	if source == null:
		return &""
	match _phase:
		EncounterBook.Phase.TELL:
			return source.tell_clip_id
		EncounterBook.Phase.AWAKENING, EncounterBook.Phase.EMERGING:
			return source.emerge_clip_id
		EncounterBook.Phase.RESOLVED:
			return source.resolved_visual_id
		_:
			return &""

## Presentation time. Frozen by set_paused along with the simulation, which is
## the whole point of holding one clock rather than two.
func presentation_clock_ms() -> float:
	return _presentation_clock_ms

func spawn_position() -> Vector2:
	var marker := get_node_or_null(spawn_point_path) as Node2D
	return marker.global_position if marker != null else global_position

func has_authored_fallback() -> bool:
	return get_node_or_null(fallback_spawn_path) is Node2D

func fallback_spawn_position() -> Vector2:
	var marker := get_node_or_null(fallback_spawn_path) as Node2D
	return marker.global_position if marker != null else spawn_position()

# --- phases ----------------------------------------------------------------

func _enter_phase(next: EncounterBook.Phase) -> void:
	_phase = next
	_phase_elapsed_ms = 0.0
	if next != EncounterBook.Phase.EMERGING:
		_blocked = false
	_record_phase(next)
	_apply_view_visibility()
	phase_changed.emit(next)

## Only ever forward. The book refuses a backwards move outside a rollback, and
## a duplicate encounter replaying earlier beats must not trip that refusal.
func _record_phase(next: EncounterBook.Phase) -> void:
	if _services == null or source == null:
		return
	if next > _services.encounters.phase_of(source.id):
		_services.encounters.record_phase(source.id, next)

func _phase_name() -> String:
	return EncounterBook.PHASE_NAMES[_phase]

func _tick_emerging(delta_ms: float) -> void:
	if not _blocked:
		if _phase_elapsed_ms >= _tuning().emerging_duration_ms:
			_attempt_spawn_transfer()
		return

	_blocked_retry_elapsed_ms += delta_ms
	_blocked_retell_elapsed_ms += delta_ms
	if _blocked_retell_elapsed_ms >= _tuning().blocked_spawn_retell_ms:
		_blocked_retell_elapsed_ms = 0.0
		_tell_repeat_count += 1
		tell_repeated.emit(&"spawn_blocked")
	if _blocked_retry_elapsed_ms >= _tuning().blocked_spawn_retry_ms:
		_blocked_retry_elapsed_ms = 0.0
		_attempt_spawn_transfer()

# --- spawn ownership -------------------------------------------------------

## The one place ownership can move from scenery to creature.
func _attempt_spawn_transfer() -> void:
	var wanted := spawn_position()
	if _is_clear(wanted):
		_transfer_spawn_ownership(wanted)
		return

	if source.blocked_spawn_policy_index() == EncounterSource.BlockedSpawnPolicy.AUTHORED_FALLBACK:
		if has_authored_fallback():
			var fallback := fallback_spawn_position()
			if _is_clear(fallback):
				_transfer_spawn_ownership(fallback)
				return
		else:
			# Loud every time it matters, not only at bind. The encounter then
			# waits, which is the safe half of the policy; what it must never do
			# is spawn into the blocked space anyway.
			_fail_content("source '%s' needs an authored safe marker to use its fallback and has none; waiting instead of spawning into an occupied space"
				% source.id)
	_begin_blocked_wait(wanted)

func _begin_blocked_wait(blocked_position: Vector2) -> void:
	if _blocked:
		return
	_blocked = true
	_blocked_retry_elapsed_ms = 0.0
	_blocked_retell_elapsed_ms = 0.0
	spawn_blocked.emit(blocked_position, source.blocked_spawn_policy)

## The minimum clearance from the target is checked first and a room's own query
## cannot relax it. Never teleport an active hitbox into Michael.
func _is_clear(at_position: Vector2) -> bool:
	if _has_target and at_position.distance_to(_target_position) < min_spawn_clearance_px:
		return false
	if _clearance_query.is_valid():
		return bool(_clearance_query.call(at_position))
	return true

func _transfer_spawn_ownership(at_position: Vector2) -> void:
	if _actor != null:
		push_error("Encounter '%s': spawn ownership already held by a live actor; refusing to create a second one" % source.id)
		return
	# Built before the one-shot event is spent, so a family that will not load
	# reports a content error instead of silently burning the only transfer this
	# source will ever get.
	var spawned := _instantiate_family_actor()
	if spawned == null:
		return
	# The transfer is itself a one-shot event, so it survives a reload exactly
	# like a reward does. A second live encounter for this source loses here.
	if not _services.ledger.consume(source.spawn_event_id(),
			{"source": String(source.id), "family": String(source.family_id)}):
		spawned.free()
		_forfeit_ownership()
		return
	_actor = spawned
	add_child(_actor)
	_actor.global_position = at_position
	_actor.bind_tuning(_tuning())
	_actor.set_paused(_paused)
	if _has_target:
		_actor.set_target_position(_target_position)
	_blocked = false
	if _pending_stagger_on_spawn:
		_pending_stagger_on_spawn = false
		_actor.stagger(_actor.stagger_s)
	_enter_phase(EncounterBook.Phase.ACTIVE)
	spawn_ownership_transferred.emit(_actor)

## Re-entry after a room unload. The actor this encounter already owns comes
## back; no transfer happens and no reward or spawn event is consumed again.
func _restore_actor() -> void:
	if _actor != null:
		return
	var restored := _instantiate_family_actor()
	if restored == null:
		return
	_actor = restored
	add_child(_actor)
	_actor.global_position = spawn_position()
	_actor.bind_tuning(_tuning())
	_actor.set_paused(_paused)
	if _has_target:
		_actor.set_target_position(_target_position)

func _instantiate_family_actor() -> EnemyActor:
	var path := source.family_scene_path()
	var packed := load(path) as PackedScene
	if packed == null:
		_fail_content("source '%s' names family '%s' whose scene '%s' will not load"
			% [source.id, source.family_id, path])
		return null
	var instance := packed.instantiate() as EnemyActor
	if instance == null:
		_fail_content("family scene '%s' does not instantiate an EnemyActor" % path)
		return null
	instance.name = "FamilyActor"
	return instance

## Another live Encounter already owns this source ID. Present nothing and spawn
## nothing: one encounter, one actor, whatever the staging did.
func _forfeit_ownership() -> void:
	_forfeited = true
	_blocked = false
	_apply_view_visibility()
	_fail_content("source '%s' is owned by another live Encounter; this duplicate forfeits and will not spawn a second actor"
		% source.id)

func _dismiss_actor() -> void:
	if _actor == null:
		return
	var doomed := _actor
	_actor = null
	remove_child(doomed)
	doomed.free()

# --- resolution ------------------------------------------------------------

func _resolve(result_name: String, extra_event_id: StringName, context: Dictionary) -> bool:
	if _phase == EncounterBook.Phase.RESOLVED:
		return false
	_dismiss_actor()
	_result = result_name
	_enter_phase(EncounterBook.Phase.RESOLVED)
	if _services != null:
		var full := context.duplicate(true)
		full["source"] = String(source.id)
		full["result"] = result_name
		_services.encounters.record_result(source.id, result_name)
		if extra_event_id != &"":
			_services.ledger.consume(extra_event_id, full)
		if source.reward_event_id != &"":
			_services.ledger.consume(source.reward_event_id, full)
	resolved.emit(result_name)
	return true

# --- views -----------------------------------------------------------------

func _build_views() -> void:
	if _source_view != null:
		return

	_source_view = SourcePropView.new()
	_source_view.name = "GrayboxSourceProp"
	_source_view.receiver_id = StringName("%s_source" % source.id)
	_source_view.allowed_verbs = source_allowed_verbs.duplicate()
	_source_view.remaining_health = source_prop_health
	_source_view.build_graybox(source.source_type)
	_source_view.destroyed.connect(_on_source_prop_destroyed)
	add_child(_source_view)

	_resolved_view = Polygon2D.new()
	_resolved_view.name = "GrayboxResolvedVisual"
	_resolved_view.polygon = SourcePropView.resolved_graybox_points(source.source_type)
	_resolved_view.color = Color(0.44, 0.42, 0.40)
	_resolved_view.visible = false
	add_child(_resolved_view)

	_apply_view_visibility()

func _apply_view_visibility() -> void:
	var showing := visible_view()
	if _source_view != null:
		_source_view.visible = showing == &"source"
		# The disguised prop stops accepting hits the moment it stops being the
		# encounter's live view, so a spent shell cannot be "destroyed" twice.
		_source_view.interactive = showing == &"source"
	if _resolved_view != null:
		_resolved_view.visible = showing == &"resolved"
	if _actor != null:
		_actor.visible = showing == &"actor"

## Placeholder readability. A tell has to be visible in a graybox build so the
## fairness rule can be judged before any art exists.
func _update_presentation() -> void:
	if _source_view == null or not _source_view.visible:
		return
	var pulse := 0.0
	match _phase:
		EncounterBook.Phase.TELL:
			pulse = 0.25
		EncounterBook.Phase.AWAKENING:
			pulse = 0.45
		EncounterBook.Phase.EMERGING:
			pulse = 0.65
	if pulse <= 0.0:
		_source_view.set_graybox_highlight(0.0)
		return
	var wave := 0.5 + 0.5 * sin(_presentation_clock_ms * 0.012)
	_source_view.set_graybox_highlight(pulse * wave)

func _on_source_prop_destroyed(hit: Hit) -> void:
	resolve_by_collateral(StringName(String(hit.tool_id) if hit.tool_id != &"" else "player"))

# --- helpers ---------------------------------------------------------------

func _tuning() -> Tuning:
	if _services != null and _services.tuning != null:
		return _services.tuning
	return Tuning.new()

## fatal means the authored DATA is unusable, so the encounter stays inert: it
## never spawns, never damages and never resolves. A non-fatal content error is
## still loud and still recorded; it just does not disarm an otherwise valid
## encounter that has a safe behaviour available to it.
func _fail_content(message: String, fatal: bool = false) -> void:
	if fatal:
		_content_valid = false
	_content_errors.append(message)
	push_error("Encounter content error: %s" % message)
	content_error.emit(message)

## The scenery view of the encounter. A HitReceiver like any other, declaring
## the verbs its authored material actually yields to.
class SourcePropView extends HitReceiver:
	signal destroyed(hit: Hit)

	var remaining_health: int = 1
	var _body: Polygon2D

	func _on_hit(hit: Hit) -> bool:
		if remaining_health <= 0:
			return false
		remaining_health -= maxi(1, hit.damage)
		if remaining_health <= 0:
			destroyed.emit(hit)
		return true

	func build_graybox(source_type: StringName) -> void:
		if _body != null:
			return
		_body = Polygon2D.new()
		_body.name = "GrayboxBody"
		_body.polygon = disguised_graybox_points(source_type)
		_body.color = Color(0.58, 0.52, 0.42)
		add_child(_body)

		# SEAM: the authored C0/M0/B0 source art replaces GrayboxBody here. The
		# jar in the background and the first animation frame must be the same
		# export (docs/production/emergence-keyframes.md).
		var seam := Marker2D.new()
		seam.name = "PlaceholderSpriteSeam"
		add_child(seam)

		var shape := RectangleShape2D.new()
		shape.size = Vector2(28, 34)
		var collision := CollisionShape2D.new()
		collision.name = "GrayboxCollision"
		collision.shape = shape
		collision.position = Vector2(0, -17)
		add_child(collision)

	func set_graybox_highlight(amount: float) -> void:
		if _body == null:
			return
		_body.color = Color(0.58, 0.52, 0.42).lightened(clampf(amount, 0.0, 1.0) * 0.5)

	## Distinct disguised silhouettes. PLACEHOLDER GEOMETRY, not art.
	static func disguised_graybox_points(source_type: StringName) -> PackedVector2Array:
		match source_type:
			&"mural":
				return PackedVector2Array([
					Vector2(-16, 0), Vector2(16, 0), Vector2(16, -40), Vector2(-16, -40)])
			&"pit":
				return PackedVector2Array([
					Vector2(-24, 0), Vector2(24, 0), Vector2(20, -6), Vector2(-20, -6)])
			&"door":
				return PackedVector2Array([
					Vector2(-14, 0), Vector2(14, 0), Vector2(14, -46), Vector2(-14, -46)])
			&"inscription":
				return PackedVector2Array([
					Vector2(-20, -8), Vector2(20, -8), Vector2(20, -26), Vector2(-20, -26)])
			_:
				return PackedVector2Array([
					Vector2(-10, 0), Vector2(10, 0), Vector2(13, -18),
					Vector2(8, -30), Vector2(-8, -30), Vector2(-13, -18)])

	static func resolved_graybox_points(source_type: StringName) -> PackedVector2Array:
		match source_type:
			&"mural":
				return PackedVector2Array([
					Vector2(-16, 0), Vector2(16, 0), Vector2(16, -40), Vector2(-16, -40)])
			&"pit":
				return PackedVector2Array([
					Vector2(-24, 0), Vector2(24, 0), Vector2(20, -4), Vector2(-20, -4)])
			_:
				return PackedVector2Array([
					Vector2(-16, 0), Vector2(16, 0), Vector2(11, -9), Vector2(-12, -7)])
