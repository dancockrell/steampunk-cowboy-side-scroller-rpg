class_name DialogueChoice
extends RefCounted
## One option in a dialogue, and the rule about what a valid set of them is.
##
## docs/relationships.md: "Each offer names its conditions and allows accept,
## defer or decline." So an offer is not allowed to degrade into a single
## "continue" button, and it is not allowed to present two of the three. That is
## a structural rule, so it lives here as a validator the Dialogue scene calls
## before it will show anything, rather than as an instruction in a comment that
## an author has to remember.
##
## Defer and decline are separate kinds on purpose. RelationshipBook maps them to
## PAUSED and ENDED, which are different states with different consequences; a UI
## that collapsed them would quietly make refusal unrecoverable.

const CONTINUE := &"continue"
const ACCEPT := &"accept"
const DEFER := &"defer"
const DECLINE := &"decline"

## The three responses an offer must carry, in the order they are presented.
const OFFER_KINDS: Array[StringName] = [ACCEPT, DEFER, DECLINE]
const ALL_KINDS: Array[StringName] = [CONTINUE, ACCEPT, DEFER, DECLINE]

## Shown before the option text so the three responses are told apart without
## colour (docs/gameplay-pillars.md: tells that do not rely on colour alone).
const KIND_PREFIX: Dictionary = {
	CONTINUE: "",
	ACCEPT: "YES - ",
	DEFER: "NOT YET - ",
	DECLINE: "NO - ",
}

var id: StringName
var kind: StringName
var text: String

func _init(choice_id: StringName = &"", choice_kind: StringName = CONTINUE, choice_text: String = "") -> void:
	id = choice_id
	kind = choice_kind
	text = choice_text

static func from_dictionary(data: Dictionary) -> DialogueChoice:
	var kind := StringName(String(data.get("kind", CONTINUE)))
	if not ALL_KINDS.has(kind):
		push_error("DialogueChoice: unknown kind '%s'. Refusing to build the choice." % kind)
		return null
	var id := StringName(String(data.get("id", "")))
	if id == &"":
		push_error("DialogueChoice: a choice without an id cannot be reported back. Refused.")
		return null
	return DialogueChoice.new(id, kind, String(data.get("text", "")))

## The label a player reads. The prefix is the part that survives losing colour.
func button_text() -> String:
	return "%s%s" % [String(KIND_PREFIX.get(kind, "")), text]

func is_offer_response() -> bool:
	return OFFER_KINDS.has(kind)

## Returns "" when the set is presentable, or the reason it is not. An empty set
## is valid: that is plain narration advanced with the dialogue_advance action.
static func validation_error(choices: Array[DialogueChoice]) -> String:
	if choices.is_empty():
		return ""
	var seen_ids: Dictionary = {}
	var present_kinds: Dictionary = {}
	for choice: DialogueChoice in choices:
		if choice == null:
			return "a choice failed to build"
		if seen_ids.has(choice.id):
			return "duplicate choice id '%s'; the emitted id would be ambiguous" % choice.id
		seen_ids[choice.id] = true
		present_kinds[choice.kind] = true

	var offer_kinds_present: int = 0
	for kind: StringName in OFFER_KINDS:
		if present_kinds.has(kind):
			offer_kinds_present += 1
	if offer_kinds_present == 0:
		return ""
	if offer_kinds_present < OFFER_KINDS.size():
		var missing: PackedStringArray = PackedStringArray()
		for kind: StringName in OFFER_KINDS:
			if not present_kinds.has(kind):
				missing.append(String(kind))
		return "an offer must allow accept, defer and decline; missing %s" % ", ".join(missing)
	if present_kinds.has(CONTINUE):
		return "an offer cannot also present a plain continue; that is the single-button offer the design forbids"
	return ""

static func build_list(entries: Array) -> Array[DialogueChoice]:
	var out: Array[DialogueChoice] = []
	for entry: Variant in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			push_error("DialogueChoice.build_list: entry is not a dictionary")
			continue
		var choice := from_dictionary(entry as Dictionary)
		if choice != null:
			out.append(choice)
	return out
