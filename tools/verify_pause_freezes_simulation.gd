extends SceneTree
## Boots the real game for real engine frames and confirms pause actually
## stops the simulation, rather than only that the code WOULD stop it if
## given a working tree.
##
## Why this exists as a separate script rather than a test in tests/run_tests.gd:
## that suite runs entirely inside SceneTree._initialize() and calls quit()
## before any frame is ever processed, so get_tree().paused, process_mode
## inheritance and is_inside_tree() can never be observed there (see
## docs/validation/gameplay-checks.md). This script boots main.tscn as the
## REAL main loop instead ("--quit-after N" lets real frames run), which is
## the only way to observe whether pausing the tree genuinely freezes
## anything. It stays --headless throughout: no window opens.
##
## Run with:
##   godot --headless --path <throwaway copy> --quit-after 290 \
##     --script res://tools/verify_pause_freezes_simulation.gd
##
## Sabotage record (see docs/validation/gameplay-checks.md for the outcome):
## setting Encounter.process_mode = ALWAYS at bind() time, and separately
## Player.process_mode = ALWAYS at bind() time, each turned this probe's
## verdict for that half to false and nothing else, confirming it actually
## discriminates a real pause bypass rather than reporting a fixed answer.

var frames := 0
var m: Main
var e: Encounter

var phase_at_pause := -1
var phase_stayed_frozen := true
var pos_at_pause := Vector2.ZERO
var pos_stayed_frozen := true
var moved_before_pause := false
var start_pos := Vector2.ZERO

const PAUSE_AT_FRAME := 100
const RESUME_AT_FRAME := 220
const TOTAL_FRAMES := 280

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	m = packed.instantiate() as Main
	root.add_child(m)

func _process(_delta: float) -> bool:
	frames += 1
	if frames == 5:
		# Cross the Entry Bridge into the Gallery so there is a real encounter
		# available to watch, rather than measuring an empty first room.
		var g := m.world_root.room
		(g.get_node_or_null(^"Counterweight") as ToolTarget).receive(Hit.new(&"lasso", Verbs.PULL, Vector2.ZERO))
		(g.get_node_or_null(^"ExitToGallery") as RoomExit)._on_body_entered(m.world_root.player)
	if frames == 10:
		e = m.world_root.room.get_node_or_null(^"JarEncounter") as Encounter
		e.set_target_position(Vector2(480, 288))
		e.trigger()
		start_pos = m.world_root.player.global_position
		Input.action_press(&"move_right")

	# Measured, not assumed: the real timeline (this same probe, unmodified,
	# with print statements at every phase change) shows "tell" -> "awakening"
	# at frame 142 when nothing is paused. Frame 100 sits inside "tell" with
	# margin either side of that transition; holding paused until frame 220
	# is well past where the transition would have landed if pause did
	# nothing.
	if frames == PAUSE_AT_FRAME:
		moved_before_pause = m.world_root.player.global_position.distance_to(start_pos) > 1.0
		phase_at_pause = int(e.phase())
		pos_at_pause = m.world_root.player.global_position
		m.pause_menu.toggle()
	if frames > PAUSE_AT_FRAME and frames < RESUME_AT_FRAME:
		if int(e.phase()) != phase_at_pause:
			phase_stayed_frozen = false
		if m.world_root.player.global_position.distance_to(pos_at_pause) > 0.01:
			pos_stayed_frozen = false
	if frames == RESUME_AT_FRAME:
		m.pause_menu.toggle()

	if frames < TOTAL_FRAMES:
		return false

	var phase_advanced_after_resume := int(e.phase()) != phase_at_pause
	var tree_reports_paused_as_the_menu_saw_it := m.pause_menu != null

	print("RESULT phase_at_pause=%s moved_before_pause=%s phase_frozen_while_paused=%s position_frozen_while_paused=%s phase_advanced_after_resume=%s final_phase=%s"
		% [EncounterBook.PHASE_NAMES[phase_at_pause], moved_before_pause, phase_stayed_frozen,
			pos_stayed_frozen, phase_advanced_after_resume, EncounterBook.PHASE_NAMES[int(e.phase())]])

	var ok := moved_before_pause and phase_stayed_frozen and pos_stayed_frozen and phase_advanced_after_resume
	print("VERDICT: %s" % ("PAUSE ACTUALLY FREEZES THE SIMULATION" if ok else "PAUSE DID NOT FREEZE SOMETHING IT SHOULD HAVE"))
	quit(0 if ok else 1)
	return true
