#!/usr/bin/env python3
"""Measure what a lasso swing actually does, instead of modelling it.

The navigation graph's first swing model was a guess -- "the landing is within
a rope length of the anchor and below it" -- and it produced 12,775 swing edges
of which the physics honoured very few. Discovering that one failed edge at a
time during play is hopeless.

Two things had to be found out before any of that could be measured at all,
and both were found by tracing single frames rather than by reading the code:

  1. A swing grabbed from a STANDING START never moves. Player._physics_swinging
     drives the pendulum through move_and_collide; with the floor underfoot the
     first sub-pixel step collides, `slide` zeroes the velocity, and Michael is
     pinned to the spot for as long as he holds the rope. Every trial the old
     version of this file ran was that: teleport, grab, hold, release, land
     exactly where he started. A swing has to be grabbed IN THE AIR.
  2. The jump has to be HELD. `act` releases every action before pressing the
     new set, so a jump pressed for one round trip is cut by
     jump_cut_multiplier on the next: 18px of height instead of 63px.

So a trial is what a player does: run up, jump and keep holding it, throw the
rope in mid-air, ride the pendulum for N frames, let go, and see where he ends
up. A few hundred of those, headless, take a couple of minutes, and the result
is the real reachability envelope of the rope rather than my arithmetic about
pendulums.

The output is a point cloud, not a formula. Every sample is one measured swing
in anchor-relative, rope-normalised coordinates, and playbot.py admits a swing
edge only where measured samples actually sit. That way the graph cannot
believe in a swing nobody has ever performed.

  python tools/calibrate_swing.py --trials 600 --port 8791
"""
import argparse
import json
import math
import random
import socket
import time

HOST, PORT = "127.0.0.1", 8777
ROOM = "res://levels/temple_clay_dead/sunken_cistern.tscn"

# How a swing is set up. playbot.Bot.run_leg performs the same sequence, so the
# envelope measured here describes the move the bot will actually attempt.
RUN_FRAMES = 20          # ~40px of run-up: enough to reach run_speed (150px/s)
AIR_FRAMES = 4           # airborne before the rope goes out
FLIGHT_FRAMES = 55       # after release, long enough to land from any arc
MAX_RIDE = 70            # give up on an auto release after this many frames
HOLDS = ("auto", "auto", 12, 20, 30, 42, 60,
         "climb", "climb", "climb", "climb")
## Holding jump during a ride hauls the rope in (SwingSolver.climb) and is the
## ONLY way a swing gains height. The first version of this file rode every
## trial with no buttons held, so it measured a pendulum and reported that
## swings cannot climb -- which was true of what it measured and false of the
## game, because the climb had just been added and nothing was pressing the
## button. An instrument that never exercises the feature reports the feature
## does not exist.
CLIMB_FRAMES = 55


class Game:
    def __init__(self, sock):
        self.f = sock.makefile("rwb")

    def send(self, **cmd):
        self.f.write((json.dumps(cmd) + "\n").encode())
        self.f.flush()
        line = self.f.readline()
        if not line:
            raise RuntimeError("server closed the connection")
        return json.loads(line.decode())


def _ride_climb(g, side):
    """Hold jump and haul the rope in, then release near the top of the arc."""
    best_y = None
    for i in range(CLIMB_FRAMES):
        st = g.send(cmd="act", n=1, press=["jump"])
        if not st["swinging"]:
            return None
        y = st["pos"][1]
        if best_y is None or y < best_y:
            best_y = y
    return CLIMB_FRAMES


def _ride_auto(g, side):
    """Hold the rope until the bottom of the arc, moving the way we want to go.

    A pendulum throws hardest at the bottom of its swing. `vy` crossing from
    positive to negative IS the bottom, and it is observable one frame at a
    time from outside, which is what makes this a rule the bot can follow live
    rather than a number only calibration knows. Returns frames ridden, or None
    if the arc never came round.
    """
    prev_vy = None
    for i in range(MAX_RIDE):
        st = g.send(cmd="act", n=1, press=[])
        if not st["swinging"]:
            return None
        vx, vy = st["vel"]
        if prev_vy is not None and prev_vy > 20.0 and vy <= 0.0 and vx * side > 40.0:
            return i + 1
        prev_vy = vy
    return None


