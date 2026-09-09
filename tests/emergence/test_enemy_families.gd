extends TestCase
## Behaviour properties of the three slice families (docs/temple-emergence.md
## and docs/production/emergence-keyframes.md).
##
## Each family is loaded from the graybox scene an Encounter would actually
## instantiate, so a scene that stopped producing an EnemyActor fails here
## rather than at runtime. --check-only does not catch an unknown method on a
## class_name, so these runtime cases are the only thing that would.
##
## Scope note: apply_motion() (move_and_slide) is not exercised. These actors
## therefore do not travel, which is deliberate - it keeps a distant target
## distant so pursuit behaviour can be observed at all.

const STEP := 1.0 / 60.0

var _nodes: Array[Node] = []
var _wrong_skull_beats: int = 0

func before_each() -> void:
	_nodes = []
	_wrong_skull_beats = 0

func after_each() -> void:
	for node: Node in _nodes:
		if is_instance_valid(node):
			node.free()
	_nodes.clear()

func _make_actor(family_id: StringName) -> EnemyActor:
	var path := String(EncounterSource.FAMILY_SCENES[family_id])
	var packed := load(path) as PackedScene
	assert_not_null(packed, "the graybox scene for %s loads" % family_id)
	var actor := packed.instantiate() as EnemyActor
	assert_not_null(actor, "the graybox scene for %s is an EnemyActor" % family_id)
	(Engine.get_main_loop() as SceneTree).root.add_child(actor)
	_nodes.append(actor)
	actor.bind_tuning(Tuning.new())
	return actor

func _advance(actor: EnemyActor, seconds: float) -> void:
	for _i in range(int(seconds / STEP)):
		actor.advance(STEP)

## Returns true if the actor ever opened a damaging window during the window.
func _saw_a_strike(actor: EnemyActor, seconds: float) -> bool:
	var struck := false
	for _i in range(int(seconds / STEP)):
		actor.advance(STEP)
		if actor.can_damage():
			struck = true
	return struck

func _body_polygon(actor: EnemyActor) -> PackedVector2Array:
	return (actor.get_node("GrayboxBody") as Polygon2D).polygon

func _on_wrong_skull() -> void:
	_wrong_skull_beats += 1

# --- shared properties -----------------------------------------------------

func test_every_family_reports_the_identity_of_the_scene_it_came_from() -> void:
	assert_eq(_make_actor(EncounterSource.CERAMIC_SENTINEL).family_id(),
		EncounterSource.CERAMIC_SENTINEL, "the ceramic scene is the ceramic family")
	assert_eq(_make_actor(EncounterSource.PAINTED_PROCESSION_GUARD).family_id(),
		EncounterSource.PAINTED_PROCESSION_GUARD, "the mural scene is the mural family")
	assert_eq(_make_actor(EncounterSource.BURIAL_PIT_ASSEMBLER).family_id(),
		EncounterSource.BURIAL_PIT_ASSEMBLER, "the pit scene is the pit family")

func test_the_three_families_have_distinct_silhouettes() -> void:
	var ceramic := _body_polygon(_make_actor(EncounterSource.CERAMIC_SENTINEL))
	var mural := _body_polygon(_make_actor(EncounterSource.PAINTED_PROCESSION_GUARD))
	var pit := _body_polygon(_make_actor(EncounterSource.BURIAL_PIT_ASSEMBLER))
	assert_ne(ceramic, mural, "the sentinel and the guard read differently")
	assert_ne(mural, pit, "the guard and the crawler read differently")
	assert_ne(ceramic, pit, "the crawling silhouette deliberately differs from the sentinel")

func test_no_family_can_damage_before_its_settle_completes() -> void:
	for family: StringName in [EncounterSource.CERAMIC_SENTINEL,
			EncounterSource.PAINTED_PROCESSION_GUARD, EncounterSource.BURIAL_PIT_ASSEMBLER]:
		var actor := _make_actor(family)
		actor.set_target_position(actor.global_position)  # as close as it can get
		assert_false(actor.can_damage(), "%s cannot damage on the frame it arrives" % family)
		_advance(actor, 0.3)  # shorter than the 420 ms settle
		assert_false(actor.can_damage(), "%s cannot damage during its settle" % family)

## The positive control for the test above: an actor that never attacks at all
## would satisfy it trivially, so each family has to be shown reaching a strike.
func test_every_family_does_eventually_strike_a_target_in_range() -> void:
	for family: StringName in [EncounterSource.CERAMIC_SENTINEL,
			EncounterSource.PAINTED_PROCESSION_GUARD, EncounterSource.BURIAL_PIT_ASSEMBLER]:
		var actor := _make_actor(family)
		actor.set_target_position(actor.global_position)
		assert_true(_saw_a_strike(actor, 5.0), "%s does attack once it is settled and ready" % family)

func test_a_lasso_pull_staggers_a_creature_rather_than_damaging_it() -> void:
	var actor := _make_actor(EncounterSource.CERAMIC_SENTINEL)
	var health_before := actor.health()
	assert_true(actor.hurtbox().receive(Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO)),
		"the hurtbox accepts a pull")
	assert_eq(actor.health(), health_before, "a pull is control, not damage")
	assert_eq(actor.state(), EnemyActor.State.STAGGERED, "it staggers the creature instead")

func test_a_hurtbox_refuses_a_verb_it_was_not_authored_to_accept() -> void:
	var actor := _make_actor(EncounterSource.CERAMIC_SENTINEL)
	var health_before := actor.health()
	assert_false(actor.hurtbox().receive(Hit.new(&"lasso", Verbs.SWING, Vector2.ZERO)),
		"swinging on a rope is not an attack a creature answers to")
	assert_eq(actor.health(), health_before, "and it costs the creature nothing")

