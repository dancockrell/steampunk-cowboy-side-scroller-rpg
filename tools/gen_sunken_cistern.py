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

# ============================================================ Z1  THE ENTRY
# You arrive high on the west with the whole cistern in front of you. Nothing
# attacks in this zone. Its whole job is to make you want to go somewhere.
beat("z1a", 0, 620, "You land on a wide safe ledge and the level is simply visible below you",
     ("ledge", 0, 0, 620), ("spawn", 90, 0, "spawn_entry"), ("spawn", 90, 0, "spawn_from_procession"),
     ("shrine", 210, -42))
beat("z1b", 700, 540, "A ledge just out of jumping range: the first thing the rope is for",
     ("ledge", 0, 0, 300), ("anchor", 40, -160))
beat("z1c", 1100, 700, "A cache in plain sight one swing further out, so the reward reads as earned",
     ("ledge", 0, 0, 260), ("anchor", 120, -190), ("cache", 130, -30))
beat("z1d", 430, 300, "The roof walkway is overhead and lit; you cannot reach it yet and you know it",
     ("ledge", 870, 0, 420), ("anchor", 1080, -120))
beat("z1e", 240, 860, "Two shelves below the entry, so down is obviously an option too",
     ("ledge", 0, 0, 130), ("ledge", 330, 40, 120), ("anchor", 200, -120))
beat("z1f", 1240, 430, "One anchor hangs over the shaft mouth: the whole level is one swing away",
     ("anchor", 0, 0), ("anchor", 260, -30))

# ============================================================ Z2  SAGGING GALLERIES (west, upper)
# The teaching zone for ceramics. Three jars, only one alive, and a chime that
# tells you which -- if you think to use it.
beat("z2a", 120, 1000, "Three jars on a shelf and no way to tell which is a sentinel",
     ("ledge", 0, 0, 420), ("urn", 90, -30), ("urn", 200, -30),
     ("jar", 320, -30, 160, -80), ("anchor", 150, -200))
beat("z2b", 300, 940, "The chime that answers the question, if you shoot it before you touch anything",
     ("chime", 0, 0,))
beat("z2c", 0, 1180, "A side shelf under the gallery: the cautious way past the jars",
     ("ledge", 0, 0, 180), ("anchor", 90, -170))
beat("z2d", 300, 1320, "A cache directly beneath the live jar, so the greedy line is the dangerous one",
     ("ledge", 0, 0, 360), ("cache", 180, -30), ("anchor", 60, -180))
beat("z2e", 640, 1160, "A lone anchor out over nothing, the reward for reading the room",
     ("anchor", 0, 0))
beat("z2f", 90, 1640, "A mural on the back wall of a narrow shelf: no room to back away from it",
     ("ledge", 0, 0, 300), ("mural", 110, -30, 250, -60), ("anchor", 40, -190))
beat("z2g", 640, 1500, "The shelf you land on if you flee the mural, deliberately just within one swing",
     ("ledge", 0, 0, 220), ("anchor", 110, -170))
beat("z2h", 380, 1900, "A wide gallery floor, the first place in the west it is safe to stand and think",
     ("ledge", 0, 0, 420), ("anchor", 210, -200), ("shrine", 380, -42))
beat("z2i", 560, 2060, "A ledge over the drop with a vent under it: the shortcut costs health",
     ("ledge", 0, 0, 200), ("vent", 100, 120, 110, 70), ("anchor", 100, -180), ("anchor", -120, -140))
beat("z2j", 140, 2200, "Two jars flanking the only route down, one of them alive",
     ("ledge", 0, 0, 340), ("urn", 80, -30), ("jar", 250, -30, 120, -70), ("anchor", 170, -190))
beat("z2k", 420, 2460, "The bar that opens the kiln door, all the way across the level from it",
     ("ledge", 0, 0, 300), ("switch", 150, -30, "pull", "cistern_kiln_bar"), ("anchor", 60, -180))
beat("z2l", 120, 2380, "One more shelf so the descent is a choice of lines, not a ladder",
     ("ledge", 0, 0, 120), ("anchor", 60, -160))

