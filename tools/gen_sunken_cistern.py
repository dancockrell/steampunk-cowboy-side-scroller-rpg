#!/usr/bin/env python3
"""Emit the Sunken Cistern.

THE RULE THIS FILE EXISTS TO ENFORCE: nothing goes in the level unless it
belongs to a named beat with a written intent. The first version of this
level placed 123 platforms and 129 anchors in `while` loops and it told
maybe eight stories in eight screens; the rest was wallpaper. A beat is a
small authored situation -- you see something, you understand something,
you choose something, or something happens to you. One hundred of them,
each one line of intent, is the level.

Beats are grouped into zones that teach, then complicate, then combine.
Coordinates inside a beat are RELATIVE to the beat's own origin, so a beat
can be moved without unpicking it.

Element kinds:
  ledge  w        a standable slab
  anchor          a lasso anchor (swing)
  jar/mural/pit   an encounter, with its trigger placed DELIBERATELY --
                  in front to warn, behind to ambush, across a gap to
                  make it emerge while you are committed to a swing
  vent   w,h      a hazard
  chime           pistol target, no reward: forces a tell early
  switch verb,id  opens the door with that id, from wherever it is
  door   id       a mechanism gate
  cache           a reward
  urn             a sacred object: destroying it is a judged act
"""

W, H = 5120, 2880
FLOOR_Y = 2720

plat, back, nodes = [], [], []
BEATS = []

def P(x, y, w, h=26): plat.append((int(x), int(y), int(w), int(h)))
def B(x, y, w, h): back.append((x, y, w, h))
def N(kind, name, x, y, **kw): nodes.append((kind, name, int(x), int(y), kw))

def beat(bid, x, y, intent, *elements):
    """One authored situation. Every element in the level comes through here."""
    BEATS.append((bid, x, y, intent))
    for el in elements:
        kind = el[0]
        ex, ey = x + el[1], y + el[2]
        rest = el[3:]
        if kind == "ledge":
            P(ex, ey, rest[0])
        elif kind == "anchor":
            N("anchor", "A_%s_%d" % (bid, len([n for n in nodes if n[1].startswith("A_" + bid)])), ex, ey)
        elif kind in ("jar", "mural", "pit"):
            tx, ty = x + rest[0], y + rest[1]
            N("encounter", "%s_%s" % (bid, kind), ex, ey, family=kind, tx=tx, ty=ty)
        elif kind == "vent":
            N("hazard", "H_%s_%d" % (bid, len([n for n in nodes if n[1].startswith("H_" + bid)])),
              ex, ey, w=rest[0], h=rest[1])
        elif kind == "chime":
            N("target", "Chime_%s" % bid, ex, ey, verb="precision_hit",
              puzzle="chime_%s" % bid, reward="chime_%s_rung" % bid)
        elif kind == "switch":
            N("target", "Switch_%s" % bid, ex, ey, verb=rest[0],
              puzzle=rest[1], reward=rest[1] + "_used")
        elif kind == "door":
            N("door", "Door_%s" % bid, ex, ey, watched=rest[0])
        elif kind == "cache":
            N("cache", "Cache_%s" % bid, ex, ey, puzzle="cache_%s" % bid,
              reward="cache_%s_found" % bid)
        elif kind == "urn":
            n = len([q for q in nodes if q[0] == "urn" and q[1].startswith("Urn_" + bid)])
            suffix = bid if n == 0 else "%s_%d" % (bid, n)
            name = "DrownedSupplicant" if bid == "z9b" else "Urn_" + suffix
            N("urn", name, ex, ey, puzzle="urn_" + suffix)
        elif kind == "shrine":
            N("shrine", "Shrine_%s" % bid, ex, ey, checkpoint="cistern_%s" % bid)
        elif kind == "spawn":
            N("spawn", rest[0], ex, ey)

B(64, 64, W - 128, H - 200)

# Intents are normalised here rather than in the beat sheet so the prose can be
# written as readable indented paragraphs in cistern_beats.py.
_raw_beat = beat
def beat(bid, x, y, intent, *elements):
    _raw_beat(bid, x, y, " ".join(intent.split()), *elements)