func test_a_stagger_always_resettles_before_it_can_strike_again() -> void:
	var actor := _make_actor(EncounterSource.CERAMIC_SENTINEL)
	actor.set_target_position(actor.global_position)
	_advance(actor, 2.0)
	actor.stagger(0.4)
	var damaged_during_recovery := false
	for _i in range(int(0.5 / STEP)):  # the stagger plus a frame or two
		actor.advance(STEP)
		if actor.can_damage():
			damaged_during_recovery = true
	assert_false(damaged_during_recovery, "a stagger cannot expire straight into a strike")
	assert_eq(actor.state(), EnemyActor.State.SETTLING, "it has to find its footing again first")

func test_a_defeated_creature_stops_simulating() -> void:
	var actor := _make_actor(EncounterSource.CERAMIC_SENTINEL)
	actor.set_target_position(actor.global_position)
	var landed := 0
	while not actor.is_defeated() and landed < 20:
		actor.hurtbox().receive(Hit.new(&"pistol", Verbs.PRECISION_HIT, Vector2.ZERO))
		landed += 1
	assert_true(actor.is_defeated(), "%d hits defeat a sentinel" % landed)
	assert_false(_saw_a_strike(actor, 3.0), "a defeated creature never attacks again")
	assert_false(actor.hurtbox().receive(Hit.new(&"pistol", Verbs.PRECISION_HIT, Vector2.ZERO)),
		"and it cannot be killed twice")

# --- ceramic sentinel ------------------------------------------------------

func test_the_sentinel_charges_in_bursts_rather_than_running_the_player_down() -> void:
	var actor := _make_actor(EncounterSource.CERAMIC_SENTINEL) as CeramicSentinel
	actor.set_target_position(actor.global_position + Vector2(600, 0))
	var saw_charge := false
	var saw_rest := false
	for _i in range(int(4.0 / STEP)):
		actor.advance(STEP)
		if actor.state() != EnemyActor.State.PURSUE:
			continue
		if absf(actor.velocity.x) > 0.0:
			saw_charge = true
		else:
			saw_rest = true
	assert_true(saw_charge, "the sentinel does close the distance")
	assert_true(saw_rest, "but it rests between charges, which is what makes the approach readable")

func test_the_sentinel_telegraphs_its_heavy_strike() -> void:
	var actor := _make_actor(EncounterSource.CERAMIC_SENTINEL)
	assert_true(actor.windup_s > actor.strike_s,
		"the readable windup is longer than the blow it announces")

# --- painted procession guard ----------------------------------------------

func test_the_guard_steps_between_wall_panels_instead_of_walking() -> void:
	var actor := _make_actor(EncounterSource.PAINTED_PROCESSION_GUARD) as PaintedProcessionGuard
	var start_x := actor.global_position.x
	actor.set_target_position(actor.global_position + Vector2(600, 0))
	_advance(actor, 4.0)
	assert_true(actor.panels_stepped() >= 3, "the guard advances panel by panel")
	assert_almost_eq(actor.global_position.x - start_x,
		float(actor.panels_stepped()) * PaintedProcessionGuard.PANEL_SPACING_PX, 0.5,
		"and moves only in whole panel widths, never sliding between them")

func test_the_guard_remains_partly_flat() -> void:
	var actor := _make_actor(EncounterSource.PAINTED_PROCESSION_GUARD) as PaintedProcessionGuard
	actor.set_target_position(actor.global_position + Vector2(600, 0))
	_advance(actor, 6.0)
	assert_true(actor.is_partly_flat(), "the guard never fully leaves the plaster")
	assert_almost_eq(actor.flatness(), PaintedProcessionGuard.MIN_FLATNESS, 0.01,
		"the trailing leg stays flat: mixed anatomy is the family's signature, not a stage")

func test_the_guard_cannot_thrust_while_it_is_still_mostly_paint() -> void:
	var actor := _make_actor(EncounterSource.PAINTED_PROCESSION_GUARD)
	actor.set_target_position(actor.global_position)
	assert_false(_saw_a_strike(actor, 0.6),
		"a painting with no volume yet has nothing to thrust with")

# --- burial-pit assembler --------------------------------------------------

func test_the_assembler_crawls_before_it_has_a_body_to_lunge_with() -> void:
	var actor := _make_actor(EncounterSource.BURIAL_PIT_ASSEMBLER) as BurialPitAssembler
	actor.set_target_position(actor.global_position)
	assert_true(actor.is_crawling(), "it starts as an incomplete torso")
	assert_false(_saw_a_strike(actor, 1.2), "a crawler cannot lunge")
	_advance(actor, 3.0)
	assert_true(actor.is_assembled(), "given time it assembles enough body")
	assert_false(actor.is_crawling(), "and stops crawling once it has one")

func test_the_assembler_gains_parts_only_through_an_explicit_assembly_action() -> void:
	var actor := _make_actor(EncounterSource.BURIAL_PIT_ASSEMBLER) as BurialPitAssembler
	assert_eq(actor.assembled_parts(), 0, "it starts with nothing assembled")
	_advance(actor, 0.4)  # still settling: no assembly action has run
	assert_eq(actor.assembled_parts(), 0,
		"completeness never changes without an assembly action having happened")

func test_the_wrong_skull_beat_is_authored_once_rather_than_randomised() -> void:
	var actor := _make_actor(EncounterSource.BURIAL_PIT_ASSEMBLER) as BurialPitAssembler
	actor.wrong_skull_adjusted.connect(_on_wrong_skull)
	actor.set_target_position(actor.global_position)
	_advance(actor, 8.0)
	assert_eq(_wrong_skull_beats, 1, "the macabre beat plays exactly once in a creature's life")
