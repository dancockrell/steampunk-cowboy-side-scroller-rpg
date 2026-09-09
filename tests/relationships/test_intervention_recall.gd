extends TestCase
## docs/relationships.md: the intervention "cannot resolve every boss or replace
## the four tools", Michael gets "clear unavailable feedback", and access "may
## require alliance but cannot require romance for the critical route".
##
## The romance one is the load-bearing test: if it ever starts consulting romance
## state, declining the goddess quietly closes the critical route.

const KEEPER := &"keeper_of_the_clay_dead"

var tuning: Tuning
var book: RelationshipBook
var recall: RecallToClay

func before_each() -> void:
	tuning = Tuning.new()
	book = RelationshipBook.new()
	book.register(Heroine.load_from_file("res://narrative/characters/keeper_of_the_clay_dead.json"))
	recall = RecallToClay.new(tuning, book)

func _ally() -> void:
	book.resolve_alliance_offer(KEEPER, true)

func test_without_an_alliance_it_is_unavailable_and_says_why() -> void:
	var state := recall.availability()
	assert_false(bool(state["available"]), "no alliance, no aid")
	assert_eq(String(state["reason"]), RecallToClay.REASON_NO_ALLIANCE,
		"and the refusal is a sentence a player can be shown, not a bare false")

func test_an_alliance_makes_it_available() -> void:
	_ally()
	assert_true(bool(recall.availability()["available"]), "an ally can call on her")

func test_declining_romance_does_not_close_the_critical_route() -> void:
	_ally()
	book.resolve_romance_offer(KEEPER, &"decline")
	assert_true(bool(recall.availability()["available"]),
		"refusing her advances must never cost Michael the intervention")

func test_romance_without_alliance_does_not_grant_it() -> void:
	book.resolve_romance_offer(KEEPER, &"accept")
	assert_false(bool(recall.availability()["available"]),
		"alliance is the gate; romance is not a back door to it")

func test_a_healthy_creature_is_not_eligible() -> void:
	assert_false(recall.is_eligible(EncounterBook.Phase.ACTIVE, 3, 3),
		"the intervention does not replace fighting; the creature must already be weakened")

func test_a_weakened_active_creature_is_eligible() -> void:
	assert_true(recall.is_eligible(EncounterBook.Phase.ACTIVE, 1, 3),
		"a creature worn down to within the authored fraction can be sent home")

func test_a_creature_that_has_not_emerged_yet_is_not_eligible() -> void:
	for phase: EncounterBook.Phase in [EncounterBook.Phase.DISGUISED, EncounterBook.Phase.TELL,
			EncounterBook.Phase.AWAKENING, EncounterBook.Phase.EMERGING]:
		assert_false(recall.is_eligible(phase, 1, 3),
			"recall is not a way to skip an emergence that has not finished")

func test_an_already_resolved_encounter_is_not_eligible() -> void:
	assert_false(recall.is_eligible(EncounterBook.Phase.RESOLVED, 1, 3), "nothing left to send home")

func test_a_dead_creature_is_not_eligible() -> void:
	assert_false(recall.is_eligible(EncounterBook.Phase.ACTIVE, 0, 3), "it is already finished")

func test_uses_are_limited_and_the_refusal_explains_itself() -> void:
	_ally()
	for i in tuning.recall_uses_per_checkpoint:
		recall._uses_remaining -= 1
	var state := recall.availability()
	assert_false(bool(state["available"]), "the charges run out")
	assert_eq(String(state["reason"]), RecallToClay.REASON_NO_USES, "and it says so in words")

func test_a_shrine_restores_the_charges() -> void:
	_ally()
	recall._uses_remaining = 0
	recall.reset_at_checkpoint()
	assert_eq(recall.uses_remaining(), tuning.recall_uses_per_checkpoint,
		"the intervention cannot be permanently spent")
	assert_true(bool(recall.availability()["available"]), "and it is available again")

func test_cooldown_blocks_and_then_expires() -> void:
	_ally()
	recall._cooldown_s = 1.0
	var state := recall.availability()
	assert_false(bool(state["available"]), "it is on cooldown")
	assert_eq(String(state["reason"]), RecallToClay.REASON_COOLDOWN, "with its own distinct reason")
	for i in 70:
		recall.step(1.0 / 60.0)
	assert_true(bool(recall.availability()["available"]), "and it recovers")

func test_no_target_reads_differently_from_no_charges() -> void:
	_ally()
	var state := recall.preview([])
	assert_false(bool(state["available"]), "with nothing eligible nearby it cannot be used")
	assert_eq(String(state["reason"]), RecallToClay.REASON_NO_TARGET,
		"and that reads differently from being out of charges, which is the point of the preview")
	assert_ne(RecallToClay.REASON_NO_TARGET, RecallToClay.REASON_NO_USES, "the two reasons are distinct")

func test_every_refusal_reason_is_a_distinct_sentence() -> void:
	var reasons: Array[String] = [RecallToClay.REASON_NO_ALLIANCE, RecallToClay.REASON_COOLDOWN,
		RecallToClay.REASON_NO_USES, RecallToClay.REASON_NO_TARGET]
	var seen: Array[String] = []
	for reason: String in reasons:
		assert_false(seen.has(reason), "each unavailable state explains itself differently")
		assert_ne(reason, "", "and none of them is blank")
		seen.append(reason)

func test_using_it_on_nothing_costs_no_charge() -> void:
	_ally()
	var before := recall.uses_remaining()
	assert_false(recall.use(null), "there is nothing to recall")
	assert_eq(recall.uses_remaining(), before, "a refused use never costs a charge")
