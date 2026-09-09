class_name RelationshipBook
extends RefCounted
## Owns every RelationshipState and applies authored judgments.
##
## The controller applies judgments the heroine actually witnessed. It never
## derives consent from a score: an offer is accepted only through an explicit
## authored choice (docs/relationships.md).

signal judgment_delivered(heroine_id: StringName, event_id: StringName, line: String)
signal arc_changed(heroine_id: StringName, arc: RelationshipState.Arc)
signal romance_changed(heroine_id: StringName, romance: RelationshipState.Romance)

var _heroines: Dictionary = {}
var _states: Dictionary = {}

func register(heroine: Heroine) -> void:
	if heroine == null:
		push_error("RelationshipBook.register: null heroine")
		return
	if _heroines.has(heroine.id):
		push_error("RelationshipBook.register: duplicate heroine id '%s'" % heroine.id)
		return
	_heroines[heroine.id] = heroine
	_states[heroine.id] = RelationshipState.new(heroine.id)

func heroine(id: StringName) -> Heroine:
	return _heroines.get(id)

func state(id: StringName) -> RelationshipState:
	return _states.get(id)

func heroine_ids() -> Array:
	var ids: Array = _heroines.keys()
	ids.sort()
	return ids

## Tells a heroine about a fact. Returns true only when this is new to her, so a
## repeated action produces no further gain and no repeated line.
func witness(heroine_id: StringName, event_id: StringName, context: Dictionary = {}) -> bool:
	var h: Heroine = _heroines.get(heroine_id)
	var s: RelationshipState = _states.get(heroine_id)
	if h == null or s == null:
		push_error("RelationshipBook.witness: unknown heroine '%s'" % heroine_id)
		return false
	if not s.witness(event_id, context):
		return false

	var rule: Dictionary = h.judgment_for(event_id)
	if rule.is_empty():
		# She saw it and has no authored opinion. That is a valid outcome, not an error.
		return true
	s.apply_deltas(rule)
	if s.arc_state == RelationshipState.Arc.ENCOUNTERED:
		_set_arc(s, RelationshipState.Arc.TESTED)
	judgment_delivered.emit(heroine_id, event_id, String(rule["line"]))
	return true

func mark_encountered(heroine_id: StringName) -> void:
	var s: RelationshipState = _states.get(heroine_id)
	if s != null and s.arc_state == RelationshipState.Arc.UNKNOWN:
		_set_arc(s, RelationshipState.Arc.ENCOUNTERED)

## Explicit authored choice. `accepted` false records a refusal that must persist
## across reload and must never block the temple exit.
func resolve_alliance_offer(heroine_id: StringName, accepted: bool) -> void:
	var s: RelationshipState = _states.get(heroine_id)
	if s == null:
		return
	s.alliance_accepted = accepted
	s.set_flag(&"alliance_offer_answered", true)
	s.set_flag(&"alliance_refused", not accepted)
	if accepted:
		_set_arc(s, RelationshipState.Arc.ALLIED)

## Explicit authored choice. A previous yes is not universal future consent, so
## every romance step calls this again rather than reading a threshold.
func resolve_romance_offer(heroine_id: StringName, response: StringName) -> void:
	var s: RelationshipState = _states.get(heroine_id)
	if s == null:
		return
	s.set_flag(&"romance_offer_answered", true)
	match response:
		&"accept":
			_set_romance(s, RelationshipState.Romance.COURTING)
		&"defer":
			_set_romance(s, RelationshipState.Romance.PAUSED)
			s.set_flag(&"romance_deferred", true)
		&"decline":
			_set_romance(s, RelationshipState.Romance.ENDED)
			s.set_flag(&"romance_declined", true)
		_:
			push_error("RelationshipBook: unknown romance response '%s'" % response)

func _set_arc(s: RelationshipState, arc: RelationshipState.Arc) -> void:
	if s.arc_state == arc:
		return
	s.arc_state = arc
	arc_changed.emit(s.heroine_id, arc)

func _set_romance(s: RelationshipState, romance: RelationshipState.Romance) -> void:
	if s.romance_state == romance:
		return
	s.romance_state = romance
	romance_changed.emit(s.heroine_id, romance)

func serialize() -> Array:
	var out: Array = []
	for id: StringName in heroine_ids():
		out.append((_states[id] as RelationshipState).serialize())
	return out

func restore(data: Array) -> bool:
	for entry: Variant in data:
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		var restored := RelationshipState.deserialize(entry as Dictionary)
		if restored == null:
			return false
		if not _heroines.has(restored.heroine_id):
			push_error("RelationshipBook.restore: save names unknown heroine '%s'" % restored.heroine_id)
			return false
		_states[restored.heroine_id] = restored
	return true
