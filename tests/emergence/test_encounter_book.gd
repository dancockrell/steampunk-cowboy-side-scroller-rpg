extends TestCase
## Room re-entry must not duplicate an enemy or re-award its result. That
## property lives in the phase/result record, so it is tested here.

var book: EncounterBook

func before_each() -> void:
	book = EncounterBook.new()

func test_unknown_source_starts_disguised() -> void:
	assert_eq(book.phase_of(&"gallery_jar_01"), EncounterBook.Phase.DISGUISED, "an unseen source is disguised")
	assert_false(book.is_resolved(&"gallery_jar_01"), "an unseen source is not resolved")

func test_phase_advances_and_is_remembered() -> void:
	book.record_phase(&"gallery_jar_01", EncounterBook.Phase.TELL)
	book.record_phase(&"gallery_jar_01", EncounterBook.Phase.ACTIVE)
	assert_eq(book.phase_of(&"gallery_jar_01"), EncounterBook.Phase.ACTIVE, "the latest phase is kept")

func test_phase_does_not_run_backwards_outside_a_rollback() -> void:
	book.record_phase(&"gallery_jar_01", EncounterBook.Phase.RESOLVED)
	book.record_phase(&"gallery_jar_01", EncounterBook.Phase.DISGUISED)
	assert_eq(book.phase_of(&"gallery_jar_01"), EncounterBook.Phase.RESOLVED,
		"a resolved source must stay resolved until a checkpoint rollback restores it")

func test_result_marks_resolved() -> void:
	book.record_result(&"gallery_jar_01", "defeated")
	assert_true(book.is_resolved(&"gallery_jar_01"), "recording a result resolves the source")
	assert_eq(book.result_of(&"gallery_jar_01"), "defeated", "the authored result is kept verbatim")

func test_round_trip_preserves_phase_and_result() -> void:
	book.record_result(&"gallery_jar_01", "recalled")
	book.record_phase(&"hall_mural_01", EncounterBook.Phase.TELL)
	var restored := EncounterBook.new()
	assert_true(restored.restore(book.serialize()), "a well-formed payload restores")
	assert_true(restored.is_resolved(&"gallery_jar_01"), "resolved survives reload")
	assert_eq(restored.result_of(&"gallery_jar_01"), "recalled", "result survives reload")
	assert_eq(restored.phase_of(&"hall_mural_01"), EncounterBook.Phase.TELL, "mid-flight phase survives reload")

func test_rollback_may_restore_an_earlier_phase() -> void:
	var earlier := EncounterBook.new()
	earlier.record_phase(&"gallery_jar_01", EncounterBook.Phase.DISGUISED)
	var snapshot := earlier.serialize()
	book.record_result(&"gallery_jar_01", "defeated")
	assert_true(book.restore(snapshot), "restore accepts the earlier snapshot")
	assert_eq(book.phase_of(&"gallery_jar_01"), EncounterBook.Phase.DISGUISED,
		"a checkpoint rollback is the one way a source returns to an earlier phase")

func test_unknown_phase_name_is_rejected_rather_than_defaulted() -> void:
	assert_false(book.restore({"gallery_jar_01": {"phase": "exploded", "result": ""}}),
		"an unknown enum value must fail validation, not silently default")
