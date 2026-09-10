#!/usr/bin/env python3
"""Emit the Sunken Cistern level.

The SHAPE below is hand-authored -- every platform, chamber and route was
placed on purpose. Only the .tscn text is machine-written, because the level
holds a few hundred elements and hand-typing node declarations at that size is
how you get a corridor instead of a place.

Design rules this file follows:
  * It is a SPACE, not a route. Four ways off the entry ledge, three ways down
    the shaft, and the two halves of the cistern connect at four heights.
  * The lasso goes anywhere. Anchors are seeded so that from any standable
    surface at least one is inside the 320px lasso range, in more than one
    direction. Free movement, not a precision check per gap.
  * The pistol is NOT scarce. Two shrines refill it and it is the only
    damaging verb; ammo is never the puzzle.
"""
import math

W, H = 5120, 2880
FLOOR_Y = 2720          # water line / bottom
OUT = []

plat = []       # Rect2 solid
back = []       # Rect2 backdrop
nodes = []      # (kind, name, x, y, extra dict)

def P(x, y, w, h): plat.append((x, y, w, h))
def B(x, y, w, h): back.append((x, y, w, h))
def N(kind, name, x, y, **kw): nodes.append((kind, name, int(x), int(y), kw))

# ---------------------------------------------------------------- backdrop
B(64, 64, W - 128, H - 200)

# ---------------------------------------------------------------- the floor
# Broken, with water gaps you can fall into -- not a continuous walkway.
for x0, w in [(0, 760), (900, 520), (1560, 380), (2120, 300),
              (2600, 640), (3400, 420), (3980, 300), (4420, 700)]:
    P(x0, FLOOR_Y, w, 160)

# ---------------------------------------------------------------- entry ledge (top left)
P(0, 620, 620, 60)
P(700, 540, 300, 48)
P(1100, 700, 260, 48)

# ---------------------------------------------------------------- west wing: stepped galleries
west_tiers = [(120, 1000, 420), (300, 1320, 360), (90, 1640, 300),
              (380, 1900, 420), (140, 2200, 340), (420, 2460, 300)]
for x0, y, w in west_tiers:
    P(x0, y, w, 44)
P(0, 1180, 180, 44)
P(640, 1500, 220, 44)
P(560, 2060, 200, 44)

# ---------------------------------------------------------------- the great shaft (centre)
# Open from the roof to the water. You can drop it, or swing up it.
SHAFT_L, SHAFT_R = 1500, 2500
for y in (900, 1500, 2100):
    P(SHAFT_L - 40, y, 150, 40)          # west lip
    P(SHAFT_R - 110, y, 150, 40)         # east lip
P(1880, 1220, 260, 40)                   # island in the shaft
P(1760, 1820, 200, 40)
P(2160, 2380, 240, 40)

# ---------------------------------------------------------------- east wing: the kiln stack
east_tiers = [(2760, 760, 460), (3320, 1020, 380), (2880, 1300, 360),
              (3460, 1560, 420), (2960, 1840, 380), (3560, 2120, 340)]
for x0, y, w in east_tiers:
    P(x0, y, w, 44)
P(4200, 900, 420, 44)
P(4560, 1240, 360, 44)
P(4260, 1560, 300, 44)
P(4620, 1880, 340, 44)
P(4180, 2200, 380, 44)

# high roof walkway, reachable only by rope
P(1300, 300, 420, 40)
P(2200, 240, 520, 40)
P(3200, 320, 460, 40)
P(4100, 420, 400, 40)

# ---------------------------------------------------------------- spawn + shrines
N("spawn", "spawn_entry", 90, 620)
N("spawn", "spawn_from_procession", 90, 620)
N("shrine", "ShrineEntry", 210, 578, checkpoint="cistern_entry")
N("shrine", "ShrineDeep", 2740, 2678, checkpoint="cistern_deep")
N("shrine", "ShrineKiln", 4420, 2678, checkpoint="cistern_kiln")

