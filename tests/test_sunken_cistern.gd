extends TestCase
## The Sunken Cistern is an open space, not a route: you can leave any surface
## in more than one direction, and the doors are opened from elsewhere on the
## map rather than in a chain.
##
## These read the room's own authored geometry rather than repeating
## coordinates as literals, so changing the level cannot leave them checking
## numbers copied out of a design note.

const CISTERN := "res://levels/temple_clay_dead/sunken_cistern.tscn"

var room: Room

func before_each() -> void:
	if tree == null:
		return
	var packed: PackedScene = load(CISTERN)
	room = packed.instantiate() as Room
	tree.root.add_child(room)
	room.bind(Services.new())

func after_each() -> void:
	if room != null and is_instance_valid(room):
		tree.root.remove_child(room)
		room.free()
	room = null

func _all(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in node.get_children():
		found.append(child)
		found.append_array(_all(child))
	return found

func _anchors() -> Array[Vector2]:
	var out: Array[Vector2] = []
	for node: Node in _all(room):
		var target := node as ToolTarget
		if target != null and target.allowed_verbs.has(Verbs.SWING):
			out.append(target.global_position)
	return out

func test_the_cistern_is_a_space_not_a_corridor() -> void:
	var bounds := room.camera_bounds()
	assert_true(bounds.size.x >= 5000.0, "wide enough to be a place: %d px" % int(bounds.size.x))
	assert_true(bounds.size.y >= 2800.0, "and tall enough that down is a direction: %d px" % int(bounds.size.y))
	# The failure this guards is a level that is merely long. Height has to be a
	# real fraction of width or it is a corridor drawn on its side.
	assert_true(bounds.size.y / bounds.size.x > 0.4,
		"the space is not overwhelmingly horizontal (ratio %.2f)" % (bounds.size.y / bounds.size.x))

func test_every_platform_has_a_swing_anchor_genuinely_in_reach() -> void:
	# The whole promise of the lasso here: you can leave any surface by rope.
	# A platform with no anchor within lasso range is a place the player can
	# get stranded, which is the soft-lock this level is most exposed to.
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	assert_not_null(terrain, "the terrain exists")
	var anchors := _anchors()
	assert_true(anchors.size() >= 60, "the level is genuinely seeded with anchors, found %d" % anchors.size())

	var reach: float = Tuning.new().lasso_range_px
	var stranded: Array[String] = []
	for rect: Rect2 in terrain.platforms:
		var stand := Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y)
		var best := INF
		for a: Vector2 in anchors:
			best = minf(best, a.distance_to(stand))
		if best > reach:
			stranded.append("(%d,%d) nearest %d px" % [int(stand.x), int(stand.y), int(best)])
	assert_eq(stranded.size(), 0,
		"no platform is out of rope reach of every anchor: %s" % ", ".join(stranded))

func test_you_can_leave_most_surfaces_in_more_than_one_direction() -> void:
	# One anchor is a route. Two or more is a choice, which is what makes the
	# space explorable rather than a sequence of single correct moves.
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	var anchors := _anchors()
	var reach: float = Tuning.new().lasso_range_px
	var with_choice := 0
	for rect: Rect2 in terrain.platforms:
		var stand := Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y)
		var n := 0
		for a: Vector2 in anchors:
			if a.distance_to(stand) <= reach:
				n += 1
		if n >= 2:
			with_choice += 1
	var ratio := float(with_choice) / float(terrain.platforms.size())
	assert_true(ratio >= 0.75,
		"at least three quarters of surfaces offer a choice of anchor (%.0f%%)" % (ratio * 100.0))

func test_all_three_creature_families_live_here() -> void:
	var families: Array[StringName] = []
	for encounter: Encounter in room.encounters():
		assert_true(encounter.is_content_valid(),
			"%s validates: %s" % [encounter.name, str(encounter.content_errors())])
		if not families.has(encounter.source.family_id):
			families.append(encounter.source.family_id)
	assert_eq(families.size(), 3, "ceramic, mural and pit all appear in one space")
	assert_true(room.encounters().size() >= 10,
		"and there are enough of them to populate a level this size, found %d" % room.encounters().size())

func test_no_door_is_opened_by_something_standing_next_to_it() -> void:
	# The level is explored outward, not walked through: a door whose switch is
	# within a screen of it is a door that may as well not be locked.
	var doors: Array[MechanismGate] = []
	var targets: Dictionary = {}
	for node: Node in _all(room):
		var gate := node as MechanismGate
		if gate != null:
			doors.append(gate)
		var target := node as ToolTarget
		if target != null and target.puzzle_id != &"":
			targets[target.puzzle_id] = target.global_position
	assert_true(doors.size() >= 4, "the level has several doors, found %d" % doors.size())
	for gate: MechanismGate in doors:
		assert_true(targets.has(gate.watched_puzzle_id),
			"door '%s' watches a puzzle that exists" % gate.name)
		var switch_at: Vector2 = targets[gate.watched_puzzle_id]
		var away := switch_at.distance_to(gate.global_position)
		assert_true(away > 640.0,
			"door '%s' is opened from at least a screen away (%d px)" % [gate.name, int(away)])

func test_traps_are_real_and_can_actually_hurt() -> void:
	var hazards: Array[Hazard] = []
	for node: Node in _all(room):
		var hazard := node as Hazard
		if hazard != null:
			hazards.append(hazard)
	assert_true(hazards.size() >= 8, "the level is trapped, found %d" % hazards.size())
	for hazard: Hazard in hazards:
		assert_true(hazard.damage >= 1, "'%s' does real damage" % hazard.name)

func test_every_puzzle_id_in_the_cistern_is_unique() -> void:
	var seen: Array[StringName] = []
	for node: Node in _all(room):
		var target := node as ToolTarget
		if target == null or target.puzzle_id == &"":
			continue
		assert_false(seen.has(target.puzzle_id),
			"puzzle_id '%s' is not reused" % target.puzzle_id)
		seen.append(target.puzzle_id)

func test_the_cistern_gives_the_keeper_a_supplicant_to_witness() -> void:
	# The one witnessed fact she has a written line for and no emitter anywhere
	# in the game: supplicant_protected.
	var supplicant := room.get_node_or_null(^"DrownedSupplicant") as SacredObject
	assert_not_null(supplicant, "there is a supplicant down here")
	assert_eq(supplicant.preserved_event_id, &"supplicant_protected",
		"leaving her alone is the fact the Keeper already has a line for")
