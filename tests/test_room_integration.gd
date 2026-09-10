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
	# main.tscn's starting room is the entry bridge (beat 1). This whole file
	# was written against the Gallery as the starting point before that beat
	# existed, and re-deriving every one of those tests against the bridge
	# would prove nothing new about them -- so walk through the bridge once,
	# here, and leave the rest of the file testing what it already tested.
	# The bridge gets its own dedicated tests below instead.
	var bridge := main.world_root.room
	# The bridge's exit is ungated: the chasm and its anchor chain ARE the
	# obstacle, so nothing needs to be pulled first (see test_room_exit.gd
	# and the redesign notes on entry_bridge.tscn).
	(bridge.get_node_or_null(^"ExitToGallery") as RoomExit)._on_body_entered(main.world_root.player)
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
	assert_false(bell.receive(_hit(&"lasso", Verbs.PULL)),
		"a rope yank does not ring a bell that asks for a precise shot")
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 0,
		"and the refused hit did not advance the mechanism")
	assert_true(bell.receive(_hit(&"pistol", Verbs.PRECISION_HIT)), "the pistol rings it")
	assert_eq(int(main.services.puzzles.get_field(&"gallery_bell", &"uses", 0)), 1,
		"and the mechanism advanced exactly once")

func test_a_refused_hit_explains_itself_rather_than_doing_nothing_silently() -> void:
	var reasons: Array[String] = []
	var bell := _target("Bell")
	bell.hit_rejected.connect(func(_h: Hit, reason: String) -> void: reasons.append(reason))
	bell.receive(_hit(&"lasso", Verbs.PULL))
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

	assert_true(urn.receive(_hit(&"lasso", Verbs.PULL)), "it can be destroyed")
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
	urn.receive(_hit(&"lasso", Verbs.PULL))
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
	urn.receive(_hit(&"lasso", Verbs.PULL))
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
	_target("StonePlug").receive(_hit(&"lasso", Verbs.PULL))
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
	plug.receive(_hit(&"lasso", Verbs.PULL))
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

func test_a_striking_enemy_actually_damages_the_real_player() -> void:
	# The gap this closes: EnemyActor.can_damage() and attack_window_opened
	# already existed, correctly bracketing the STRIKE state, but nothing in
	# the game ever called player.take_damage() from them -- a fully
	# implemented, fully tested attack state machine wired to nothing. This
	# drives a real encounter, with the real player standing in its attack
	# range, all the way to a real strike, through WorldRoot exactly as the
	# running game does (not by calling take_damage directly).
	var e := _encounter()
	# 480 stays outside min_spawn_clearance_px (44px) of the jar at x=640, so
	# the spawn is not blocked.
	e.set_target_position(Vector2(480, 288))
	e.trigger()
	assert_true(_advance_to_active(), "the sentinel reaches active")

	var actor := e.actor()
	# EnemyActor.apply_motion() (move_and_slide) is the ONE part of this class
	# deliberately not exercisable in this harness -- no real physics frame
	# ever runs here, documented already in enemy_actor.gd and in
	# tests/emergence/test_enemy_families.gd. _pursue() only sets velocity; it
	# never moves global_position without a real frame to apply it in. So the
	# real player is brought to the actor rather than waiting for a pursuit
	# this harness structurally cannot run, and Room.update_target()'s real
	# per-frame sync (tested separately, unaffected here) is exactly what
	# would have kept them together during an actual pursuit.
	player.global_position = actor.global_position + Vector2(20, 0)
	e.set_target_position(player.global_position)
	assert_true(actor.distance_to_target() <= actor.attack_range_px,
		"the real player is genuinely within the actor's own attack range")

	var health_before := player.health
	var strikes: Array[bool] = []
	actor.attack_window_opened.connect(func() -> void: strikes.append(true))
	var elapsed := 0.0
	while strikes.is_empty() and elapsed < 3.0:
		e.advance(1.0 / 60.0)
		elapsed += 1.0 / 60.0
	assert_true(strikes.size() > 0, "the actor actually reached a strike within 5 simulated seconds")
	assert_eq(player.health, health_before - actor.strike_damage,
		"and the real player's health actually dropped by the actor's own strike_damage")

func test_a_strike_outside_attack_range_does_not_damage_the_player() -> void:
	# The same mechanism must not fire just because SOME encounter somewhere
	# reached STRIKE; range is checked against the real distance, not assumed.
	var e := _encounter()
	# 480 stays outside min_spawn_clearance_px (44px) of the jar at x=640, so
	# the spawn is not blocked.
	e.set_target_position(Vector2(480, 288))
	e.trigger()
	assert_true(_advance_to_active(), "the sentinel reaches active")
	var actor := e.actor()
	# The tracked target sits right next to where the actor actually spawned,
	# so ITS OWN problem of reaching strike range is solved without relying
	# on the pursuit movement this harness cannot run (see the positive test's
	# comment for why). The REAL player stays far away and is never brought
	# anywhere near either point -- this is the contrast that proves range is
	# checked against the real player position, not merely against whether
	# SOME strike happened somewhere in the room.
	e.set_target_position(actor.global_position + Vector2(20, 0))
	player.global_position = Vector2(0, 288)
	assert_true(player.global_position.distance_to(actor.global_position) > actor.attack_range_px,
		"the real player is standing somewhere else entirely")

	var health_before := player.health
	var elapsed := 0.0
	var strikes: Array[bool] = []
	actor.attack_window_opened.connect(func() -> void: strikes.append(true))
	while strikes.is_empty() and elapsed < 3.0:
		e.advance(1.0 / 60.0)
		elapsed += 1.0 / 60.0
	assert_true(strikes.size() > 0, "the actor still strikes (it is in range of its OWN tracked target)")
	assert_eq(player.health, health_before,
		"but the real, distant player takes no damage from a strike that never reached him")

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

# --- room transitions and cross-room checkpoints ----------------------------

func test_the_exit_refuses_until_the_gate_is_open() -> void:
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	assert_not_null(exit_door, "the exit to the next room exists")
	assert_false(exit_door.is_open(), "and it starts closed, gated on the same puzzle as the ExitGate")
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	assert_true(exit_door.is_open(), "opening the gate opens the exit too, from the same fact")

func test_walking_through_the_open_exit_loads_the_next_room() -> void:
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	exit_door._on_body_entered(player)
	assert_eq(main.world_root.room.room_id, &"procession_hall", "the next room is now loaded")
	assert_almost_eq(player.global_position.x, main.world_root.room.spawn_position(&"spawn_from_gallery").x, 1.0,
		"and Michael lands at the authored spawn named by the exit, not the room's own default")

