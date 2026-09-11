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

func _beats() -> Array:
	var f := FileAccess.open("res://data/levels/sunken_cistern_beats.json", FileAccess.READ)
	assert_not_null(f, "the beat sheet ships with the level")
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed as Array

func test_the_level_is_authored_as_beats_not_filled_with_furniture() -> void:
	# The rule this level is built under: nothing exists in it unless it belongs
	# to a named beat with a written intent. The first version of this level was
	# 123 platforms and 129 anchors emitted by `while` loops -- big, and telling
	# about eight stories. Counting beats is the check that stops that returning.
	var beats := _beats()
	assert_true(beats.size() >= 100,
		"the level is authored as at least a hundred situations, found %d" % beats.size())
	var ids: Array = []
	for beat: Variant in beats:
		var b: Dictionary = beat
		var intent := String(b.get("intent", ""))
		var id := String(b.get("id", ""))
		assert_false(ids.has(id), "beat id '%s' is used once" % id)
		ids.append(id)
		# A one-liner is a caption. A beat has to say what the player sees,
		# what they will try, what it costs and what the better play is, and
		# that does not fit in a sentence -- so the floor is a paragraph.
		assert_true(intent.length() >= 240,
			"beat '%s' is designed, not captioned (%d chars): '%s'" % [id, intent.length(), intent])
		assert_true(intent.count(". ") >= 2,
			"beat '%s' is more than one sentence long" % id)

func test_every_beat_is_inside_the_level() -> void:
	var bounds := room.camera_bounds()
	for beat: Variant in _beats():
		var b: Dictionary = beat
		var at := Vector2(float(b["x"]), float(b["y"]))
		assert_true(bounds.has_point(at),
			"beat '%s' is placed inside the room at %s" % [String(b["id"]), str(at)])

func test_beats_are_spread_through_the_space_rather_than_clumped() -> void:
	# 102 beats stacked in one corner would pass a count and fail the point.
	# Every quarter of the map has to carry real content.
	var bounds := room.camera_bounds()
	var quadrant := [0, 0, 0, 0]
	for beat: Variant in _beats():
		var b: Dictionary = beat
		var right := float(b["x"]) > bounds.size.x * 0.5
		var low := float(b["y"]) > bounds.size.y * 0.5
		quadrant[(1 if right else 0) + (2 if low else 0)] += 1
	for i in 4:
		assert_true(quadrant[i] >= 10,
			"quadrant %d holds real content, not filler (%d beats)" % [i, quadrant[i]])

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

## Michael's jump, derived from the tuning resource rather than copied out of
## it: rise is v^2/2g, and reach is run speed times the time up plus the time
## back down under the heavier fall gravity. Copying the numbers as literals
## would make this test agree with a tuning change it never saw.
func _jump_budget() -> Vector2:
	var t := Tuning.new()
	var rise := (t.jump_velocity * t.jump_velocity) / (2.0 * t.gravity)
	var up := absf(t.jump_velocity) / t.gravity
	var down := sqrt(2.0 * rise / (t.gravity * t.fall_gravity_multiplier))
	return Vector2(t.run_speed * (up + down), rise)

func _gap(a: Rect2, b: Rect2) -> float:
	return maxf(0.0, maxf(a.position.x - b.end.x, b.position.x - a.end.x))

func test_climbing_by_jumping_is_a_real_option_not_decoration() -> void:
	# A nav-graph pass over this level found 91% of its connections were rope
	# swings: shelves sat ~300px apart, so a player who could not swing could
	# not move. The rope is meant to be the fast, expressive route, not the
	# only one. This asserts the slow route exists: from most surfaces there is
	# somewhere higher within one jump.
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	assert_not_null(terrain, "the terrain exists")
	var budget := _jump_budget()
	assert_true(budget.x > 60.0 and budget.y > 40.0,
		"the jump budget is a real distance (%.0f px across, %.0f px up)" % [budget.x, budget.y])
	assert_true(terrain.platforms.size() >= 100,
		"the level still has its surfaces, found %d" % terrain.platforms.size())
	var climbable := 0
	for a: Rect2 in terrain.platforms:
		for b: Rect2 in terrain.platforms:
			if a == b:
				continue
			var rise := a.position.y - b.position.y
			if rise > 0.0 and rise <= budget.y and _gap(a, b) <= budget.x:
				climbable += 1
				break
	var ratio := float(climbable) / float(terrain.platforms.size())
	assert_true(ratio >= 0.5,
		"at least half the surfaces can be climbed out of by jumping (%d of %d, %.0f%%)"
			% [climbable, terrain.platforms.size(), ratio * 100.0])

