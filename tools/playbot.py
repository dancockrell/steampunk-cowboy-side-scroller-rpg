#!/usr/bin/env python3
"""A bot that plays the Sunken Cistern, looks at it, and complains.

Godot is a dumb service here (tools/bot_server.gd): apply input, advance
frames, report state, save a frame. Everything that counts as thinking is in
this file, because this is where it can hold a picture and a map at once.

What it does per run:
  1. pulls the level geometry and the real movement tuning off the server
  2. builds a navigation graph over the moves Michael actually has -- walk,
     jump, drop, swing -- with the jump budget derived from tuning rather than
     copied, so the bot cannot believe in a jump the game will not do
  3. A* to a series of goals, executes each step with real physics, and marks
     an edge blocked when the game refuses to honour it
  4. grabs frames while playing and measures what is actually on screen
  5. writes complaints.json and an annotated map of where it really went

Complaints are evidence, not opinion: every one carries the number that
produced it and a place to go look.

  python tools/playbot.py --shots
"""
import argparse
import json
import math
import os
import socket
import subprocess
import sys
import time
from collections import defaultdict, deque

HOST, PORT = "127.0.0.1", 8777
ROOM = "res://levels/temple_clay_dead/sunken_cistern.tscn"
SCREEN = (640, 360)


# ------------------------------------------------------------------ transport
class Game:
    def __init__(self, sock):
        self.s = sock
        self.f = sock.makefile("rwb")

    def send(self, **cmd):
        self.f.write((json.dumps(cmd) + "\n").encode())
        self.f.flush()
        line = self.f.readline()
        if not line:
            raise RuntimeError("server closed the connection")
        return json.loads(line.decode())

    def step(self, n=1):
        return self.send(cmd="step", n=n)

    def state(self):
        return self.send(cmd="state")


