extends TestCase
## Properties of the encounter state machine in docs/temple-emergence.md.
##
## One property per test, and the message says the property rather than the
## mechanism, so a test that starts failing says what stopped being true.
##
## Scope note, so a green run is not read as more than it is: these cover the
## SIMULATION half only. EnemyActor.apply_motion() - the move_and_slide call -
## is deliberately not exercised, because collision response cannot be judged
## without a real room, and a headless assertion that pretended otherwise would
## be the more expensive kind of pass.

const STEP := 1.0 / 60.0
## Long enough for tell (900ms) + awakening (500ms) + emerging (1400ms).
const FULL_EMERGENCE_S := 3.2

var services: Services
var _nodes: Array[Node] = []
var _consumptions: Dictionary = {}
var _phase_log: Array[int] = []
## Flipped by tests that need to model an occupied spawn space.
var _space_is_clear: bool = true

func before_each() -> void:
	services = Services.new()
	_nodes = []
	_consumptions = {}
	_phase_log = []
	_space_is_clear = true
	services.ledger.event_consumed.connect(_on_event_consumed)

func after_each() -> void:
	for node: Node in _nodes:
		if is_instance_valid(node):
			node.free()
	_nodes.clear()
	services.free()

# --- fixture ---------------------------------------------------------------

func _make_source(id: StringName = &"gallery_jar_01", interrupt_rule: StringName = &"none",
		blocked_policy: StringName = &"wait", family: StringName = EncounterSource.CERAMIC_SENTINEL,
		source_type: StringName = &"ceramic") -> EncounterSource:
	var authored := EncounterSource.new()
	authored.id = id
	authored.room_id = &"gallery_of_vessels"
	authored.source_type = source_type
	authored.family_id = family
	authored.trigger_id = StringName("%s_trigger" % id)
	authored.spawn_point_id = StringName("%s_spawn" % id)
	authored.tell_clip_id = StringName("%s_tell" % id)
	authored.emerge_clip_id = StringName("%s_emerge" % id)
	authored.resolved_visual_id = StringName("%s_resolved" % id)
	authored.interrupt_rule = interrupt_rule
	authored.blocked_spawn_policy = blocked_policy
	authored.reward_event_id = StringName("%s_reward" % id)
	return authored

func _make_encounter(authored: EncounterSource) -> Encounter:
	var encounter := Encounter.new()
	encounter.name = "Encounter%d" % _nodes.size()
	encounter.source = authored
	encounter.position = Vector2(400, 200)
	(Engine.get_main_loop() as SceneTree).root.add_child(encounter)
	_nodes.append(encounter)
	return encounter

func _add_fallback_marker(encounter: Encounter, offset: Vector2) -> void:
	var marker := Marker2D.new()
	marker.name = "AuthoredFallbackSpawn"
	marker.position = offset
	encounter.add_child(marker)
	encounter.fallback_spawn_path = ^"AuthoredFallbackSpawn"

func _drive(encounter: Encounter, seconds: float) -> void:
	var steps := int(seconds / STEP)
	for _i in range(steps):
		encounter.advance(STEP)

func _on_event_consumed(event_id: StringName, _context: Dictionary) -> void:
	_consumptions[event_id] = int(_consumptions.get(event_id, 0)) + 1

func _consumed_count(event_id: StringName) -> int:
	return int(_consumptions.get(event_id, 0))

func _on_phase_changed(phase: int) -> void:
	_phase_log.append(phase)

func _space_clear_query(_at: Vector2) -> bool:
	return _space_is_clear

func _only_far_right_is_clear(at: Vector2) -> bool:
	return at.x > 450.0

func _prop_of(encounter: Encounter) -> HitReceiver:
	return encounter.get_node("GrayboxSourceProp") as HitReceiver