func test_no_surface_is_cut_off_from_the_entry() -> void:
	# 19% of this level used to be unreachable from the spawn -- whole roof
	# walkways and the high eastern shelves, visible and impossible. The graph
	# below is deliberately conservative about what Michael can do (jump within
	# budget, drop straight down, or swing to something under an anchor within
	# rope length) so a pass here is not resting on a generous model.
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	var plats: Array[Rect2] = terrain.platforms
	var anchors := _anchors()
	var reach: float = Tuning.new().lasso_range_px
	var budget := _jump_budget()

	var links: Array[PackedInt32Array] = []
	for i in plats.size():
		links.append(PackedInt32Array())
	for i in plats.size():
		var a: Rect2 = plats[i]
		for j in plats.size():
			if i == j:
				continue
			var b: Rect2 = plats[j]
			var rise := a.position.y - b.position.y
			if rise <= budget.y and rise > -400.0 and _gap(a, b) <= budget.x:
				links[i].append(j)                      # jump across or down
			elif rise < 0.0 and _gap(a, b) <= 0.0:
				links[i].append(j)                      # drop off the edge
		for anchor: Vector2 in anchors:
			var near := Vector2(clampf(anchor.x, a.position.x, a.end.x), a.position.y)
			var rope := anchor.distance_to(near)
			if rope > reach:
				continue
			for j in plats.size():
				if i == j:
					continue
				var b: Rect2 = plats[j]
				if b.position.y <= anchor.y:
					continue
				if absf(clampf(anchor.x, b.position.x, b.end.x) - anchor.x) <= rope \
						and b.position.y - anchor.y <= rope + 40.0:
					links[i].append(j)

	var start := -1
	var spawn := (room.get_node_or_null(^"spawn_entry") as Marker2D).global_position
	var best := INF
	for i in plats.size():
		var top := Vector2(clampf(spawn.x, plats[i].position.x, plats[i].end.x), plats[i].position.y)
		var d := top.distance_to(spawn)
		if d < best:
			best = d
			start = i
	assert_true(start >= 0 and best < 200.0, "the entry spawn stands on a real surface")

	var seen := {start: true}
	var stack: Array[int] = [start]
	while not stack.is_empty():
		for j: int in links[stack.pop_back()]:
			if not seen.has(j):
				seen[j] = true
				stack.append(j)
	var missed: Array[String] = []
	for i in plats.size():
		if not seen.has(i):
			missed.append("(%d,%d)" % [int(plats[i].position.x), int(plats[i].position.y)])
	assert_eq(missed.size(), 0,
		"every surface is reachable from the entry; %d of %d are not: %s"
			% [missed.size(), plats.size(), ", ".join(missed)])

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

# --- ladders, trellises and chains ------------------------------------------

func _climbables() -> Array[Climbable]:
	var out: Array[Climbable] = []
	for node: Node in _all(room):
		var c := node as Climbable
		if c != null:
			out.append(c)
	return out

func test_every_vertical_region_has_a_climb_as_well_as_a_rope() -> void:
	# The rope is the fast, expressive way up and it asks for timing. A temple
	# that can ONLY be ascended by rope punishes a player who is bad at rope,
	# which is the same complaint that produced the jump-reachability work.
	var climbs := _climbables()
	assert_true(climbs.size() >= 5,
		"the cistern has climbable surfaces, found %d" % climbs.size())
	var bounds := room.camera_bounds()
	var left := 0
	var right := 0
	for c: Climbable in climbs:
		if c.global_position.x < bounds.size.x * 0.5:
			left += 1
		else:
			right += 1
	assert_true(left >= 2 and right >= 2,
		"both halves of the level can be climbed (%d west, %d east)" % [left, right])

func test_no_ladder_is_crossed_by_a_floor_slab() -> void:
	# The defect this exists for, found by driving a real climb: a ladder that
	# passes through a solid platform is a ladder you climb two pixels and stop
	# on, and it looks identical to a broken climbing mechanic from outside.
	# Four of the first six ladders authored here had a floor through them.
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	assert_not_null(terrain, "the terrain exists")
	var blocked: Array[String] = []
	for c: Climbable in _climbables():
		var span := c.vertical_span()
		for rect: Rect2 in terrain.platforms:
			var overlaps_x: bool = c.global_position.x > rect.position.x - 13.0 \
				and c.global_position.x < rect.end.x + 13.0
			var overlaps_y: bool = rect.end.y > span.x and rect.position.y < span.y
			if overlaps_x and overlaps_y:
				blocked.append("%s at x=%d crossed by a slab at y=%d"
					% [c.name, int(c.global_position.x), int(rect.position.y)])
				break
	assert_eq(blocked.size(), 0, "no climbable is blocked by terrain: %s" % ", ".join(blocked))

func test_a_climbable_declares_what_it_is_made_of() -> void:
	# Presentation only -- the simulation treats a vine exactly like an iron
	# ladder -- but a level that names its surfaces can look like a temple
	# rather than a set of identical brown rectangles.
	var kinds: Array[StringName] = []
	for c: Climbable in _climbables():
		assert_true(c.surface_kind != &"", "'%s' says what it is" % c.name)
		if not kinds.has(c.surface_kind):
			kinds.append(c.surface_kind)
	assert_true(kinds.size() >= 3,
		"the cistern uses more than one kind of climbable surface, found %s" % str(kinds))