# ============================================================ Z3  THE WEST DESCENT
# Getting from the galleries to the water. Rope work with consequences.
beat("z3a", 60, 1150, "An anchor with nothing under it: your first swing that must land",
     ("anchor", 0, 0), ("anchor", 300, 40))
beat("z3b", 60, 1470, "A rope line staggered so the swing arcs are not a straight fall",
     ("anchor", 0, 0), ("anchor", 280, -60), ("anchor", 560, 20))
beat("z3c", 60, 1790, "The same again lower, tightening as the wall closes in",
     ("anchor", 0, 0), ("anchor", 260, 40), ("anchor", 520, -30))
beat("z3d", 60, 2100, "The last rope line above the water, wide enough to recover a bad swing",
     ("anchor", 0, 0), ("anchor", 300, 0), ("anchor", 600, 30))
beat("z3e", 200, 2320, "Broken shelves you can chain if you would rather climb than swing",
     ("ledge", 0, 0, 120), ("ledge", 260, -60, 110), ("ledge", 520, 30, 120),
     ("anchor", 130, -170), ("anchor", 420, -200))
beat("z3f", 820, 1300, "A slab in mid-air with a cache on it, only reachable mid-swing",
     ("ledge", 0, 0, 140), ("cache", 70, -30), ("anchor", 70, -200))
beat("z3g", 900, 1700, "An anchor placed so the obvious swing carries you over the vent, not into it",
     ("anchor", 0, 0), ("vent", 60, 260, 110, 70))
beat("z3h", 760, 2000, "A ledge that looks like a rest and has a mural on it",
     ("ledge", 0, 0, 180), ("mural", 80, -30, -60, -60))
beat("z3i", 1000, 2300, "Stepping stones over the water gap, small enough to make you commit",
     ("ledge", 0, 0, 90), ("ledge", 200, -40, 90), ("ledge", 400, 20, 90), ("anchor", 200, -200))
beat("z3j", 420, 2620, "The west waterline: shards in the shallows punish a missed landing",
     ("vent", 0, 0, 180, 90), ("anchor", 0, -180))
beat("z3k", 1180, 1900, "A high anchor that lets a confident player skip the whole descent",
     ("anchor", 0, 0), ("anchor", 0, -400))
beat("z3l", 1300, 2450, "Where that skip lands you, right next to something that was waiting",
     ("ledge", 0, 0, 200), ("pit", 120, -30, -100, -60), ("anchor", 100, -190), ("anchor", -140, -150))

# ============================================================ Z4  THE SHAFT, UPPER
# The centre of the level. Open from roof to water; three ways down it.
beat("z4a", 1460, 900, "The west lip of the shaft: the first place you can look straight down it",
     ("ledge", 0, 0, 150), ("anchor", 80, -180))
beat("z4b", 2390, 900, "The east lip, visibly the same height, so the shaft reads as a crossing too",
     ("ledge", 0, 0, 150), ("anchor", 40, -180))
beat("z4c", 1580, 620, "Anchors up the middle of the shaft: it is a way UP as much as down",
     ("anchor", 0, 0), ("anchor", 280, -40), ("anchor", 560, 30), ("anchor", 800, -20))
beat("z4d", 1880, 1220, "An island in the middle of the shaft with the grate pin above it",
     ("ledge", 0, 0, 260), ("switch", 140, -84, "precision_hit", "cistern_grate_pin"),
     ("anchor", 130, -220), ("anchor", -80, -140), ("anchor", 340, -160))
beat("z4e", 2020, 1176, "A jar sits ON the island: the pin shot is taken from a compromised place",
     ("jar", 0, 0, -220, -60))
beat("z4f", 1620, 1000, "Ledges down the shaft's west wall for the careful route",
     ("ledge", 0, 0, 100), ("ledge", 240, 120, 100), ("ledge", 60, 260, 110),
     ("anchor", 60, -150), ("anchor", 300, -40), ("anchor", 120, 120))
beat("z4g", 2200, 1000, "And the east wall, offset, so the two routes cannot be taken at once",
     ("ledge", 0, 0, 100), ("ledge", -180, 140, 100), ("ledge", 40, 280, 110),
     ("anchor", 60, -150), ("anchor", -140, 0), ("anchor", 100, 140))
