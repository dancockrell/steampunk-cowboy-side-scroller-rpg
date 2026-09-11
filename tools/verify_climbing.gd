extends SceneTree
## Verifies that a ladder can actually be climbed.
##
## Like the swing liftoff check, this cannot be a normal test: mounting depends
## on Area2D overlap and climbing on move_and_slide, and the headless `--script`
## harness never reaches a frame, so neither exists there.
##
##   godot --headless --fixed-fps 60 --path <copy> --script res://tools/verify_climbing.gd --quit-after 420
##
## --fixed-fps 60 is REQUIRED, not decoration. This script counts frames in
## _process while climbing happens in _physics_process, and headless with no
## vsync runs render frames far faster than physics ticks -- so the same climb
## measured 75, 77 and 99 px on three consecutive runs before the rate was
## pinned, and the wobble was entirely in the instrument. Pinned: 192 px, three
## runs, identical, against a theoretical 195 for 90 ticks at 130 px/s.
##
## Measured 11 Sep 2026: 192 px of ascent in 90 physics ticks on the gallery
## trellis (z12b), with the rope untouched.

const RIDE := 90
## A climb at 130px/s should cover ~195px in 90 frames. Anything under this is
## the ladder not being mounted, or gravity still winning.
const PASS_PX := 150.0

var f := 0
var m: Main
var start := Vector2.ZERO
var mounted_at := -1
var peak := 1.0e9

func _initialize() -> void:
	m = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Main
	root.add_child(m)

func _process(_delta: float) -> bool:
	f += 1
	if m.world_root == null:
		return false
	var p: Player = m.world_root.player
	if f == 4:
		m.world_root.load_room(load("res://levels/temple_clay_dead/sunken_cistern.tscn"))
		return false
	if p == null:
		return false
	if f == 8:
		# The gallery trellis (beat z12b) sits at (700, 1300), 340px tall, so it
		# spans y 1130..1470 -- and unlike z12a it has a clear column above it.
		# Two earlier versions of this probe aimed at ladders with a floor slab
		# crossing them and reported a broken mechanic that was working.
		p.global_position = Vector2(700, 1440)
		return false

	if f > 12 and mounted_at < 0:
		if not p.can_climb():
			if f > 120:
				print("NOT CHECKED: never overlapped a ladder; nothing was measured")
				return true
			return false
		start = p.global_position
		Input.action_press(&"jump")
		mounted_at = f
		return false

	if mounted_at > 0:
		peak = minf(peak, p.global_position.y)
	if mounted_at > 0 and f == mounted_at + RIDE:
		Input.action_release(&"jump")
		# Peak, not final position: he climbs off the top of the trellis and
		# falls back, and an earlier version of this check measured the landing
		# and reported 77px for a climb that had covered nearly 200.
		var climbed := start.y - peak
		print("climbed %d px in %d frames, mode=%d" % [int(climbed), RIDE, p.traversal_mode])
		if climbed >= PASS_PX:
			print("RESULT: PASSED (a ladder can be climbed)")
		else:
			print("RESULT: FAILED (the ladder did not lift him)")
		return true

	if f > 360:
		print("NOT CHECKED: the run never reached its measurement")
		return true
	return false
