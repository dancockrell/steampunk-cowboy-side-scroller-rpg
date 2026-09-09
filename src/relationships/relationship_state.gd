class_name RelationshipState
extends RefCounted
## Per-heroine arc state. Fields follow docs/data-contracts.md.
##
## Alliance and romance are separate fields on purpose: a blessing can follow a
## non-romantic alliance, and refusal is a valid state that cannot soft-lock the
## temple (docs/relationships.md).

enum Arc { UNKNOWN, ENCOUNTERED, TESTED, ALLIED }
enum Romance { NONE, INTERESTED, COURTING, INTIMATE, PAUSED, ENDED }

const ARC_NAMES: Array[String] = ["unknown", "encountered", "tested", "allied"]
const ROMANCE_NAMES: Array[String] = ["none", "interested", "courting", "intimate", "paused", "ended"]

## The floor is deliberately BELOW the starting value. With a floor of 0 and a
## start of 0, every negative judgment clamped away to nothing and she could not
## think worse of Michael than neutral, which contradicts the pillar that she is
## allowed to disagree. Range is a small bounded tuning proposal, not approved.
const DIMENSION_MIN := -5
const DIMENSION_MAX := 10

var heroine_id: StringName
var arc_state: Arc = Arc.UNKNOWN
var romance_state: Romance = Romance.NONE
var alliance_accepted: bool = false
var trust: int = 0
var respect: int = 0
var fascination: int = 0

## Unique. A fact witnessed twice is still one fact, which is what stops a
## farmable action from producing unlimited relationship gain.
var witnessed_event_ids: Dictionary = {}
var choice_flags: Dictionary = {}

func _init(id: StringName = &"") -> void:
	heroine_id = id

func has_witnessed(event_id: StringName) -> bool:
	return witnessed_event_ids.has(event_id)

## Records a witnessed fact. Returns false if she already knew it, so the caller
## can tell "she reacts" from "nothing new happened".
func witness(event_id: StringName, context: Dictionary = {}) -> bool:
	if witnessed_event_ids.has(event_id):
		return false
	witnessed_event_ids[event_id] = context.duplicate(true)
	return true

func apply_deltas(deltas: Dictionary) -> void:
	trust = clampi(trust + int(deltas.get("trust", 0)), DIMENSION_MIN, DIMENSION_MAX)
	respect = clampi(respect + int(deltas.get("respect", 0)), DIMENSION_MIN, DIMENSION_MAX)
	fascination = clampi(fascination + int(deltas.get("fascination", 0)), DIMENSION_MIN, DIMENSION_MAX)

func set_flag(flag: StringName, value: Variant = true) -> void:
	choice_flags[flag] = value

func flag(name: StringName, default_value: Variant = false) -> Variant:
	return choice_flags.get(name, default_value)

func arc_name() -> String:
	return ARC_NAMES[arc_state]

func romance_name() -> String:
	return ROMANCE_NAMES[romance_state]

func serialize() -> Dictionary:
	var witnessed: Dictionary = {}
	for id: StringName in witnessed_event_ids:
		witnessed[String(id)] = witnessed_event_ids[id]
	var flags: Dictionary = {}
	for f: StringName in choice_flags:
		flags[String(f)] = choice_flags[f]
	return {
		"heroine_id": String(heroine_id),
		"arc_state": arc_name(),
		"romance_state": romance_name(),
		"alliance_accepted": alliance_accepted,
		"trust": trust,
		"respect": respect,
		"fascination": fascination,
		"witnessed_event_ids": witnessed,
		"choice_flags": flags,
	}

static func deserialize(data: Dictionary) -> RelationshipState:
	var state := RelationshipState.new(StringName(String(data.get("heroine_id", ""))))
	var arc_index: int = ARC_NAMES.find(String(data.get("arc_state", "unknown")))
	var romance_index: int = ROMANCE_NAMES.find(String(data.get("romance_state", "none")))
	if arc_index < 0 or romance_index < 0:
		push_error("RelationshipState.deserialize: unknown enum value in save data")
		return null
	state.arc_state = arc_index as Arc
	state.romance_state = romance_index as Romance
	state.alliance_accepted = bool(data.get("alliance_accepted", false))
	state.trust = int(data.get("trust", 0))
	state.respect = int(data.get("respect", 0))
	state.fascination = int(data.get("fascination", 0))
	for key: String in data.get("witnessed_event_ids", {}):
		state.witnessed_event_ids[StringName(key)] = data["witnessed_event_ids"][key]
	for key: String in data.get("choice_flags", {}):
		state.choice_flags[StringName(key)] = data["choice_flags"][key]
	return state
