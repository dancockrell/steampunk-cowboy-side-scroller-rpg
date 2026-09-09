class_name Main
extends Node
## Application root and world/portrait compositor (task F02).
##
## Two layers, deliberately: a 640x360 SubViewport for the pixel world with
## nearest filtering and INTEGER scaling, and a separate full-window UI layer at
## native resolution for high-detail divine portraits. A portrait must not
## collapse to world pixels, which is the whole reason the split exists
## (docs/art-direction.md, docs/architecture/engine-decision.md).

const WORLD_WIDTH := 640
const WORLD_HEIGHT := 360

@export var starting_room: PackedScene

var services: Services
var world_viewport: SubViewport
var world_root: WorldRoot
var ui_layer: CanvasLayer

var _booted: bool = false
var _last_window_size: Vector2i = Vector2i.ZERO

func _ready() -> void:
	boot()

## Explicit, idempotent start-up. Separate from _ready so a test can boot the
## real scene without waiting for a frame, and so the order of operations is
## readable in one place rather than implied by node order.
func boot() -> void:
	if _booted:
		return
	_booted = true
	services = Services.new()
	services.name = "Services"
	add_child(services)
	_load_authored_content()

	world_viewport = get_node_or_null(^"WorldViewportContainer/WorldViewport") as SubViewport
	ui_layer = get_node_or_null(^"UILayer") as CanvasLayer
	if world_viewport == null:
		push_error("Main: expected WorldViewportContainer/WorldViewport in the scene")
		return

	world_viewport.size = Vector2i(WORLD_WIDTH, WORLD_HEIGHT)
	world_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	world_root = get_node_or_null(^"WorldViewportContainer/WorldViewport/WorldRoot") as WorldRoot
	if world_root != null:
		world_root.bind(services)
		if starting_room != null:
			world_root.load_room(starting_room)

	var tree := get_tree()
	if tree != null and tree.get_root() != null:
		tree.get_root().size_changed.connect(_apply_integer_scale)
	_apply_integer_scale()

## Authored records that the whole game reads. Loaded once, here, so no
## subsystem has to know a file path.
func _load_authored_content() -> void:
	var keeper := Heroine.load_from_file("res://narrative/characters/keeper_of_the_clay_dead.json")
	if keeper != null:
		services.relationships.register(keeper)

## Scales the low-resolution world by a whole number only. A fractional scale
## puts uneven pixel widths on a pixel-art stage, which is exactly the artefact
## the nearest filter is there to avoid.
## Recomputed whenever the window size actually differs from the size the
## current scale was calculated for. The size_changed signal alone is not
## enough: boot can run before the window has settled, and then the world stays
## stuck at the scale it was given, which is how it silently rendered at 1x in a
## 1280x720 window during a capture.
func _process(_delta: float) -> void:
	var window := get_window()
	if window != null and window.size != _last_window_size:
		_apply_integer_scale()

func _apply_integer_scale() -> void:
	var container := get_node_or_null(^"WorldViewportContainer") as SubViewportContainer
	if container == null:
		return
	var window := get_window()
	if window == null:
		return
	_last_window_size = window.size
	var window_size := Vector2(window.size)
	var scale := maxi(1, int(floor(minf(
		window_size.x / float(WORLD_WIDTH),
		window_size.y / float(WORLD_HEIGHT)))))
	container.scale = Vector2(scale, scale)
	container.size = Vector2(WORLD_WIDTH, WORLD_HEIGHT)
	# Centre the scaled world; the letterbox is the clear colour behind it.
	container.position = ((window_size - Vector2(WORLD_WIDTH, WORLD_HEIGHT) * scale) * 0.5).floor()

func current_scale() -> int:
	var container := get_node_or_null(^"WorldViewportContainer") as SubViewportContainer
	return int(container.scale.x) if container != null else 1