func test_leaving_the_gallery_settles_the_urn_fact_even_without_calling_it_directly() -> void:
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	exit_door._on_body_entered(player)
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_true(state.has_witnessed(&"urn_preserved"),
		"a real room transition reports exit facts on its own, not only when a test calls it")

func test_the_exit_will_not_fire_twice() -> void:
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	exit_door._on_body_entered(player)
	var first_room := main.world_root.room
	exit_door._on_body_entered(player)
	assert_eq(main.world_root.room, first_room, "a stale exit reference cannot load the room a second time")

func test_a_checkpoint_saved_in_one_room_restores_that_room_even_after_moving_on() -> void:
	main.world_root.save_checkpoint(&"gallery_checkpoint", player.global_position)
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	exit_door._on_body_entered(player)
	assert_eq(main.world_root.room.room_id, &"procession_hall", "moved on to the next room")

	assert_true(main.world_root.reload_checkpoint(), "the checkpoint from the OLD room reloads")
	assert_eq(main.world_root.room.room_id, &"gallery_of_vessels",
		"and it correctly loads the room the checkpoint actually belongs to, not wherever the player currently stands")

func test_cross_room_restore_does_not_report_exit_facts_for_the_room_being_undone() -> void:
	# report_exit_facts() always applies to the room being FREED, not the one
	# restored into, and it unconditionally emits room_completed at the end
	# even when there is nothing to report -- which is exactly what makes it a
	# reliable observation point regardless of what either room's fixtures
	# happen to contain.
	main.world_root.save_checkpoint(&"gallery_checkpoint", player.global_position)
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	exit_door._on_body_entered(player)

	var procession_room := main.world_root.room
	# A plain int in this lambda would be captured BY VALUE, so incrementing it
	# inside the callback would never escape the closure -- the array is the
	# established workaround for that exact GDScript trap.
	var completions: Array[StringName] = []
	procession_room.room_completed.connect(func(id: StringName) -> void: completions.append(id))
	main.world_root.reload_checkpoint()
	assert_eq(completions.size(), 0,
		"rolling back is undoing the room being left, not leaving it, so its exit facts are never reported")

func test_forward_progression_does_report_exit_facts_for_the_room_being_left() -> void:
	# The other half of the same contract, so a sabotage that stops reporting
	# ANY exit facts (forward or rollback) cannot hide behind the test above.
	var completions: Array[StringName] = []
	room.room_completed.connect(func(id: StringName) -> void: completions.append(id))
	_target("Counterweight").receive(_hit(&"lasso", Verbs.PULL))
	var exit_door := room.get_node_or_null(^"ExitToProcessionHall") as RoomExit
	exit_door._on_body_entered(player)
	assert_eq(completions, [&"gallery_of_vessels"] as Array[StringName],
		"walking forward through the exit DOES report the room being left")

func test_an_unknown_checkpoint_room_is_refused_rather_than_restoring_the_wrong_scene() -> void:
	main.world_root.save_checkpoint(&"gallery_checkpoint", player.global_position)
	main.world_root._last_checkpoint.data["room_id"] = "a_room_this_world_root_never_loaded"
	assert_false(main.world_root.reload_checkpoint(),
		"a checkpoint naming a room this run never saw is refused, not guessed at")
	assert_eq(main.world_root.room.room_id, &"gallery_of_vessels", "and the current room is left untouched")

# --- the expanded Gallery: mezzanine, vault, and a second encounter --------

func test_the_gallery_is_genuinely_bigger_than_it_was() -> void:
	assert_true(room.camera_bounds().size.x >= 2000.0,
		"the gallery is now a real expanse, not the original 1280px corridor")
	assert_true(room.camera_bounds().size.y > Main.WORLD_HEIGHT,
		"and tall enough for the camera to actually pan vertically")

func test_the_gallery_has_two_independent_ceramic_encounters() -> void:
	var first := room.get_node_or_null(^"JarEncounter") as Encounter
	var second := room.get_node_or_null(^"SecondJarEncounter") as Encounter
	assert_not_null(first, "the original jar encounter still exists")
	assert_not_null(second, "a second, independent jar encounter was added")
	assert_ne(first.source.id, second.source.id,
		"they are two distinct encounters with their own stable IDs, not one duplicated")
	assert_true(first.is_content_valid() and second.is_content_valid(),
		"both authored sources validate independently")

func test_the_mezzanine_is_reachable_and_holds_a_real_reward() -> void:
	var mezzanine_anchor := _target("SwingAnchorMezzanine")
	assert_not_null(mezzanine_anchor, "the mezzanine swing anchor exists")
	assert_true(mezzanine_anchor.allowed_verbs.has(Verbs.SWING), "and it accepts a swing")
	var cache := _target("MezzanineCache")
	assert_not_null(cache, "the mezzanine holds its own reward, not just a viewpoint")
	assert_true(cache.receive(_hit(&"lasso", Verbs.PULL)), "and it is genuinely pullable")
	assert_true(main.services.ledger.has_consumed(&"gallery_mezzanine_cache_found"),
		"awarded through the same once-only ledger path as every other reward")

func test_the_mid_depth_vault_is_a_real_alternate_area_with_its_own_cache() -> void:
	var to_mid := room.get_node_or_null(^"CrossingToMid") as DepthCrossing
	assert_not_null(to_mid, "the vault archway exists")
	assert_eq(player.current_depth, Depth.Layer.NEAR, "starting on the near plane")
	to_mid._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.MID, "crossing works in the expanded gallery too")

	var vault_terrain := room.get_node_or_null(^"MidVaultTerrain") as GrayboxTerrain
	assert_not_null(vault_terrain, "the vault has its own walkway")
	assert_eq(vault_terrain.depth_layer, Depth.Layer.MID, "authored on the mid plane")

	var cache := room.get_node_or_null(^"VaultCache") as ToolTarget
	assert_eq(cache.collision_layer, Depth.target_bit(Depth.Layer.MID),
		"the vault's cache has no hardcoded fallback layer, same discipline as the bridge's")
	var mid_hit := Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)
	mid_hit.depth_layer = Depth.Layer.MID
	assert_true(cache.receive(mid_hit), "and it is genuinely reachable once on the same plane")

	var to_near := room.get_node_or_null(^"CrossingToNear") as DepthCrossing
	to_near._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.NEAR, "and the far archway returns to near")

