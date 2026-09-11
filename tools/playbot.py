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

# How a swing is set up, and it has to match tools/calibrate_swing.py exactly:
# the envelope measured there describes THIS approach, so the graph is only
# entitled to believe in it while the executor performs the same move.
RUN_FRAMES = 20
AIR_FRAMES = 4
MAX_RIDE = 110


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

    # Tolerances for matching a proposed swing against the measured cloud, in
    # rope-normalised units, so a short rope is judged more tightly in pixels
    # than a long one -- which is what the measurements actually show.
    TOL_ANCHOR = 0.28       # how alike the anchor geometry has to be
    TOL_LANDING = 0.22      # how close the landing has to be to a real one
    MIN_SUPPORT = 2         # how many measured swings must vouch for an edge

    def __init__(self, level, swing_samples=None):
        t = level["tuning"]
        self.tuning = t
        v = abs(t["jump_velocity"])
        self.up = (v * v) / (2.0 * t["gravity"])
        t_up = v / t["gravity"]
        t_dn = math.sqrt(2.0 * self.up / (t["gravity"] * t["fall_gravity_multiplier"]))
        self.across = t["run_speed"] * (t_up + t_dn)
        self.reach = t["lasso_range_px"]
        self.fall_g = t["gravity"] * t["fall_gravity_multiplier"]
        self.run_speed = t["run_speed"]
        self.term = t.get("terminal_fall_speed", 700.0)
        self.bottom = level["bounds"][1] + level["bounds"][3] + 200.0

        # The measured swing envelope. None means NOT MEASURED, and in that
        # case no swing edge is created at all: a graph with a guessed rope in
        # it looks exactly like a graph with a real one until the bot tries it.
        self.samples = swing_samples
        self.swing_measured = bool(swing_samples)
        self.grab_dx, self.grab_dy = 0.0, 0.0
        self.climb_apex = 0.0
        self.rope_lo, self.rope_hi = 0.0, 0.0
        if self.swing_measured:
            gdx = sorted(s["side"] * (s["grab"][0] - s["from"][0]) for s in swing_samples)
            gdy = sorted(s["grab"][1] - s["from"][1] for s in swing_samples)
            ropes = sorted(s["rope"] for s in swing_samples)
            self.grab_dx = gdx[len(gdx) // 2]
            self.grab_dy = gdy[len(gdy) // 2]
            self.rope_lo, self.rope_hi = ropes[0], ropes[-1]
            # How high the rope can actually put him, measured. A climb lifts
            # Michael and he then falls back to whatever is underneath, so the
            # LANDING is at or below the launch and says nothing about whether a
            # ledge above is reachable. The apex does. Taken at the 80th
            # percentile of measured climbs rather than the best single one, so
            # the graph believes in a height most climbs reach and not a fluke.
            apexes = sorted(-s["apex_dy"] for s in swing_samples
                            if s.get("apex_dy") is not None and s["apex_dy"] < 0)
            self.climb_apex = apexes[int(len(apexes) * 0.8)] if len(apexes) >= 8 else 0.0
            self.sbucket = defaultdict(list)
            for s in swing_samples:
                key = (int(round(s["ax"] / self.TOL_ANCHOR)),
                       int(round(s["ay"] / self.TOL_ANCHOR)))
                self.sbucket[key].append(s)

        self.plats = [tuple(p) for p in level["platforms"]]
        self.anchors = [tuple(a) for a in level["anchors"]]
        # Hazards hurt, and an active encounter is a solid body that simply
        # stops Michael walking: one guard standing on a ledge held the bot at
        # x=632 for a whole 70s leg, pushing it back a pixel at a time, with the
        # level geometry entirely innocent.
        self.hazards = [tuple(h) for h in level.get("hazards", [])]
        self.foes = [tuple(e["at"]) for e in level.get("encounters", [])]
        # A closed MechanismGate is solid and is not in the platform list. One
        # of them (Door_z10a, watching cistern_west_winch) sits across the only
        # walkway off the y=1900 ledge, and every run before the server started
        # reporting doors ended standing against it, unable to move, with the
        # bot blaming the physics for a puzzle nobody had told it about.
        self.switches = {}
        for t in level.get("targets", []):
            if isinstance(t, dict):
                self.switches[t["puzzle"]] = (tuple(t["at"]), list(t.get("verbs", [])))
        self.shut = [tuple(d["rect"]) for d in level.get("doors", [])
                     if not d.get("open")]
        self.locked_by = sorted({d.get("puzzle", "?") for d in level.get("doors", [])
                                 if not d.get("open")})
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

        # Platforms bucketed by x column, so simulating a fall does not have to
        # ask all 66 of them on every one of its frames.
        self.pcol = defaultdict(list)
        for (px, py, pw, ph) in self.plats:
            for c in range(int(px // self.CELL), int((px + pw) // self.CELL) + 1):
                self.pcol[c].append((px, py, pw, ph))

        self.danger = [0.0] * len(self.nodes)
        for i, (x, y) in enumerate(self.nodes):
            for hx, hy in self.hazards:
                if math.dist((x, y), (hx, hy)) < self.HAZARD_RADIUS:
                    self.danger[i] += self.HAZARD_COST
            for fx, fy in self.foes:
                if math.dist((x, y), (fx, fy)) < self.FOE_RADIUS:
                    self.danger[i] += self.FOE_COST

        self.edges = defaultdict(list)
        self.blocked = set()
        self._build()

    HALF_W = 12.0           # Player.BODY_WIDTH / 2

    def _fall(self, x, y, vx, max_frames=260):
        """Simulate a real fall. Returns the platform top landed on, or None.

        The first version of the drop edge said "any node below within a
        ballistic span", which let the graph plan a 560px drop straight down
        THROUGH the platform Michael was standing on. Terrain here is solid
        StaticBody2D rectangles (GrayboxTerrain), so a fall can be simulated
        against them, and a drop that hits a wall or a ceiling on the way is
        simply not an edge.
        """
        dt = 1.0 / 60.0
        vy = 0.0
        for _ in range(max_frames):
            nx = x + vx * dt
            vy = min(vy + self.fall_g * dt, self.term)
            ny = y + vy * dt
            best = None
            for (px, py, pw, ph) in list(self.pcol.get(int(nx // self.CELL), ())) + self.shut:
                if nx + self.HALF_W <= px or nx - self.HALF_W >= px + pw:
                    continue
                if y <= py <= ny and (best is None or py < best):
                    best = py                       # landed on this top surface
                elif py + 4.0 < ny < py + ph and y > py + 4.0:
                    return None                     # walked into its side
            if best is not None:
                return (nx, best)
            x, y = nx, ny
            if y > self.bottom:
                return None
        return None

    def _near(self, x, y, radius):
        cx, cy = int(x // self.CELL), int(y // self.CELL)
        span = int(radius // self.CELL) + 1
        out = []
        for gx in range(cx - span, cx + span + 1):
            for gy in range(cy - span, cy + span + 1):
                out.extend(self.bucket.get((gx, gy), ()))
        return out

    HAZARD_RADIUS = 90.0
    HAZARD_COST = 400.0
    FOE_RADIUS = 70.0
    FOE_COST = 120.0

    def _add(self, a, b, move, cost, anchor=None, hold=None):
        # A route that walks over a hazard is cheap in distance and expensive in
        # health: the first run of this reached one goal and arrived at 1 of 5
        # health, having simply strolled through everything in the way.
        self.edges[a].append({"to": b, "move": move,
                              "cost": cost + self.danger[b],
                              "anchor": anchor, "hold": hold})

    def _barred(self, ax, ay, bx, by):
        """True if a closed gate stands between two standing spots."""
        lo, hi = min(ax, bx) - self.HALF_W, max(ax, bx) + self.HALF_W
        top, bot = min(ay, by) - 64.0, max(ay, by)
        for (dx, dy, dw, dh) in self.shut:
            if dx < hi and dx + dw > lo and dy < bot and dy + dh > top:
                return True
        return False

    def _landing_node(self, hit):
        """The standable node nearest a simulated landing, or None if it is bare."""
        best, bd = None, 1e18
        for j in self._near(hit[0], hit[1], 200.0):
            if abs(self.nodes[j][1] - hit[1]) > 6.0:
                continue
            d = abs(self.nodes[j][0] - hit[0])
            if d < bd and d <= self.SAMPLE:
                best, bd = j, d
        return best

    def _vouchers(self, ax, ay):
        """Measured swings whose anchor geometry resembles this one."""
        out = []
        kx = int(round(ax / self.TOL_ANCHOR))
        ky = int(round(ay / self.TOL_ANCHOR))
        for gx in (kx - 1, kx, kx + 1):
            for gy in (ky - 1, ky, ky + 1):
                for s in self.sbucket.get((gx, gy), ()):
                    if abs(s["ax"] - ax) <= self.TOL_ANCHOR and abs(s["ay"] - ay) <= self.TOL_ANCHOR:
                        out.append(s)
        return out

    def _build(self):
        for i, (ax, ay) in enumerate(self.nodes):
            for j in self._near(ax, ay, max(self.across, 60.0) + self.SAMPLE):
                if i == j:
                    continue
                bx, by = self.nodes[j]
                dx, dy = abs(bx - ax), by - ay
                if self._barred(ax, ay, bx, by):
                    continue
                if self.owner[i] == self.owner[j] and dx <= self.SAMPLE * 1.2:
                    self._add(i, j, "walk", dx)
                elif dx <= self.across and -dy <= self.up and dy <= 20.0:
                    # Upward or level only. A "jump" 260px downward was really a
                    # drop with no obstruction check on it.
                    self._add(i, j, "jump", dx + abs(dy) + 40.0)

        # drops: step off the end of a platform and fall wherever the physics
        # puts you. Both ends, at a walk and at a run, since the two land in
        # meaningfully different places over a wide gap.
        for i, (x, y) in enumerate(self.nodes):
            px, py, pw, ph = self.plats[self.owner[i]]
            for edge_x, out in ((px - self.HALF_W - 2.0, -1.0),
                                (px + pw + self.HALF_W + 2.0, 1.0)):
                if abs(edge_x - x) > self.SAMPLE * 1.5:
                    continue
                for speed in (self.run_speed, self.run_speed * 0.45):
                    hit = self._fall(edge_x, y - 2.0, out * speed)
                    if hit is None:
                        continue
                    j = self._landing_node(hit)
                    if j is None or j == i:
                        continue
                    self._add(i, j, "drop",
                              (hit[1] - y) * 0.35 + abs(hit[0] - x) * 0.3 + 30.0)

        # swings: only where a swing has actually been measured landing there.
        if not self.swing_measured:
            return
        abucket = defaultdict(list)
        for k, (x, y) in enumerate(self.anchors):
            abucket[(int(x // self.CELL), int(y // self.CELL))].append(k)
        for i, (nx, ny) in enumerate(self.nodes):
            cx, cy = int(nx // self.CELL), int(ny // self.CELL)
            for side in (1.0, -1.0):
                # Where the rope actually goes out from: a run-up and a held
                # jump ahead of the standing spot, measured, not assumed.
                gx = nx + side * self.grab_dx
                gy = ny + self.grab_dy
                for bgx in range(cx - 1, cx + 2):
                    for bgy in range(cy - 1, cy + 2):
                        for k in abucket.get((bgx, bgy), ()):
                            anx, anyy = self.anchors[k]
                            if (anx - nx) * side < 0.0:
                                continue          # you run at the anchor, not away
                            rope = math.dist((gx, gy), (anx, anyy))
                            if not (self.rope_lo <= rope <= min(self.rope_hi, self.reach)):
                                continue
                            ax = side * (anx - nx) / rope
                            ay = (anyy - ny) / rope
                            near = self._vouchers(ax, ay)
                            if len(near) < self.MIN_SUPPORT:
                                continue
                            for j in self._near(nx, ny, self.reach * 2.0):
                                if j == i:
                                    continue
                                bx, by = self.nodes[j]
                                u = side * (bx - nx) / rope
                                v = (by - ny) / rope
                                hits = [s for s in near
                                        if abs(s["u"] - u) <= self.TOL_LANDING
                                        and abs(s["v"] - v) <= self.TOL_LANDING]
                                if len(hits) < self.MIN_SUPPORT:
                                    continue
                                holds = sorted(h["hold"] for h in hits)
                                # Swings are priced above their distance because
                                # even a measured one only lands where the graph
                                # expects about half the time, while a walk is
                                # near certain. But not priced too far above:
                                # at +400 A* preferred long chains of drops, and
                                # a drop is ONE WAY -- a swing gains no height
                                # (measured: best +3px in 248 trials) and the
                                # jump is 63px -- so the bot fell somewhere it
                                # could never climb out of and every later leg
                                # started from there. Measured at +90, +150 and
                                # +400: the leg count did not separate them, so
                                # this sits in the middle rather than claiming
                                # a win it did not earn.
                                self._add(i, j, "swing",
                                          math.dist((nx, ny), (bx, by)) * 0.9 + 150.0,
                                          k, holds[len(holds) // 2])

                            # Upward edges, which no amount of pendulum gives
                            # you. Hauling the rope in raises Michael toward the
                            # anchor, so a ledge ABOVE the launch is reachable
                            # when the measured apex clears it and the ledge
                            # sits near the anchor rather than out at the end of
                            # the arc. Measured apex: best +362px, and +155px on
                            # the 45 rides that held the climb.
                            if self.climb_apex > 40.0:
                                for j in self._near(anx, anyy, self.reach):
                                    if j == i:
                                        continue
                                    bx, by = self.nodes[j]
                                    rise = ny - by
                                    if rise <= 40.0 or rise > self.climb_apex:
                                        continue
                                    if by < anyy - 24.0:
                                        continue      # never above the anchor
                                    if abs(bx - anx) > rope * 1.1:
                                        continue      # out at the end of the arc
                                    self._add(i, j, "climb",
                                              rise * 1.2 + 170.0, k, "climb")

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
                    prev, move, anchor, hold = came[cur]
                    out.append({"node": cur, "move": move, "anchor": anchor,
                                "hold": hold, "from": prev})
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
                    came[nxt] = (cur, e["move"], e["anchor"], e["hold"])
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
    def __init__(self, game, nav, shots_dir=None, trace=False):
        self.g = game
        self.nav = nav
        self.shots = shots_dir
        self.trace = trace
        self.path = []
        self.cells = set()
        self.damage = 0
        self.health = 5
        self.blocked_edges = 0
        self.replans = 0
        self.shots_at = {}
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

    def _closest_reachable(self, start, goal):
        """The best place still open, preferring not to throw away height.

        Height is measurably one-way here: a swing gains none (best +3px over
        248 measured trials) and the jump is 63px, so a drop can never be
        undone. Taking the single nearest reachable node sent the bot down a
        shaft on leg one, 396px from a goal it could not reach anyway, and
        every later leg then started below the gate it needed. Among the
        candidates that are near enough to be indistinguishable, take the
        highest one.
        """
        cands = [(math.dist(self.nav.nodes[i], goal), i)
                 for i in self.nav.reachable(start)]
        if not cands:
            return None
        bd = min(d for d, _ in cands)
        near = [i for d, i in cands if d <= max(bd * 1.25, bd + 80.0)]
        return min(near, key=lambda i: self.nav.nodes[i][1])

    def _clear_the_way(self, st, toward_x):
        """Shoot whatever is standing in the way, if anything is.

        An active encounter is a solid body. One painted guard on the ledge at
        y=1900 stopped Michael dead at x=632 -- pressing move_right produced a
        velocity of exactly zero -- and every route onward from that platform
        ran through it, so the bot spent leg after leg failing at a piece of
        level design that was entirely fine. Michael carries a pistol; the bot
        had simply never fired it.

        Returns True if it shot at something.
        """
        p = tuple(st["pos"])
        side = 1.0 if toward_x > p[0] else -1.0
        ahead = [e for e in st.get("encounters", [])
                 if abs(e["at"][1] - p[1]) < 90.0
                 and 0.0 < (e["at"][0] - p[0]) * side < 260.0]
        if not ahead:
            return False
        press = ["move_right"] if side > 0 else ["move_left"]
        self._act({"cmd": "act", "n": 2, "press": ["tool_pistol"]})
        for _ in range(6):
            # tool_use is read with is_action_just_pressed, so it has to be
            # released between shots or only the first one ever fires.
            self._act({"cmd": "act", "n": 3, "press": press + ["tool_use"]})
            self._act({"cmd": "act", "n": 7, "press": press})
        return True

    def unlock(self, puzzle_id):
        """Go to the switch that opens a door, and actually operate it.

        This is the capability the bot was missing entirely. It knew doors were
        shut -- it routed around them and complained about them -- but nothing
        in walk/jump/drop/swing can open one, so 35% of the level stayed behind
        gates that had working switches the whole time.

        It drives the real ToolController: equip, face the switch, press
        tool_use. ToolController.aim_direction falls back to Michael's facing
        when there is no mouse, which headless always is, so facing IS aiming
        and a bot that stands the wrong way misses.
        """
        entry = self.nav.switches.get(puzzle_id)
        if entry is None:
            return {"puzzle": puzzle_id, "opened": False, "why": "no switch exists"}
        at, verbs = entry
        tool = "tool_lasso" if "pull" in verbs else "tool_pistol"
        reach = self.nav.reach if tool == "tool_lasso" else 220.0

        leg = self.run_leg("switch for %s" % puzzle_id, at, budget_s=55.0)
        st = self.g.state()
        p = tuple(st["pos"])
        if math.dist(p, at) > reach:
            return {"puzzle": puzzle_id, "opened": False,
                    "why": "could not get within reach (%d px away)" % math.dist(p, at)}

        press = ["move_right"] if at[0] > p[0] else ["move_left"]
        self._act({"cmd": "act", "n": 3, "press": [tool]})
        for _ in range(8):
            # A nudge toward the switch first, so facing is right, then the use.
            self._act({"cmd": "act", "n": 2, "press": press})
            self._act({"cmd": "act", "n": 3, "press": press + ["tool_use"]})
            self._act({"cmd": "act", "n": 6, "press": []})
            st = self.g.state()
            for gate in st.get("gates", []):
                if gate["puzzle"] == puzzle_id and gate["open"]:
                    return {"puzzle": puzzle_id, "opened": True,
                            "why": "opened with %s" % tool.replace("tool_", "")}
        return {"puzzle": puzzle_id, "opened": False,
                "why": "in reach with %s but it never opened" % tool.replace("tool_", "")}

    def _replan(self, p, target, goal):
        """Re-plan to the goal, or failing that to the best place still open.

        Breaking out of a leg the moment the plan runs dry threw away most of
        the budget: several legs stopped with sixty seconds unspent while
        standing somewhere the graph could still have improved on.
        """
        here = self.nav.nearest(p)
        plan = self.nav.plan(here, target)
        if plan:
            return plan
        alt = self._closest_reachable(here, goal)
        if alt is None or alt == here:
            return []
        return self.nav.plan(here, alt)

    def _do_swing(self, step, budget_frames=240):
        """Run up, jump, grab in the air, ride to the bottom of the arc, let go.

        This is the same sequence tools/calibrate_swing.py measured, which is
        the only reason the graph is entitled to believe in the edge. The old
        version threw the rope from a standing start, and a standing swing does
        not move at all: the pendulum's first sub-pixel step collides with the
        floor and `slide` zeroes the velocity, so Michael was pinned to the spot
        for the whole timeout, every time.

        Returns the state after landing, and how many frames it cost.
        """
        anchor = self.nav.anchors[step["anchor"]]
        target = self.nav.nodes[step["node"]] if step.get("node") is not None else None
        st = self.g.state()
        side = 1.0 if anchor[0] >= st["pos"][0] else -1.0
        press = ["move_right"] if side > 0 else ["move_left"]
        used = 0

        st = self._act({"cmd": "act", "n": RUN_FRAMES, "press": press})
        st = self._act({"cmd": "act", "n": 1, "press": press + ["jump"]})
        st = self._act({"cmd": "act", "n": AIR_FRAMES, "press": press + ["jump"]})
        used += RUN_FRAMES + 1 + AIR_FRAMES
        if st["on_floor"]:
            return st, used, "never left the ground"
        rope = math.dist(tuple(st["pos"]), anchor)
        if rope > self.nav.reach:
            return st, used, "anchor out of reach at the grab (%.0fpx)" % rope

        st = self._act({"cmd": "act", "n": 1, "press": [], "swing_at": list(anchor)})
        used += 1
        # Holding jump on the rope hauls it in, and that is the only way a swing
        # gains height at all -- a pendulum is a closed system and strictly
        # loses. So: climb when the landing is above the grab, ride the arc when
        # it is not. Without this the bot could physically never reach anything
        # higher than it started, which read as "the level is unreachable".
        climbing = target is not None and target[1] < st["pos"][1] - 40.0
        ride_press = ["jump"] if climbing else []
        # Release at the bottom of the arc going the right way: vy crossing from
        # positive to negative IS the bottom, and it is visible from outside.
        prev_vy = None
        for _ in range(min(MAX_RIDE, budget_frames - used)):
            st = self._act({"cmd": "act", "n": 1, "press": ride_press})
            used += 1
            if not st["swinging"]:
                break
            vx, vy = st["vel"]
            if climbing:
                # Climbing, the useful moment is being level with or above the
                # landing, not the bottom of the arc.
                if st["pos"][1] <= target[1] + 20.0 and vx * side > -10.0:
                    break
            elif prev_vy is not None and prev_vy > 20.0 and vy <= 0.0 and vx * side > 40.0:
                break
            prev_vy = vy
        st = self._act({"cmd": "act", "n": 1, "press": [], "release_swing": True})
        used += 1
        for _ in range(14):
            st = self._act({"cmd": "act", "n": 6, "press": []})
            used += 6
            if st["on_floor"]:
                break
        return st, used, None

    def run_leg(self, label, goal, budget_s=90.0):
        st = self.g.state()
        start = self.nav.nearest(tuple(st["pos"]))
        target = self.nav.nearest(goal)
        plan = self.nav.plan(start, target)
        planned = bool(plan)
        fallback = False
        if not plan:
            # No route to the goal. Standing still measures nothing; going as
            # far as the graph allows measures how far short the level leaves
            # you, which is the number worth reporting.
            alt = self._closest_reachable(start, goal)
            if alt is not None and alt != start:
                plan = self.nav.plan(start, alt)
                target = alt
                fallback = bool(plan)
        elapsed = 0.0
        step_i = 0
        step_t = 0.0
        step_from = tuple(st["pos"])
        jump_held = 0
        best = math.dist(tuple(st["pos"]), goal)
        # When a leg stops closing on its goal it is usually standing at a dead
        # end -- most often a locked gate -- and the rest of the budget goes
        # into re-trying rope edges that have already failed. Six legs doing
        # that is nine minutes of run time telling you nothing the first twenty
        # seconds did not.
        stale = 0.0

        while step_i < len(plan) and elapsed < budget_s:
            # Arriving is the point, not finishing the plan. Without this the
            # bot walked through the goal and kept going, and a leg that had
            # been within 165px of its target was scored a failure from
            # wherever the budget happened to run out.
            if st["on_floor"] and not st["swinging"] \
                    and math.dist(tuple(st["pos"]), goal) < 200.0:
                break
            if stale > 25.0:
                break
            step = plan[step_i]
            tgt = self.nav.nodes[step["node"]]
            move = step["move"]

            if move in ("swing", "climb"):
                at = tuple(st["pos"])
                st, used, why = self._do_swing(step)
                elapsed += used / 60.0
                p = tuple(st["pos"])
                # "Within 60px of the target" is not enough on its own: a swing
                # that goes nowhere at all can satisfy it when the target is the
                # next node along, and then the edge is scored a success and
                # planned again, forever. A leg was burning its whole 70s budget
                # doing exactly that against an enemy body that was blocking the
                # ledge. Arriving has to include having moved.
                landed_on_target = (abs(p[0] - tgt[0]) < 60 and abs(p[1] - tgt[1]) < 56
                                    and st["on_floor"] and math.dist(p, at) > 55.0)
                if self.trace:
                    print("      swing  from %s anchor %s -> want %s got %s  %s"
                          % ([int(v) for v in at],
                             [int(v) for v in self.nav.anchors[step["anchor"]]],
                             [int(v) for v in tgt], [int(v) for v in p],
                             "OK" if landed_on_target else (why or "landed elsewhere")))
                if not landed_on_target:
                    self.nav.blocked.add((step["from"], step["node"]))
                    self.blocked_edges += 1
                # A swing is a throw, not a step: wherever it put him is the new
                # truth, so replan from there instead of insisting on the plan.
                self.replans += 1
                plan = self._replan(p, target, goal)
                step_i, step_t, step_from, jump_held = 0, 0.0, p, 0
                gap = math.dist(p, goal)
                stale = 0.0 if gap < best - 20.0 else stale + used / 60.0
                best = min(best, gap)
                if not plan:
                    break
                continue

            act = {"cmd": "act", "n": 4, "press": self._dir(st["pos"][0], tgt[0])}
            if move == "jump":
                # The jump must be HELD or jump_cut_multiplier takes two thirds
                # of the height: 18px instead of 63px, which is most of the
                # jumps in this level.
                if st["on_floor"]:
                    act["press"].append("jump")
                    jump_held = 1
                elif 0 < jump_held < 4 and st["vel"][1] < 0:
                    act["press"].append("jump")
                    jump_held += 1
            else:
                jump_held = 0

            st = self._act(act)
            step_t += 4 / 60.0
            elapsed += 4 / 60.0
            p = tuple(st["pos"])
            gap = math.dist(p, goal)
            stale = 0.0 if gap < best - 20.0 else stale + 4 / 60.0
            best = min(best, gap)

            if abs(p[0] - tgt[0]) < 44 and abs(p[1] - tgt[1]) < 48 \
                    and st["on_floor"] and not st["swinging"]:
                step_i += 1
                step_t = 0.0
                step_from = p
                jump_held = 0
            elif step_t > 2.4:
                # Before disbelieving the edge, check whether the obstacle is a
                # living thing rather than the geometry, and shoot it if so.
                if (self.shots_at.get(step["from"], 0) < 2
                        and self._clear_the_way(st, tgt[0])):
                    self.shots_at[step["from"]] = self.shots_at.get(step["from"], 0) + 1
                    st = self._tick(1)
                    step_t = 0.0
                    elapsed += 1.5
                    continue
                # the level did not honour this edge; stop believing in it
                if self.trace:
                    print("      %-6s want %s got %s  TIMED OUT"
                          % (move, [int(v) for v in tgt], [int(v) for v in p]))
                self.nav.blocked.add((step["from"], step["node"]))
                self.blocked_edges += 1
                self.replans += 1
                if st["swinging"]:
                    self.g.send(cmd="release_swing")
                plan = self._replan(p, target, goal)
                step_i, step_t, step_from, jump_held = 0, 0.0, p, 0
                if not plan:
                    break

        self.g.send(cmd="release_all")
        st = self.g.state()
        p = tuple(st["pos"])
        return {
            "goal": label, "at": list(goal), "planned": planned,
            "fallback": fallback,
            "plan_steps": len(plan), "reached": math.dist(p, goal) < 200,
            "closest": int(best),
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

    if nav.shut:
        out.append({
            "severity": "blocker",
            "what": "Closed puzzle gates stand across the route, and nothing "
                    "on the way to them opens one.",
            "number": "%d gates shut, watching %s" % (len(nav.shut), ", ".join(nav.locked_by)),
            "where": "; ".join("gate at %d,%d" % (int(d[0]), int(d[1])) for d in nav.shut),
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
    ap.add_argument("--trace", action="store_true",
                    help="print every step the executor attempts and what came of it")
    ap.add_argument("--out", default="playbot_out")
    ap.add_argument("--port", type=int, default=PORT)
    ap.add_argument("--host", default=HOST)
    ap.add_argument("--room", default=ROOM,
                    help="scene path of the room to play or audit")
    ap.add_argument("--audit", action="store_true",
                    help="build the graph and report reachability, then stop. "
                         "No play, no goals -- for rooms that have no authored "
                         "route through them yet.")
    ap.add_argument("--swing-model", default="swing_model.json",
                    help="the measured envelope from tools/calibrate_swing.py")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    shots = os.path.join(args.out, "shots") if args.shots else None
    if shots:
        os.makedirs(shots, exist_ok=True)

    # A swing edge exists only where a swing was measured landing there. With no
    # measurement the graph gets NO swing edges and says so: a guessed rope and
    # a real one look identical in a node count, and the first version of this
    # file shipped 12,775 guessed ones.
    samples = None
    if os.path.exists(args.swing_model):
        with open(args.swing_model) as f:
            blob = json.load(f)
        samples = blob["samples"] if isinstance(blob, dict) else blob
        samples = [s for s in samples if s.get("landed") and "u" in s]
    if samples:
        print("swing model: %d measured swings from %s" % (len(samples), args.swing_model))
    else:
        print("swing model: NOT MEASURED (%s missing or empty). Building the graph "
              "with ZERO swing edges rather than guessing them." % args.swing_model)

    s = socket.create_connection((args.host, args.port), timeout=30)
    g = Game(s)
    g.send(cmd="load_room", scene=args.room)
    level = g.send(cmd="level")
    level["encounters"] = g.send(cmd="state").get("encounters", [])

    t0 = time.time()
    nav = Nav(level, samples)
    build_s = time.time() - t0
    print("graph: %d nodes, %d edges in %.1fs (walk %d / jump %d / drop %d / swing %d)" % (
        len(nav.nodes), sum(len(v) for v in nav.edges.values()), build_s,
        *[sum(1 for i in nav.edges for e in nav.edges[i] if e["move"] == m)
          for m in ("walk", "jump", "drop", "swing")]))
    print("jump budget: %.0fpx up, %.0fpx across | lasso %.0fpx" % (nav.up, nav.across, nav.reach))
    if nav.swing_measured:
        print("swing envelope: grab %+.0f,%+.0f from the launch spot; rope %.0f-%.0fpx"
              % (nav.grab_dx, nav.grab_dy, nav.rope_lo, nav.rope_hi))
    if nav.shut:
        print("closed gates: %d, solid and not in the platform list (%s)"
              % (len(nav.shut), ", ".join(nav.locked_by)))
    start = nav.nearest((90, 620))
    print("reachable from entry: %d of %d spots (%.0f%%)" % (
        len(nav.reachable(start)), len(nav.nodes),
        100.0 * len(nav.reachable(start)) / len(nav.nodes)))

    if args.audit:
        start = nav.nearest((90, 620))
        reach = nav.reachable(start)
        orphans = len(nav.nodes) - len(reach)
        print("AUDIT %s: %d spots, %d reachable (%.0f%%), %d orphaned" % (
            args.room.split("/")[-1], len(nav.nodes), len(reach),
            100.0 * len(reach) / max(1, len(nav.nodes)), orphans))
        g.send(cmd="quit")
        return

    bot = Bot(g, nav, shots, trace=args.trace)

    # Unlock first. Every shut door in this level has a working switch
    # somewhere else on the map, and the bot could not operate one, so it spent
    # every previous run routing around puzzles it was capable of solving.
    unlocks = []
    if nav.locked_by:
        print("unlocking %d gates before the route: %s" % (
            len(nav.locked_by), ", ".join(nav.locked_by)))
        for puzzle in nav.locked_by:
            u = bot.unlock(puzzle)
            unlocks.append(u)
            print("  %-26s %s  (%s)" % (
                puzzle, "OPENED" if u["opened"] else "shut  ", u["why"]))
        level = g.send(cmd="level")
        nav = Nav(level, swing_samples=nav.samples if hasattr(nav, "samples") else None)
        bot.nav = nav
        print("  graph rebuilt with the opened doors: %d nodes, %d edges" % (
            len(nav.nodes), sum(len(v) for v in nav.edges.values())))

    legs = []
    for label, goal in GOALS:
        r = bot.run_leg(label, goal)
        legs.append(r)
        print("  %-42s %s %5.1fs  %2d steps  ended %s  closest %dpx" % (
            label, "REACHED" if r["reached"] else "failed ", r["seconds"],
            r["plan_steps"], r["ended"], r["closest"]))
        if shots:
            bot.look(label.split()[0])

    complaints = evaluate(nav, legs, bot, level)
    report = {
        "graph": {"nodes": len(nav.nodes), "edges": sum(len(v) for v in nav.edges.values())},
        "legs": legs, "cells": len(bot.cells), "damage": bot.damage,
        "blocked_edges": bot.blocked_edges, "unlocks": unlocks,
        "complaints": complaints,
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
