extends TestCase
## The ledger is what makes rewards and judgments idempotent, so its
## once-and-only-once property is asserted directly rather than assumed.

var ledger: EventLedger

func before_each() -> void:
	ledger = EventLedger.new()

func test_first_consume_succeeds_and_repeats_do_not() -> void:
	assert_true(ledger.consume(&"urn_preserved"), "first consume must return true")
	assert_false(ledger.consume(&"urn_preserved"), "second consume of the same id must return false")
	assert_false(ledger.consume(&"urn_preserved"), "third consume must also return false")
	assert_eq(ledger.count(), 1, "a repeated event must not grow the ledger")

func test_distinct_ids_are_independent() -> void:
	assert_true(ledger.consume(&"urn_preserved"), "first id")
	assert_true(ledger.consume(&"shrine_destroyed"), "a different id is not blocked by the first")
	assert_eq(ledger.count(), 2, "two distinct facts are two records")

func test_signal_fires_once_per_event() -> void:
	var seen: Array[StringName] = []
	ledger.event_consumed.connect(func(id: StringName, _c: Dictionary) -> void: seen.append(id))
	ledger.consume(&"a")
	ledger.consume(&"a")
	ledger.consume(&"b")
	assert_eq(seen.size(), 2, "the signal must not re-fire for an already consumed event")

func test_round_trip_preserves_consumed_ids() -> void:
	ledger.consume(&"urn_preserved", {"room": "gallery"})
	ledger.consume(&"bridge_crossed_without_breaking")
	var restored := EventLedger.new()
	restored.restore(ledger.serialize())
	assert_eq(restored.count(), 2, "restore must carry both ids")
	assert_true(restored.has_consumed(&"urn_preserved"), "restored ledger knows the first id")
	assert_false(restored.consume(&"urn_preserved"), "a reloaded game cannot re-award a consumed event")
	assert_eq(String(restored.context_for(&"urn_preserved").get("room", "")), "gallery", "context survives the round trip")