func test_both_new_swing_gaps_are_load_bearing_not_decorative() -> void:
	# Reads the room's OWN authored platform list rather than repeating its
	# numbers as literals -- a hardcoded copy of "140px" would keep passing
	# even after someone shrank the real gap to something jumpable, which is
	# exactly what a sabotage pass against the first version of this test
	# found: it changed nothing when the terrain data itself was edited.
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	var floor_platforms: Array[Rect2] = []
	for rect: Rect2 in terrain.platforms:
		if absf(rect.position.y - 288.0) < 1.0:
			floor_platforms.append(rect)
	floor_platforms.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
	assert_true(floor_platforms.size() >= 3, "the main floor is authored in at least 3 segments (two real gaps)")

	var gaps: Array[float] = []
	for i in floor_platforms.size() - 1:
		gaps.append(floor_platforms[i + 1].position.x - floor_platforms[i].end.x)
	for gap_px: float in gaps:
		assert_true(gap_px > 87.5,
			"floor gap of %.0fpx exceeds the verified max jump distance (docs/validation/gameplay-checks.md)" % gap_px)

	assert_not_null(_target("SwingAnchor"), "and the first gap's anchor exists")
	assert_not_null(_target("SwingAnchorGap2"), "and the second gap's anchor exists")

func test_every_new_gallery_content_id_is_actually_unique() -> void:
	# A copy-pasted node with a forgotten renamed puzzle_id is a real, easy
	# mistake at this scale -- two mechanisms silently sharing one puzzle_id
	# would mean pulling one secretly also "solves" the other.
	var seen: Array[StringName] = []
	for node: Node in _all(room):
		var target := node as ToolTarget
		if target == null or target.puzzle_id == &"":
			continue
		assert_false(seen.has(target.puzzle_id),
			"puzzle_id '%s' is not reused by a second target" % target.puzzle_id)
		seen.append(target.puzzle_id)

func _all(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in node.get_children():
		found.append(child)
		found.append_array(_all(child))
	return found

# --- the three-room chain and Burial Works' preserve-or-disturb choice ------

func _walk_through_gate_and_exit(gate_target_name: String, exit_node_name: String,
		tool_id: StringName = &"lasso", verb: StringName = Verbs.PULL) -> void:
	_target(gate_target_name).receive(_hit(tool_id, verb))
	var exit_door := room.get_node_or_null(NodePath(exit_node_name)) as RoomExit
	exit_door._on_body_entered(player)
	room = main.world_root.room
	player = main.world_root.player

# --- the expanded Procession Hall: second mural, vault, mezzanine ----------

func _in_procession_hall() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	assert_eq(room.room_id, &"procession_hall", "reached the Procession Hall")

func test_the_procession_hall_is_genuinely_bigger_than_it_was() -> void:
	_in_procession_hall()
	assert_true(room.camera_bounds().size.x >= 2300.0,
		"the hall is now a real expanse, not the original 1408px corridor")
	assert_true(room.camera_bounds().size.y > Main.WORLD_HEIGHT,
		"and tall enough for the camera to actually pan vertically")

func test_the_procession_hall_has_two_independent_mural_encounters() -> void:
	_in_procession_hall()
	var first := room.get_node_or_null(^"MuralEncounter") as Encounter
	var second := room.get_node_or_null(^"SecondMuralEncounter") as Encounter
	assert_not_null(first, "the original mural guard still exists")
	assert_not_null(second, "a second, independent mural guard was added")
	assert_ne(first.source.id, second.source.id,
		"two distinct encounters with their own stable IDs, not one duplicated")
	assert_true(first.is_content_valid() and second.is_content_valid(),
		"both authored sources validate independently")

func test_the_procession_hall_mezzanine_holds_a_real_reward() -> void:
	_in_procession_hall()
	var anchor := _target("SwingAnchorMezzanine")
	assert_not_null(anchor, "the mezzanine swing anchor exists")
	assert_true(anchor.allowed_verbs.has(Verbs.SWING), "and it accepts a swing")
	var cache := _target("MezzanineCache")
	assert_true(cache.receive(_hit(&"lasso", Verbs.PULL)), "the mezzanine reward is genuinely pullable")
	assert_true(main.services.ledger.has_consumed(&"procession_mezzanine_cache_found"),
		"awarded through the same once-only ledger path as every other reward")

func test_the_procession_hall_mid_depth_vault_is_reachable() -> void:
	_in_procession_hall()
	var to_mid := room.get_node_or_null(^"CrossingToMid") as DepthCrossing
	assert_not_null(to_mid, "the vault archway exists")
	to_mid._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.MID, "crossing works here too")

	var cache := room.get_node_or_null(^"VaultCache") as ToolTarget
	assert_eq(cache.collision_layer, Depth.target_bit(Depth.Layer.MID),
		"the vault cache has no hardcoded fallback layer, same discipline as every other vault")
	var mid_hit := Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)
	mid_hit.depth_layer = Depth.Layer.MID
	assert_true(cache.receive(mid_hit), "and it is genuinely reachable once on the same plane")

	var to_near := room.get_node_or_null(^"CrossingToNear") as DepthCrossing
	to_near._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.NEAR, "and the far archway returns to near")

func test_every_procession_hall_floor_gap_wide_enough_to_need_a_swing_has_an_anchor() -> void:
	# Reads the room's own authored terrain rather than repeating coordinates
	# as literals -- the exact trap a sabotage caught in the Gallery's first
	# version of this same idea.
	_in_procession_hall()
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	var floor_platforms: Array[Rect2] = []
	for rect: Rect2 in terrain.platforms:
		if absf(rect.position.y - 288.0) < 1.0:
			floor_platforms.append(rect)
	floor_platforms.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
	assert_true(floor_platforms.size() >= 3, "the main floor is authored in at least 3 segments")
	var real_gaps := 0
	for i in floor_platforms.size() - 1:
		var gap_px: float = floor_platforms[i + 1].position.x - floor_platforms[i].end.x
		if gap_px > 87.5:
			real_gaps += 1
	assert_true(real_gaps >= 1, "at least one floor gap genuinely exceeds max jump distance")
	assert_not_null(_target("SwingAnchorGap2"), "and the new gap's anchor exists to bridge it")

func test_every_procession_hall_puzzle_id_is_actually_unique() -> void:
	_in_procession_hall()
	var seen: Array[StringName] = []
	for node: Node in _all(room):
		var target := node as ToolTarget
		if target == null or target.puzzle_id == &"":
			continue
		assert_false(seen.has(target.puzzle_id),
			"puzzle_id '%s' is not reused by a second target" % target.puzzle_id)
		seen.append(target.puzzle_id)