func _defeat_actor(actor: EnemyActor) -> int:
	var landed := 0
	while not actor.is_defeated() and landed < 20:
		actor.hurtbox().receive(Hit.new(&"pistol", Verbs.PRECISION_HIT, Vector2.ZERO))
		landed += 1
	return landed

# --- the authored flow -----------------------------------------------------

func test_an_untriggered_source_is_disguised_scenery_with_no_actor() -> void:
	var encounter := _make_encounter(_make_source())
	assert_true(encounter.bind(services), "a well-formed source binds")
	_drive(encounter, 5.0)
	assert_eq(encounter.phase(), EncounterBook.Phase.DISGUISED, "nothing happens until the trigger fires")
	assert_eq(encounter.actor_count(), 0, "no creature exists before the trigger")
	assert_eq(encounter.visible_view(), &"source", "the scenery is the only visible view")

func test_the_authored_flow_visits_every_phase_in_order() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	encounter.phase_changed.connect(_on_phase_changed)
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	assert_eq(_phase_log, [
			EncounterBook.Phase.TELL,
			EncounterBook.Phase.AWAKENING,
			EncounterBook.Phase.EMERGING,
			EncounterBook.Phase.ACTIVE,
		], "disguised -> tell -> awakening -> emerging -> active, with nothing skipped")

func test_a_trigger_that_fires_again_cannot_restart_the_encounter() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	assert_true(encounter.trigger(), "the first crossing activates the source")
	assert_false(encounter.trigger(), "activation is latched once")
	_drive(encounter, FULL_EMERGENCE_S)
	assert_false(encounter.trigger(), "a trigger volume crossed again cannot re-run the encounter")
	assert_eq(encounter.actor_count(), 1, "exactly one creature exists however often the trigger fires")

# --- spawn ownership -------------------------------------------------------

func test_spawn_ownership_transfers_exactly_once_for_one_source_id() -> void:
	var authored := _make_source()
	var first := _make_encounter(authored)
	var second := _make_encounter(authored)
	first.bind(services)
	second.bind(services)

	first.trigger()
	_drive(first, FULL_EMERGENCE_S)
	second.trigger()
	_drive(second, FULL_EMERGENCE_S)

	assert_eq(_consumed_count(authored.spawn_event_id()), 1,
		"spawn ownership for one source ID transfers exactly once")
	assert_eq(first.actor_count() + second.actor_count(), 1,
		"two live encounters for one source still produce one creature between them")
	assert_true(second.has_forfeited_ownership(), "the encounter that lost the transfer says so")
	assert_eq(second.visible_view(), &"none", "and presents nothing rather than a second copy")

func test_room_reentry_restores_one_actor_without_a_second_transfer() -> void:
	var authored := _make_source()
	var first := _make_encounter(authored)
	first.bind(services)
	first.trigger()
	_drive(first, FULL_EMERGENCE_S)
	assert_eq(first.actor_count(), 1, "the room's first visit spawned the creature")

	first.free()  # room unload
	var revisit := _make_encounter(authored)
	revisit.bind(services)

	assert_eq(revisit.phase(), EncounterBook.Phase.ACTIVE, "re-entry resumes the recorded phase")
	assert_eq(revisit.actor_count(), 1, "re-entering a room cannot produce a second actor")
	assert_eq(_consumed_count(authored.spawn_event_id()), 1,
		"restoring the creature is not a second transfer of ownership")

func test_a_resolved_source_stays_resolved_on_room_reentry() -> void:
	var authored := _make_source()
	var first := _make_encounter(authored)
	first.bind(services)
	first.trigger()
	_drive(first, FULL_EMERGENCE_S)
	_defeat_actor(first.actor())
	first.advance(STEP)
	assert_eq(first.phase(), EncounterBook.Phase.RESOLVED, "a defeated creature resolves its source")

	first.free()  # room unload
	var revisit := _make_encounter(authored)
	revisit.bind(services)

	assert_eq(revisit.phase(), EncounterBook.Phase.RESOLVED, "a resolved source stays resolved")
	assert_eq(revisit.actor_count(), 0, "and never spawns again")
	assert_false(revisit.trigger(), "its trigger no longer activates anything")
	assert_eq(revisit.visible_view(), &"resolved", "the resolved visual is what the room shows")

