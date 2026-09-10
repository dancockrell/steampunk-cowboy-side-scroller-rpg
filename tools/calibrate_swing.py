#!/usr/bin/env python3
"""Measure what a lasso swing actually does, instead of modelling it.

The navigation graph's first swing model was a guess -- "the landing is within
a rope length of the anchor and below it" -- and it produced 12,775 swing edges
of which the physics honoured very few. Discovering that one failed edge at a
time during play is hopeless.

So: teleport Michael somewhere, grab an anchor, hold for a while, release, and
see where he ends up. A few hundred of those, run headless with no vsync, take
seconds, and the result is the real reachability envelope of the rope rather
than my arithmetic about pendulums. The bot is much faster than I am; this is
the thing worth spending that speed on.

  python tools/calibrate_swing.py --trials 240
"""
import argparse
import json
import math
import random
import socket

HOST, PORT = "127.0.0.1", 8777
ROOM = "res://levels/temple_clay_dead/sunken_cistern.tscn"


class Game:
    def __init__(self, sock):
        self.f = sock.makefile("rwb")

    def send(self, **cmd):
        self.f.write((json.dumps(cmd) + "\n").encode())
        self.f.flush()
        return json.loads(self.f.readline().decode())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=240)
    ap.add_argument("--out", default="swing_model.json")
    args = ap.parse_args()

    g = Game(socket.create_connection((HOST, PORT), timeout=30))
    g.send(cmd="load_room", scene=ROOM)
    level = g.send(cmd="level")
    plats = [tuple(p) for p in level["platforms"]]
    anchors = [tuple(a) for a in level["anchors"]]
    reach = level["tuning"]["lasso_range_px"]

    # standable spots to launch from
    spots = []
    for x, y, w, h in plats:
        step = max(48.0, w / 4.0)
        cx = x + 12
        while cx < x + w - 12:
            spots.append((cx, y - 20))
            cx += step

    random.seed(7)
    results = []
    for _ in range(args.trials):
        start = random.choice(spots)
        near = [a for a in anchors if 30.0 < math.dist(start, a) <= reach]
        if not near:
            continue
        anchor = random.choice(near)
        hold = random.choice([12, 20, 28, 36, 48, 64])

        g.send(cmd="teleport", x=start[0], y=start[1])
        g.send(cmd="act", n=2, press=[])
        g.send(cmd="act", n=1, press=[], swing_at=list(anchor))
        # ride the pendulum, then let go and let him land
        st = g.send(cmd="act", n=hold, press=[])
        st = g.send(cmd="act", n=1, press=[], release_swing=True)
        st = g.send(cmd="act", n=70, press=[])

        end = tuple(st["pos"])
        results.append({
            "from": [round(start[0]), round(start[1])],
            "anchor": [round(anchor[0]), round(anchor[1])],
            "hold": hold,
            "rope": round(math.dist(start, anchor)),
            "end": [round(end[0]), round(end[1])],
            "dx": round(end[0] - start[0]),
            "dy": round(end[1] - start[1]),
            "landed": bool(st["on_floor"]),
            "health": st["health"],
        })

    landed = [r for r in results if r["landed"]]
    moved = [r for r in landed if abs(r["dx"]) > 40 or abs(r["dy"]) > 40]
    gained = [r for r in landed if r["dy"] < -30]

    print("=== SWING, MEASURED ===")
    print("  trials              : %d" % len(results))
    print("  ended on solid ground: %d (%.0f%%)" % (len(landed), 100.0 * len(landed) / max(1, len(results))))
    print("  actually went somewhere: %d (%.0f%% of landings)" % (
        len(moved), 100.0 * len(moved) / max(1, len(landed))))
    print("  ENDED HIGHER than it started: %d (%.0f%% of landings)" % (
        len(gained), 100.0 * len(gained) / max(1, len(landed))))
    if landed:
        dxs = sorted(abs(r["dx"]) for r in landed)
        dys = sorted(r["dy"] for r in landed)
        print("  horizontal gain: median %d px, best %d px" % (dxs[len(dxs) // 2], dxs[-1]))
        print("  vertical      : median %+d px, best %+d px (negative is upward)" % (
            dys[len(dys) // 2], dys[0]))
    by_hold = {}
    for r in landed:
        by_hold.setdefault(r["hold"], []).append(r["dy"])
    print("  by hold time (frames -> median dy):")
    for h in sorted(by_hold):
        v = sorted(by_hold[h])
        print("     %2d frames  %+5d px   (%d samples)" % (h, v[len(v) // 2], len(v)))

    with open(args.out, "w") as f:
        json.dump(results, f, indent=1)
    print("  wrote %s" % args.out)
    g.send(cmd="quit")


if __name__ == "__main__":
    main()