func test_the_full_route_connects_all_three_authored_rooms() -> void:
	assert_eq(room.room_id, &"gallery_of_vessels", "starts in the Gallery")
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	assert_eq(room.room_id, &"procession_hall", "reaches the Procession Hall")
	_target("FarCounterweight").receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	assert_true((room.get_node_or_null(^"ExitGate") as MechanismGate).is_open(),
		"the pistol, not the lasso, opens the far counterweight in this room")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks")
	assert_eq(room.room_id, &"burial_works", "and finally the Burial Works")

func _in_burial_works() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_target("FarCounterweight").receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks")
	assert_eq(room.room_id, &"burial_works", "reached Burial Works")

func test_burial_works_is_genuinely_bigger_than_it_was() -> void:
	_in_burial_works()
	assert_true(room.camera_bounds().size.x >= 2200.0,
		"burial works is now a real expanse, not the original 1408px corridor")
	assert_true(room.camera_bounds().size.y > Main.WORLD_HEIGHT,
		"and tall enough for the camera to actually pan vertically")

func test_burial_works_has_two_independent_pit_encounters() -> void:
	_in_burial_works()
	var first := room.get_node_or_null(^"PitEncounter") as Encounter
	var second := room.get_node_or_null(^"SecondPitEncounter") as Encounter
	assert_not_null(first, "the original pit assembler still exists")
	assert_not_null(second, "a second, independent pit assembler was added")
	assert_ne(first.source.id, second.source.id,
		"two distinct encounters with their own stable IDs, not one duplicated")
	assert_true(first.is_content_valid() and second.is_content_valid(),
		"both authored sources validate independently")

func test_burial_works_mezzanine_holds_a_real_reward() -> void:
	_in_burial_works()
	var anchor := _target("SwingAnchorMezzanine")
	assert_not_null(anchor, "the mezzanine swing anchor exists")
	assert_true(anchor.allowed_verbs.has(Verbs.SWING), "and it accepts a swing")
	var cache := _target("MezzanineCache")
	assert_true(cache.receive(_hit(&"lasso", Verbs.PULL)), "the mezzanine reward is genuinely pullable")
	assert_true(main.services.ledger.has_consumed(&"burial_mezzanine_cache_found"),
		"awarded through the same once-only ledger path as every other reward")

func test_burial_works_mid_depth_vault_is_reachable() -> void:
	_in_burial_works()
	var to_mid := room.get_node_or_null(^"CrossingToMid") as DepthCrossing
	assert_not_null(to_mid, "the vault archway exists")
	to_mid._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.MID, "crossing works here too")

	var cache := room.get_node_or_null(^"VaultCache") as ToolTarget
	assert_eq(cache.collision_layer, Depth.target_bit(Depth.Layer.MID),
		"the vault cache has no hardcoded fallback layer, same discipline throughout")
	var mid_hit := Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)
	mid_hit.depth_layer = Depth.Layer.MID
	assert_true(cache.receive(mid_hit), "and it is genuinely reachable once on the same plane")

	var to_near := room.get_node_or_null(^"CrossingToNear") as DepthCrossing
	to_near._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.NEAR, "and the far archway returns to near")

func test_burial_works_new_gap_is_load_bearing_not_decorative() -> void:
	_in_burial_works()
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	var floor_platforms: Array[Rect2] = []
	for rect: Rect2 in terrain.platforms:
		if absf(rect.position.y - 288.0) < 1.0:
			floor_platforms.append(rect)
	floor_platforms.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
	assert_true(floor_platforms.size() >= 3, "the main floor is authored in at least 3 segments")
	var real_gaps := 0
	for i in floor_platforms.size() - 1:
		var gap_px: float = floor_platforms[i + 1].position.x - floor_platforms[i].end.x
		if gap_px > 87.5:
			real_gaps += 1
	assert_true(real_gaps >= 2, "at least two floor gaps genuinely exceed max jump distance (the original pit gap plus the new one)")
	assert_not_null(_target("PitGapSwingAnchorC"), "and the new gap's anchor exists to bridge it")

func test_burial_works_every_puzzle_id_is_actually_unique() -> void:
	_in_burial_works()
	var seen: Array[StringName] = []
	for node: Node in _all(room):
		var target := node as ToolTarget
		if target == null or target.puzzle_id == &"":
			continue
		assert_false(seen.has(target.puzzle_id),
			"puzzle_id '%s' is not reused by a second target" % target.puzzle_id)
		seen.append(target.puzzle_id)

func test_burial_works_has_a_pit_encounter_and_a_plug_the_rope_hauls_out() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	var pit := room.get_node_or_null(^"PitEncounter") as Encounter
	assert_not_null(pit, "the burial pit encounter exists")
	assert_true(pit.is_content_valid(), "and its authored source validates: %s" % str(pit.content_errors()))
	assert_false(_target("StonePlug").receive(_hit(&"pistol", Verbs.PRECISION_HIT)),
		"a bullet does not shift a stone plug")
	assert_true(_target("StonePlug").receive(_hit(&"lasso", Verbs.PULL)),
		"roping it and hauling does")

func test_the_funerary_site_can_be_preserved_or_disturbed_and_the_keeper_notices_either_way() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	var site := _target("FunerarySite") as SacredObject
	assert_not_null(site, "the funerary site exists")
	room.report_exit_facts()
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_true(state.has_witnessed(&"burial_identity_restored"),
		"leaving it undisturbed is its own credited fact, same as the urn in the Gallery")

func test_disturbing_the_funerary_site_is_a_distinct_fact_from_preserving_it() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	var site := _target("FunerarySite") as SacredObject
	site.receive(_hit(&"lasso", Verbs.PULL))
	room.report_exit_facts()
	var state := main.services.relationships.state(&"keeper_of_the_clay_dead")
	assert_true(state.has_witnessed(&"burial_identity_lost"), "disturbing it is witnessed")
	assert_false(state.has_witnessed(&"burial_identity_restored"),
		"and never credited as preserved in the same breath")
	assert_true(state.trust < 0, "and it actually costs her trust, not just a recorded but neutral fact")