import cistern_beats
cistern_beats.author(beat, FLOOR_Y)

FAMILY = {"jar": ("ceramic", "ceramic_sentinel"),
          "mural": ("inscription", "painted_procession_guard"),
          "pit": ("pit", "burial_pit_assembler")}

# ================================================================= emit
def rects(rs):
    return ", ".join("Rect2(%d, %d, %d, %d)" % r for r in rs)

def poly(hw, hh):
    return "PackedVector2Array(%d, %d, %d, %d, %d, %d, %d, %d)" % (
        -hw, -hh, hw, -hh, hw, hh, -hw, hh)

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

sources = [n for n in nodes if n[0] == "encounter"]
L = ["[gd_scene load_steps=%d format=3]\n" % (len(ext) + 5 + len(sources))]
for t, p, i in ext:
    L.append('[ext_resource type="%s" path="%s" id="%s"]' % (t, p, i))
L.append("")
for sid, sz in [("small_box", "28, 28"), ("trigger_box", "64, 160"),
                ("gate_box", "32, 112"), ("anchor_box", "30, 24"),
                ("supplicant_box", "34, 44")]:
    L.append('[sub_resource type="RectangleShape2D" id="%s"]\nsize = Vector2(%s)\n' % (sid, sz))

for _k, name, _x, _y, kw in sources:
    stype, fam = FAMILY[kw["family"]]
    L.append('[sub_resource type="Resource" id="src_%s"]' % name)
    L.append('script = ExtResource("7_source")')
    L.append('id = &"%s"' % name)
    L.append('room_id = &"sunken_cistern"')
    L.append('source_type = &"%s"' % stype)
    L.append('family_id = &"%s"' % fam)
    L.append('trigger_id = &"%s_trigger"' % name)
    L.append('spawn_point_id = &"%s_spawn"' % name)
    L.append('tell_clip_id = &"%s_tell"' % fam)
    L.append('emerge_clip_id = &"%s_emerge"' % fam)
    L.append('resolved_visual_id = &"%s_resolved"' % fam)
    L.append('interrupt_rule = &"to_staggered_active"')
    L.append('blocked_spawn_policy = &"wait"')
    L.append('reward_event_id = &"%s_resolved"\n' % name)