def one_trial(g, start, anchor, hold, reach):
    """Run up, jump, grab in the air, ride, release, land. Returns a sample."""
    side = 1.0 if anchor[0] >= start[0] else -1.0
    press = ["move_right"] if side > 0 else ["move_left"]

    g.send(cmd="teleport", x=start[0], y=start[1])
    g.send(cmd="act", n=2, press=[])
    # Run up and jump, holding jump the whole way so the arc is the full 63px.
    g.send(cmd="act", n=RUN_FRAMES, press=press)
    g.send(cmd="act", n=1, press=press + ["jump"])
    st = g.send(cmd="act", n=AIR_FRAMES, press=press + ["jump"])
    grab = tuple(st["pos"])
    grab_vel = tuple(st["vel"])
    if st["on_floor"]:
        return None                      # never got airborne: no swing happened
    # He ran off the platform instead of jumping from it: the rope then goes out
    # from somewhere far below, which is a different move and was polluting the
    # first run of this file with rope lengths of 3000px.
    if grab[1] > start[1] + 40.0 or abs(grab[0] - start[0]) > 140.0:
        return None
    rope = math.dist(grab, anchor)
    # bot_server calls begin_swing directly, which does NOT range-check, so an
    # out-of-reach grab silently attaches a rope no player could throw.
    if rope < 30.0 or rope > reach:
        return None

    g.send(cmd="act", n=1, press=[], swing_at=list(anchor))
    if hold == "climb":
        held = _ride_climb(g, side)
        if held is None:
            return None
    elif hold == "auto":
        held = _ride_auto(g, side)
        if held is None:
            return None
    else:
        held = hold
        st = g.send(cmd="act", n=hold, press=[])
        if not st["swinging"]:
            return None                  # something ended the swing for us
    st = g.send(cmd="act", n=1, press=[], release_swing=True)
    st = g.send(cmd="act", n=FLIGHT_FRAMES, press=[])
    end = tuple(st["pos"])
    # Fell into a pit / off the world rather than completed a swing.
    if end[1] > start[1] + 3.0 * reach or abs(end[0] - start[0]) > 3.0 * reach:
        return None

    dx = end[0] - start[0]
    dy = end[1] - start[1]
    return {
        "from": [round(start[0]), round(start[1])],
        "anchor": [round(anchor[0]), round(anchor[1])],
        "grab": [round(grab[0]), round(grab[1])],
        "grab_vel": [round(grab_vel[0]), round(grab_vel[1])],
        "mode": hold if isinstance(hold, str) else "fixed",
        "hold": held,
        "rope": round(rope, 1),
        "side": int(side),
        "end": [round(end[0]), round(end[1])],
        "dx": round(dx, 1),
        "dy": round(dy, 1),
        # Anchor-relative, rope-normalised. `u` is forward along the run, so a
        # left-hand swing and its mirror image are the same sample.
        "ax": round(side * (anchor[0] - start[0]) / rope, 4),
        "ay": round((anchor[1] - start[1]) / rope, 4),
        "u": round(side * dx / rope, 4),
        "v": round(dy / rope, 4),
        "landed": bool(st["on_floor"]),
        "health": st["health"],
    }


def launch_spots(plats):
    """Standable spots with runway either side, in the frame a swing starts from."""
    spots = []
    for x, y, w, h in plats:
        step = max(56.0, w / 5.0)
        cx = x + 8.0
        while cx < x + w - 8.0:
            spots.append((cx, y - 4.0))
            cx += step
    return spots


def summarise(samples):
    """Print the envelope. Numbers only; the cloud is what playbot actually uses."""
    good = [s for s in samples if s["landed"]]
    moved = [s for s in good if abs(s["dx"]) > 50 or abs(s["dy"]) > 50]
    up = [s for s in moved if s["dy"] < -40]

    def pct(v, q):
        v = sorted(v)
        return v[min(len(v) - 1, int(q * len(v)))] if v else float("nan")

    print("=== SWING, MEASURED ===")
    print("  trials attempted      : %d" % len(samples))
    print("  landed on solid ground: %d (%.0f%%)"
          % (len(good), 100.0 * len(good) / max(1, len(samples))))
    print("  actually went somewhere: %d (%.0f%% of landings)"
          % (len(moved), 100.0 * len(moved) / max(1, len(good))))
    print("  ended HIGHER than they started: %d (%.0f%% of movers)"
          % (len(up), 100.0 * len(up) / max(1, len(moved))))
    if not moved:
        print("  NOTHING MOVED. The envelope below would be empty; do not trust it.")
        return
    fwd = [s["dx"] * s["side"] for s in moved]
    dys = [s["dy"] for s in moved]
    ropes = [s["rope"] for s in moved]
    print("  forward travel px : p05 %+d  median %+d  p95 %+d  max %+d"
          % (pct(fwd, 0.05), pct(fwd, 0.5), pct(fwd, 0.95), max(fwd)))
    print("  vertical px       : best %+d (up)  median %+d  p95 %+d (down)"
          % (min(dys), pct(dys, 0.5), pct(dys, 0.95)))
    print("  rope length px    : min %d  median %d  max %d"
          % (min(ropes), pct(ropes, 0.5), max(ropes)))
    print("  rope-normalised   : u p05 %+.2f  median %+.2f  p95 %+.2f"
          % (pct([s["u"] for s in moved], 0.05), pct([s["u"] for s in moved], 0.5),
             pct([s["u"] for s in moved], 0.95)))
    print("                      v p05 %+.2f  median %+.2f  p95 %+.2f"
          % (pct([s["v"] for s in moved], 0.05), pct([s["v"] for s in moved], 0.5),
             pct([s["v"] for s in moved], 0.95)))
    print("  by hold (frames -> median forward px / median dy px / n):")
    by = {}
    for s in moved:
        by.setdefault(s["hold"], []).append(s)
    for h in sorted(by):
        g = by[h]
        print("     %2d  %+5d px  %+5d px  (%d)"
              % (h, pct([q["dx"] * q["side"] for q in g], 0.5),
                 pct([q["dy"] for q in g], 0.5), len(g)))
    print("  by release rule (the bot can only follow 'auto' live):")
    for mode in ("auto", "fixed"):
        gm = [s for s in moved if s["mode"] == mode]
        if gm:
            print("     %-5s n=%-4d median forward %+d px, p95 forward %+d px, median dy %+d px"
                  % (mode, len(gm), pct([q["dx"] * q["side"] for q in gm], 0.5),
                     pct([q["dx"] * q["side"] for q in gm], 0.95), pct([q["dy"] for q in gm], 0.5)))
    print("  by anchor height (anchor above / level / below the launch):")
    for name, lo, hi in (("above", -9.0, -0.15), ("level", -0.15, 0.15), ("below", 0.15, 9.0)):
        g = [s for s in moved if lo <= s["ay"] < hi]
        if g:
            print("     %-6s n=%-4d median forward %+d px, median dy %+d px, best up %+d px"
                  % (name, len(g), pct([q["dx"] * q["side"] for q in g], 0.5),
                     pct([q["dy"] for q in g], 0.5), min(q["dy"] for q in g)))