func test_phase_and_result_persist_by_source_id() -> void:
	var authored := _make_source()
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, 1.0)
	assert_eq(services.encounters.phase_of(authored.id), EncounterBook.Phase.AWAKENING,
		"the book carries the live phase, keyed by source ID")
	_drive(encounter, FULL_EMERGENCE_S)
	_defeat_actor(encounter.actor())
	encounter.advance(STEP)
	assert_eq(services.encounters.result_of(authored.id), Encounter.RESULT_DEFEATED,
		"the book carries the authored result, keyed by source ID")

# --- rewards ---------------------------------------------------------------

func test_the_reward_is_applied_once_even_across_a_reload() -> void:
	var authored := _make_source()
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	_defeat_actor(encounter.actor())
	encounter.advance(STEP)
	assert_eq(_consumed_count(authored.reward_event_id), 1, "resolving awards the reward once")

	var snapshot := services.capture(&"gallery_checkpoint", authored.room_id, &"spawn_gallery",
		{"health": 4}, {"pistol": 6})
	assert_not_null(snapshot, "the run can be checkpointed after the encounter resolves")
	var reloaded := Services.new()
	assert_true(reloaded.restore(snapshot), "the checkpoint reloads")
	assert_true(reloaded.encounters.is_resolved(authored.id), "the source is still resolved after a reload")
	assert_false(reloaded.ledger.consume(authored.reward_event_id),
		"a reload cannot award the same reward a second time")
	reloaded.free()

# --- environmental collateral ----------------------------------------------

func test_destroying_the_source_records_a_different_fact_from_defeating_the_creature() -> void:
	var authored := _make_source()
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, 0.3)

	assert_true(_prop_of(encounter).receive(Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)),
		"the authored verb destroys the disguised source")
	assert_eq(encounter.result(), Encounter.RESULT_COLLATERAL,
		"destroying the source is its own outcome, not a defeat")
	assert_eq(services.encounters.result_of(authored.id), Encounter.RESULT_COLLATERAL,
		"and the book records which of the two happened")
	assert_true(services.ledger.has_consumed(authored.collateral_event_id()),
		"collateral is a distinct authored fact of its own")
	assert_eq(encounter.actor_count(), 0, "no creature was ever released")
	assert_false(services.ledger.has_consumed(authored.spawn_event_id()),
		"spawn ownership never transferred, so nothing is owed a second resolution")

func test_the_collateral_fact_is_authored_rather_than_inferred_from_the_rubble() -> void:
	var fought := _make_source(&"gallery_jar_01")
	var smashed := _make_source(&"gallery_jar_02")
	# Two jars from one culture share one authored resolved visual, which is
	# exactly the case where reading the final appearance would lose the fact.
	fought.resolved_visual_id = &"jar_shards_resolved"
	smashed.resolved_visual_id = &"jar_shards_resolved"

	var combat := _make_encounter(fought)
	combat.bind(services)
	combat.trigger()
	_drive(combat, FULL_EMERGENCE_S)
	_defeat_actor(combat.actor())
	combat.advance(STEP)

	var collateral := _make_encounter(smashed)
	collateral.bind(services)
	collateral.trigger()
	_drive(collateral, 0.3)
	_prop_of(collateral).receive(Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO))

	assert_eq(combat.presentation_clip(), collateral.presentation_clip(),
		"both endings look the same on the floor")
	assert_ne(combat.result(), collateral.result(),
		"yet the recorded fact still tells them apart, so nothing has to read the rubble")