# ---------------------------------------------------------------- swing anchors
# Seeded so movement is free in every direction. Hand-placed rows rather than
# a uniform lattice, so the space still reads as architecture.
ANCHOR_ROWS = [
    (520, 1500, 210, 430),    # under the entry ledge, out over the shaft
    (300, 4700, 260, 180),    # roof line, the whole width
    (260, 1400, 240, 780),    # west wing air
    (60, 1400, 235, 1150),    # west wing, tier by tier -- the first pass left a
    (60, 1400, 235, 1470),    # 1500px vertical gap here and seven surfaces were
    (60, 1400, 235, 1790),    # out of rope reach entirely, which is a place you
    (60, 1400, 235, 2100),    # can get stranded, not a hard route.
    (1560, 2460, 230, 700),   # shaft, upper
    (1560, 2460, 230, 1180),  # shaft, middle
    (1560, 2460, 230, 1660),  # shaft, lower
    (1600, 2440, 240, 2160),  # shaft, above the water
    (2700, 4800, 250, 620),   # east wing air, upper
    (2760, 4820, 250, 1120),
    (2820, 4800, 250, 1640),
    (2760, 4800, 250, 2120),
    (200, 1300, 260, 2320),   # west, low
    (3600, 4900, 260, 2400),  # east, low
    (200, 4900, 300, 2560),   # just over the water, so a fall is recoverable
]
ai = 0
for x0, x1, step, y in ANCHOR_ROWS:
    x = x0
    while x <= x1:
        ai += 1
        N("anchor", "Anchor%03d" % ai, x, y)
        x += step

# ---------------------------------------------------------------- hazards / traps
# Kiln vents on the east side, broken pottery in the water gaps.
for x in (960, 1620, 2180, 3460, 4040):
    N("hazard", "Shards%d" % x, x, FLOOR_Y + 40, w=180, h=90)
for x, y in [(3040, 1796), (3620, 1516), (4300, 1516), (2940, 1256)]:
    N("hazard", "KilnVent%d_%d" % (x, y), x, y, w=110, h=70)

# ---------------------------------------------------------------- enemies
ENEMIES = [
    ("jar", "cistern_jar_01", 380, 1276, "ceramic"),
    ("jar", "cistern_jar_02", 520, 2416, "ceramic"),
    ("jar", "cistern_jar_03", 2020, 1176, "ceramic"),
    ("jar", "cistern_jar_04", 4340, 856, "ceramic"),
    ("mural", "cistern_mural_01", 200, 1596, "inscription"),
    ("mural", "cistern_mural_02", 3040, 976, "inscription"),
    ("mural", "cistern_mural_03", 4700, 1196, "inscription"),
    ("pit", "cistern_pit_01", 2900, 2676, "burial_pit"),
    ("pit", "cistern_pit_02", 3560, 2676, "burial_pit"),
    ("pit", "cistern_pit_03", 4600, 2676, "burial_pit"),
    ("pit", "cistern_pit_04", 2280, 2336, "burial_pit"),
]
FAMILY = {"ceramic": ("ceramic", "ceramic_sentinel"),
          "inscription": ("inscription", "painted_procession_guard"),
          "burial_pit": ("pit", "burial_pit_assembler")}
for kind, sid, x, y, fam in ENEMIES:
    N("encounter", sid, x, y, family=fam)

# ---------------------------------------------------------------- doors + their puzzles
# Deliberately NOT in a chain. Each door is opened by something somewhere else,
# so the level is explored outward rather than walked through.
DOORS = [
    ("WestVaultDoor", 660, 1856, "cistern_west_winch", 3600, 2076, "pull",
     "the west winch, out on the east tiers"),
    ("RoofHatch", 2740, 396, "cistern_roof_latch", 1480, 356, "precision_hit",
     "a latch on the roof walkway, shot from across the gap"),
    ("KilnDoor", 4160, 2356, "cistern_kiln_bar", 420, 2416, "pull",
     "a bar in the west galleries"),
    ("ShaftGrate", 2280, 2236, "cistern_grate_pin", 2020, 1136, "precision_hit",
     "a pin above the shaft island"),
]
for door, dx, dy, pid, px, py, verb, _why in DOORS:
    N("door", door, dx, dy, watched=pid)
    N("target", pid, px, py, verb=verb, puzzle=pid, reward=pid + "_used")

# ---------------------------------------------------------------- caches
CACHES = [
    ("RoofCache", 2420, 196, "cistern_roof_cache"),
    ("WestVaultCache", 180, 1856, "cistern_west_cache"),
    ("KilnCache", 4760, 1836, "cistern_kiln_cache"),
    ("DrownedCache", 2760, 2676, "cistern_drowned_cache"),
    ("ShaftCache", 1820, 1776, "cistern_shaft_cache"),
]
for name, x, y, pid in CACHES:
    N("cache", name, x, y, puzzle=pid, reward=pid + "_found")

# ---------------------------------------------------------------- supplicant
N("supplicant", "DrownedSupplicant", 2660, 2676)

# ================================================================= emit
def rects(rs):
    return ", ".join("Rect2(%d, %d, %d, %d)" % r for r in rs)