def _write(path, level, samples, partial=False):
    with open(path, "w") as f:
        json.dump({
            "setup": {"run_frames": RUN_FRAMES, "air_frames": AIR_FRAMES,
                      "flight_frames": FLIGHT_FRAMES, "holds": list(HOLDS),
                      "partial": partial},
            "tuning": level["tuning"],
            "samples": samples,
        }, f, indent=1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=600)
    ap.add_argument("--port", type=int, default=PORT)
    ap.add_argument("--host", default=HOST)
    ap.add_argument("--out", default="swing_model.json")
    ap.add_argument("--seed", type=int, default=7)
    args = ap.parse_args()

    g = Game(socket.create_connection((args.host, args.port), timeout=120))
    g.send(cmd="load_room", scene=ROOM)
    level = g.send(cmd="level")
    plats = [tuple(p) for p in level["platforms"]]
    anchors = [tuple(a) for a in level["anchors"]]
    reach = level["tuning"]["lasso_range_px"]
    spots = launch_spots(plats)
    print("level: %d platforms, %d anchors, %d launch spots, lasso reach %.0fpx"
          % (len(plats), len(anchors), len(spots), reach))

    random.seed(args.seed)
    samples = []
    t0 = time.time()
    attempted = 0
    for n in range(args.trials):
        start = random.choice(spots)
        # The rope goes out from the air, a jump's worth up and a run-up along,
        # so judge reach from roughly there rather than from the standing spot.
        near = [a for a in anchors if 40.0 < math.dist((start[0], start[1] - 50.0), a) <= reach]
        if not near:
            continue
        attempted += 1
        s = one_trial(g, start, random.choice(near), random.choice(HOLDS), reach)
        if s is not None:
            samples.append(s)
        if (n + 1) % 50 == 0:
            print("  %d/%d trials, %d samples, %.0fs"
                  % (n + 1, args.trials, len(samples), time.time() - t0))
            # Checkpoint. A long measurement that saves only at the end loses
            # everything to a timeout, and this one did: 300 trials and 189
            # usable samples went in the bin because the file was written last.
            if len(samples) >= 40:
                _write(args.out, level, samples, partial=True)

    print("attempted %d of %d draws (%d had no anchor in reach), %d usable samples in %.0fs"
          % (attempted, args.trials, args.trials - attempted, len(samples), time.time() - t0))
    # A run that measured nothing must not be able to write a model file that
    # reads like a successful one -- section 1, "assert the denominator".
    if len(samples) < max(20, args.trials // 20):
        raise SystemExit("REFUSING to write a model: only %d usable samples from %d trials. "
                         "The harness, not the rope, is what this measured." % (len(samples), args.trials))
    summarise(samples)

    _write(args.out, level, samples)
    print("  wrote %s (%d samples)" % (args.out, len(samples)))
    # Deliberately does NOT quit the server: calibration is something you run
    # repeatedly against one long-lived window, and playbot.py runs next.


if __name__ == "__main__":
    main()
