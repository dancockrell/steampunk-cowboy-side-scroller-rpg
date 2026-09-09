extends TestCase
## End-to-end through the real scene: a hit lands on a real ToolTarget, the fact
## reaches the PuzzleBook and the Keeper, a shrine captures a checkpoint, and a
## rollback undoes what happened after it.
##
## The unit tests each prove one link. This proves the chain is actually
## connected, which is the thing they cannot tell you.

var main: Main
var room: Room
var player: Player

func before_each() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null or tree == null:
		return
	main = packed.instantiate() as Main
	tree.root.add_child(main)
	main.boot()
	room = main.world_root.room
	player = main.world_root.player
	# UI scenes' @onready lookups need NOTIFICATION_READY, which this harness
	# withholds the same way it withholds _ready generally (see
	# docs/validation/gameplay-checks.md). Main's own wiring is deferred with
	# call_deferred for the same reason, so drive both by hand, mirroring
	# tests/test_boot_smoke.gd's idiom for the identical underlying problem.
	for ui_node: Node in [main.hud, main.dialogue, main.pause_menu]:
		if ui_node != null:
			ui_node.notification(Node.NOTIFICATION_READY)
	if main.dialogue != null:
		main.dialogue.bind(main.services)

func after_each() -> void:
	if main != null and is_instance_valid(main):
		tree.root.remove_child(main)
		main.free()
	main = null
	room = null
	player = null

func _target(node_name: String) -> ToolTarget:
	return room.get_node_or_null(NodePath(node_name)) as ToolTarget

func _hit(tool_id: StringName, verb: StringName) -> Hit:
	var h := Hit.new(tool_id, verb, Vector2.ZERO)
	h.damage = 1
	return h

func test_the_right_tool_moves_a_mechanism_and_the_wrong_one_does_not() -> void:
	var bell := _target("Bell")
	assert_not_null(bell, "the bell exists in the room")
	assert_false(bell.receive(_hit(&"shotgun", Verbs.FORCE_HIT)),
		"a shotgun blast does not ring a bell that asks for a precise shot")
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 0,
		"and the refused hit did not advance the mechanism")
	assert_true(bell.receive(_hit(&"pistol", Verbs.PRECISION_HIT)), "the pistol rings it")
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 1,
		"and the mechanism advanced exactly once")

func test_a_refused_hit_explains_itself_rather_than_doing_nothing_silently() -> void:
	var reasons: Array[String] = []
	var bell := _target("Bell")
	bell.hit_rejected.connect(func(_h: Hit, reason: String) -> void: reasons.append(reason))
	bell.receive(_hit(&"shotgun", Verbs.FORCE_HIT))
	assert_eq(reasons.size(), 1, "the refusal is reported")
	assert_eq(reasons[0], "wrong tool", "with a reason the feedback layer can show")

func test_the_reward_event_fires_once_no_matter_how_often_the_target_is_used() -> void:
	var bell := _target("Bell")
	bell.receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	bell.receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	bell.receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 3,
		"the mechanism counts every use")
	assert_true(main.services.ledger.has_consumed(&"gallery_bell_rung"), "the reward was awarded")
	assert_false(main.services.ledger.consume(&"gallery_bell_rung"),
		"but only once, however many times the bell is rung")

func test_destroying_the_sacred_urn_is_a_fact_the_keeper_witnesses() -> void:
	var urn := _target("SacredUrn") as SacredObject
	assert_not_null(urn, "the sacred urn exists")
	var lines: Array[String] = []
	main.services.relationships.judgment_delivered.connect(
		func(_h: StringName, _e: StringName, line: String) -> void: lines.append(line))

	assert_true(urn.receive(_hit(&"shotgun", Verbs.FORCE_HIT)), "it can be destroyed")
	assert_true(urn.is_destroyed(), "and it records that it was")
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_true(state.has_witnessed(&"urn_destroyed"), "the Keeper saw it happen")
	assert_true(state.trust < 0, "and it cost trust, because she objects to this specifically")
	assert_eq(lines.size(), 1, "she says something about it, exactly once")