beat("z4h", 1460, 1500, "Mid-shaft lip with a vent on the wall at exactly swing height",
     ("ledge", 0, 0, 150), ("vent", 210, -60, 110, 70), ("anchor", 60, -170))
beat("z4i", 2390, 1500, "Its opposite number, so the vent is passed on one side or the other",
     ("ledge", 0, 0, 150), ("anchor", 70, -170), ("anchor", -140, -120))
beat("z4j", 1760, 1820, "A slab low in the shaft holding a cache, in the vents' reach",
     ("ledge", 0, 0, 200), ("cache", 100, -30), ("vent", -80, -40, 110, 70),
     ("anchor", 100, -200), ("anchor", 320, -120))

# ============================================================ Z5  THE GRATE AND THE DEEP
beat("z5a", 2280, 2236, "The grate: shot open from the island far above, and you saw it happen",
     ("door", 0, 0, "cistern_grate_pin"))
beat("z5b", 2160, 2380, "The slab under the grate, the only soft landing in the shaft's bottom",
     ("ledge", 0, 0, 240), ("anchor", 120, -190))
beat("z5c", 2280, 2336, "An assembler waits under the grate for whoever opens it",
     ("pit", 0, 0, 0, -180))
beat("z5d", 1460, 2100, "The last lip before the water, and an anchor to bail out with",
     ("ledge", 0, 0, 150), ("anchor", 80, -170))
beat("z5e", 2390, 2100, "Its twin, because a bail-out with one option is not a decision",
     ("ledge", 0, 0, 150), ("anchor", 60, -170))
beat("z5f", 1600, 2160, "Rope line strung above the water so a fall down the shaft is survivable",
     ("anchor", 0, 0), ("anchor", 260, 0), ("anchor", 520, 0), ("anchor", 780, 0))
beat("z5g", 1820, 1776, "A cache tucked behind the shaft wall, visible only on the way down",
     ("cache", 0, 0))
beat("z5h", 2600, 2560, "The rope line continues east over the water toward the shrine",
     ("anchor", 0, 0), ("anchor", 300, 0), ("anchor", 600, 0))

# ============================================================ Z6  THE ROOFLINE
# Optional, high, and the best rewards. Pure traversal.
beat("z6a", 1300, 300, "The first roof walkway, reachable only by a long swing from the entry side",
     ("ledge", 0, 0, 420), ("anchor", 200, -120))
beat("z6b", 1480, 356, "The latch that opens the roof hatch, shot across the gap from here",
     ("switch", 0, 0, "precision_hit", "cistern_roof_latch"))
beat("z6c", 2200, 240, "The widest roof slab, and the only flat run up here",
     ("ledge", 0, 0, 520), ("anchor", 260, -100))
beat("z6d", 2740, 396, "The roof hatch itself, opened from a walkway you had to reach first",
     ("door", 0, 0, "cistern_roof_latch"))
beat("z6e", 2420, 196, "The best cache in the level, on the roof, behind everything",
     ("cache", 0, 0))
beat("z6f", 3200, 320, "Roof continues east, so the hatch is not the only thing up here",
     ("ledge", 0, 0, 460), ("anchor", 230, -110), ("anchor", 460, -60))
beat("z6g", 4100, 420, "The last roof slab, overlooking the kiln stack",
     ("ledge", 0, 0, 400), ("anchor", 200, -120))
beat("z6h", 1720, 180, "The roof anchor chain: four swings, no floor, one mistake is the whole drop",
     ("anchor", 0, 0), ("anchor", 300, 40), ("anchor", 620, -20), ("anchor", 940, 30))

# ============================================================ Z7  THE KILN STACK (east, upper)
# Hazards and creatures share one space. Learn to let the temple do the work.
beat("z7a", 2760, 760, "A broad kiln floor, hot at one end",
     ("ledge", 0, 0, 460), ("vent", 380, -60, 110, 70), ("anchor", 200, -190))
beat("z7b", 3040, 976, "A mural where the only standing room is beside a vent",
     ("ledge", -120, 44, 380), ("mural", 0, 0, 200, -60))