ext = [
    ("Script", "res://src/world/room.gd", "1_room"),
    ("Script", "res://src/world/graybox_terrain.gd", "2_terrain"),
    ("Script", "res://src/world/tool_target.gd", "3_target"),
    ("Script", "res://src/world/checkpoint_shrine.gd", "4_shrine"),
    ("Script", "res://src/puzzles/mechanism_gate.gd", "5_gate"),
    ("Script", "res://src/emergence/encounter.gd", "6_encounter"),
    ("Script", "res://src/emergence/encounter_source.gd", "7_source"),
    ("Script", "res://src/world/encounter_trigger.gd", "8_trigger"),
    ("Script", "res://src/world/hazard.gd", "9_hazard"),
    ("Script", "res://src/world/sacred_object.gd", "10_sacred"),
    ("Script", "res://src/world/room_exit.gd", "11_exit"),
    ("PackedScene", "res://levels/temple_clay_dead/burial_works.tscn", "12_burial"),
]

L = []
sources = [n for n in nodes if n[0] == "encounter"]
load_steps = len(ext) + 5 + len(sources)
L.append("[gd_scene load_steps=%d format=3]\n" % load_steps)
for t, p, i in ext:
    L.append('[ext_resource type="%s" path="%s" id="%s"]' % (t, p, i))
L.append("")
L.append('[sub_resource type="RectangleShape2D" id="small_box"]\nsize = Vector2(28, 28)\n')
L.append('[sub_resource type="RectangleShape2D" id="trigger_box"]\nsize = Vector2(64, 160)\n')
L.append('[sub_resource type="RectangleShape2D" id="gate_box"]\nsize = Vector2(32, 112)\n')
L.append('[sub_resource type="RectangleShape2D" id="anchor_box"]\nsize = Vector2(30, 24)\n')
L.append('[sub_resource type="RectangleShape2D" id="supplicant_box"]\nsize = Vector2(34, 44)\n')

for kind, sid, x, y, kw in sources:
    stype, fam = FAMILY[kw["family"]]
    L.append('[sub_resource type="Resource" id="src_%s"]' % sid)
    L.append('script = ExtResource("7_source")')
    L.append('id = &"%s"' % sid)
    L.append('room_id = &"sunken_cistern"')
    L.append('source_type = &"%s"' % stype)
    L.append('family_id = &"%s"' % fam)
    L.append('trigger_id = &"%s_trigger"' % sid)
    L.append('spawn_point_id = &"%s_spawn"' % sid)
    L.append('tell_clip_id = &"%s_tell"' % fam)
    L.append('emerge_clip_id = &"%s_emerge"' % fam)
    L.append('resolved_visual_id = &"%s_resolved"' % fam)
    L.append('interrupt_rule = &"to_staggered_active"')
    L.append('blocked_spawn_policy = &"wait"')
    L.append('reward_event_id = &"%s_resolved"\n' % sid)

L.append('[node name="SunkenCistern" type="Node2D"]')
L.append('script = ExtResource("1_room")')
L.append('room_id = &"sunken_cistern"')
L.append('default_spawn_id = &"spawn_entry"')
L.append('bounds = Rect2(0, 0, %d, %d)\n' % (W, H))

L.append('[node name="Terrain" type="Node2D" parent="."]')
L.append('script = ExtResource("2_terrain")')
L.append('platforms = Array[Rect2]([%s])' % rects(plat))
L.append('backdrop = Array[Rect2]([%s])\n' % rects(back))

def poly(hw, hh):
    return "PackedVector2Array(%d, %d, %d, %d, %d, %d, %d, %d)" % (
        -hw, -hh, hw, -hh, hw, hh, -hw, hh)