func test_preserving_the_urn_is_its_own_fact_not_merely_the_absence_of_breaking_it() -> void:
	room.report_exit_facts()
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_true(state.has_witnessed(&"urn_preserved"),
		"leaving it standing is a positive fact she can respond to")
	assert_true(state.trust > 0, "and it earns credit rather than nothing")

func test_a_destroyed_urn_is_never_also_reported_as_preserved() -> void:
	var urn := _target("SacredUrn") as SacredObject
	urn.receive(_hit(&"shotgun", Verbs.FORCE_HIT))
	room.report_exit_facts()
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_true(state.has_witnessed(&"urn_destroyed"), "she saw the destruction")
	assert_false(state.has_witnessed(&"urn_preserved"),
		"and the room does not also credit him with preserving it")

func test_pulling_the_counterweight_opens_the_gate() -> void:
	var gate := room.get_node_or_null(^"ExitGate") as MechanismGate
	assert_not_null(gate, "the gate exists")
	assert_false(gate.is_open(), "it starts closed")
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	assert_true(gate.is_open(), "pulling the counterweight opens it")

func test_a_checkpoint_rolls_back_everything_that_happened_after_it() -> void:
	main.world_root.save_checkpoint(&"test_checkpoint", player.global_position)
	var urn := _target("SacredUrn") as SacredObject
	urn.receive(_hit(&"shotgun", Verbs.FORCE_HIT))
	_target("Bell").receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	assert_true(urn.is_destroyed(), "the urn was destroyed after the checkpoint")

	assert_true(main.world_root.reload_checkpoint(), "the checkpoint reloads")
	assert_false(urn.is_destroyed(), "and the urn is standing again")
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 0,
		"the bell is back to untouched")
	assert_false(main.services.ledger.has_consumed(&"urn_destroyed"),
		"and the fact itself was rolled back, not left recorded against him")

func test_a_reloaded_room_puts_the_gate_back_where_the_save_says() -> void:
	main.world_root.save_checkpoint(&"test_checkpoint", player.global_position)
	var gate := room.get_node_or_null(^"ExitGate") as MechanismGate
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	assert_true(gate.is_open(), "the gate opened")
	main.world_root.reload_checkpoint()
	assert_false(gate.is_open(), "and a rollback closes it again rather than leaving it open")

func test_progress_made_before_a_checkpoint_survives_the_rollback() -> void:
	_target("Bell").receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	main.world_root.save_checkpoint(&"test_checkpoint", player.global_position)
	_target("StonePlug").receive(_hit(&"shotgun", Verbs.FORCE_HIT))
	main.world_root.reload_checkpoint()
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 1,
		"work done before the checkpoint is kept")
	assert_eq(int(main.services.puzzles.get_field(&"gallery_stone_plug", &"uses", 0)), 0,
		"work done after it is not")

func test_the_shrine_refills_a_spent_magazine() -> void:
	var machine := player.tools.machine
	machine.request_switch(&"pistol")
	machine.request_use()
	assert_true(machine.loaded(&"pistol") < main.services.tuning.pistol_magazine, "a round was spent")
	var shrine := room.get_node_or_null(^"Shrine") as CheckpointShrine
	assert_not_null(shrine, "the entry shrine exists")
	shrine._on_body_entered(player)
	assert_eq(machine.loaded(&"pistol"), main.services.tuning.pistol_magazine,
		"a shrine tops the tools back up, so critical ammunition cannot be exhausted for good")

func test_the_shrine_captures_a_checkpoint_the_game_can_actually_reload() -> void:
	var shrine := room.get_node_or_null(^"Shrine") as CheckpointShrine
	shrine._on_body_entered(player)
	assert_not_null(main.services.last_valid_snapshot, "the shrine captured a snapshot")
	assert_eq(main.services.last_valid_snapshot.validation_error(), "", "and it is a valid one")
	assert_true(main.world_root.reload_checkpoint(), "and the game can reload it")

