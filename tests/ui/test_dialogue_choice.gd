extends TestCase
## docs/relationships.md: "Each offer names its conditions and allows accept,
## defer or decline."
##
## The property under test is that the UI cannot present an offer which quietly
## drops one of the three. Dropping decline would make refusal impossible;
## dropping defer would make "not yet" read as "no", and RelationshipBook maps
## those to PAUSED and ENDED, which are not the same future.

func _choice(id: StringName, kind: StringName, text: String) -> DialogueChoice:
	return DialogueChoice.new(id, kind, text)

func _offer() -> Array[DialogueChoice]:
	return [
		_choice(&"accept_alliance", DialogueChoice.ACCEPT, "Stand with you."),
		_choice(&"defer_alliance", DialogueChoice.DEFER, "Let me think."),
		_choice(&"decline_alliance", DialogueChoice.DECLINE, "I walk alone."),
	]

func test_a_complete_offer_is_presentable() -> void:
	assert_eq(DialogueChoice.validation_error(_offer()), "", "accept, defer and decline is a valid offer")

func test_an_offer_missing_decline_is_refused_and_names_what_is_missing() -> void:
	var partial: Array[DialogueChoice] = [
		_choice(&"a", DialogueChoice.ACCEPT, "Yes"),
		_choice(&"d", DialogueChoice.DEFER, "Later"),
	]
	var error := DialogueChoice.validation_error(partial)
	assert_ne(error, "", "an offer the player cannot refuse is not presentable")
	assert_true(error.contains("decline"), "and the error says which response is missing: %s" % error)

func test_an_offer_missing_defer_is_refused() -> void:
	var partial: Array[DialogueChoice] = [
		_choice(&"a", DialogueChoice.ACCEPT, "Yes"),
		_choice(&"n", DialogueChoice.DECLINE, "No"),
	]
	assert_ne(DialogueChoice.validation_error(partial), "",
		"postponement is a valid state and cannot be removed from an offer")

func test_an_offer_cannot_degrade_into_a_single_continue() -> void:
	var mixed: Array[DialogueChoice] = _offer()
	mixed.append(_choice(&"go_on", DialogueChoice.CONTINUE, "Continue"))
	assert_ne(DialogueChoice.validation_error(mixed), "",
		"an offer with a plain continue beside it is the single-button offer the design forbids")

func test_plain_narration_carries_no_choices_and_that_is_valid() -> void:
	var none: Array[DialogueChoice] = []
	assert_eq(DialogueChoice.validation_error(none), "",
		"a line with nothing to answer is advanced, not chosen")

func test_defer_and_decline_read_differently_with_no_colour_at_all() -> void:
	var defer := _choice(&"d", DialogueChoice.DEFER, "Let me think.")
	var decline := _choice(&"n", DialogueChoice.DECLINE, "I walk alone.")
	assert_ne(defer.button_text(), decline.button_text(), "the two refusal-shaped answers differ in text")
	assert_true(defer.button_text().begins_with("NOT YET"), "defer says not yet: %s" % defer.button_text())
	assert_true(decline.button_text().begins_with("NO"), "decline says no: %s" % decline.button_text())

func test_all_three_responses_carry_a_word_before_the_authored_line() -> void:
	for choice: DialogueChoice in _offer():
		assert_ne(String(DialogueChoice.KIND_PREFIX[choice.kind]), "",
			"'%s' is labelled by a word, not by position or colour" % choice.kind)

func test_two_choices_with_one_id_are_refused_because_the_emitted_id_would_be_ambiguous() -> void:
	var clashing: Array[DialogueChoice] = [
		_choice(&"same", DialogueChoice.ACCEPT, "Yes"),
		_choice(&"same", DialogueChoice.DEFER, "Later"),
		_choice(&"other", DialogueChoice.DECLINE, "No"),
	]
	assert_ne(DialogueChoice.validation_error(clashing), "", "duplicate ids are caught before presentation")

func test_a_choice_without_an_id_cannot_be_built() -> void:
	assert_null(DialogueChoice.from_dictionary({"kind": "accept", "text": "Yes"}),
		"a choice that cannot be reported back is refused rather than shown")

func test_a_choice_with_an_invented_kind_cannot_be_built() -> void:
	assert_null(DialogueChoice.from_dictionary({"id": "x", "kind": "maybe", "text": "?"}),
		"an unknown response kind is refused rather than treated as a continue")

func test_the_offer_kinds_are_the_three_the_relationship_book_understands() -> void:
	assert_eq(DialogueChoice.OFFER_KINDS.size(), 3, "three responses, no more and no fewer")
	for kind: StringName in DialogueChoice.OFFER_KINDS:
		assert_true([&"accept", &"defer", &"decline"].has(kind),
			"'%s' is a response RelationshipBook.resolve_romance_offer accepts" % kind)