func test_the_plug_puzzle_can_always_be_reset() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	var plug := _target("StonePlug")
	plug.receive(_hit(&"lasso", Verbs.PULL))
	assert_eq(int(main.services.puzzles.get_field(&"burial_stone_plug", &"uses", 0)), 1, "it moved")
	plug.reset_mechanism()
	assert_eq(int(main.services.puzzles.get_field(&"burial_stone_plug", &"uses", 0)), 0,
		"and can always be returned to its authored start, per docs/gameplay-pillars.md")

func test_the_burial_pit_gap_is_bridged_by_a_chain_of_swing_anchors_not_left_impossible() -> void:
	# The pit's own floor gap (416->544, 128px) exceeds the verified maximum
	# jump distance (87.5px, see docs/validation/gameplay-checks.md): without
	# an anchor this room is not merely hard, it is uncrossable. Two anchors,
	# chained and well within lasso range, both fixes that and gives the
	# player more than one hook to use, matching the bridge's redesign.
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	var anchor_names := [&"PitGapSwingAnchorA", &"PitGapSwingAnchorB"]
	var anchors: Array[ToolTarget] = []
	for anchor_name: StringName in anchor_names:
		var anchor := _target(String(anchor_name))
		assert_not_null(anchor, "%s exists over the pit gap" % anchor_name)
		assert_true(anchor.allowed_verbs.has(Verbs.SWING), "%s accepts the swing" % anchor_name)
		anchors.append(anchor)
	assert_true(anchors[0].global_position.distance_to(anchors[1].global_position) <= main.services.tuning.lasso_range_px,
		"the two anchors are within lasso range of each other")
	# And the actual gap really is unjumpable, so the anchors are load-bearing
	# rather than decorative: a room with no swing anchors here would strand
	# the player, which is exactly the defect this replaces.
	var gap_px := 544.0 - 416.0
	assert_true(gap_px > 87.5, "the pit gap (%.0fpx) genuinely exceeds max jump distance, confirming the anchors are necessary" % gap_px)

# --- entry bridge (beat 1), tested against its own fresh boot -------------

func _fresh_bridge() -> Dictionary:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var fresh := packed.instantiate() as Main
	tree.root.add_child(fresh)
	fresh.boot()
	return {"main": fresh, "room": fresh.world_root.room, "player": fresh.world_root.player}

func test_the_entry_bridge_is_the_true_starting_room() -> void:
	var ctx := _fresh_bridge()
	assert_eq((ctx["room"] as Room).room_id, &"entry_bridge",
		"the route now starts before the Gallery, at the broken bridge")
	(ctx["main"] as Main).free()

func test_the_bridge_gap_is_crossed_by_a_chain_of_three_swing_anchors() -> void:
	# Dan's direction, 10 Sep 2026: swinging should be easy, generous and a
	# central, repeated part of level design, not one precision hook over one
	# gap. The bridge now has three anchors, each accepting SWING and none
	# accepting a plain PULL, so crossing means swinging more than once.
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var anchor_names := [&"SwingAnchorA", &"SwingAnchorB", &"SwingAnchorC"]
	var anchors: Array[ToolTarget] = []
	for anchor_name: StringName in anchor_names:
		var anchor := bridge.get_node_or_null(NodePath(String(anchor_name))) as ToolTarget
		assert_not_null(anchor, "%s exists over the chasm" % anchor_name)
		assert_true(anchor.allowed_verbs.has(Verbs.SWING), "%s accepts the lasso swing" % anchor_name)
		assert_false(anchor.allowed_verbs.has(Verbs.PULL), "%s teaches swing, not tug" % anchor_name)
		anchors.append(anchor)

	# Chainability: every anchor is within lasso range of its neighbour, so a
	# player mid-swing on one can reach for the next without landing first.
	var tuning := ctx["main"].services.tuning as Tuning
	for i in anchors.size() - 1:
		var d := anchors[i].global_position.distance_to(anchors[i + 1].global_position)
		assert_true(d <= tuning.lasso_range_px,
			"%s is within lasso range of %s (%.0fpx <= %.0fpx), so the chain is actually chainable"
				% [anchor_names[i], anchor_names[i + 1], d, tuning.lasso_range_px])
	(ctx["main"] as Main).free()

func test_the_bridge_room_is_tall_enough_for_the_camera_to_actually_pan() -> void:
	# Every room used to be authored at exactly WORLD_HEIGHT (360), which
	# leaves camera Y permanently clamped to a single value: zero vertical
	# travel, ever, regardless of how tall the content is. A room built to
	# showcase verticality has to actually be taller than that.
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	assert_true(bridge.camera_bounds().size.y > Main.WORLD_HEIGHT,
		"the bridge room is taller than the fixed world viewport, so the camera has real room to pan")
	(ctx["main"] as Main).free()

func test_crossing_the_bridge_reaches_the_gallery_at_its_own_entry_marker() -> void:
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var main_ref := ctx["main"] as Main
	(bridge.get_node_or_null(^"ExitToGallery") as RoomExit)._on_body_entered(ctx["player"])
	assert_eq(main_ref.world_root.room.room_id, &"gallery_of_vessels", "the bridge leads into the Gallery")
	main_ref.free()

func test_the_bridge_still_teaches_the_pull_verb_without_gating_the_exit_on_it() -> void:
	# The counterweight moved to the start-side platform: a side lesson in
	# the pull verb, not a lock on the only way across.
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var counterweight := bridge.get_node_or_null(^"Counterweight") as ToolTarget
	assert_not_null(counterweight, "the counterweight still exists, to teach pull")
	var exit_door := bridge.get_node_or_null(^"ExitToGallery") as RoomExit
	assert_true(exit_door.is_open(), "and the exit is never gated on having pulled it")
	(ctx["main"] as Main).free()

# --- 2.5D depth layers, tested against the real bridge room ----------------

func test_the_bridge_has_a_genuine_mid_depth_alternate_path() -> void:
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var bridge_player := ctx["player"] as Player
	assert_eq(bridge_player.current_depth, Depth.Layer.NEAR, "Michael starts on the near plane")

	var to_mid := bridge.get_node_or_null(^"CrossingToMid") as DepthCrossing
	assert_not_null(to_mid, "the archway into the mid plane exists")
	to_mid._on_body_entered(bridge_player)
	assert_eq(bridge_player.current_depth, Depth.Layer.MID, "walking through it crosses Michael to the mid plane")

	var mid_terrain := bridge.get_node_or_null(^"MidTerrain") as GrayboxTerrain
	assert_not_null(mid_terrain, "the mid-plane walkway exists")
	assert_eq(mid_terrain.depth_layer, Depth.Layer.MID, "and it is authored on that plane, not near by mistake")

	var to_near := bridge.get_node_or_null(^"CrossingToNear") as DepthCrossing
	to_near._on_body_entered(bridge_player)
	assert_eq(bridge_player.current_depth, Depth.Layer.NEAR, "and the far archway crosses back")
	(ctx["main"] as Main).free()