func test_the_source_cannot_be_destroyed_once_the_creature_is_out() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	assert_false(_prop_of(encounter).receive(Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)),
		"a spent shell is scenery; it cannot resolve an encounter that is already active")
	assert_eq(encounter.phase(), EncounterBook.Phase.ACTIVE, "the fight continues")

# --- the Keeper's recall ---------------------------------------------------
#
# src/relationships/intervention_recall.gd calls Encounter.resolve_by_recall.
# Nothing executed that call: --check-only cannot see an unknown method on a
# class_name, and that class's own suite only ever passes it plain values or
# null. These two cases are the consuming side of that seam.

func test_recalling_a_creature_is_its_own_result_rather_than_a_kill() -> void:
	var authored := _make_source()
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)

	assert_true(encounter.resolve_by_recall(&"keeper_of_the_clay_dead"), "an active creature can be sent home")
	assert_eq(encounter.result(), Encounter.RESULT_RECALLED,
		"sending one home is not the same fact as killing it")
	assert_eq(services.encounters.result_of(authored.id), Encounter.RESULT_RECALLED,
		"and the book keeps which of the two happened")
	assert_eq(encounter.actor_count(), 0, "the creature is gone from the room")
	assert_false(encounter.resolve_by_recall(&"keeper_of_the_clay_dead"),
		"a second recall is refused, so a refused use can cost the Keeper nothing")

func test_the_keepers_recall_actually_reaches_the_encounter_it_targets() -> void:
	var relationships := RelationshipBook.new()
	relationships.register(Heroine.load_from_file("res://narrative/characters/keeper_of_the_clay_dead.json"))
	relationships.resolve_alliance_offer(&"keeper_of_the_clay_dead", true)
	var recall := RecallToClay.new(services.tuning, relationships)

	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	assert_false(recall.use(encounter), "a creature at full health is not eligible")

	# Weaken it to within the intervention's authored fraction.
	while encounter.actor().health() > int(encounter.actor().max_health / 2):
		encounter.actor().hurtbox().receive(Hit.new(&"pistol", Verbs.PRECISION_HIT, Vector2.ZERO))

	assert_true(recall.use(encounter), "a weakened creature is sent home by the real intervention")
	assert_eq(encounter.phase(), EncounterBook.Phase.RESOLVED, "which resolves the encounter")
	assert_eq(encounter.result(), Encounter.RESULT_RECALLED, "by its own authored route")

# --- pause -----------------------------------------------------------------

func test_a_mid_emergence_pause_freezes_simulation_and_presentation_together() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, 1.6)
	assert_eq(encounter.phase(), EncounterBook.Phase.EMERGING, "the pause lands mid-emergence")

	var frozen_phase := encounter.phase()
	var frozen_clock := encounter.presentation_clock_ms()
	encounter.set_paused(true)
	_drive(encounter, 5.0)
	assert_eq(encounter.phase(), frozen_phase, "a paused emergence does not advance")
	assert_eq(encounter.presentation_clock_ms(), frozen_clock,
		"presentation is frozen with the simulation, not separately from it")
	assert_eq(encounter.actor_count(), 0, "no creature arrives while the game is paused")

	encounter.set_paused(false)
	_drive(encounter, 3.0)
	assert_eq(encounter.phase(), EncounterBook.Phase.ACTIVE, "unpausing resumes the same emergence")

func test_a_pause_during_combat_freezes_the_creature_too() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	encounter.set_target_position(Vector2(470, 200))
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	# Standing inside its reach, so an unfrozen creature would settle and strike
	# during the window below rather than idling out of range.
	encounter.set_target_position(encounter.actor().global_position)
	encounter.set_paused(true)
	var frozen_state := encounter.actor().state()
	_drive(encounter, 5.0)
	assert_eq(encounter.actor().state(), frozen_state, "the creature is frozen by the same pause")
	assert_false(encounter.actor().can_damage(), "a frozen creature cannot damage anything")

# --- skipped animation -----------------------------------------------------

