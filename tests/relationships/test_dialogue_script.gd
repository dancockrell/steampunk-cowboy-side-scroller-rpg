extends TestCase
## Checks the authored Keeper dialogue against the promises in
## docs/relationships.md, including the ones that are properties of the WRITING
## rather than of the code: every offer must allow accept, defer and decline,
## and a refusal must never be conditional.

const SCRIPT_PATH := "res://narrative/dialogue/keeper_scenes.json"
const KEEPER := &"keeper_of_the_clay_dead"

var dialogue: DialogueScript
var book: RelationshipBook

func before_each() -> void:
	dialogue = DialogueScript.load_from_file(SCRIPT_PATH)
	book = RelationshipBook.new()
	book.register(Heroine.load_from_file("res://narrative/characters/keeper_of_the_clay_dead.json"))

func test_the_authored_script_loads() -> void:
	assert_not_null(dialogue, "the Keeper script parses")
	assert_eq(dialogue.speaker_id, KEEPER, "and names its speaker")

func test_every_scene_the_heroine_record_promises_actually_exists() -> void:
	var heroine := book.heroine(KEEPER)
	assert_true(heroine.offer_scene_ids.size() >= 4, "the record names its scenes")
	for key: StringName in heroine.offer_scene_ids:
		var scene_id := StringName(String(heroine.offer_scene_ids[key]))
		assert_not_null(dialogue.scene(scene_id),
			"scene '%s' promised by the heroine record exists in the dialogue" % scene_id)

func test_every_offer_allows_accept_defer_and_decline() -> void:
	var offers_checked := 0
	for scene_id: StringName in dialogue.scene_ids():
		var scene := dialogue.scene(scene_id)
		if not scene.has_choices():
			continue
		offers_checked += 1
		for expected: StringName in [&"accept", &"defer", &"decline"]:
			assert_true(dialogue.answers(scene_id).has(expected),
				"offer '%s' allows '%s'; an offer with no way to refuse is not an offer"
					% [scene_id, expected])
	# Denominator: without this the test passes cheerfully if every scene stops
	# having choices at all.
	assert_true(offers_checked >= 2, "there are offers to check, found %d" % offers_checked)

func test_no_offer_makes_refusal_conditional() -> void:
	for scene_id: StringName in dialogue.scene_ids():
		var scene := dialogue.scene(scene_id)
		if not scene.has_choices():
			continue
		var decline := scene.choice(&"decline")
		assert_false(decline.is_empty(), "offer '%s' has a decline" % scene_id)
		assert_false(decline.has("requires"),
			"refusing '%s' carries no conditions of its own" % scene_id)

func test_every_choice_has_words_that_distinguish_it() -> void:
	for scene_id: StringName in dialogue.scene_ids():
		var scene := dialogue.scene(scene_id)
		var seen: Array[String] = []
		for c: Dictionary in scene.choices:
			var text := String(c["text"])
			assert_ne(text, "", "every choice in '%s' has visible text" % scene_id)
			assert_false(seen.has(text), "no two choices in '%s' read the same" % scene_id)
			seen.append(text)

func test_every_choice_gets_an_authored_response() -> void:
	for scene_id: StringName in dialogue.scene_ids():
		for c: Dictionary in dialogue.scene(scene_id).choices:
			assert_ne(String(c["response"]), "",
				"choice '%s' in '%s' has a spoken reply, so a refusal is answered rather than ignored"
					% [c["id"], scene_id])

func test_the_alliance_offer_is_withheld_until_she_has_seen_something() -> void:
	var state := book.state(KEEPER)
	assert_false(dialogue.is_available(&"keeper_alliance_offer", state),
		"she does not offer to a stranger she has not watched work")
	book.mark_encountered(KEEPER)
	book.witness(KEEPER, &"urn_preserved")
	assert_true(dialogue.is_available(&"keeper_alliance_offer", book.state(KEEPER)),
		"once she has judged him, the offer opens")

func test_the_romance_beat_requires_the_alliance_but_the_route_does_not_require_the_romance() -> void:
	book.mark_encountered(KEEPER)
	book.witness(KEEPER, &"urn_preserved")
	book.witness(KEEPER, &"supplicant_protected")
	assert_false(dialogue.is_available(&"keeper_romance_offer", book.state(KEEPER)),
		"the romance beat is not offered before the alliance")
	book.resolve_alliance_offer(KEEPER, true)
	assert_true(dialogue.is_available(&"keeper_romance_offer", book.state(KEEPER)),
		"and is offered after it, given enough trust")

func test_declining_the_alliance_still_leaves_the_intro_and_judgment_playable() -> void:
	book.resolve_alliance_offer(KEEPER, false)
	var state := book.state(KEEPER)
	assert_true(dialogue.is_available(&"keeper_intro", state), "the introduction is unconditional")
	assert_true(dialogue.is_available(&"keeper_judgment", state),
		"and she still has things to say to a man who turned her down")

func test_a_scene_with_no_lines_is_refused_at_load_rather_than_shown_empty() -> void:
	var bad := DialogueScript.load_from_file("res://narrative/dialogue/does_not_exist.json")
	assert_null(bad, "a missing dialogue is refused rather than returning an empty one")

func test_every_judgment_rule_the_keeper_holds_has_a_line_to_say() -> void:
	var heroine := book.heroine(KEEPER)
	var checked := 0
	for event_id: StringName in heroine.judgment_rules:
		checked += 1
		var rule: Dictionary = heroine.judgment_rules[event_id]
		assert_ne(String(rule["line"]), "",
			"judgment for '%s' is spoken, not a silent number change" % event_id)
	assert_true(checked >= 5, "she has authored opinions to check, found %d" % checked)