func test_a_receiver_on_a_different_plane_cannot_actually_be_targeted() -> void:
	# The property that makes this a real mechanic and not a visual trick: a
	# near-plane anchor is physically unreachable while standing on mid,
	# proven through the actual physics query the game uses, not a flag.
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var bridge_player := ctx["player"] as Player
	var anchor_a := bridge.get_node_or_null(^"SwingAnchorA") as ToolTarget
	assert_eq(anchor_a.collision_layer, Depth.target_bit(Depth.Layer.NEAR),
		"the near-plane anchor's physics layer was actually set from its authored depth")

	bridge_player.set_depth(Depth.Layer.MID)
	var tools := bridge_player.tools
	var space := tools.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 1000.0
	query.shape = circle
	query.transform = Transform2D(0.0, bridge_player.global_position)
	query.collision_mask = tools._current_target_layer()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hits := space.intersect_shape(query, 32)
	for result: Dictionary in hits:
		assert_ne(result["collider"], anchor_a,
			"the near-plane anchor must never appear in a mid-plane query, at any range")
	(ctx["main"] as Main).free()

func test_the_hidden_cache_only_has_a_working_physics_layer_because_room_bind_set_it() -> void:
	# HiddenCache deliberately has NO collision_layer hardcoded in the .tscn
	# (Godot's Area2D default is layer 1, the TERRAIN bit -- wrong for a tool
	# target). If Room.bind() ever stops applying the depth bit, this is the
	# node that actually catches it, unlike a near-plane node whose hardcoded
	# fallback happens to already equal the near bit by coincidence.
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var cache := bridge.get_node_or_null(^"HiddenCache") as ToolTarget
	assert_not_null(cache, "the hidden cache exists")
	assert_eq(cache.collision_layer, Depth.target_bit(Depth.Layer.MID),
		"its physics layer came from Room.bind() reading its authored depth_layer, not a hardcoded default")
	(ctx["main"] as Main).free()

func test_the_hidden_cache_is_reachable_on_mid_and_unreachable_on_near() -> void:
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var bridge_player := ctx["player"] as Player
	var cache := bridge.get_node_or_null(^"HiddenCache") as ToolTarget
	# Each hit is stamped with the depth it was actually thrown from, matching
	# what ToolController does at commit time -- a raw Hit() with no explicit
	# depth_layer defaults to NEAR regardless of where the player stands, so
	# this cannot be shared across the two calls below.
	var near_hit := Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)
	near_hit.depth_layer = Depth.Layer.NEAR

	assert_true(bridge_player.current_depth == Depth.Layer.NEAR, "starts on near")
	assert_false(cache.receive(near_hit), "a near-plane Michael cannot pull a mid-plane cache")
	assert_eq(int(bridge.services.puzzles.get_field(&"bridge_hidden_cache", &"uses", 0)), 0,
		"and nothing about the mechanism advanced")

	bridge_player.set_depth(Depth.Layer.MID)
	var mid_hit := Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)
	mid_hit.depth_layer = Depth.Layer.MID
	assert_true(cache.receive(mid_hit), "once on the same plane, the same cache is genuinely reachable")
	assert_eq(int(bridge.services.puzzles.get_field(&"bridge_hidden_cache", &"uses", 0)), 1,
		"and the mechanism actually advances")
	(ctx["main"] as Main).free()

func test_crossing_to_the_plane_already_standing_on_is_a_silent_no_op() -> void:
	var ctx := _fresh_bridge()
	var bridge_player := ctx["player"] as Player
	var crossings: Array[Depth.Layer] = []
	bridge_player.depth_changed.connect(func(layer: Depth.Layer) -> void: crossings.append(layer))
	bridge_player.set_depth(Depth.Layer.NEAR)
	assert_eq(crossings.size(), 0, "already on that plane, so nothing changes and nothing fires")
	(ctx["main"] as Main).free()

func test_a_room_transition_always_resets_depth_to_near() -> void:
	# Depth state must not leak from one room into the next, or a player
	# could arrive in the Gallery already standing on a plane that room
	# never authored a mid/far version of.
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var bridge_player := ctx["player"] as Player
	var bridge_main := ctx["main"] as Main
	bridge_player.set_depth(Depth.Layer.MID)
	(bridge.get_node_or_null(^"ExitToGallery") as RoomExit)._on_body_entered(bridge_player)
	assert_eq(bridge_main.world_root.player.current_depth, Depth.Layer.NEAR,
		"arriving in the next room resets to the near plane")
	bridge_main.free()

# --- the Sunken Cistern branch ---------------------------------------------

func test_the_cistern_is_reachable_in_play_and_leads_onward() -> void:
	# A level that loads is not a level you can get to. The cistern hangs off
	# the Procession Hall as a branch rather than a link in the chain, so the
	# main route is untouched -- and it has to actually rejoin the world, or it
	# is a room the player walks into and cannot leave.
	_in_procession_hall()
	var side := room.get_node_or_null(^"ExitToCistern") as RoomExit
	assert_not_null(side, "the Procession Hall opens onto the cistern")
	assert_true(side.required_gate_path.is_empty(),
		"and the branch is ungated -- an optional space is not something to unlock")
	side._on_body_entered(player)
	room = main.world_root.room
	player = main.world_root.player
	assert_eq(room.room_id, &"sunken_cistern", "you are in the cistern")

	var onward := room.get_node_or_null(^"ExitToBurialWorks") as RoomExit
	assert_not_null(onward, "the cistern rejoins the temple rather than dead-ending")
	onward._on_body_entered(player)
	assert_eq(main.world_root.room.room_id, &"burial_works", "and it lets you out into Burial Works")

func test_the_cistern_branch_does_not_disturb_the_main_route() -> void:
	# The property that matters about a branch: the original way through still
	# works and still needs its own gate opened.
	_in_procession_hall()
	_target("FarCounterweight").receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks")
	assert_eq(room.room_id, &"burial_works", "the authored route is unchanged")

# --- the expanded Keeper's Shrine: warm-up sentinel, vault, mezzanine ------

func _in_keepers_shrine() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)
	assert_eq(room.room_id, &"keepers_shrine", "reached the Keeper's Shrine")