func test_a_mechanism_can_always_be_reset() -> void:
	var plug := _target("StonePlug")
	plug.receive(_hit(&"shotgun", Verbs.FORCE_HIT))
	assert_eq(int(main.services.puzzles.get_field(&"gallery_stone_plug", &"uses", 0)), 1, "it moved")
	plug.reset_mechanism()
	assert_eq(int(main.services.puzzles.get_field(&"gallery_stone_plug", &"uses", 0)), 0,
		"a critical mechanism can always be returned to its start state")
	assert_true(plug.interactive, "and it is interactive again")

# --- the encounter placed in this room, end to end ------------------------

func _encounter() -> Encounter:
	return room.get_node_or_null(^"JarEncounter") as Encounter

## Runs the encounter forward until it reaches ACTIVE or the budget expires.
func _advance_to_active(limit_s: float = 12.0) -> bool:
	var e := _encounter()
	var elapsed := 0.0
	while e.phase() != EncounterBook.Phase.ACTIVE and elapsed < limit_s:
		e.advance(1.0 / 60.0)
		elapsed += 1.0 / 60.0
	return e.phase() == EncounterBook.Phase.ACTIVE

func test_the_authored_jar_encounter_has_valid_content() -> void:
	var e := _encounter()
	assert_not_null(e, "the room contains the ceramic encounter")
	assert_true(e.is_content_valid(),
		"its authored source validates: %s" % str(e.content_errors()))
	assert_eq(e.phase(), EncounterBook.Phase.DISGUISED, "and it starts as scenery")

func test_the_jar_becomes_exactly_one_creature() -> void:
	var e := _encounter()
	# Well outside min_spawn_clearance_px of the jar at x=640: the encounter
	# correctly refuses to spawn a hitbox on top of Michael.
	e.set_target_position(Vector2(480, 288))
	assert_true(e.trigger(), "the tell starts")
	assert_true(_advance_to_active(), "and it reaches active, phase is %s"
		% EncounterBook.PHASE_NAMES[e.phase()])
	assert_eq(e.actor_count(), 1, "exactly one actor exists, counted as real children")
	assert_not_null(e.actor(), "and the encounter owns it")

func test_re_triggering_does_not_produce_a_second_creature() -> void:
	var e := _encounter()
	# Well outside min_spawn_clearance_px of the jar at x=640: the encounter
	# correctly refuses to spawn a hitbox on top of Michael.
	e.set_target_position(Vector2(480, 288))
	e.trigger()
	_advance_to_active()
	e.trigger()
	e.advance(1.0 / 60.0)
	assert_eq(e.actor_count(), 1, "one encounter can never own two actors")

func test_recall_actually_runs_end_to_end_and_the_keeper_notices() -> void:
	var e := _encounter()
	# Well outside min_spawn_clearance_px of the jar at x=640: the encounter
	# correctly refuses to spawn a hitbox on top of Michael.
	e.set_target_position(Vector2(480, 288))
	e.trigger()
	assert_true(_advance_to_active(), "the sentinel is up")

	var recall := RecallToClay.new(main.services.tuning, main.services.relationships)
	main.services.relationships.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)

	var actor := e.actor()
	assert_false(recall.is_encounter_eligible(e), "a fresh sentinel is not eligible")

	# Wear it down the way the player would, through a real hit on its hurtbox.
	while actor.health() > 1:
		var hit := Hit.new(&"pistol", Verbs.PRECISION_HIT, Vector2.ZERO)
		hit.damage = 1
		actor.hurtbox().receive(hit)
	assert_true(recall.is_encounter_eligible(e), "worn down, it can be sent home")

	assert_true(recall.use(e), "the intervention runs")
	assert_eq(e.result(), Encounter.RESULT_RECALLED,
		"and being recalled is its own result, not the same as being killed")
	assert_eq(e.actor_count(), 0, "the creature is gone")
	assert_true(main.services.relationships.state(&"keeper_of_the_clay_dead")
		.has_witnessed(&"sentinel_spared_by_recall"), "and she saw Michael choose it")