beat("z7c", 2940, 1256, "A vent directly below a narrow ledge: staggered things fall into it",
     ("ledge", -60, -60, 200), ("vent", 0, 0, 110, 70))
beat("z7d", 3320, 1020, "A shelf between two heats, wide enough to fight on and no wider",
     ("ledge", 0, 0, 380), ("anchor", 190, -190), ("anchor", -40, -130))
beat("z7e", 2880, 1300, "Kiln mouths in a rising line, the first place the route IS the hazard",
     ("ledge", 0, 0, 360), ("anchor", 180, -200))
beat("z7f", 3460, 1560, "The widest kiln tier, with a jar at the far end you will meet on the way back",
     ("ledge", 0, 0, 420), ("jar", 380, -30, 120, -70), ("anchor", 210, -200), ("anchor", -20, -140))
beat("z7g", 3620, 1516, "A vent between you and that jar, which is the point",
     ("vent", 0, 0, 110, 70))
beat("z7h", 2960, 1840, "A lower tier, cooler, where you can see the whole stack you just crossed",
     ("ledge", 0, 0, 380), ("anchor", 190, -190))
beat("z7i", 3560, 2120, "The bottom of the stack, and an assembler between you and the east wall",
     ("ledge", 0, 0, 340), ("pit", 260, -30, 40, -70), ("anchor", 170, -190), ("anchor", -80, -140))
beat("z7j", 4200, 900, "The east high shelf with a jar guarding a cache",
     ("ledge", 0, 0, 420), ("jar", 140, -30, 340, -70), ("cache", 330, -30),
     ("anchor", 210, -190), ("anchor", -20, -140))
beat("z7k", 4560, 1240, "A shelf you reach by rope only, holding nothing: a lesson about greed",
     ("ledge", 0, 0, 360), ("anchor", 180, -180), ("anchor", -40, -130))
beat("z7l", 4700, 1196, "The mural on that empty shelf, which is what it was really holding",
     ("mural", 0, 0, -240, -60))
beat("z7m", 4260, 1560, "A shelf under the empty one, so fleeing downward is possible",
     ("ledge", 0, 0, 300), ("anchor", 150, -180), ("vent", 40, -44, 110, 70), ("anchor", -60, -140))
beat("z7n", 4620, 1880, "Low east shelf, with the kiln cache behind a vent",
     ("ledge", 0, 0, 340), ("cache", 140, -30), ("vent", 260, -44, 110, 70), ("anchor", 170, -190))

# ============================================================ Z8  THE EAST TIERS AND THE WINCH
beat("z8a", 3600, 2076, "The winch that opens the west vault, an entire level away from the vault",
     ("switch", 0, 0, "pull", "cistern_west_winch"))
beat("z8b", 3520, 2120, "A mural directly behind the winch: you pull it with your back turned",
     ("mural", 0, -180, 300, -40))
beat("z8c", 4180, 2200, "The tier the winch fight spills onto",
     ("ledge", 0, 0, 380), ("anchor", 190, -190), ("anchor", -30, -130))
beat("z8d", 4160, 2356, "The kiln door, opened by a bar back in the west galleries",
     ("door", 0, 0, "cistern_kiln_bar"))
beat("z8e", 4420, 2560, "Past the kiln door: a shrine, because the deep east is a long way from anywhere",
     ("shrine", 0, 0))
beat("z8f", 4620, 2400, "Rope out over the deep east water",
     ("anchor", 0, 0), ("anchor", 260, -40))
beat("z8g", 3980, 2620, "Shards under the east rope line, so a missed swing over the water still costs you",
     ("vent", 0, 0, 180, 90))
beat("z8h", 4600, 2676, "An assembler in the last stretch of water before the way out",
     ("pit", 0, 0, -180, -60))
beat("z8i", 4340, 856, "A jar on the high east shelf, positioned to emerge behind you at the cache",
     ("jar", 0, 0, 240, -60))
beat("z8j", 4780, 1560, "One anchor at the far east edge so the wall is never a dead end",
     ("anchor", 0, 0), ("anchor", 0, 300))
beat("z8k", 4880, 2000, "And the corner, which would otherwise be the one place you could strand yourself",
     ("anchor", 0, 0), ("anchor", 0, 260))