L.append('[node name="SunkenCistern" type="Node2D"]')
L.append('script = ExtResource("1_room")')
L.append('room_id = &"sunken_cistern"')
L.append('default_spawn_id = &"spawn_entry"')
L.append('bounds = Rect2(0, 0, %d, %d)\n' % (W, H))
L.append('[node name="Terrain" type="Node2D" parent="."]')
L.append('script = ExtResource("2_terrain")')
L.append('platforms = Array[Rect2]([%s])' % rects(plat))
L.append('backdrop = Array[Rect2]([%s])\n' % rects(back))

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
        L.append('collision_layer = 8\ncollision_mask = 0')
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
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('script = ExtResource("9_hazard")\n')
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("small_box")')
        L.append('scale = Vector2(%f, %f)\n' % (kw["w"] / 28.0, kw["h"] / 28.0))
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.72, 0.28, 0.18, 1)')
        L.append('polygon = %s\n' % poly(kw["w"] // 2, kw["h"] // 2))
    elif kind == "encounter":
        enc, trg = "Enc_" + name, "Trig_" + name
        L.append('[node name="%s" type="Node2D" parent="."]' % enc)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('script = ExtResource("6_encounter")')
        L.append('source = SubResource("src_%s")' % name)
        L.append('spawn_point_path = NodePath("SpawnPoint")')
        L.append('source_allowed_verbs = Array[StringName]([&"pull"])\n')
        L.append('[node name="SpawnPoint" type="Marker2D" parent="%s"]\n' % enc)
        L.append('[node name="%s" type="Area2D" parent="."]' % trg)
        L.append('position = Vector2(%d, %d)' % (kw["tx"], kw["ty"]))
        L.append('script = ExtResource("8_trigger")')
        L.append('encounter_path = NodePath("../%s")\n' % enc)
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % trg)
        L.append('shape = SubResource("trigger_box")\n')
    elif kind == "door":
        L.append('[node name="%s" type="StaticBody2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 1\ncollision_mask = 0')
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
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 8\ncollision_mask = 0')
        L.append('script = ExtResource("3_target")')
        L.append('receiver_id = &"%s"' % kw["puzzle"])
        L.append('allowed_verbs = Array[StringName]([&"%s"])' % kw.get("verb", "pull"))
        L.append('puzzle_id = &"%s"' % kw["puzzle"])
        L.append('reward_event_id = &"%s"\n' % kw["reward"])
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("small_box")\n')
        L.append('[node name="InteractionPoint" type="Marker2D" parent="%s"]\n' % name)
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = %s' % col)
        L.append('polygon = %s\n' % poly(14, 14))
    elif kind == "urn":
        supplicant = name == "DrownedSupplicant"
        L.append('[node name="%s" type="Area2D" parent="."]' % name)
        L.append('position = Vector2(%d, %d)' % (x, y))
        L.append('collision_layer = 8\ncollision_mask = 0')
        L.append('script = ExtResource("10_sacred")')
        L.append('receiver_id = &"%s"' % kw["puzzle"])
        L.append('allowed_verbs = Array[StringName]([&"pull", &"precision_hit"])')
        L.append('puzzle_id = &"%s"' % kw["puzzle"])
        if supplicant:
            L.append('destroyed_event_id = &"supplicant_lost"')
            L.append('preserved_event_id = &"supplicant_protected"\n')
        else:
            L.append('destroyed_event_id = &"%s_destroyed"' % kw["puzzle"])
            L.append('preserved_event_id = &"%s_preserved"\n' % kw["puzzle"])
        L.append('[node name="Shape" type="CollisionShape2D" parent="%s"]' % name)
        L.append('shape = SubResource("supplicant_box")\n')
        L.append('[node name="InteractionPoint" type="Marker2D" parent="%s"]\n' % name)
        L.append('[node name="Graybox" type="Polygon2D" parent="%s"]' % name)
        L.append('color = Color(0.88, 0.84, 0.72, 1)')
        L.append('polygon = %s\n' % poly(17, 22))
    elif kind == "exit":
        pass

L.append('[node name="ExitToBurialWorks" type="Area2D" parent="."]')
L.append('position = Vector2(4980, 2640)')
L.append('collision_layer = 0\ncollision_mask = 2')
L.append('script = ExtResource("11_exit")')
L.append('next_room = ExtResource("12_burial")')
L.append('next_spawn_id = &"spawn_from_procession"\n')
L.append('[node name="Shape" type="CollisionShape2D" parent="ExitToBurialWorks"]')
L.append('shape = SubResource("gate_box")\n')
L.append('[node name="Graybox" type="Polygon2D" parent="ExitToBurialWorks"]')
L.append('color = Color(0.85, 0.75, 0.4, 1)')
L.append('polygon = %s\n' % poly(16, 56))

open("levels/temple_clay_dead/sunken_cistern.tscn", "w", newline="\n").write("\n".join(L))

# The beat list is emitted as data so a test can assert every beat has an
# intent and no element exists outside one.
import json
json.dump([{"id": b[0], "x": b[1], "y": b[2], "intent": b[3]} for b in BEATS],
          open("data/levels/sunken_cistern_beats.json", "w", newline="\n"), indent=1)

print("beats     :", len(BEATS))
print("platforms :", len(plat))
print("anchors   :", sum(1 for n in nodes if n[0] == "anchor"))
print("encounters:", len(sources))
print("hazards   :", sum(1 for n in nodes if n[0] == "hazard"))
print("doors     :", sum(1 for n in nodes if n[0] == "door"))
print("switches  :", sum(1 for n in nodes if n[0] == "target"))
print("caches    :", sum(1 for n in nodes if n[0] == "cache"))
print("sacred    :", sum(1 for n in nodes if n[0] == "urn"))
print("shrines   :", sum(1 for n in nodes if n[0] == "shrine"))
print("size      : %dx%d = %.1f x %.1f screens" % (W, H, W / 640.0, H / 360.0))
