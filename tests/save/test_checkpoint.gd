extends TestCase
## docs/data-contracts.md: "On failed or unsupported load, keep the previous
## valid save and explain the problem; do not partly restore a room."
## The atomicity half of that promise is the one worth a test.

const KEEPER_PATH := "res://narrative/characters/keeper_of_the_clay_dead.json"

var services: Services

func before_each() -> void:
	services = Services.new()
	services.relationships.register(Heroine.load_from_file(KEEPER_PATH))

func after_each() -> void:
	services.free()

func _sample_snapshot() -> CheckpointSnapshot:
	return services.capture(&"shrine_gallery", &"gallery_of_vessels", &"spawn_shrine",
		{"health": 4, "facing": 1}, {"pistol": 6})

func test_capture_produces_every_required_field() -> void:
	var snapshot := _sample_snapshot()
	assert_not_null(snapshot, "capture returns a snapshot")
	for field: String in CheckpointSnapshot.REQUIRED_FIELDS:
		assert_true(snapshot.data.has(field), "snapshot carries required field %s" % field)
	assert_eq(snapshot.validation_error(), "", "a freshly captured snapshot validates")

func test_snapshot_survives_a_json_round_trip() -> void:
	services.puzzles.declare(&"bridge_counterweight", {"released": false})
	services.puzzles.set_field(&"bridge_counterweight", &"released", true)
	var text := _sample_snapshot().to_json()
	var reloaded := CheckpointSnapshot.from_json(text)
	assert_eq(reloaded.validation_error(), "", "the round-tripped snapshot still validates")
	assert_eq(bool(reloaded.data["puzzle_states"]["bridge_counterweight"]["released"]), true,
		"puzzle state survives serialisation")

func test_restore_reinstates_every_system() -> void:
	services.puzzles.declare(&"bridge_counterweight", {"released": false})
	services.puzzles.set_field(&"bridge_counterweight", &"released", true)
	services.encounters.record_result(&"gallery_jar_01", "defeated")
	services.ledger.consume(&"urn_preserved")
	services.relationships.witness(&"keeper_of_the_clay_dead", &"urn_preserved")
	var snapshot := _sample_snapshot()

	# Play on past the checkpoint, then roll back to it.
	services.encounters.record_result(&"hall_mural_01", "defeated")
	services.ledger.consume(&"shrine_destroyed")

	assert_true(services.restore(snapshot), "the snapshot restores")
	assert_true(services.encounters.is_resolved(&"gallery_jar_01"), "work before the checkpoint is kept")
	assert_false(services.encounters.is_resolved(&"hall_mural_01"), "work after the checkpoint is rolled back")
	assert_false(services.ledger.has_consumed(&"shrine_destroyed"), "so are events after the checkpoint")
	assert_true(services.ledger.has_consumed(&"urn_preserved"), "and events before it are not lost")

func test_reload_cannot_duplicate_a_reward() -> void:
	services.ledger.consume(&"gallery_jar_01_reward")
	var snapshot := _sample_snapshot()
	services.restore(snapshot)
	assert_false(services.ledger.consume(&"gallery_jar_01_reward"),
		"an already-awarded reward stays awarded across a reload")

func test_an_unsupported_schema_version_is_refused_with_a_reason() -> void:
	var snapshot := _sample_snapshot()
	snapshot.data["schema_version"] = 99
	var reason := snapshot.validation_error()
	assert_ne(reason, "", "an unsupported version produces an explanation")
	assert_true(reason.contains("99"), "and the explanation names the offending version: %s" % reason)

func test_a_failed_restore_leaves_the_running_game_untouched() -> void:
	services.encounters.record_result(&"gallery_jar_01", "defeated")
	services.ledger.consume(&"urn_preserved")
	var good := _sample_snapshot()

	# A payload that passes the top-level field check and fails deeper, which is
	# exactly the shape that could half-restore if restore were not atomic.
	var corrupt := CheckpointSnapshot.new(good.data.duplicate(true))
	corrupt.data["encounter_results"] = {"gallery_jar_01": {"phase": "exploded", "result": ""}}
	corrupt.data["puzzle_states"] = {"bridge_counterweight": {"released": true}}

	# Collected through an Array because a GDScript lambda captures locals by
	# value: assigning to a plain local inside the callback never escapes it.
	var reasons: Array[String] = []
	services.restore_failed.connect(func(reason: String) -> void: reasons.append(reason))
	assert_false(services.restore(corrupt), "a corrupt payload is refused")
	assert_eq(reasons.size(), 1, "the refusal is reported exactly once")
	assert_true(reasons.size() > 0 and reasons[0].contains("encounter_results"),
		"and the refusal names what failed: %s" % str(reasons))
	assert_true(services.encounters.is_resolved(&"gallery_jar_01"), "live encounter state is untouched")
	assert_true(services.ledger.has_consumed(&"urn_preserved"), "live ledger is untouched")
	assert_eq(services.puzzles.state_of(&"bridge_counterweight").size(), 0,
		"the valid half of a corrupt payload must NOT be applied; that is what partial restore means")
	assert_eq(services.last_valid_snapshot, good, "the previous valid save is kept")

func test_a_missing_required_field_is_named() -> void:
	var snapshot := _sample_snapshot()
	snapshot.data.erase("ammo_state")
	assert_true(snapshot.validation_error().contains("ammo_state"),
		"the error names the missing field so a player can be told what is wrong")