func test_recall_spends_a_charge_only_when_it_succeeds() -> void:
	var e := _encounter()
	# Well outside min_spawn_clearance_px of the jar at x=640: the encounter
	# correctly refuses to spawn a hitbox on top of Michael.
	e.set_target_position(Vector2(480, 288))
	e.trigger()
	_advance_to_active()
	var recall := RecallToClay.new(main.services.tuning, main.services.relationships)
	main.services.relationships.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)
	var before := recall.uses_remaining()
	assert_false(recall.use(e), "a healthy sentinel refuses the recall")
	assert_eq(recall.uses_remaining(), before, "and the refused attempt costs nothing")

# --- Keeper dialogue in the real room, end to end --------------------------

func _keeper_npc() -> HeroineNpc:
	return room.get_node_or_null(^"KeeperNpc") as HeroineNpc

func test_the_keeper_npc_exists_and_is_bound() -> void:
	var npc := _keeper_npc()
	assert_not_null(npc, "the Keeper stands in the Gallery of Vessels")
	assert_not_null(npc.player, "and she is wired to the dialogue player")

func test_first_interaction_plays_the_introduction() -> void:
	var npc := _keeper_npc()
	npc._offer_next_scene()
	assert_true(main.dialogue_player.is_playing(), "a scene starts")
	assert_eq(main.dialogue.speaker_text(), "The Keeper of the Clay Dead", "and it is spoken by her")
	assert_eq(main.services.relationships.state(&"keeper_of_the_clay_dead").arc_state,
		RelationshipState.Arc.ENCOUNTERED, "meeting her at all advances the arc")

## Advances through every non-final line of the current offer, leaving it
## sitting on the line where choices are shown, without answering it.
func _advance_to_choices() -> void:
	var scene := main.dialogue_player._current_scene
	if scene == null:
		return
	for i in scene.lines.size() - 1:
		main.dialogue.advanced.emit()

func _finish_current_scene() -> void:
	var e := main.dialogue_player._current_scene
	for i in e.lines.size():
		if main.dialogue_player.is_playing():
			main.dialogue.advanced.emit()

func test_declining_the_alliance_through_real_dialogue_is_recorded() -> void:
	var npc := _keeper_npc()
	npc._offer_next_scene()
	_finish_current_scene()

	main.services.relationships.witness(&"keeper_of_the_clay_dead", &"urn_preserved")
	npc._offer_next_scene()
	assert_true(main.dialogue_player.is_playing(), "the alliance offer opens once she has judged him")
	_advance_to_choices()
	assert_eq(main.dialogue.choice_ids(), [&"accept", &"defer", &"decline"],
		"all three answers are on screen")

	main.dialogue.choice_made.emit(&"decline")
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_false(state.alliance_accepted, "declining through the real UI is recorded")
	assert_true(bool(state.flag(&"alliance_refused")), "as an explicit refusal, not silence")

func test_accepting_the_alliance_through_real_dialogue_reaches_the_book() -> void:
	var npc := _keeper_npc()
	npc._offer_next_scene()
	_finish_current_scene()
	main.services.relationships.witness(&"keeper_of_the_clay_dead", &"urn_preserved")
	npc._offer_next_scene()
	_advance_to_choices()
	main.dialogue.choice_made.emit(&"accept")
	assert_true(main.services.relationships.state(&"keeper_of_the_clay_dead").alliance_accepted,
		"accepting through the real dialogue UI reaches the RelationshipBook, not just the script")
	assert_true(main.services.relationships.state(&"keeper_of_the_clay_dead").flag(&"alliance_offer_answered"),
		"and the offer is marked answered so it does not repeat")

func test_a_refused_alliance_still_leaves_judgment_playable() -> void:
	var npc := _keeper_npc()
	npc._offer_next_scene()
	_finish_current_scene()
	main.services.relationships.witness(&"keeper_of_the_clay_dead", &"urn_preserved")
	npc._offer_next_scene()
	_advance_to_choices()
	main.dialogue.choice_made.emit(&"decline")
	npc._offer_next_scene()
	assert_true(main.dialogue_player.is_playing(),
		"she still has something to say to a man who turned her down")
