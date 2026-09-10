extends SceneTree
## A control socket so an external bot can play the game.
##
## Godot's job here is deliberately small: apply input, advance frames, report
## state, save a frame to disk. All the thinking -- reading the level, building
## a navigation graph, planning, judging whether the level is any good -- lives
## in tools/playbot.py, because that is where it can look at pictures.
##
## Newline-delimited JSON both ways. One long-lived window, driven for as long
## as the bot wants it, rather than a process launched per question.
##
## godot --path <copy> --script res://tools/bot_server.gd -- --port 877

const PORT_DEFAULT := 8777
## Every action `act` owns. Anything here is released before the new press
## set is applied, so each round trip is a clean edge for just_pressed.
const ACT_ACTIONS := ["move_left", "move_right", "jump", "tool_use",
		"tool_pistol", "tool_lasso", "tool_cancel", "reload"]

var server := TCPServer.new()
var peer: StreamPeerTCP
var m: Main
var buffer := ""
var booted := false
var frames_to_step := 0
var pending: Dictionary = {}

func _initialize() -> void:
	var port := PORT_DEFAULT
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
	var err := server.listen(port, "127.0.0.1")
	print("bot_server listening on 127.0.0.1:%d (err %d)" % [port, err])
	m = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Main
	root.add_child(m)

func _process(_delta: float) -> bool:
	if not booted:
		booted = true
		return false

	# A new client always wins. The first version only accepted a connection
	# when `peer` was null, and a client that died left a socket that still
	# reported CONNECTED, so every later run timed out against a server that
	# was healthy and holding a corpse.
	if server.is_connection_available():
		peer = server.take_connection()
		buffer = ""
		frames_to_step = 0
		pending = {}
		print("bot connected")

	if frames_to_step > 0:
		frames_to_step -= 1
		if frames_to_step == 0 and not pending.is_empty():
			_reply(_state() if pending.has("__state") else pending)
			pending = {}
		return false

	if peer == null:
		return false
	peer.poll()
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		peer = null
		return false

	var available := peer.get_available_bytes()
	if available > 0:
		buffer += peer.get_utf8_string(available)
	var newline := buffer.find("\n")
	if newline < 0:
		return false
	var line := buffer.substr(0, newline)
	buffer = buffer.substr(newline + 1)
	return _handle(line)

func _handle(line: String) -> bool:
	var parsed: Variant = JSON.parse_string(line)
	if typeof(parsed) != TYPE_DICTIONARY:
		_reply({"ok": false, "error": "bad json"})
		return false
	var cmd: Dictionary = parsed
	var what := String(cmd.get("cmd", ""))

	match what:
		"quit":
			_reply({"ok": true})
			return true
		"load_room":
			m.world_root.load_room(load(String(cmd["scene"])))
			frames_to_step = 4
			pending = {"ok": true}
		"state":
			_reply(_state())
		"level":
			_reply(_level())
		"press":
			Input.action_press(StringName(String(cmd["action"])))
			_reply({"ok": true})
		"release":
			Input.action_release(StringName(String(cmd["action"])))
			_reply({"ok": true})
		"release_all":
			for a: String in ["move_left", "move_right", "jump", "tool_use"]:
				Input.action_release(StringName(a))
			_reply({"ok": true})
		"swing":
			m.world_root.player.begin_swing(Vector2(float(cmd["x"]), float(cmd["y"])))
			_reply({"ok": true})
		"release_swing":
			if m.world_root.player.traversal_mode == Player.TraversalMode.SWINGING:
				m.world_root.player.end_swing()
			_reply({"ok": true})
		"teleport":
			m.world_root.player.global_position = Vector2(float(cmd["x"]), float(cmd["y"]))
			m.world_root.player.velocity = Vector2.ZERO
			_reply({"ok": true})
		"step":
			frames_to_step = maxi(1, int(cmd.get("n", 1)))
			pending = {"ok": true}
		"act":
			# One round trip per decision: set the whole input state, advance a
			# few frames, come back with the world. The chatty version of this
			# protocol was capped at one command per rendered frame, which made
			# the bot slower than the thing it was measuring.
			# Tool actions are released here too, not only movement. The
			# controller reads them with is_action_just_pressed, so an action
			# left held from the previous `act` never fires a second time --
			# which is why a bot that held tool_use got exactly one shot and
			# then stood there while an enemy body blocked the ledge.
			for a: String in ACT_ACTIONS:
				Input.action_release(StringName(a))
			for a: Variant in cmd.get("press", []):
				Input.action_press(StringName(String(a)))
			if cmd.has("swing_at"):
				var at: Array = cmd["swing_at"]
				m.world_root.player.begin_swing(Vector2(float(at[0]), float(at[1])))
			if bool(cmd.get("release_swing", false)) \
					and m.world_root.player.traversal_mode == Player.TraversalMode.SWINGING:
				m.world_root.player.end_swing()
			frames_to_step = maxi(1, int(cmd.get("n", 4)))
			pending = {"__state": true}
		"camera":
			var cam := m.world_root.camera
			cam.zoom = Vector2(float(cmd.get("zoom", 1.0)), float(cmd.get("zoom", 1.0)))
			if cmd.has("x"):
				m.world_root.set_process(false)
				cam.global_position = Vector2(float(cmd["x"]), float(cmd["y"]))
			else:
				m.world_root.set_process(true)
			_reply({"ok": true})
		"shot":
			var img := root.get_texture().get_image()
			if img == null:
				_reply({"ok": false, "error": "no pixels: running headless?"})
			else:
				img.save_png(String(cmd["path"]))
				_reply({"ok": true, "path": String(cmd["path"])})
		_:
			_reply({"ok": false, "error": "unknown cmd '%s'" % what})
	return false

