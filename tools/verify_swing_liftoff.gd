extends SceneTree
## Verifies that a rope thrown from a standing start actually swings.
##
## This cannot be a normal test. tests/ runs under `--headless --script`, which
## never reaches a frame, so `move_and_slide`, `move_and_collide` and
## `is_on_floor` -- the three things this behaviour is entirely made of -- do
## nothing there. It lives here for the same reason
## tools/verify_pause_freezes_simulation.gd does.
##
##   godot --headless --path <throwaway copy> --script res://tools/verify_swing_liftoff.gd --quit-after 300
##
## Measured on 10 Sep 2026:
##   before the liftoff:   1 px of travel in 60 frames (pinned)
##   after  the liftoff: 106 px
##
## The failure it guards against: Player._physics_swinging drives the pendulum
## through move_and_collide, so with ground underfoot the first step collides
## and slide() eats the velocity, every frame, forever. The lasso is the
## identity tool of this game and it did nothing from the most natural place a
## player would ever throw it from.

const SETTLE_LIMIT := 240
const RIDE_FRAMES := 60
## Anything below this is the bug back again. A working throw moves a hundred
## pixels; the broken one moved one.
const PASS_PX := 60.0

var f := 0
var m: Main
var start := Vector2.ZERO
var settled := -1
var swung := false

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
		# Dropped just above the entry ledge and allowed to land, rather than
		# teleported and assumed grounded: an earlier version of this check
		# asserted on a frame where is_on_floor() was still false, so the branch
		# under test never ran and it measured nothing at all.
		p.global_position = Vector2(300, 560)
		return false

	if f > 10 and settled < 0 and p.is_on_floor():
		settled = f
		start = p.global_position
		return false

	if settled > 0 and not swung and f == settled + 2:
		if not p.is_on_floor():
			print("NOT CHECKED: never reached a grounded frame; nothing was measured")
			return true
		p.begin_swing(Vector2(420, 430))
		swung = true
		return false

	if swung and f == settled + 2 + RIDE_FRAMES:
		var moved := p.global_position.distance_to(start)
		print("grounded throw travelled %d px in %d frames" % [int(moved), RIDE_FRAMES])
		if moved >= PASS_PX:
			print("RESULT: PASSED (a rope thrown while standing actually swings)")
		else:
			print("RESULT: FAILED (the floor is eating the pendulum again)")
		return true

	if f > SETTLE_LIMIT:
		print("NOT CHECKED: the player never settled on a floor; nothing was measured")
		return true
	return false