func test_a_skipped_beat_completes_exactly_one_transition() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	encounter.trigger()
	assert_eq(encounter.phase(), EncounterBook.Phase.TELL, "the tell is playing")

	encounter.skip_current_beat()
	assert_eq(encounter.phase(), EncounterBook.Phase.AWAKENING,
		"skipping the tell completes the tell's transition and no other")
	assert_eq(encounter.actor_count(), 0, "a skip does not cascade into a spawn")

	encounter.skip_current_beat()
	assert_eq(encounter.phase(), EncounterBook.Phase.EMERGING, "the next skip completes the next transition")

	encounter.skip_current_beat()
	assert_eq(encounter.phase(), EncounterBook.Phase.ACTIVE, "and the last one completes the transfer")
	assert_eq(encounter.actor_count(), 1, "a fast-forwarded emergence still produces exactly one creature")

func test_a_skipped_beat_presents_the_clip_that_matches_the_new_state() -> void:
	var authored := _make_source()
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	assert_eq(encounter.presentation_clip(), authored.tell_clip_id, "the tell clip plays during the tell")
	encounter.skip_current_beat()
	assert_eq(encounter.presentation_clip(), authored.emerge_clip_id,
		"a skipped animation leaves presentation on the state it actually reached")

# --- views -----------------------------------------------------------------

func test_the_prop_and_the_creature_are_swapped_views_of_one_encounter() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	assert_eq(encounter.visible_view(), &"source", "the disguised prop is the encounter's first view")
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	assert_eq(encounter.visible_view(), &"actor", "the creature becomes the same encounter's view")
	assert_false(_prop_of(encounter).visible, "exactly one view is shown at a time")
	assert_eq(encounter.actor().get_parent(), encounter, "and one node owns both of them")
	_defeat_actor(encounter.actor())
	encounter.advance(STEP)
	assert_eq(encounter.visible_view(), &"resolved", "resolution swaps in the resolved visual")

# --- content validation ----------------------------------------------------

func test_an_incomplete_source_leaves_the_encounter_inert_instead_of_spawning() -> void:
	var authored := _make_source()
	authored.reward_event_id = &""
	var encounter := _make_encounter(authored)
	assert_false(encounter.bind(services), "a source missing a required field fails content validation")
	assert_false(encounter.trigger(), "an inert encounter cannot be activated")
	_drive(encounter, 10.0)
	assert_eq(encounter.actor_count(), 0, "invalid content never produces a creature")
	assert_true(encounter.content_errors().size() > 0, "and the encounter says what is wrong with it")

func test_an_unrecognised_interrupt_rule_fails_content_validation() -> void:
	var authored := _make_source(&"gallery_jar_01", &"explode_on_michael")
	assert_ne(authored.validation_error(), "",
		"an unknown interrupt rule is a content error, never a default")
	var encounter := _make_encounter(authored)
	assert_false(encounter.bind(services), "the encounter refuses to run on it")
	_drive(encounter, 10.0)
	assert_eq(encounter.actor_count(), 0, "and produces nothing that could damage Michael")

func test_an_unknown_blocked_spawn_policy_fails_content_validation() -> void:
	var authored := _make_source(&"gallery_jar_01", &"none", &"teleport_anyway")
	assert_ne(authored.validation_error(), "",
		"blocked_spawn_policy is wait or authored_fallback and nothing else")

# --- interrupts ------------------------------------------------------------

func test_an_interrupt_to_resolved_never_produces_a_creature() -> void:
	var authored := _make_source(&"gallery_jar_01", &"to_resolved")
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, 1.0)
	assert_eq(encounter.phase(), EncounterBook.Phase.AWAKENING, "the interrupt lands during awakening")

	assert_true(encounter.apply_interrupt(&"counterweight_dropped"), "the authored interrupt applies")
	assert_eq(encounter.phase(), EncounterBook.Phase.RESOLVED, "it routes the encounter to resolved")
	assert_eq(encounter.result(), Encounter.RESULT_INTERRUPTED, "with its own authored result")
	assert_eq(encounter.actor_count(), 0, "no creature is ever released by this route")
	assert_false(services.ledger.has_consumed(authored.spawn_event_id()),
		"spawn ownership never transferred")

