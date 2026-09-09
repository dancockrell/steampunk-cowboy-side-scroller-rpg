extends TestCase
## docs/relationships.md makes four promises this file checks directly:
## a farmable action gives no unlimited gain, consent is an explicit choice and
## never a threshold, refusal persists, and alliance is separate from romance.

const KEEPER_PATH := "res://narrative/characters/keeper_of_the_clay_dead.json"

var book: RelationshipBook
var keeper: Heroine

func before_each() -> void:
	book = RelationshipBook.new()
	keeper = Heroine.load_from_file(KEEPER_PATH)
	if keeper != null:
		book.register(keeper)

func test_authored_keeper_record_loads() -> void:
	assert_not_null(keeper, "the authored Keeper record must load")
	assert_eq(String(keeper.id), "keeper_of_the_clay_dead", "id matches the file")
	assert_true(keeper.judgment_rules.size() >= 5, "the Keeper has authored opinions to deliver")

func test_a_heroine_record_without_adult_true_is_refused() -> void:
	var bad := Heroine.from_dictionary({
		"id": "test", "adult": false, "display_name": "x", "domain": "x",
		"agenda": "x", "judgment_rules": {},
	})
	assert_null(bad, "every romanceable character is an explicitly adult woman; the loader enforces it")

func test_repeating_a_witnessed_fact_gives_no_further_gain() -> void:
	assert_true(book.witness(&"keeper_of_the_clay_dead", &"urn_preserved"), "the first time is news")
	var after_first: int = book.state(&"keeper_of_the_clay_dead").trust
	assert_false(book.witness(&"keeper_of_the_clay_dead", &"urn_preserved"), "the second time is not news")
	assert_false(book.witness(&"keeper_of_the_clay_dead", &"urn_preserved"), "nor the third")
	assert_eq(book.state(&"keeper_of_the_clay_dead").trust, after_first,
		"a farmable action must not produce unlimited relationship gain")

func test_she_only_reacts_to_what_she_witnessed() -> void:
	var state := book.state(&"keeper_of_the_clay_dead")
	assert_false(state.has_witnessed(&"shrine_destroyed"), "she has not seen it yet")
	assert_eq(state.trust, 0, "an unwitnessed fact changes nothing")

func test_judgment_line_is_delivered_once() -> void:
	var lines: Array[String] = []
	book.judgment_delivered.connect(func(_h: StringName, _e: StringName, line: String) -> void: lines.append(line))
	book.witness(&"keeper_of_the_clay_dead", &"urn_destroyed")
	book.witness(&"keeper_of_the_clay_dead", &"urn_destroyed")
	assert_eq(lines.size(), 1, "she does not repeat a judgment she has already given")

func test_a_witnessed_fact_with_no_authored_rule_is_not_an_error() -> void:
	assert_true(book.witness(&"keeper_of_the_clay_dead", &"stepped_on_a_loose_tile"),
		"she can see something she has no opinion about")
	assert_eq(book.state(&"keeper_of_the_clay_dead").trust, 0, "and it moves nothing")

func test_dimensions_stay_inside_bounds() -> void:
	var state := book.state(&"keeper_of_the_clay_dead")
	state.apply_deltas({"trust": 999})
	assert_eq(state.trust, RelationshipState.DIMENSION_MAX, "trust is clamped at the top")
	state.apply_deltas({"trust": -999})
	assert_eq(state.trust, RelationshipState.DIMENSION_MIN, "and at the bottom")

func test_alliance_and_romance_are_separate_fields() -> void:
	book.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)
	var state := book.state(&"keeper_of_the_clay_dead")
	assert_true(state.alliance_accepted, "alliance was accepted")
	assert_eq(state.romance_state, RelationshipState.Romance.NONE,
		"accepting an alliance does not begin a romance")
	assert_eq(state.arc_state, RelationshipState.Arc.ALLIED, "the arc advances to allied")

func test_high_scores_alone_never_produce_consent() -> void:
	var state := book.state(&"keeper_of_the_clay_dead")
	state.apply_deltas({"trust": 10, "respect": 10, "fascination": 10})
	assert_eq(state.romance_state, RelationshipState.Romance.NONE,
		"consent comes from an explicit authored choice, never from a threshold")

func test_declining_romance_is_recorded_and_does_not_end_the_alliance() -> void:
	book.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)
	book.resolve_romance_offer(&"keeper_of_the_clay_dead", &"decline")
	var state := book.state(&"keeper_of_the_clay_dead")
	assert_eq(state.romance_state, RelationshipState.Romance.ENDED, "the refusal is recorded")
	assert_true(state.alliance_accepted, "and the alliance is untouched by it")

func test_deferring_romance_is_a_distinct_state_from_declining() -> void:
	book.resolve_romance_offer(&"keeper_of_the_clay_dead", &"defer")
	assert_eq(book.state(&"keeper_of_the_clay_dead").romance_state, RelationshipState.Romance.PAUSED,
		"defer is pause, not refusal")

func test_refusing_the_alliance_persists_across_a_reload() -> void:
	book.resolve_alliance_offer(&"keeper_of_the_clay_dead", false)
	var payload := book.serialize()
	var reloaded := RelationshipBook.new()
	reloaded.register(Heroine.load_from_file(KEEPER_PATH))
	assert_true(reloaded.restore(payload), "the payload restores")
	var state := reloaded.state(&"keeper_of_the_clay_dead")
	assert_false(state.alliance_accepted, "a reload cannot quietly un-refuse an offer")
	assert_true(bool(state.flag(&"alliance_refused")), "the refusal itself is recorded, not just the absence of a yes")
	assert_true(bool(state.flag(&"alliance_offer_answered")), "and the offer cannot be re-awarded as unanswered")

func test_witnessed_facts_survive_a_reload_so_judgments_do_not_repeat() -> void:
	book.witness(&"keeper_of_the_clay_dead", &"urn_destroyed")
	var reloaded := RelationshipBook.new()
	reloaded.register(Heroine.load_from_file(KEEPER_PATH))
	reloaded.restore(book.serialize())
	assert_false(reloaded.witness(&"keeper_of_the_clay_dead", &"urn_destroyed"),
		"after a reload she still remembers what she saw")

func test_restore_rejects_a_save_naming_an_unknown_heroine() -> void:
	assert_false(book.restore([{"heroine_id": "a_goddess_who_does_not_exist", "arc_state": "unknown",
		"romance_state": "none", "trust": 0, "respect": 0, "fascination": 0,
		"alliance_accepted": false, "witnessed_event_ids": {}, "choice_flags": {}}]),
		"an unknown heroine id must fail validation rather than silently create a character")