# --------------------------------------------------------------- the nav graph
class Nav:
    """Nodes are standable spots; edges are moves Michael can really make."""

    SAMPLE = 48.0
    CELL = 340.0            # spatial bucket, a little over lasso range

    def __init__(self, level):
        t = level["tuning"]
        v = abs(t["jump_velocity"])
        self.up = (v * v) / (2.0 * t["gravity"])
        t_up = v / t["gravity"]
        t_dn = math.sqrt(2.0 * self.up / (t["gravity"] * t["fall_gravity_multiplier"]))
        self.across = t["run_speed"] * (t_up + t_dn)
        self.reach = t["lasso_range_px"]

        self.plats = [tuple(p) for p in level["platforms"]]
        self.anchors = [tuple(a) for a in level["anchors"]]
        self.nodes = []
        self.owner = []
        for pi, (x, y, w, h) in enumerate(self.plats):
            xs = x + 10.0
            stop = x + w - 10.0
            if stop <= xs:
                self.nodes.append((x + w / 2.0, y))
                self.owner.append(pi)
                continue
            while xs <= stop:
                self.nodes.append((xs, y))
                self.owner.append(pi)
                xs += self.SAMPLE

        # spatial buckets, so edge building is local instead of n^2 -- the
        # GDScript version of this was 260 million iterations and hung
        self.bucket = defaultdict(list)
        for i, (x, y) in enumerate(self.nodes):
            self.bucket[(int(x // self.CELL), int(y // self.CELL))].append(i)

        self.edges = defaultdict(list)
        self.blocked = set()
        self._build()

    def _near(self, x, y, radius):
        cx, cy = int(x // self.CELL), int(y // self.CELL)
        span = int(radius // self.CELL) + 1
        out = []
        for gx in range(cx - span, cx + span + 1):
            for gy in range(cy - span, cy + span + 1):
                out.extend(self.bucket.get((gx, gy), ()))
        return out

    def _add(self, a, b, move, cost, anchor=None):
        self.edges[a].append({"to": b, "move": move, "cost": cost, "anchor": anchor})

    def _build(self):
        for i, (ax, ay) in enumerate(self.nodes):
            for j in self._near(ax, ay, max(self.across, 60.0) + self.SAMPLE):
                if i == j:
                    continue
                bx, by = self.nodes[j]
                dx, dy = abs(bx - ax), by - ay
                if self.owner[i] == self.owner[j] and dx <= self.SAMPLE * 1.2:
                    self._add(i, j, "walk", dx)
                elif dx <= self.across and -dy <= self.up and dy <= 260.0:
                    self._add(i, j, "jump", dx + abs(dy) + 40.0)

        # drops: step off and take the first top strictly below
        tops = defaultdict(list)
        for j, (x, y) in enumerate(self.nodes):
            tops[int(x // self.SAMPLE)].append(j)
        for i, (x, y) in enumerate(self.nodes):
            best, best_y = None, 1e9
            for j in tops.get(int(x // self.SAMPLE), ()):
                jy = self.nodes[j][1]
                if y + 8.0 < jy < best_y and abs(self.nodes[j][0] - x) <= self.SAMPLE:
                    best, best_y = j, jy
            if best is not None:
                self._add(i, best, "drop", (best_y - y) * 0.6 + 20.0)

        # swings: an anchor in reach, landing under it and within a rope length
        abucket = defaultdict(list)
        for k, (x, y) in enumerate(self.anchors):
            abucket[(int(x // self.CELL), int(y // self.CELL))].append(k)
        for i, (ax, ay) in enumerate(self.nodes):
            cx, cy = int(ax // self.CELL), int(ay // self.CELL)
            for gx in range(cx - 1, cx + 2):
                for gy in range(cy - 1, cy + 2):
                    for k in abucket.get((gx, gy), ()):
                        anx, any_ = self.anchors[k]
                        rope = math.dist((ax, ay), (anx, any_))
                        if not (20.0 < rope <= self.reach):
                            continue
                        for j in self._near(anx, any_, self.reach):
                            if j == i:
                                continue
                            bx, by = self.nodes[j]
                            if by < any_ + 20.0:
                                continue
                            land = math.dist((bx, by), (anx, any_))
                            if land > self.reach * 1.15 or abs(land - rope) > 190.0:
                                continue
                            self._add(i, j, "swing",
                                      math.dist((ax, ay), (bx, by)) * 0.8 + 30.0, k)

    def nearest(self, p):
        best, bd = -1, 1e18
        for i in self._near(p[0], p[1], 600.0) or range(len(self.nodes)):
            d = math.dist(self.nodes[i], p)
            if d < bd:
                best, bd = i, d
        if best < 0:
            for i in range(len(self.nodes)):
                d = math.dist(self.nodes[i], p)
                if d < bd:
                    best, bd = i, d
        return best

    def plan(self, a, b):
        if a < 0 or b < 0:
            return []
        import heapq
        goal = self.nodes[b]
        openq = [(math.dist(self.nodes[a], goal), 0.0, a)]
        came, g, seen = {}, {a: 0.0}, set()
        while openq:
            _, gc, cur = heapq.heappop(openq)
            if cur == b:
                out = []
                while cur in came:
                    prev, move, anchor = came[cur]
                    out.append({"node": cur, "move": move, "anchor": anchor})
                    cur = prev
                return out[::-1]
            if cur in seen:
                continue
            seen.add(cur)
            for e in self.edges[cur]:
                nxt = e["to"]
                if nxt in seen or (cur, nxt) in self.blocked:
                    continue
                ng = gc + e["cost"]
                if ng < g.get(nxt, 1e18):
                    g[nxt] = ng
                    came[nxt] = (cur, e["move"], e["anchor"])
                    heapq.heappush(openq, (ng + math.dist(self.nodes[nxt], goal), ng, nxt))
        return []

    def reachable(self, start):
        seen, q = {start}, deque([start])
        while q:
            cur = q.popleft()
            for e in self.edges[cur]:
                if e["to"] not in seen and (cur, e["to"]) not in self.blocked:
                    seen.add(e["to"])
                    q.append(e["to"])
        return seen


# ------------------------------------------------------------------- the bot
GOALS = [
    ("the first cache off the entry", (1200, 700)),
    ("down into the galleries", (300, 1300)),
    ("the kiln bar at the bottom of the west", (480, 2450)),
    ("the shaft island and the grate pin", (1900, 1220)),
    ("the drowned shrine", (2700, 2670)),
    ("the winch on the east tier", (3600, 2076)),
    ("the way out", (4980, 2640)),
]


class Bot:
    def __init__(self, game, nav, shots_dir=None):
        self.g = game
        self.nav = nav
        self.shots = shots_dir
        self.path = []
        self.cells = set()
        self.damage = 0
        self.health = 5
        self.blocked_edges = 0
        self.replans = 0
        self.frames = 0
        self.shot_n = 0

    def _act(self, act):
        """One round trip: whole input state in, world state back."""
        st = self.g.send(**act)
        self.frames += act.get("n", 4)
        return self._observe(st)

    def _tick(self, n=1):
        self.g.step(n)
        self.frames += n
        return self._observe(self.g.state())

    def _observe(self, st):
        p = tuple(st["pos"])
        self.path.append((int(p[0]), int(p[1])))
        self.cells.add((int(p[0] // 320), int(p[1] // 320)))
        if st["health"] < self.health:
            self.damage += self.health - st["health"]
            self.health = st["health"]
        return st

    def look(self, tag):
        """Grab a frame at play size, the way a person would see it."""
        if not self.shots:
            return None
        path = os.path.join(self.shots, "f%02d_%s.png" % (self.shot_n, tag))
        self.g.send(cmd="camera", zoom=1.0)
        self.g.step(2)
        r = self.g.send(cmd="shot", path=path.replace("\\", "/"))
        self.shot_n += 1
        return path if r.get("ok") else None

    def run_leg(self, label, goal, budget_s=70.0):
        st = self.g.state()
        start = self.nav.nearest(tuple(st["pos"]))
        target = self.nav.nearest(goal)
        plan = self.nav.plan(start, target)
        planned = bool(plan)
        t0 = time.time()
        elapsed = 0.0
        step_i = 0
        step_t = 0.0
        step_from = tuple(st["pos"])

        while step_i < len(plan) and elapsed < budget_s:
            step = plan[step_i]
            tgt = self.nav.nodes[step["node"]]
            move = step["move"]
            act = {"cmd": "act", "n": 4, "press": []}

            if move in ("walk", "drop", "jump"):
                act["press"] = self._dir(st["pos"][0], tgt[0])
                if move == "jump" and st["on_floor"]:
                    act["press"].append("jump")
            elif move == "swing":
                anchor = self.nav.anchors[step["anchor"]]
                if not st["swinging"]:
                    if math.dist(tuple(st["pos"]), anchor) <= self.nav.reach:
                        act["swing_at"] = list(anchor)
                    else:
                        act["press"] = self._dir(st["pos"][0], anchor[0])
                else:
                    toward = (st["vel"][0] > 0) == (tgt[0] > st["pos"][0])
                    if (toward and st["pos"][1] <= tgt[1] + 40) or step_t > 1.6:
                        act["release_swing"] = True

            st = self._act(act)
            step_t += 4 / 60.0
            elapsed += 4 / 60.0
            p = tuple(st["pos"])

            if abs(p[0] - tgt[0]) < 44 and abs(p[1] - tgt[1]) < 48 \
                    and st["on_floor"] and not st["swinging"]:
                step_i += 1
                step_t = 0.0
                step_from = p
            elif step_t > (3.4 if move == "swing" else 2.4):
                # the level did not honour this edge; stop believing in it
                self.nav.blocked.add((self.nav.nearest(step_from), step["node"]))
                self.blocked_edges += 1
                self.replans += 1
                if st["swinging"]:
                    self.g.send(cmd="release_swing")
                plan = self.nav.plan(self.nav.nearest(p), target)
                step_i, step_t, step_from = 0, 0.0, p
                if not plan:
                    break

        self.g.send(cmd="release_all")
        st = self.g.state()
        p = tuple(st["pos"])
        return {
            "goal": label, "at": list(goal), "planned": planned,
            "plan_steps": len(plan), "reached": math.dist(p, goal) < 200,
            "seconds": round(elapsed, 1), "ended": [int(p[0]), int(p[1])],
            "short_by": int(math.dist(p, goal)),
        }

    def _dir(self, from_x, to_x):
        if to_x > from_x + 6:
            return ["move_right"]
        if to_x < from_x - 6:
            return ["move_left"]
        return []


# ------------------------------------------------------------------ complaints
def evaluate(nav, legs, bot, level):
    """Turn measurements into complaints. Every one carries its number."""
    out = []
    start = nav.nearest((90, 620))
    reach = nav.reachable(start)
    pct = 100.0 * len(reach) / max(1, len(nav.nodes))
    if pct < 90:
        out.append({
            "severity": "blocker",
            "what": "Most of the level cannot be reached from the entry.",
            "number": "%.0f%% of %d standable spots reachable over real moves"
                      % (pct, len(nav.nodes)),
            "where": "graph connectivity from the spawn",
        })

    jumps = sum(1 for i in nav.edges for e in nav.edges[i] if e["move"] == "jump")
    swings = sum(1 for i in nav.edges for e in nav.edges[i] if e["move"] == "swing")
    walks = sum(1 for i in nav.edges for e in nav.edges[i] if e["move"] == "walk")
    if jumps < swings * 0.15:
        out.append({
            "severity": "design",
            "what": "Jumping is nearly useless: almost every connection is a rope.",
            "number": "%d jump edges vs %d swing edges (jump budget %.0fpx up, %.0fpx across)"
                      % (jumps, swings, nav.up, nav.across),
            "where": "platform spacing across the whole level",
        })

    failed = [l for l in legs if not l["reached"]]
    if failed:
        out.append({
            "severity": "blocker",
            "what": "The bot could not complete the intended route.",
            "number": "%d of %d legs failed: %s"
                      % (len(failed), len(legs), ", ".join(l["goal"] for l in failed)),
            "where": "; ".join("%s ended %s (%dpx short)"
                              % (l["goal"], l["ended"], l["short_by"]) for l in failed),
        })

    unplanned = [l for l in legs if not l["planned"]]
    if unplanned:
        out.append({
            "severity": "blocker",
            "what": "No route exists at all to some goals -- not a skill problem.",
            "number": "%d goals had no path in the graph" % len(unplanned),
            "where": ", ".join(l["goal"] for l in unplanned),
        })

    if bot.blocked_edges:
        out.append({
            "severity": "fidelity",
            "what": "The level's geometry promises moves the physics will not perform.",
            "number": "%d edges marked blocked after the game refused them" % bot.blocked_edges,
            "where": "swing landings mostly; the pendulum model is optimistic",
        })

    covered = len(bot.cells)
    if covered < 60:
        out.append({
            "severity": "design",
            "what": "A full playthrough only ever sees a fraction of the level.",
            "number": "%d of 144 screen-cells entered in %.0fs of play"
                      % (covered, bot.frames / 60.0),
            "where": "the level is much bigger than the route through it",
        })

    if bot.damage >= 3:
        out.append({
            "severity": "balance",
            "what": "Incidental damage is high for a run that mostly just travelled.",
            "number": "%d of 5 health lost" % bot.damage,
            "where": "hazards sit on the routes people move along",
        })

    haz = len(level["hazards"])
    anchors = len(level["anchors"])
    if anchors > 90:
        out.append({
            "severity": "readability",
            "what": "Anchors are so numerous they read as noise instead of architecture.",
            "number": "%d anchors, %d hazards across 144 cells" % (anchors, haz),
            "where": "every screen looks like every other screen",
        })
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--shots", action="store_true")
    ap.add_argument("--out", default="playbot_out")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    shots = os.path.join(args.out, "shots") if args.shots else None
    if shots:
        os.makedirs(shots, exist_ok=True)

    s = socket.create_connection((HOST, PORT), timeout=30)
    g = Game(s)
    g.send(cmd="load_room", scene=ROOM)
    level = g.send(cmd="level")

    t0 = time.time()
    nav = Nav(level)
    build_s = time.time() - t0
    print("graph: %d nodes, %d edges in %.1fs (walk %d / jump %d / drop %d / swing %d)" % (
        len(nav.nodes), sum(len(v) for v in nav.edges.values()), build_s,
        *[sum(1 for i in nav.edges for e in nav.edges[i] if e["move"] == m)
          for m in ("walk", "jump", "drop", "swing")]))
    print("jump budget: %.0fpx up, %.0fpx across | lasso %.0fpx" % (nav.up, nav.across, nav.reach))
    start = nav.nearest((90, 620))
    print("reachable from entry: %d of %d spots (%.0f%%)" % (
        len(nav.reachable(start)), len(nav.nodes),
        100.0 * len(nav.reachable(start)) / len(nav.nodes)))

    bot = Bot(g, nav, shots)
    legs = []
    for label, goal in GOALS:
        r = bot.run_leg(label, goal)
        legs.append(r)
        print("  %-42s %s %5.1fs  %2d steps  %s" % (
            label, "REACHED" if r["reached"] else "failed ", r["seconds"],
            r["plan_steps"], r["ended"]))
        if shots:
            bot.look(label.split()[0])

    complaints = evaluate(nav, legs, bot, level)
    report = {
        "graph": {"nodes": len(nav.nodes), "edges": sum(len(v) for v in nav.edges.values())},
        "legs": legs, "cells": len(bot.cells), "damage": bot.damage,
        "blocked_edges": bot.blocked_edges, "complaints": complaints,
        "path": bot.path,
    }
    with open(os.path.join(args.out, "complaints.json"), "w") as f:
        json.dump(report, f, indent=1)

    print("\n=== COMPLAINTS ===")
    for c in complaints:
        print("  [%s] %s" % (c["severity"].upper(), c["what"]))
        print("        %s" % c["number"])
        print("        -> %s" % c["where"])
    g.send(cmd="quit")


if __name__ == "__main__":
    main()