func test_an_interrupt_can_never_reach_a_damaging_attack() -> void:
	var authored := _make_source(&"gallery_jar_01", &"to_staggered_active")
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.set_target_position(Vector2(470, 200))
	encounter.trigger()
	_drive(encounter, 1.6)
	assert_eq(encounter.phase(), EncounterBook.Phase.EMERGING, "the interrupt lands mid-emergence")

	assert_true(encounter.apply_interrupt(&"lasso_pull"), "the authored interrupt applies")
	assert_eq(encounter.phase(), EncounterBook.Phase.ACTIVE, "it routes to a staggered active state")
	assert_eq(encounter.actor().state(), EnemyActor.State.STAGGERED, "the creature arrives staggered")

	# Michael now standing inside its reach, so the strike path is genuinely
	# available and "it did not damage" cannot be an accident of distance. The
	# stagger and the settle are then the only things holding it off.
	encounter.set_target_position(encounter.actor().global_position)
	var damaged_early := false
	for _i in range(90):  # 1.5 s, comfortably before any legitimate strike
		encounter.advance(STEP)
		if encounter.actor() != null and encounter.actor().can_damage():
			damaged_early = true
	assert_false(damaged_early,
		"an interrupt cannot skip to a damaging attack; the stagger and the settle both have to run")

func test_a_source_that_authors_no_interrupt_refuses_rather_than_routing_to_damage() -> void:
	var authored := _make_source(&"gallery_jar_01", &"none")
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, 1.0)
	assert_false(encounter.apply_interrupt(&"lasso_pull"), "an unauthored interrupt is refused")
	assert_eq(encounter.phase(), EncounterBook.Phase.AWAKENING, "the emergence continues unchanged")
	assert_eq(encounter.actor_count(), 0, "and the refusal did not release anything early")

func test_an_interrupt_rule_that_becomes_unrecognised_at_runtime_refuses_loudly() -> void:
	var authored := _make_source(&"gallery_jar_01", &"to_staggered_active")
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, 1.0)
	# Authored data reloaded or edited under a running encounter.
	authored.interrupt_rule = &"explode_on_michael"
	assert_false(encounter.apply_interrupt(&"lasso_pull"),
		"an unrecognised rule is refused, never defaulted to a damaging attack")
	assert_eq(encounter.actor_count(), 0, "nothing was released by the refusal")
	assert_true(encounter.content_errors().size() > 0, "and the refusal is reported, not silent")

func test_an_interrupt_outside_awakening_or_emerging_is_refused() -> void:
	var authored := _make_source(&"gallery_jar_01", &"to_resolved")
	var encounter := _make_encounter(authored)
	encounter.bind(services)
	assert_false(encounter.apply_interrupt(), "a disguised source has nothing to interrupt")
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	assert_false(encounter.apply_interrupt(), "an active fight is not interrupted, it is fought")
	assert_eq(encounter.phase(), EncounterBook.Phase.ACTIVE, "the fight is untouched by the refusal")

# --- blocked spawn ---------------------------------------------------------

func test_a_blocked_spawn_waits_instead_of_placing_a_hitbox_in_the_blocked_space() -> void:
	var encounter := _make_encounter(_make_source(&"gallery_jar_01", &"none", &"wait"))
	encounter.set_spawn_clearance_query(Callable(self, "_space_clear_query"))
	encounter.bind(services)
	_space_is_clear = false
	encounter.trigger()
	_drive(encounter, 6.0)
	assert_true(encounter.is_spawn_blocked(), "the encounter knows its spawn space is occupied")
	assert_eq(encounter.phase(), EncounterBook.Phase.EMERGING, "it waits in emerging rather than forcing itself out")
	assert_eq(encounter.actor_count(), 0, "no hitbox exists anywhere while the space is blocked")

