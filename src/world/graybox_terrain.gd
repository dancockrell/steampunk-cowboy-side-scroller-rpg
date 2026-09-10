class_name GrayboxTerrain
extends Node2D
## PLACEHOLDER GEOMETRY. Not art, and not an admitted asset.
##
## Builds collision bodies and flat blocks from authored rectangles so the slice
## is playable before any tileset exists. docs/art-direction.md requires
## collision to be authored separately from texture silhouettes, so this stays
## the source of collision truth even after art arrives: an admitted TileMapLayer
## renders on top of these rectangles rather than replacing them.
##
## Rectangles are in room-local pixels on the 32 px module from decision D06.

const PLACEHOLDER_FILL := Color(0.16, 0.13, 0.12, 1.0)
const PLACEHOLDER_EDGE := Color(0.34, 0.27, 0.21, 1.0)

@export var platforms: Array[Rect2] = []
## Drawn behind the player without collision, for reading depth in graybox.
@export var backdrop: Array[Rect2] = []
@export var backdrop_color: Color = Color(0.10, 0.08, 0.08, 1.0)
## Which of the room's up-to-three parallel planes this terrain belongs to
## (src/world/depth.gd). A room with only one GrayboxTerrain, left at the
## default NEAR, behaves exactly as it always has: this is additive, not a
## breaking change to any room authored before the depth system existed.
@export var depth_layer: Depth.Layer = Depth.Layer.NEAR

var _built: bool = false

func _ready() -> void:
	build()

## Explicit and idempotent, so room set-up has a defined order instead of
## depending on when _ready happens to fire. Room.bind() calls it directly.
func build() -> void:
	if _built:
		return
	_built = true
	# Colour only, deliberately not node scale: scaling this node would also
	# scale its StaticBody2D children's collision shapes in world space,
	# desyncing where a platform LOOKS like it is from where the player can
	# actually stand on it. The depth cue stays purely visual.
	modulate = Depth.modulate_for(depth_layer)
	for rect: Rect2 in backdrop:
		_add_block(rect, backdrop_color, false)
	for rect: Rect2 in platforms:
		_add_block(rect, PLACEHOLDER_FILL, true)

func _add_block(rect: Rect2, color: Color, solid: bool) -> void:
	var visual := Polygon2D.new()
	visual.name = "GrayboxBlock"
	visual.polygon = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.end,
		rect.position + Vector2(0.0, rect.size.y),
	])
	visual.color = color
	add_child(visual)

	if not solid:
		return
	# A light top edge so a landing surface reads without relying on colour
	# alone, which docs/gameplay-pillars.md requires of every gameplay signal.
	var edge := Line2D.new()
	edge.name = "GrayboxEdge"
	edge.width = 1.0
	edge.default_color = PLACEHOLDER_EDGE
	edge.points = PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0.0)])
	add_child(edge)

	var body := StaticBody2D.new()
	body.name = "GrayboxCollision"
	body.collision_layer = Depth.terrain_bit(depth_layer)
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.position + rect.size * 0.5
	body.add_child(shape)
	add_child(body)
