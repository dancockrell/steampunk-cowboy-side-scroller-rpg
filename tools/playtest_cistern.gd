extends SceneTree
## Plays the Sunken Cistern with real physics and reports what actually happens.
##
## Not a test. A test asserts something I already believed; this runs the level
## and tells me facts I do not have -- how long a crossing takes, where a bot
## with a simple policy gets stuck, whether the rope work is possible at all
## when a body with real collision tries it rather than when a distance check
## says an anchor is in range.
##
## Run headless: godot --headless --path <copy> --script res://tools/playtest_cistern.gd --quit-after 40000

const TICK := 1.0 / 60.0
const STUCK_S := 2.5

var m: Main
var room: Room
var player: Player
var anchors: Array[Vector2] = []
var lasso_range: float = 320.0

var frame := 0
var trial := 0
var trial_frame := 0
var goal: Vector2
var last_pos: Vector2
var stuck_s := 0.0
var swing_s := 0.0
var visited: Dictionary = {}          # 320px cell -> true
var report: Array[String] = []
var trial_log: Array = []
var damage_taken := 0
var falls := 0
var start_health := 5

# Waypoints along the route the design claims: entry, galleries, west descent,
# the water, the drowned shrine, the east tiers, the exit.
var GOALS: Array[Vector2] = [
	Vector2(1200, 700),    # z1c, the first cache off the entry
	Vector2(300, 1300),    # z2d, down into the galleries
	Vector2(480, 2450),    # z2k, the kiln bar at the bottom of the west
	Vector2(1900, 1220),   # z4d, the shaft island with the grate pin
	Vector2(2700, 2670),   # z9b, the drowned shrine
	Vector2(3600, 2076),   # z8a, the winch on the east tier
	Vector2(4980, 2640),   # z8l, the way out
]

func _initialize() -> void:
	m = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Main
	root.add_child(m)

func _ready_world() -> void:
	m.world_root.load_room(load("res://levels/temple_clay_dead/sunken_cistern.tscn"))
	room = m.world_root.room
	player = m.world_root.player
	lasso_range = m.services.tuning.lasso_range_px
	for node: Node in _all(room):
		var t := node as ToolTarget
		if t != null and t.allowed_verbs.has(&"swing"):
			anchors.append(t.global_position)
	start_health = player.health
	_begin_trial()

func _begin_trial() -> void:
	goal = GOALS[trial]
	trial_frame = 0
	stuck_s = 0.0
	last_pos = player.global_position
	report.append("trial %d -> %s from %s" % [trial, str(goal), str(player.global_position)])

func _all(n: Node) -> Array[Node]:
	var f: Array[Node] = []
	for c in n.get_children():
		f.append(c)
		f.append_array(_all(c))
	return f

func _nearest_anchor(from: Vector2, toward: Vector2) -> Vector2:
	var best := Vector2.INF
	var best_score := INF
	for a: Vector2 in anchors:
		var d := a.distance_to(from)
		if d > lasso_range or d < 24.0:
			continue
		# prefer anchors that are up and in the direction of travel
		var score := a.distance_to(toward) - (from.y - a.y) * 0.5
		if score < best_score:
			best_score = score
			best = a
	return best

func _process(_d: float) -> bool:
	frame += 1
	if frame == 3:
		_ready_world()
		return false
	if frame < 3 or player == null:
		return false

	trial_frame += 1
	var pos := player.global_position
	visited[Vector2i(int(pos.x / 320.0), int(pos.y / 320.0))] = true

	if player.health < start_health:
		damage_taken += start_health - player.health
		start_health = player.health

	# --- policy -----------------------------------------------------------
	var want := signf(goal.x - pos.x)
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	Input.action_release(&"jump")

	if player.traversal_mode == Player.TraversalMode.SWINGING:
		swing_s += TICK
		var gaining: bool = signf(player.velocity.x) == want
		# The release must have a hard ceiling as well as a condition. The first
		# version released only when the swing was carrying Michael the way he
		# wanted to go, and a pendulum that never satisfies that hangs forever:
		# four of seven trials ended at the identical pixel, which is what a
		# deadlocked harness looks like from the outside.
		if (swing_s > 0.55 and gaining) or swing_s > 1.6:
			player.end_swing()
			swing_s = 0.0
	else:
		if want > 0.0:
			Input.action_press(&"move_right")
		elif want < 0.0:
			Input.action_press(&"move_left")

		var needs_height: bool = pos.y - goal.y > 90.0
		var falling: bool = player.velocity.y > 60.0
		if (needs_height or falling or stuck_s > 0.5) and player.tools != null:
			var a := _nearest_anchor(pos, goal)
			if a != Vector2.INF:
				player.begin_swing(a)
				swing_s = 0.0
		elif player.is_on_floor() and stuck_s > 0.25:
			Input.action_press(&"jump")

	# --- progress / stuck -------------------------------------------------
	if pos.distance_to(last_pos) < 3.0:
		stuck_s += TICK
	else:
		stuck_s = 0.0
		last_pos = pos

	if pos.y > room.camera_bounds().end.y - 40.0:
		falls += 1

	var reached: bool = pos.distance_to(goal) < 180.0
	var gave_up: bool = stuck_s > STUCK_S or trial_frame > 60 * 90
	if reached or gave_up:
		trial_log.append({
			"trial": trial, "goal": goal, "reached": reached,
			"seconds": trial_frame * TICK, "ended_at": pos,
			"distance_left": pos.distance_to(goal),
		})
		trial += 1
		if trial >= GOALS.size():
			_finish()
			return true
		_begin_trial()
	return false

func _finish() -> void:
	print("\n=== SUNKEN CISTERN, PLAYED ===")
	var reached := 0
	var total := 0.0
	for r: Dictionary in trial_log:
		var ok: bool = r["reached"]
		if ok:
			reached += 1
		total += float(r["seconds"])
		print("  %-28s %s  %5.1fs   ended %s  (%d px short)" % [
			str(r["goal"]), ("REACHED" if ok else "STUCK  "),
			r["seconds"], str(Vector2i(r["ended_at"])), int(r["distance_left"])])
	print("  ---")
	print("  legs reached      : %d of %d" % [reached, trial_log.size()])
	print("  total play time   : %.1f s" % total)
	print("  damage taken      : %d" % damage_taken)
	print("  fell out of bounds: %d" % falls)
	print("  distinct 320px cells entered: %d" % visited.size())
	print("  encounters triggered: %d of %d" % [_triggered(), room.encounters().size()])

func _triggered() -> int:
	var n := 0
	for e: Encounter in room.encounters():
		if e.phase() != EncounterBook.Phase.DISGUISED:
			n += 1
	return n