for kind, name, x, y, kw in nodes:
    if kind == "spawn":
        L.append('[node name="%s" type="Marker2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)\n' % (x, y))
    elif kind == "shrine":
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('script = ExtResource("4_shrine")')
        L.append('checkpoint_id = &"%s"\n' % kw["checkpoint"])
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("small_box")\n')
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.42, 0.7, 0.62, 1)')
        L.append('polygon = %s\n' % poly(16, 16))
    elif kind == "anchor":
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 8')
        L.append('collision_mask = 0')
        L.append('script = ExtResource("3_target")')
        L.append('receiver_id = &"%s"' % name.lower())
        L.append('allowed_verbs = Array[StringName]([&"swing"])')
        L.append('puzzle_id = &"%s"\n' % name.lower())
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("anchor_box")\n')
        L.append('[node name="InteractionPoint" type="Marker2D" parent="%s"]\n' % name)
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.55, 0.75, 0.85, 1)')
        L.append('polygon = %s\n' % poly(15, 11))
    elif kind == "hazard":
        hw, hh = kw["w"] // 2, kw["h"] // 2
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('script = ExtResource("9_hazard")\n')
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("small_box")')
        L.append('scale = Vector2(%f, %f)\n' % (kw["w"] / 28.0, kw["h"] / 28.0))
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.72, 0.28, 0.18, 1)')
        L.append('polygon = %s\n' % poly(hw, hh))
    elif kind == "encounter":
        enc = "Enc_" + name
        L.append('[node name="%s" type="Node2D" parent="."]' % enc)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('script = ExtResource("6_encounter")')
        L.append('source = SubResource("src_%s")' % name)
        L.append('spawn_point_path = NodePath("SpawnPoint")')
        L.append('source_allowed_verbs = Array[StringName]([&"pull"])\n')
        L.append('[node name="SpawnPoint" type="Marker2D" parent="%s"]\n' % enc)
        trg = "Trig_" + name
        L.append('[node name="%s" type="Area2D" parent="."]' % trg)
        L.append('position = Vector2(%d, %d)' % (x - 150, y - 60))
        L.append('script = ExtResource("8_trigger")')
        L.append('encounter_path = NodePath("../%s")\n' % enc)
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % trg)
        L.append('shape = SubResource("trigger_box")\n')
    elif kind == "door":
        L.append('[node name="%s" type="StaticBody2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 1')
        L.append('collision_mask = 0')
        L.append('script = ExtResource("5_gate")')
        L.append('watched_puzzle_id = &"%s"' % kw["watched"])
        L.append('watched_field = &"uses"')
        L.append('open_offset = Vector2(0, -128)\n')
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("gate_box")\n')
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.30, 0.26, 0.24, 1)')
        L.append('polygon = %s\n' % poly(16, 56))
    elif kind in ("target", "cache"):
        col = "Color(0.62, 0.45, 0.30, 1)" if kind == "target" else "Color(0.78, 0.66, 0.28, 1)"
        verb = kw.get("verb", "pull")
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 8')
        L.append('collision_mask = 0')
        L.append('script = ExtResource("3_target")')
        L.append('receiver_id = &"%s"' % kw["puzzle"])
        L.append('allowed_verbs = Array[StringName]([&"%s"])' % verb)
        L.append('puzzle_id = &"%s"' % kw["puzzle"])
        L.append('reward_event_id = &"%s"\n' % kw["reward"])
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("small_box")\n')
        L.append('[node name="InteractionPoint" type="Marker2D" parent="%s"]\n' % name)
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = %s' % col)
        L.append('polygon = %s\n' % poly(14, 14))
    elif kind == "supplicant":
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 8')
        L.append('collision_mask = 0')
        L.append('script = ExtResource("10_sacred")')
        L.append('receiver_id = &"cistern_supplicant"')
        L.append('allowed_verbs = Array[StringName]([&"pull", &"precision_hit"])')
        L.append('puzzle_id = &"cistern_supplicant"')
        L.append('destroyed_event_id = &"supplicant_lost"')
        L.append('preserved_event_id = &"supplicant_protected"\n')
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("supplicant_box")\n')
        L.append('[node name="InteractionPoint" type="Marker2D" parent="%s"]\n' % name)
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.88, 0.84, 0.72, 1)')
        L.append('polygon = %s\n' % poly(17, 22))

L.append('[node name="ExitToBurialWorks" type="Area2D" parent="."]')
L.append('position = Vector2(4980, 2640)')
L.append('collision_layer = 0')
L.append('collision_mask = 2')
L.append('script = ExtResource("11_exit")')
L.append('next_room = ExtResource("12_burial")')
L.append('next_spawn_id = &"spawn_from_procession"\n')
L.append('[node name="Shape" type="CollisionShape2D" parent="ExitToBurialWorks"]')
L.append('shape = SubResource("gate_box")\n')
L.append('[node name="Graybox" type="Polygon2D" parent="ExitToBurialWorks"]')
L.append('color = Color(0.85, 0.75, 0.4, 1)')
L.append('polygon = %s\n' % poly(16, 56))

open("levels/temple_clay_dead/sunken_cistern.tscn", "w", newline="\n").write("\n".join(L))
print("platforms:", len(plat))
print("anchors  :", sum(1 for n in nodes if n[0] == "anchor"))
print("enemies  :", len(sources))
print("hazards  :", sum(1 for n in nodes if n[0] == "hazard"))
print("doors    :", sum(1 for n in nodes if n[0] == "door"))
print("targets  :", sum(1 for n in nodes if n[0] in ("target", "cache")))
print("size     : %dx%d = %.1f x %.1f screens" % (W, H, W / 640.0, H / 360.0))
