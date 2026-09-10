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

## Vertical extent of everything this node draws, so height can be shaded.
## Computed from its own rectangles rather than read off the room, which keeps
## the terrain drawable on its own in a test or a tool.
func _vertical_span() -> Vector2:
	var top := INF
	var bottom := -INF
	for list: Array[Rect2] in [platforms, backdrop]:
		for r: Rect2 in list:
			top = minf(top, r.position.y)
			bottom = maxf(bottom, r.end.y)
	if top == INF:
		return Vector2(0.0, 1.0)
	return Vector2(top, maxf(bottom, top + 1.0))

## How high in the space this rectangle sits, 0 at the roof and 1 at the floor.
func _depth_ratio(rect: Rect2) -> float:
	var span := _vertical_span()
	return clampf((rect.position.y - span.x) / (span.y - span.x), 0.0, 1.0)

func _add_block(rect: Rect2, color: Color, solid: bool) -> void:
	# Light falls from above in this temple, so a slab low in the cistern is
	# darker than one near the roof. Without this every screen of a 2880px-tall
	# level renders identically and the player cannot tell how deep they are --
	# which was the single loudest complaint about the first render of the
	# Sunken Cistern: "every screen looks like every other screen".
	var lit := color.lerp(Color(0.02, 0.02, 0.03, color.a), _depth_ratio(rect) * 0.45)

	var visual := Polygon2D.new()
	visual.name = "GrayboxBlock"
	visual.polygon = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.end,
		rect.position + Vector2(0.0, rect.size.y),
	])
	visual.color = lit
	add_child(visual)

	if not solid:
		return

	# A slab is drawn as masonry rather than a bar: a lit cap along the top few
	# pixels and a darker underside. A flat rectangle reads as a floating line
	# and gives the eye nothing to measure distance against.
	var cap_h := minf(6.0, rect.size.y * 0.34)
	var cap := Polygon2D.new()
	cap.name = "GrayboxCap"
	cap.polygon = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + Vector2(rect.size.x, cap_h),
		rect.position + Vector2(0.0, cap_h),
	])
	cap.color = lit.lerp(PLACEHOLDER_EDGE, 0.55)
	add_child(cap)

	if rect.size.y > cap_h + 4.0:
		var under := Polygon2D.new()
		under.name = "GrayboxUnderside"
		under.polygon = PackedVector2Array([
			rect.position + Vector2(0.0, rect.size.y - 3.0),
			rect.position + Vector2(rect.size.x, rect.size.y - 3.0),
			rect.end,
			rect.position + Vector2(0.0, rect.size.y),
		])
		under.color = lit.darkened(0.45)
		add_child(under)

	# A bright hairline on the standing surface itself. docs/gameplay-pillars.md
	# requires every gameplay signal to read without relying on colour alone, and
	# this is the line that says "you can stand here".
	var edge := Line2D.new()
	edge.name = "GrayboxEdge"
	edge.width = 2.0
	edge.default_color = PLACEHOLDER_EDGE.lerp(Color(1, 0.94, 0.82, 1), 0.35)
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