func _state() -> Dictionary:
	var p := m.world_root.player
	var room := m.world_root.room
	var encounters: Array = []
	for e: Encounter in room.encounters():
		encounters.append({
			"id": String(e.source.id), "family": String(e.source.family_id),
			"phase": e.phase(), "at": [e.global_position.x, e.global_position.y],
		})
	var gates: Array = []
	for node: Node in _all(room):
		var gate := node as MechanismGate
		if gate != null:
			gates.append({"puzzle": String(gate.watched_puzzle_id), "open": gate.is_open()})
	return {
		"ok": true,
		"gates": gates,
		"pos": [p.global_position.x, p.global_position.y],
		"vel": [p.velocity.x, p.velocity.y],
		"health": p.health,
		"on_floor": p.is_on_floor(),
		"swinging": p.traversal_mode == Player.TraversalMode.SWINGING,
		"room": String(room.room_id),
		"encounters": encounters,
	}

func _level() -> Dictionary:
	var room := m.world_root.room
	var platforms: Array = []
	var terrain := room.get_node_or_null(^"Terrain") as GrayboxTerrain
	for r: Rect2 in terrain.platforms:
		platforms.append([r.position.x, r.position.y, r.size.x, r.size.y])
	var anchors: Array = []
	var hazards: Array = []
	var caches: Array = []
	var doors: Array = []
	for node: Node in _all(room):
		var t := node as ToolTarget
		if t != null and t.allowed_verbs.has(&"swing"):
			anchors.append([t.global_position.x, t.global_position.y])
		elif t != null:
			# The verb matters: the bot has two tools and a target that wants a
			# rope cannot be opened with a bullet. Without this it had to guess,
			# and a wrong guess is refused silently by ToolTarget.receive.
			var verbs: Array = []
			for v: StringName in t.allowed_verbs:
				verbs.append(String(v))
			caches.append({
				"at": [t.global_position.x, t.global_position.y],
				"puzzle": String(t.puzzle_id), "verbs": verbs,
			})
		var h := node as Hazard
		if h != null:
			hazards.append([h.global_position.x, h.global_position.y])
		# A locked gate is solid, invisible to the platform list, and sits in the
		# middle of routes. The bot spent whole legs walking into Door_z10a at
		# (660, 1856) with a velocity of exactly zero, blaming the physics for a
		# puzzle it had never been told about.
		var gate := node as MechanismGate
		if gate != null:
			var box := Rect2(gate.global_position - Vector2(16.0, 16.0), Vector2(32.0, 32.0))
			for c: Node in gate.get_children():
				var cs := c as CollisionShape2D
				if cs != null and cs.shape is RectangleShape2D:
					var ext: Vector2 = (cs.shape as RectangleShape2D).size * 0.5
					box = Rect2(cs.global_position - ext, ext * 2.0)
			doors.append({
				"rect": [box.position.x, box.position.y, box.size.x, box.size.y],
				"open": gate.is_open(), "puzzle": String(gate.watched_puzzle_id),
			})
	var tuning := m.services.tuning
	return {
		"ok": true,
		"bounds": [room.bounds.position.x, room.bounds.position.y, room.bounds.size.x, room.bounds.size.y],
		"platforms": platforms, "anchors": anchors, "hazards": hazards, "targets": caches,
		"doors": doors,
		"tuning": {
			"run_speed": tuning.run_speed, "gravity": tuning.gravity,
			"jump_velocity": tuning.jump_velocity,
			"fall_gravity_multiplier": tuning.fall_gravity_multiplier,
			"lasso_range_px": tuning.lasso_range_px,
		},
	}

func _all(n: Node) -> Array[Node]:
	var f: Array[Node] = []
	for c in n.get_children():
		f.append(c)
		f.append_array(_all(c))
	return f

func _reply(d: Dictionary) -> void:
	if peer != null:
		peer.put_data((JSON.stringify(d) + "\n").to_utf8_buffer())
