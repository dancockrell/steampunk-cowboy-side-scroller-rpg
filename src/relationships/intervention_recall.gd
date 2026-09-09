class_name RecallToClay
extends RefCounted
## The Keeper's slice intervention: return ONE eligible weakened dead creature to
## its vessel, briefly clearing a route (docs/relationships.md).
##
## Three rules from that document shape this class:
##  - It cannot resolve every boss or replace the four tools, so eligibility is
##    narrow and checked here rather than at the call site.
##  - Michael gets a visible preview and CLEAR unavailable feedback, so every
##    refusal returns a reason a HUD can show instead of a bare false.
##  - Access may require alliance but must NOT require romance, or the critical
##    route would depend on a romance the player is free to decline.

signal used(source_id: StringName)
signal availability_changed(available: bool, reason: String)

const REASON_READY := ""
const REASON_NO_ALLIANCE := "The Keeper has not offered you her aid."
const REASON_COOLDOWN := "She is gathering herself."
const REASON_NO_USES := "She will not be called again before the next shrine."
const REASON_NO_TARGET := "Nothing here is weak enough to send home."

var tuning: Tuning
var relationships: RelationshipBook
var heroine_id: StringName = &"keeper_of_the_clay_dead"

var _uses_remaining: int
var _cooldown_s: float = 0.0
var _last_available: bool = false
var _last_reason: String = REASON_NO_ALLIANCE

func _init(p_tuning: Tuning, p_relationships: RelationshipBook) -> void:
	tuning = p_tuning
	relationships = p_relationships
	_uses_remaining = tuning.recall_uses_per_checkpoint

## Alliance only. Romance state is deliberately not consulted anywhere in this
## class, so declining her cannot close the route.
func has_access() -> bool:
	var state := relationships.state(heroine_id) if relationships != null else null
	return state != null and state.alliance_accepted

func uses_remaining() -> int:
	return _uses_remaining

func cooldown_remaining() -> float:
	return _cooldown_s

## Whether the ability itself can be invoked at all, ignoring whether anything
## nearby happens to be a valid target.
func availability() -> Dictionary:
	if not has_access():
		return {"available": false, "reason": REASON_NO_ALLIANCE}
	if _uses_remaining <= 0:
		return {"available": false, "reason": REASON_NO_USES}
	if _cooldown_s > 0.0:
		return {"available": false, "reason": REASON_COOLDOWN}
	return {"available": true, "reason": REASON_READY}

## Eligibility expressed in plain values rather than in terms of an Encounter, so
## the rule can be asserted without building a scene.
func is_eligible(phase: EncounterBook.Phase, health: int, max_health: int) -> bool:
	if phase != EncounterBook.Phase.ACTIVE:
		return false
	if max_health <= 0 or health <= 0:
		return false
	return float(health) <= float(max_health) * tuning.recall_health_fraction

func is_encounter_eligible(encounter: Encounter) -> bool:
	if encounter == null:
		return false
	var actor := encounter.actor()
	if actor == null or actor.is_defeated():
		return false
	return is_eligible(encounter.phase(), actor.health(), actor.max_health)

## Only one major manifestation occupies the action field at a time, so this
## returns the single best target rather than a list to apply to all of them.
func best_target(encounters: Array) -> Encounter:
	var best: Encounter = null
	var best_health := 1 << 30
	for candidate: Variant in encounters:
		var encounter := candidate as Encounter
		if not is_encounter_eligible(encounter):
			continue
		var health := encounter.actor().health()
		if health < best_health:
			best = encounter
			best_health = health
	return best

## Full check including whether a target exists. This is what a HUD preview
## should call, because "no valid target" and "on cooldown" must read
## differently to the player.
func preview(encounters: Array) -> Dictionary:
	var base := availability()
	if not bool(base["available"]):
		return base
	var target := best_target(encounters)
	if target == null:
		return {"available": false, "reason": REASON_NO_TARGET}
	return {"available": true, "reason": REASON_READY, "target": target}

func step(delta: float) -> void:
	if _cooldown_s > 0.0:
		_cooldown_s = maxf(0.0, _cooldown_s - delta)
		if _cooldown_s == 0.0:
			_emit_availability()

## Attempts the intervention. Returns false with no side effect whenever it is
## refused, so a refused use never costs a charge.
func use(encounter: Encounter) -> bool:
	var base := availability()
	if not bool(base["available"]):
		return false
	if not is_encounter_eligible(encounter):
		return false
	if not encounter.resolve_by_recall(heroine_id):
		# The encounter refused. Charge nothing: the creature is still there.
		return false

	_uses_remaining -= 1
	_cooldown_s = tuning.recall_cooldown_ms / 1000.0
	var source_id: StringName = encounter.source.id if encounter.source != null else &""
	# Sending one home rather than finishing it is a fact she has opinions about.
	if relationships != null:
		relationships.witness(heroine_id, &"sentinel_spared_by_recall", {"source": String(source_id)})
	used.emit(source_id)
	_emit_availability()
	return true

## Uses refresh at a safe shrine, which is also where ammunition refreshes, so
## the intervention cannot be permanently spent.
func reset_at_checkpoint() -> void:
	_uses_remaining = tuning.recall_uses_per_checkpoint
	_cooldown_s = 0.0
	_emit_availability()

func _emit_availability() -> void:
	var current := availability()
	var available := bool(current["available"])
	var reason := String(current["reason"])
	if available == _last_available and reason == _last_reason:
		return
	_last_available = available
	_last_reason = reason
	availability_changed.emit(available, reason)