beat("z8l", 4980, 2640, "The way on to Burial Works, at the deep east end",
     ("exit", 0, 0))

# ============================================================ Z9  THE WATER AND THE DROWNED SHRINE
# The moral centre of the level.
beat("z9a", 2600, FLOOR_Y, "The cistern floor proper, broken so the water is always near",
     ("ledge", 0, 0, 640, 160), ("anchor", 320, -200), ("anchor", 580, -160))
beat("z9b", 2660, 2676, "A supplicant on a slab above the water, still holding her token",
     ("urn", 0, 0))
beat("z9c", 2900, 2676, "An assembler between you and her, closer to her than to you",
     ("pit", 0, 0, -300, -60))
beat("z9d", 2740, 2634, "The shrine beside her, so you can save and try again",
     ("shrine", 0, 0))
beat("z9e", 2760, 2676, "The offering cache at her feet: taking it is not the same as protecting her",
     ("cache", 0, 0))
beat("z9f", 2480, 2560, "The anchor you would naturally rope to cross -- it is over HER slab",
     ("anchor", 0, 0))
beat("z9g", 0, FLOOR_Y, "West floor, with the first water gap immediately after it",
     ("ledge", 0, 0, 760, 160), ("anchor", 380, -190), ("anchor", 660, -240))
beat("z9h", 900, FLOOR_Y, "A floor island with shards on both approaches",
     ("ledge", 0, 0, 520, 160), ("vent", 60, -120, 180, 90),
     ("anchor", 260, -190), ("anchor", 40, -240))
beat("z9i", 1560, FLOOR_Y, "Another island, smaller, so crossing the floor is its own traversal problem",
     ("ledge", 0, 0, 380, 160), ("vent", 60, -120, 180, 90),
     ("anchor", 190, -190), ("anchor", 380, -250))
beat("z9j", 2120, FLOOR_Y, "The narrowest island, right under the shaft, where falls land",
     ("ledge", 0, 0, 300, 160), ("vent", 60, -120, 180, 90),
     ("anchor", 150, -190), ("anchor", -60, -250))
beat("z9k", 3400, FLOOR_Y, "East floor begins, with an assembler already up",
     ("ledge", 0, 0, 420, 160), ("pit", 160, -44, -120, -70),
     ("anchor", 210, -190), ("anchor", 20, -250))
beat("z9l", 4420, FLOOR_Y, "The last floor run to the exit, deliberately clear: you have earned it",
     ("ledge", 0, 0, 700, 160), ("anchor", 350, -190), ("anchor", 620, -230))

# ============================================================ Z10 CONNECTIVE
# The few remaining pieces that exist to stop the level having dead ends.
beat("z10a", 660, 1856, "The west vault door, opened by the winch across the level",
     ("door", 0, 0, "cistern_west_winch"))
beat("z10b", 180, 1856, "The vault opens on a cache and nothing else, so the winch was worth crossing the level for",
     ("ledge", -60, 44, 320), ("cache", 0, 0))
beat("z10c", 3980, FLOOR_Y - 60, "An island shelf so the east water is crossable without the rope",
     ("ledge", 0, 0, 300), ("anchor", 150, -180), ("anchor", -70, -220))
beat("z10d", 1300, 1000, "Rope between the west wing and the shaft, so the two halves are one place",
     ("anchor", 0, 0), ("anchor", 0, 400), ("anchor", 0, 800))
beat("z10e", 2560, 620, "Rope between the shaft and the kiln stack, same reason",
     ("anchor", 0, 0), ("anchor", 200, 40), ("anchor", 400, -20))
beat("z10f", 2700, 1120, "And lower, so the crossing is possible at more than one height",
     ("anchor", 0, 0), ("anchor", 240, 30), ("anchor", 480, -20))
beat("z10g", 2760, 2120, "The lowest crossing between the two halves, taken at water level where a fall is short",
     ("anchor", 0, 0), ("anchor", 250, 0), ("anchor", 500, 0))
beat("z10h", 1120, 620, "Rope back up to the entry, so the level is never one-way",
     ("anchor", 0, 0), ("anchor", 0, -240))

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