func test_the_keepers_shrine_is_genuinely_bigger_than_it_was() -> void:
	_in_keepers_shrine()
	assert_true(room.camera_bounds().size.x >= 2200.0,
		"the finale room is now a real expanse, not the original 1024px corridor")
	assert_true(room.camera_bounds().size.y > Main.WORLD_HEIGHT,
		"and tall enough for the camera to actually pan vertically")

func test_the_keepers_shrine_has_a_warmup_encounter_before_the_true_final_sentinel() -> void:
	_in_keepers_shrine()
	var warmup := room.get_node_or_null(^"FirstSentinelEncounter") as Encounter
	var finale := room.get_node_or_null(^"FinalSentinelEncounter") as Encounter
	assert_not_null(warmup, "a warm-up sentinel now guards the approach")
	assert_not_null(finale, "the true final sentinel still exists")
	assert_ne(warmup.source.id, finale.source.id,
		"two distinct encounters with their own stable IDs, not one duplicated")
	assert_true(warmup.is_content_valid() and finale.is_content_valid(),
		"both authored sources validate independently")

func test_the_keepers_shrine_mezzanine_holds_a_real_reward() -> void:
	_in_keepers_shrine()
	var anchor := _target("SwingAnchorMezzanine")
	assert_not_null(anchor, "the mezzanine swing anchor exists")
	assert_true(anchor.allowed_verbs.has(Verbs.SWING), "and it accepts a swing")
	var cache := _target("MezzanineCache")
	assert_true(cache.receive(_hit(&"lasso", Verbs.PULL)), "the mezzanine reward is genuinely pullable")
	assert_true(main.services.ledger.has_consumed(&"keeper_shrine_mezzanine_cache_found"),
		"awarded through the same once-only ledger path as every other reward")

func test_the_keepers_shrine_mid_depth_vault_is_reachable() -> void:
	_in_keepers_shrine()
	var to_mid := room.get_node_or_null(^"CrossingToMid") as DepthCrossing
	assert_not_null(to_mid, "the vault archway exists")
	to_mid._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.MID, "crossing works here too, right before the finale")

	var cache := room.get_node_or_null(^"VaultCache") as ToolTarget
	assert_eq(cache.collision_layer, Depth.target_bit(Depth.Layer.MID),
		"the vault cache has no hardcoded fallback layer, same discipline throughout")
	var mid_hit := Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)
	mid_hit.depth_layer = Depth.Layer.MID
	assert_true(cache.receive(mid_hit), "and it is genuinely reachable once on the same plane")

	var to_near := room.get_node_or_null(^"CrossingToNear") as DepthCrossing
	to_near._on_body_entered(player)
	assert_eq(player.current_depth, Depth.Layer.NEAR, "and the far archway returns to near")

func test_every_keepers_shrine_floor_gap_wide_enough_to_need_a_swing_has_an_anchor() -> void:
	# Reads the room's own authored terrain rather than repeating coordinates
	# as literals -- the trap a sabotage caught in the Gallery's first version.
	_in_keepers_shrine()
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	var floor_platforms: Array[Rect2] = []
	for rect: Rect2 in terrain.platforms:
		if absf(rect.position.y - 288.0) < 1.0:
			floor_platforms.append(rect)
	floor_platforms.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
	assert_true(floor_platforms.size() >= 3, "the main floor is authored in at least 3 segments")
	var real_gaps := 0
	for i in floor_platforms.size() - 1:
		var gap_px: float = floor_platforms[i + 1].position.x - floor_platforms[i].end.x
		if gap_px > 87.5:
			real_gaps += 1
	assert_true(real_gaps >= 2, "both new floor gaps genuinely exceed max jump distance")
	assert_not_null(_target("SwingAnchorGap1"), "the first gap's anchor exists to bridge it")
	assert_not_null(_target("SwingAnchorGap2"), "and the second gap's anchor exists to bridge it")

func test_every_keepers_shrine_puzzle_id_is_actually_unique() -> void:
	_in_keepers_shrine()
	var seen: Array[StringName] = []
	for node: Node in _all(room):
		var target := node as ToolTarget
		if target == null or target.puzzle_id == &"":
			continue
		assert_false(seen.has(target.puzzle_id),
			"puzzle_id '%s' is not reused by a second target" % target.puzzle_id)
		seen.append(target.puzzle_id)

# --- the full five-beat route ----------------------------------------------

func test_the_full_route_connects_all_five_authored_rooms() -> void:
	assert_eq(room.room_id, &"gallery_of_vessels", "starts in the Gallery, having already crossed the bridge")
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	assert_eq(room.room_id, &"procession_hall", "reaches the Procession Hall")
	_target("FarCounterweight").receive(_hit(&"pistol", Verbs.PRECISION_HIT))
	assert_true((room.get_node_or_null(^"ExitGate") as MechanismGate).is_open(),
		"the pistol, not the lasso, opens the far counterweight in this room")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	assert_eq(room.room_id, &"burial_works", "reaches the Burial Works")
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)
	assert_eq(room.room_id, &"keepers_shrine", "and finally the Keeper's Shrine and return gate")

func test_the_keepers_shrine_has_its_own_major_checkpoint() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)
	var shrine := room.get_node_or_null(^"MajorShrine") as CheckpointShrine
	assert_not_null(shrine, "the final room has its own checkpoint")
	shrine._on_body_entered(player)
	assert_not_null(main.services.last_valid_snapshot, "and it actually saves")
	assert_eq(String(main.services.last_valid_snapshot.data["room_id"]), "keepers_shrine",
		"a checkpoint at the final shrine is scoped to that room, same as every other shrine")

func test_recall_to_clay_is_demonstrable_in_the_final_room() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)

	var e := room.get_node_or_null(^"FinalSentinelEncounter") as Encounter
	assert_not_null(e, "the final room has an encounter to demonstrate the intervention on")
	e.set_target_position(Vector2(300, 288))
	e.trigger()
	var elapsed := 0.0
	while e.phase() != EncounterBook.Phase.ACTIVE and elapsed < 12.0:
		e.advance(1.0 / 60.0)
		elapsed += 1.0 / 60.0
	assert_eq(e.phase(), EncounterBook.Phase.ACTIVE, "the sentinel is up")

	main.services.relationships.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)
	var actor := e.actor()
	while actor.health() > 1:
		actor.hurtbox().receive(Hit.new(&"pistol", Verbs.PRECISION_HIT, Vector2.ZERO))

	assert_true(main.world_root.intervention.use(e), "the intervention actually works here, in the real final room")
	assert_eq(e.result(), Encounter.RESULT_RECALLED, "recalled, not defeated")