func test_a_blocked_spawn_repeats_its_tell_rather_than_waiting_silently() -> void:
	var encounter := _make_encounter(_make_source(&"gallery_jar_01", &"none", &"wait"))
	encounter.set_spawn_clearance_query(Callable(self, "_space_clear_query"))
	encounter.bind(services)
	_space_is_clear = false
	encounter.trigger()
	_drive(encounter, 6.0)
	assert_true(encounter.tell_repeat_count() >= 1,
		"a delayed emergence repeats its warning so the delay is still fair")

func test_a_blocked_spawn_completes_once_the_space_clears() -> void:
	var authored := _make_source(&"gallery_jar_01", &"none", &"wait")
	var encounter := _make_encounter(authored)
	encounter.set_spawn_clearance_query(Callable(self, "_space_clear_query"))
	encounter.bind(services)
	_space_is_clear = false
	encounter.trigger()
	_drive(encounter, 4.0)
	assert_eq(encounter.actor_count(), 0, "still waiting")

	_space_is_clear = true
	_drive(encounter, 1.0)
	assert_eq(encounter.phase(), EncounterBook.Phase.ACTIVE, "the delayed emergence completes")
	assert_eq(encounter.actor_count(), 1, "and delivers exactly one creature")
	assert_eq(_consumed_count(authored.spawn_event_id()), 1,
		"waiting did not cost or duplicate the single transfer")

func test_an_authored_fallback_spawn_uses_its_authored_safe_marker() -> void:
	var encounter := _make_encounter(_make_source(&"gallery_jar_01", &"none", &"authored_fallback"))
	_add_fallback_marker(encounter, Vector2(120, 0))
	encounter.set_spawn_clearance_query(Callable(self, "_only_far_right_is_clear"))
	encounter.bind(services)
	encounter.trigger()
	_drive(encounter, FULL_EMERGENCE_S)
	assert_eq(encounter.actor_count(), 1, "the fallback lets the blocked emergence complete")
	assert_almost_eq(encounter.actor().global_position.x, encounter.fallback_spawn_position().x, 0.5,
		"the creature appears at the authored safe marker, not in the occupied space")

func test_an_authored_fallback_without_a_marker_is_a_content_error_not_a_silent_fallthrough() -> void:
	var encounter := _make_encounter(_make_source(&"gallery_jar_01", &"none", &"authored_fallback"))
	encounter.set_spawn_clearance_query(Callable(self, "_space_clear_query"))
	encounter.bind(services)
	assert_true(encounter.content_errors().size() > 0,
		"a fallback policy with no authored safe marker is reported at bind")

	_space_is_clear = false
	encounter.trigger()
	_drive(encounter, 6.0)
	assert_eq(encounter.actor_count(), 0,
		"and the missing marker never becomes permission to spawn into the occupied space")
	assert_true(encounter.is_spawn_blocked(), "it waits, loudly, instead")

func test_a_creature_never_appears_within_the_minimum_clearance_of_the_target() -> void:
	var encounter := _make_encounter(_make_source())
	encounter.bind(services)
	# Michael standing on the spawn point. No room query at all: the clearance
	# rule has to hold on its own.
	encounter.set_target_position(encounter.spawn_position() + Vector2(10, 0))
	encounter.trigger()
	_drive(encounter, 6.0)
	assert_eq(encounter.actor_count(), 0, "an active hitbox is never teleported into Michael")
	assert_true(encounter.is_spawn_blocked(), "the encounter treats him as an occupied space")

	encounter.set_target_position(encounter.spawn_position() + Vector2(300, 0))
	_drive(encounter, 1.0)
	assert_eq(encounter.actor_count(), 1, "once he moves away the emergence completes normally")
