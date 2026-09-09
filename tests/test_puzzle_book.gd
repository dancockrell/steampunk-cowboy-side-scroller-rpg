extends TestCase
## A critical mechanism can always be reset (docs/gameplay-pillars.md), so the
## reset path is asserted rather than left to the level author to remember.

var book: PuzzleBook

func before_each() -> void:
	book = PuzzleBook.new()
	book.declare(&"bridge_counterweight", {"released": false, "uses": 0})

func test_declare_installs_the_default_state() -> void:
	assert_eq(bool(book.get_field(&"bridge_counterweight", &"released")), false, "starts unreleased")

func test_redeclaring_does_not_wipe_progress() -> void:
	book.set_field(&"bridge_counterweight", &"released", true)
	book.declare(&"bridge_counterweight", {"released": false, "uses": 0})
	assert_eq(bool(book.get_field(&"bridge_counterweight", &"released")), true,
		"re-entering a room must not silently reset a solved mechanism")

func test_reset_returns_a_mechanism_to_its_authored_start() -> void:
	book.set_field(&"bridge_counterweight", &"released", true)
	book.set_field(&"bridge_counterweight", &"uses", 3)
	book.reset(&"bridge_counterweight")
	assert_eq(bool(book.get_field(&"bridge_counterweight", &"released")), false, "released is reset")
	assert_eq(int(book.get_field(&"bridge_counterweight", &"uses")), 0, "so is every other field")

func test_reset_after_a_restore_uses_the_authored_default_not_the_saved_value() -> void:
	book.set_field(&"bridge_counterweight", &"released", true)
	var reloaded := PuzzleBook.new()
	reloaded.declare(&"bridge_counterweight", {"released": false, "uses": 0})
	reloaded.restore(book.serialize())
	assert_eq(bool(reloaded.get_field(&"bridge_counterweight", &"released")), true, "saved progress is restored")
	reloaded.reset(&"bridge_counterweight")
	assert_eq(bool(reloaded.get_field(&"bridge_counterweight", &"released")), false,
		"reset means the authored start state, not the last saved state")

func test_round_trip_preserves_state() -> void:
	book.set_field(&"bridge_counterweight", &"uses", 2)
	var reloaded := PuzzleBook.new()
	assert_true(reloaded.restore(book.serialize()), "payload restores")
	assert_eq(int(reloaded.get_field(&"bridge_counterweight", &"uses")), 2, "field survives")