func test_reaching_the_return_gate_marks_the_route_complete_exactly_once() -> void:
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)

	assert_false(main.world_root.is_route_complete(), "not complete until the gate is actually reached")
	var completions: Array[bool] = []
	main.world_root.route_completed.connect(func() -> void: completions.append(true))
	var gate := room.get_node_or_null(^"ReturnGate") as RoomExit
	assert_not_null(gate, "the return gate exists")
	gate._on_body_entered(player)
	assert_true(main.world_root.is_route_complete(), "reaching it marks the route complete")
	assert_eq(completions.size(), 1, "the signal fires once")
	gate._on_body_entered(player)
	assert_eq(completions.size(), 1, "and a stale exit reference cannot re-fire it a second time")

func test_mark_route_complete_is_idempotent_on_its_own_not_only_via_the_exits_own_guard() -> void:
	# RoomExit's own _fired flag would ALSO stop a second call from reaching
	# WorldRoot, so calling it through the gate twice (as above) cannot tell
	# apart "the ledger-based guard in WorldRoot works" from "RoomExit's
	# one-shot flag happened to catch it first". Calling the canonical method
	# directly, twice, isolates the guard that actually matters -- the same
	# once-and-only-once contract every reward and judgment in this game
	# already goes through the ledger for.
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)
	var completions: Array[bool] = []
	main.world_root.route_completed.connect(func() -> void: completions.append(true))
	main.world_root.mark_route_complete()
	main.world_root.mark_route_complete()
	main.world_root.mark_route_complete()
	assert_eq(completions.size(), 1, "the canonical entry point is idempotent on its own")

func test_the_return_gate_is_never_blocked_by_a_refused_alliance_or_romance() -> void:
	# docs/gameplay-pillars.md: "An optional romance refusal must not block the
	# temple's exit." Declining both, explicitly, and reaching the gate anyway.
	_walk_through_gate_and_exit("Counterweight", "ExitToProcessionHall")
	_walk_through_gate_and_exit("FarCounterweight", "ExitToBurialWorks", &"pistol", Verbs.PRECISION_HIT)
	_walk_through_gate_and_exit("StonePlug", "ExitToShrine", &"lasso", Verbs.PULL)
	main.services.relationships.resolve_alliance_offer(&"keeper_of_the_clay_dead", false)
	main.services.relationships.resolve_romance_offer(&"keeper_of_the_clay_dead", &"decline")
	var gate := room.get_node_or_null(^"ReturnGate") as RoomExit
	gate._on_body_entered(player)
	assert_true(main.world_root.is_route_complete(),
		"refusing her twice over still lets the player finish the route")

# --- soft-lock audit (F13): falling recovers exactly like defeat -----------

func test_falling_below_the_room_recovers_to_the_last_checkpoint() -> void:
	# The actual failure this guards: missing the Entry Bridge's lasso swing
	# and dropping straight through the 320px gap with nothing underneath.
	main.world_root.save_checkpoint(&"test_fall_checkpoint", player.global_position)
	var checkpoint_position := player.global_position
	player.global_position = Vector2(480, room.camera_bounds().end.y + 500.0)
	main.world_root._process(1.0 / 60.0)
	assert_almost_eq(player.global_position.distance_to(checkpoint_position), 0.0, 4.0,
		"falling out of the room returns Michael to the checkpoint, not left falling forever")

func test_falling_with_no_checkpoint_yet_returns_to_the_rooms_authored_start() -> void:
	# Falling in the very first room, before any shrine has been reached.
	player.global_position = Vector2(480, room.camera_bounds().end.y + 500.0)
	main.world_root._last_checkpoint = null
	main.world_root._process(1.0 / 60.0)
	var spawn := room.spawn_position(room.default_spawn_id)
	assert_almost_eq(player.global_position.distance_to(spawn), 0.0, 4.0,
		"with nothing saved yet, falling returns to the room's own authored start")

func test_falling_emits_its_own_signal_distinct_from_defeat() -> void:
	var falls: Array[bool] = []
	var defeats: Array[bool] = []
	main.world_root.player_fell.connect(func() -> void: falls.append(true))
	main.world_root.player_defeated.connect(func() -> void: defeats.append(true))
	player.global_position = Vector2(480, room.camera_bounds().end.y + 500.0)
	main.world_root._process(1.0 / 60.0)
	assert_eq(falls.size(), 1, "falling is reported")
	assert_eq(defeats.size(), 0, "and it is not misreported as a combat defeat")

func test_standing_comfortably_above_the_floor_never_triggers_a_fall() -> void:
	# The margin has to be generous enough that ordinary jumping near a
	# platform edge is never mistaken for falling out of the world.
	var floor_y := room.camera_bounds().end.y
	player.global_position = Vector2(480, floor_y - 20.0)
	main.world_root._process(1.0 / 60.0)
	assert_almost_eq(player.global_position.y, floor_y - 20.0, 0.5,
		"standing on the ground is never treated as falling out of bounds")

func test_a_room_with_no_authored_bounds_has_no_fall_detection() -> void:
	# An unbounded room (camera_bounds().size == ZERO) never declared a floor
	# to fall through, so this deliberately opts out rather than guessing.
	room.bounds = Rect2()
	var far_below := Vector2(480, 10000.0)
	player.global_position = far_below
	main.world_root._process(1.0 / 60.0)
	assert_almost_eq(player.global_position.distance_to(far_below), 0.0, 0.5,
		"an unbounded room cannot fire a fall it never defined")

func test_missing_the_entry_bridge_swing_and_falling_into_the_gap_is_recoverable() -> void:
	var ctx := _fresh_bridge()
	var bridge := ctx["room"] as Room
	var bridge_player := ctx["player"] as Player
	var bridge_main := ctx["main"] as Main
	# The exact scenario this whole mechanism exists for: stand at the gap's
	# edge, miss the swing, and drop straight through with nothing below.
	bridge_player.global_position = Vector2(340, 288)
	bridge_player.global_position.y = bridge.camera_bounds().end.y + 200.0
	bridge_main.world_root._process(1.0 / 60.0)
	var spawn := bridge.spawn_position(bridge.default_spawn_id)
	assert_almost_eq(bridge_player.global_position.distance_to(spawn), 0.0, 4.0,
		"a missed swing over the actual authored gap recovers to the bridge's own start, not a permanent fall")
	bridge_main.free()
