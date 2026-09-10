"""Every authored situation in the Sunken Cistern, with the design written out.

A beat is not a label. Each one states what the player sees when they arrive,
what they will try first, what that costs them, and what the better play is.
If it cannot be written as a paragraph it is furniture, and furniture does not
go in the level.

Element kinds are documented in gen_sunken_cistern.py. Coordinates inside a
beat are relative to the beat's own origin.
"""


def author(beat, FLOOR_Y):

    # ======================================================== Z1  THE ENTRY
    beat("z1a", 0, 620, """
        Michael comes through the crack from the Procession Hall onto a wide,
        safe ledge high on the western wall, and the first thing that happens
        is nothing. The cistern is simply in front of him: the shaft falling
        away in the middle distance, kiln-light on the far wall, black water
        at the bottom with slabs standing out of it. Nothing here attacks and
        nothing is gated. The beat exists so the player picks a direction
        instead of being handed one, which is the difference between a place
        and a corridor. The shrine at the back of the ledge means the choice
        is cheap to get wrong.
        """,
        ("ledge", 0, 0, 620), ("spawn", 90, 0, "spawn_entry"),
        ("spawn", 90, 0, "spawn_from_procession"), ("shrine", 210, -42))

    beat("z1b", 700, 540, """
        A ledge sits above and to the right, plainly further than a jump. Most
        players will try the jump anyway, fall to the shelf below, and climb
        back; that is fine and costs nothing. The single anchor overhead is the
        answer, and it is placed so the swing is short and forgiving. This is
        the first rope in the level and it is deliberately the easiest one:
        the lesson is that the rope goes UP, which is not obvious to anyone
        who has played a platformer where a grapple is a horizontal thing.
        """,
        ("ledge", 0, 0, 300), ("anchor", 40, -160))

    beat("z1c", 1100, 700, """
        A gold cache sits on a ledge one swing further out, in plain sight from
        the entry. Nothing guards it and nothing is hidden -- the point is to
        show, before any risk exists, that leaving the obvious path is how you
        get things. A player who takes it has learned to look sideways for the
        rest of the level. A player who ignores it will see two more of these
        and eventually work it out.
        """,
        ("ledge", 0, 0, 260), ("anchor", 120, -190), ("cache", 130, -30))

    beat("z1d", 430, 300, """
        The roof walkway runs overhead, well lit and clearly standable, and
        there is no way to reach it from here. The anchor at its lip is
        visible and out of range from every surface in this zone. It is a
        promise: the best rewards in the cistern are up there, and getting to
        them is a problem to solve later from somewhere else. An unreachable
        thing you can see is worth more than a locked door, because the player
        invents the route themselves. The walkway itself is z6a's slab; this
        beat owns only the anchor at its lip, so the two are one piece of
        geometry rather than two copies of it.
        """,
        ("anchor", 1080, -120))

    beat("z1e", 240, 860, """
        Two shelves step down below the entry ledge, close enough to drop to
        without the rope. They exist so that down reads as a direction and not
        as a fall. Everything else in the west wing hangs off this: a player
        who steps down here is in the galleries within a few seconds, and a
        player who ropes across the shaft instead skips them entirely. Both are
        correct, which is the whole design of the zone.
        """,
        ("ledge", 0, 0, 130), ("ledge", 330, 40, 120), ("anchor", 200, -120))

    beat("z1f", 1240, 430, """
        Two anchors hang out over the mouth of the shaft with nothing beneath
        them but the whole level. From the entry ledge they are in range, and
        taking them commits Michael to the centre of the map before he has seen
        the west wing at all. This is the fast route and it is available
        immediately -- the cistern does not withhold its middle until the
        player has earned it. The cost is that the shaft is where the vents
        are, and he arrives without having found the shrine in the galleries.
        """,
        ("anchor", 0, 0), ("anchor", 260, -30))

    # ================================= Z2  THE SAGGING GALLERIES (west, upper)
    beat("z2a", 120, 1000, """
        Three grave jars stand on a long shelf, identical, one of them alive.
        The player has no way to tell which from looking, and the natural move
        with a lasso in hand is to rope one and haul it aside to get past. Do
        that to the wrong jar and a ceramic sentinel unfolds at arm's length on
        a shelf too narrow to retreat along. The two inert jars are real
        funerary vessels, so hauling them over is also an act the Keeper counts
        against you. The shelf is the whole introduction to ceramics: the tool
        that solves traversal is the tool that starts fights.
        """,
        ("ledge", 0, 0, 420), ("urn", 90, -30), ("urn", 200, -30),
        ("jar", 320, -30, 160, -80), ("anchor", 150, -200))

    beat("z2b", 300, 940, """
        A bronze chime hangs above the jar shelf, within pistol range and
        nothing else. Shooting it rings the gallery and forces every ceramic
        source in earshot to show its tell -- dust, a hairline crack, a hand
        below the rim -- before anything emerges. It costs one round and one
        second and it converts the previous beat from a coin flip into a
        readable problem. It is placed slightly behind and above the shelf so
        that a player who has already committed to hauling a jar cannot use it
        in time, which is the difference between caution and reflex.
        """,
        ("chime", 0, 0,))

    beat("z2c", 0, 1180, """
        A short shelf tucks in under the jar gallery, low enough that a player
        who does not want to deal with the jars at all can drop past them
        entirely. It leads nowhere special and holds nothing. Its job is to
        make cowardice a legitimate strategy, so that the players who DO engage
        with the jars are the ones who chose to.
        """,
        ("ledge", 0, 0, 180), ("anchor", 90, -170))

    beat("z2d", 300, 1320, """
        A cache sits on the shelf directly beneath the live jar. The line to it
        that requires no thought is a straight drop from the gallery above,
        which lands Michael inside the sentinel's reach with his back to a
        wall. The safe line is longer: rope out from the side shelf and come at
        it from the left. This is the first time the level places a reward
        where the fast route and the safe route genuinely differ, and it is
        early enough that the lesson is cheap to learn.
        """,
        ("ledge", 0, 0, 360), ("cache", 180, -30), ("anchor", 60, -180))

    beat("z2e", 640, 1160, """
        One anchor hangs alone in the air east of the galleries with no
        platform under it and nothing marked near it. It is the pivot that
        connects the jar shelf to the shaft in a single swing, and it is only
        obvious to a player who has started reading anchors as routes rather
        than as fixtures. Nothing is lost by missing it -- there is a slower
        way round -- but finding it is the moment the rope stops being a tool
        for crossing gaps and starts being how you move.
        """,
        ("anchor", 0, 0))

    beat("z2f", 90, 1640, """
        A painted procession runs along the back wall of a shelf barely wider
        than Michael, and one of the figures is a guard. The trigger is set at
        the far end, so it peels off the plaster when he is already committed
        to walking the shelf, with the wall at his back and a drop on the open
        side. There is no room here to back away and shoot, which is the point:
        the answer is the rope, either to stagger it and slip past or to leave
        immediately on the anchor overhead. It is the first fight the level
        actually stages rather than merely places.
        """,
        ("ledge", 0, 0, 300), ("mural", 110, -30, 250, -60), ("anchor", 40, -190))

    beat("z2g", 640, 1500, """
        A shelf sits one swing east of the mural, positioned exactly where a
        player fleeing that fight will end up. It is wide, empty and safe. A
        level that stages an ambush owes the player somewhere to arrive when
        the ambush works, or the fight is just damage; this is that place, and
        the guard cannot follow across the gap.
        """,
        ("ledge", 0, 0, 220), ("anchor", 110, -170))

    beat("z2h", 380, 1900, """
        The gallery floor widens into the first genuinely safe ground in the
        west wing, with a shrine on it. Michael can stand, reload, and look at
        what he has been doing. Its position matters more than its contents:
        it sits below the jars and the mural and above the long descent, so it
        is the natural place to fail back to, and it means the descent that
        follows can be dangerous without being punishing.
        """,
        ("ledge", 0, 0, 420), ("anchor", 210, -200), ("shrine", 380, -42))

    beat("z2i", 560, 2060, """
        A ledge juts out over the drop with a kiln vent burning directly
        beneath it. Dropping from here is the fastest way to the lower
        galleries and it costs health every time, because the vent sits exactly
        where a fall passes. Two anchors alongside let a player take the same
        line for free if they use the rope instead. It is a small, repeatable
        toll on impatience, placed where the player will pass it more than
        once.
        """,
        ("ledge", 0, 0, 200), ("vent", 100, 120, 110, 70),
        ("anchor", 100, -180), ("anchor", -120, -140))

    beat("z2j", 140, 2200, """
        Two more jars flank the only walkable route down through the lower
        galleries, and again one is alive -- but by now the player has met the
        chime and knows there is a way to ask. This is the beat that pays off
        z2b: the same problem, no new mechanic, and a player who learned the
        lesson walks through it in three seconds while a player who did not
        fights a sentinel on a staircase. Repetition with a solution available
        is how a teaching beat becomes a skill check.
        """,
        ("ledge", 0, 0, 340), ("urn", 80, -30), ("jar", 250, -30, 120, -70),
        ("anchor", 170, -190))

    beat("z2k", 420, 2460, """
        A heavy iron bar is set into the wall at the bottom of the west
        galleries. Roping it and hauling releases the kiln door -- which is
        four thousand pixels away on the far east side of the cistern, past the
        shaft, the water and the entire kiln stack. Nothing here indicates what
        it opened. The player will find out much later and, ideally, remember
        pulling it. Switches next to their doors are just doors; this is the
        beat that makes the cistern one connected machine instead of a series
        of rooms.
        """,
        ("ledge", 0, 0, 300), ("switch", 150, -30, "pull", "cistern_kiln_bar"),
        ("anchor", 60, -180))

    beat("z2l", 120, 2380, """
        One more broken shelf offset from the others, so the way down through
        the galleries is a choice between two lines rather than a ladder with
        one rung per floor. It carries nothing. Its whole function is to stop
        the descent reading as a single authored path, which is what the first
        version of this level got wrong everywhere.
        """,
        ("ledge", 0, 0, 120), ("anchor", 60, -160))

    # =============================================== Z3  THE WEST DESCENT
    beat("z3a", 60, 1150, """
        The first pair of anchors with genuinely nothing underneath them. Up to
        this point every swing in the level has had a floor within falling
        distance; here the next solid thing is three hundred pixels down and to
        the side. The swing is not hard, but it is the first one the player has
        to believe in before they take it, and the level has spent the whole
        west gallery earning the right to ask.
        """,
        ("anchor", 0, 0), ("anchor", 300, 40))

    beat("z3b", 60, 1470, """
        Three anchors staggered so that their arcs do not line up into a
        straight drop. A player swinging on rhythm alone will overshoot the
        third; a player who looks will see that the middle one is set high and
        use it to kill speed. This is the descent teaching that the pendulum
        has momentum, without saying so and without a tutorial prompt.
        """,
        ("anchor", 0, 0), ("anchor", 280, -60), ("anchor", 560, 20))

    beat("z3c", 60, 1790, """
        The same shape again, tighter, with the wall closer on the left so
        there is less room to arc. Repetition at increased difficulty, with no
        new element introduced. If a player struggles here it is because the
        skill from z3b did not land, and the shrine two beats up means finding
        that out is not expensive.
        """,
        ("anchor", 0, 0), ("anchor", 260, 40), ("anchor", 520, -30))

    beat("z3d", 60, 2100, """
        The last rope line above the waterline, deliberately the widest and
        most forgiving of the three. The level has just spent two beats
        tightening and now it opens up, because the next thing below is water
        and shards, and a difficulty spike immediately before a hazard reads
        as unfair rather than demanding. A player arriving with momentum from
        the tighter line above will overshoot and land in the shallows, which
        costs a little health and nothing else. That is the intended failure:
        the level wants this descent to end in relief rather than in another
        test, because the water below is where the drowned shrine is, and
        arriving there furious is the wrong mood for the beat that follows.
        """,
        ("anchor", 0, 0), ("anchor", 300, 0), ("anchor", 600, 30))

    beat("z3e", 200, 2320, """
        A run of broken shelves offset from each other, chainable by jumping
        alone. It is slower than the rope line beside it and completely safe.
        Every vertical section of this level has one of these, because a player
        who is bad at swinging should still be able to see the whole cistern --
        they should just take longer, and miss the caches that need the rope.
        """,
        ("ledge", 0, 0, 120), ("ledge", 150, -56, 110), ("ledge", 300, -8, 120),
        ("anchor", 130, -170), ("anchor", 420, -200))

    beat("z3f", 820, 1300, """
        A slab hangs in mid-air west of the shaft with a cache on it and only
        one anchor above. There is no way to stand near it and no way to reach
        it except by releasing a swing at the right moment, which means the
        player has to commit to the grab before they can see whether they will
        land. It is the first reward in the level gated on actual rope skill
        rather than on noticing something.
        """,
        ("ledge", 0, 0, 140), ("cache", 70, -30), ("anchor", 70, -200))

    beat("z3g", 900, 1700, """
        An anchor placed so that the natural swing from the shelf above carries
        Michael OVER a vent rather than into it, if he holds on long enough. A
        player who panics and releases early lands on the burner. The vent is
        visible from the take-off point, so the information needed is all
        present before the commitment -- the beat punishes nerve failure, not
        ignorance.
        """,
        ("anchor", 0, 0), ("vent", 60, 260, 110, 70))

    beat("z3h", 760, 2000, """
        A wide, flat, comfortable ledge in the middle of the descent that looks
        exactly like the rest stops the level has been handing out -- and it
        has a procession guard on the wall behind it. The trigger is set on the
        approach so the guard is already moving when Michael lands. The design
        job here is to poison the pattern: after this, the player reads a
        convenient ledge as a question rather than a gift, and every later rest
        in the cistern is a small decision.
        """,
        ("ledge", 0, 0, 180), ("mural", 80, -30, -60, -60))

    beat("z3i", 1000, 2300, """
        Three small stepping slabs over the water gap, each just wide enough
        to stand on and spaced so every hop is a commitment. There is an
        anchor overhead for players who would rather not, which makes this the
        clearest statement of the level's traversal contract: the platforming
        route always exists and is always more fiddly than the rope. Most
        players take the slabs the first time and the rope every time after,
        which is the correct progression and does not need teaching. The slabs
        also serve as recovery ground for anyone who misses the swing, so the
        two routes catch each other rather than competing.
        """,
        ("ledge", 0, 0, 90), ("ledge", 160, -40, 90), ("ledge", 320, 20, 90),
        ("anchor", 200, -200))

    beat("z3j", 420, 2620, """
        The west waterline, with broken pottery in the shallows directly under
        the last rope line. A missed swing at the bottom of the descent lands
        here and costs health, and an anchor sits above the shards so the
        recovery is immediate rather than a walk of shame. Failure at the end
        of a long sequence should cost something and should not cost the
        sequence.
        """,
        ("vent", 0, 0, 180, 90), ("anchor", 0, -180))

    beat("z3k", 1180, 1900, """
        A high anchor with a second one four hundred pixels above it, forming a
        line straight back up to the entry level. A confident player can use it
        to skip the entire west descent in two swings, in either direction. It
        is not hidden and not marked; it simply exists for whoever is looking
        up. Skips like this are worth building deliberately, because the
        players who find them feel like they beat the level rather than
        completed it.
        """,
        ("anchor", 0, 0), ("anchor", 0, -400))

    beat("z3l", 1300, 2450, """
        Where that skip drops you, and there is a burial pit assembler waiting
        beside the landing with its trigger set on the arrival point. The fast
        route down is genuinely faster and it puts Michael on the floor of the
        cistern next to something that has already started standing up, with
        his rope still swinging. Two anchors nearby give him an immediate exit
        if he wants one. Shortcuts should be real shortcuts and should have a
        bill attached.
        """,
        ("ledge", 0, 0, 200), ("pit", 120, -30, -100, -60),
        ("anchor", 100, -190), ("anchor", -140, -150))

    # ==================================================== Z4  THE SHAFT
    beat("z4a", 1460, 900, """
        The western lip of the great shaft, and the first place in the level
        where Michael can stand still and look straight down the middle of it
        to the water. The kiln stack is visible across the gap, lit, at the
        same height. Everything about the geometry says this is the centre of
        the cistern and that it can be crossed as well as descended.
        """,
        ("ledge", 0, 0, 150), ("anchor", 80, -180))

    beat("z4b", 2390, 900, """
        The eastern lip, deliberately at exactly the same height as the
        western one and clearly visible from it. Matched heights across a gap
        are the oldest way of saying "you are meant to cross here" without a
        marker, and the anchors between them make it a single swing for anyone
        who has got this far. Standing on either lip, the other is close
        enough to read as reachable and far enough that a jump plainly will
        not do it. Nothing here is gated and nothing warns; the geometry does
        all the work. If the player crosses on their first look at the shaft,
        the level has communicated properly.
        """,
        ("ledge", 0, 0, 150), ("anchor", 40, -180))

    beat("z4c", 1580, 620, """
        Four anchors run up the middle of the shaft above the lips, spaced for
        upward chaining. The shaft is the only part of the cistern that is
        fully vertical in both directions, and this line is what makes it a
        route up rather than a hole. A player who falls the whole shaft can
        climb back out along it without walking anywhere, which is what stops
        the level's centre being a punishment.
        """,
        ("anchor", 0, 0), ("anchor", 280, -40), ("anchor", 560, 30), ("anchor", 800, -20))

    beat("z4d", 1880, 1220, """
        An island slab hangs in the middle of the shaft with the grate pin
        mounted on the wall above it. Shooting the pin opens the grate at the
        very bottom of the shaft, which is the way into the deep water --
        and from up here the player can watch it swing open in the distance.
        Cause and effect at a visible distance is worth more than a door that
        opens beside you, because it teaches that this level's mechanisms talk
        to each other across space.
        """,
        ("ledge", 0, 0, 260), ("switch", 140, -84, "precision_hit", "cistern_grate_pin"),
        ("anchor", 130, -220), ("anchor", -80, -140), ("anchor", 340, -160))

    beat("z4e", 2020, 1176, """
        There is a jar on that island, at the far end from where a swing lands,
        and it is alive. The pin shot therefore has to be taken from a slab
        Michael is sharing with a ceramic sentinel, or the sentinel has to be
        dealt with first while standing on the smallest piece of solid ground
        in the shaft. Neither is hard. Both mean the simple act of shooting a
        switch happens under pressure, which is most of what makes a level feel
        alive rather than administrative.
        """,
        ("jar", 0, 0, -220, -60))

    beat("z4f", 1620, 1000, """
        Three ledges step down the shaft's western wall with anchors between
        them: the careful route down the middle of the level. It is slower than
        dropping and it keeps Michael on the west side, which matters because
        the vents are on the east wall. Choosing a wall is choosing a hazard
        profile, and the choice is legible before it is made.
        """,
        ("ledge", 0, 0, 100), ("ledge", 240, 120, 100), ("ledge", 60, 260, 110),
        ("anchor", 60, -150), ("anchor", 300, -40), ("anchor", 120, 120))

    beat("z4g", 2200, 1000, """
        The eastern wall's ledges, offset vertically from the western ones so
        the two routes never line up. A player cannot zigzag between them
        casually; committing to a side is a real commitment for the length of
        the shaft. The offset is the entire design of the beat and it costs
        nothing to implement -- it is just refusing to put the shelves at
        matching heights.
        """,
        ("ledge", 0, 0, 100), ("ledge", -180, 140, 100), ("ledge", 40, 280, 110),
        ("anchor", 60, -150), ("anchor", -140, 0), ("anchor", 100, 140))

    beat("z4h", 1460, 1500, """
        The mid-shaft western lip, with a kiln vent set into the wall at
        exactly the height a pendulum swinging from the anchor above reaches
        its widest point. Swinging past it is a matter of releasing early or
        holding through, and both work; drifting is what burns. The vent is
        the shaft's one genuinely hostile piece of geometry and it is placed to
        be readable from above before anyone commits.
        """,
        ("ledge", 0, 0, 150), ("vent", 210, -60, 110, 70), ("anchor", 60, -170))

    beat("z4i", 2390, 1500, """
        Its opposite number on the east wall, with no vent, so the mid-shaft
        crossing has a safe side and a fast side. The safe side is the long way
        round. Every hazard in this level has an alternative that costs time
        instead of health, and this is the clearest instance of that rule.
        """,
        ("ledge", 0, 0, 150), ("anchor", 70, -170), ("anchor", -140, -120))

    beat("z4j", 1760, 1820, """
        A slab low in the shaft with a cache on it and a vent burning on the
        wall immediately beside it. The cache is grabbable from a swing without
        landing, if the player thinks to use the rope's reach rather than their
        feet, and standing on the slab to take it costs health for as long as
        they linger. It is the beat that most directly rewards understanding
        that pull has range.
        """,
        ("ledge", 0, 0, 200), ("cache", 100, -30), ("vent", -80, -40, 110, 70),
        ("anchor", 100, -200), ("anchor", 320, -120))

    beat("z4k", 2100, 1650, """
        A jar wedged into a niche on the shaft's eastern wall, positioned so
        its trigger fires when Michael swings past on the main descent line
        rather than when he lands anywhere. The sentinel unfolds into open air
        while he is mid-arc with no floor under either of them. It cannot
        reach him during the swing and it will be waiting at the bottom, which
        turns a traversal sequence into a countdown.
        """,
        ("jar", 0, 0, -140, -120))

    # ============================================ Z5  THE GRATE AND THE DEEP
    beat("z5a", 2280, 2236, """
        The grate at the bottom of the shaft, opened by the pin far above. If
        the player shot the pin on the way down they arrive to find it standing
        open and will barely register it; if they did not, they arrive at a
        barrier with no switch anywhere near it and have to work out that the
        answer was a thousand pixels overhead. Both experiences are intended.
        The second one is why the pin is visible from the island rather than
        hidden.
        """,
        ("door", 0, 0, "cistern_grate_pin"))

    beat("z5b", 2160, 2380, """
        The one slab directly beneath the grate, and the only soft landing at
        the base of the shaft -- everything else down here is water or shards.
        Anyone who falls the shaft rather than descending it lands near enough
        to reach it. It is the level being generous at the exact place where it
        has been most dangerous.
        """,
        ("ledge", 0, 0, 240), ("anchor", 120, -190))

    beat("z5c", 2280, 2336, """
        An assembler sits under the grate with its trigger on the grate itself,
        so it begins standing up the moment the way opens rather than when
        Michael arrives. A player who shot the pin early from the island and
        then took the slow route down will find it fully assembled and waiting.
        A player who opens the grate from close range gets it half-built and
        vulnerable. The reward for doing things in the harder order is a
        genuinely easier fight, which is the kind of thing worth building even
        though most players will never notice it.
        """,
        ("pit", 0, 0, 0, -180))

    beat("z5d", 1460, 2100, """
        The last western lip above the water, with an anchor beside it. This
        is the bail-out point for a descent that has gone wrong: from here
        Michael can still get back onto the west wall instead of committing to
        the bottom of the cistern. From the lip Michael can see both the water
        below and the west wall behind him, which is what makes this a
        decision point rather than a ledge. It is placed at the height where a
        descent usually starts going wrong, so the option appears exactly when
        it becomes useful.
        """,
        ("ledge", 0, 0, 150), ("anchor", 80, -170))

    beat("z5e", 2390, 2100, """
        Its eastern twin, because a bail-out with one destination is not a
        decision. From this height the player chooses which half of the
        cistern's floor to drop into, and the two halves are meaningfully
        different: west is shards and the drowned shrine, east is assemblers
        and the way out. From this height the player picks which half of the
        cistern floor to drop into, and the two halves differ: west is shards,
        the drowned shrine and the moral beat, east is assemblers and the way
        out. Choosing badly is not fatal, but crossing the floor afterwards is
        slow and costs health, so the choice carries weight.
        """,
        ("ledge", 0, 0, 150), ("anchor", 60, -170))

    beat("z5f", 1600, 2160, """
        A rope line strung the full width of the shaft's base, above the water.
        Its only job is to make falling down the shaft survivable: anywhere
        along the drop, there is something to catch. Without it the shaft is a
        death pit and players stop using the fastest route in the level, which
        would waste the best piece of geometry in the cistern.
        """,
        ("anchor", 0, 0), ("anchor", 260, 0), ("anchor", 520, 0), ("anchor", 780, 0))

    beat("z5g", 1820, 1776, """
        A cache tucked behind the shaft's western wall where it is invisible
        from above and from the floor, and only comes into view during the
        descent itself. It rewards a player who looks around while falling,
        which is a thing people do only once they are comfortable, so it tends
        to be found on the second trip down rather than the first. It sits on
        the western wall where the descending routes hug the stone, so it
        appears in peripheral vision during a swing rather than as something
        to search for. Players usually find it on a second trip down, once
        they are comfortable enough to look around while falling, which makes
        it a quiet marker of growing competence.
        """,
        ("cache", 0, 0))

    beat("z5h", 2600, 2560, """
        The rope line continues east from the shaft's base out over the water
        toward the drowned shrine. It is the only comfortable way across, and
        it is deliberately strung high enough that Michael passes above the
        slabs rather than beside them, which means he sees the supplicant
        before he can reach her. Because the line runs high, Michael passes
        above the slabs rather than beside them and sees the supplicant before
        he can reach her. That is deliberate: the beat at the drowned shrine
        works far better if the player has had ten seconds to notice she is
        down there. A player who drops off the line early lands in the shards
        instead.
        """,
        ("anchor", 0, 0), ("anchor", 300, 0), ("anchor", 600, 0))

    # ==================================================== Z6  THE ROOFLINE
    beat("z6a", 1300, 300, """
        The first roof walkway, reachable only by a long swing from the entry
        side of the level and visible from the moment the player arrives in
        the cistern. Getting up here is the first genuinely optional thing the
        level asks for, and it is asked with geometry rather than a marker.
        Reaching it takes a long swing from the entry side with the whole
        cistern underneath and no safety net on the way. A miss drops the
        player back where they started, costing time and nothing else, which
        is the right price for the level's first optional climb: expensive
        enough to feel deliberate, cheap enough to attempt twice.
        """,
        ("ledge", 0, 0, 420), ("anchor", 200, -120))

    beat("z6b", 1480, 356, """
        The latch that opens the roof hatch is mounted where nothing can stand,
        across a gap from this walkway. It must be shot. The pistol has been in
        Michael's hand the entire level and has mostly been for killing things;
        this is the beat that says it is also a key, and it says it in the one
        place where the player has already proved they are paying attention by
        getting up here at all.
        """,
        ("switch", 0, 0, "precision_hit", "cistern_roof_latch"))

    beat("z6c", 2200, 240, """
        The widest slab on the roof and the only flat run at this height. It
        is a rest and a vantage point: from here the whole cistern is below
        and the player can see the shaft, the kiln stack and the water at
        once, which is the same view the entry ledge gave them at the start of
        the level except now they know what all of it is. It is also the only
        place up here with room to stand and reload without something nearby,
        which makes it the natural staging point for the roof chain that
        follows. A wide safe slab immediately before the hardest traversal in
        the level is not an accident.
        """,
        ("ledge", 0, 0, 520), ("anchor", 260, -100))

    beat("z6d", 2740, 396, """
        The roof hatch, opened by the latch on a walkway the player had to
        reach first. Through it is the drop into the shaft's upper anchors,
        which means the roof is not a dead end -- it is a shortcut into the
        middle of the level for anyone who has done the work. Through it is a
        drop into the shaft's upper anchors, so the roof is not a dead end but
        a shortcut into the middle of the level for anyone who did the work of
        getting up here. A player who opens it early can use it for the rest
        of the level as a fast route between the entry and the shaft.
        """,
        ("door", 0, 0, "cistern_roof_latch"))

    beat("z6e", 2420, 196, """
        The best cache in the cistern, on the roof, behind a long swing and a
        shot latch and the willingness to go up when the whole level slopes
        down. Nothing guards it. The guarding was the journey, and putting a
        creature here as well would be charging twice for the same thing.
        """,
        ("cache", 0, 0))

    beat("z6f", 3200, 320, """
        The roof continues east past the hatch, which means the hatch is not
        the only reason to be up here and a player who took it immediately has
        left something behind. The walkway leads toward the kiln stack's upper
        shelves and connects the two halves of the level at their highest
        point. A player who dropped through the hatch the moment it opened has
        therefore left the eastern roof unexplored, and will only find out
        later when they see the walkway from below. The level does not signal
        this. It builds the reward and lets people miss it.
        """,
        ("ledge", 0, 0, 460), ("anchor", 230, -110), ("anchor", 460, -60))

    beat("z6g", 4100, 420, """
        The last roof slab, overlooking the kiln stack from above and slightly
        east of everything. From here the player can drop directly onto the
        high eastern shelf and skip the entire kiln climb, arriving at the top
        of a zone that is designed to be fought upward through. Dropping from
        here skips the entire kiln climb and lands at the top of a zone
        designed to be fought upward through, which inverts every ambush in
        it: triggers set behind a climbing player now fire in front of a
        descending one. It is the most consequential shortcut in the cistern
        and it is available to anyone who simply walked east along the roof.
        """,
        ("ledge", 0, 0, 400), ("anchor", 200, -120))

    beat("z6h", 1720, 180, """
        Four anchors in a chain across the very top of the level with no floor
        under any of them and the full height of the cistern below. It is the
        hardest pure traversal in the level and it is entirely optional. A
        missed grab here costs the player everything they were carrying
        themselves toward and drops them into the shaft's rope line, which
        catches them -- so the punishment is the loss of the attempt, not the
        loss of progress.
        """,
        ("anchor", 0, 0), ("anchor", 300, 40), ("anchor", 620, -20), ("anchor", 940, 30))

    # ============================================== Z7  THE KILN STACK (east)
    beat("z7a", 2760, 760, """
        A broad kiln floor, cool at the western end where Michael arrives and
        hot at the eastern end where he needs to go. The vent is at the far
        edge with the anchor above it, so the intended line runs directly over
        the heat. The zone opens by stating its rule plainly: in the kiln
        stack, the route and the hazard are the same geometry.
        """,
        ("ledge", 0, 0, 460), ("vent", 380, -60, 110, 70), ("anchor", 200, -190))

    beat("z7b", 3040, 976, """
        A procession guard on the wall of a shelf whose only standing room is
        beside a burning vent. Fighting it properly means holding ground next
        to the heat; backing off means dropping a tier and climbing again. The
        third option, and the one the level wants the player to find, is to
        stagger it with the rope so that it stumbles into the vent -- letting
        the temple do the work, which is what a control tool is for.
        """,
        ("ledge", -120, 44, 380), ("mural", 0, 0, 200, -60))

    beat("z7c", 2940, 1256, """
        A vent set directly below a narrow ledge, positioned so that anything
        knocked off the ledge lands in it. It is placed here, one beat after
        the guard, as the uncomplicated version of the same idea: no fight, no
        pressure, just a clear demonstration of what "off this edge" means, so
        that the previous beat's solution is legible in hindsight. There is no
        fight here and nothing to do. The beat is a plain statement placed one
        step after the guard, so that the previous beat's solution becomes
        legible in hindsight. Teaching after the fact works better than
        teaching before it, because the player has already had the problem and
        is looking for an answer.
        """,
        ("ledge", -60, -60, 200), ("vent", 0, 0, 110, 70))

    beat("z7d", 3320, 1020, """
        A shelf between two heats, wide enough to fight on and no wider. Both
        neighbouring beats have vents; this one has none, which makes it the
        obvious place to stand and deal with anything following Michael up the
        stack. It is a deliberate island of safety in a hostile zone, and its
        existence is what makes the rest of the zone fair.
        """,
        ("ledge", 0, 0, 380), ("anchor", 190, -190), ("anchor", -40, -130))

    beat("z7e", 2880, 1300, """
        Kiln mouths in a rising diagonal line with the shelf threading between
        them. There is no enemy in this beat at all and it is still one of the
        harder pieces of the level, because the geometry alone demands accurate
        swinging under a time pressure the player sets themselves. Hazard-only
        beats are worth building; they prove the traversal is interesting
        without a creature attached to it.
        """,
        ("ledge", 0, 0, 360), ("anchor", 180, -200))

    beat("z7f", 3460, 1560, """
        The widest tier in the kiln stack, with a jar at the far eastern end
        and its trigger set on the western approach -- so the sentinel begins
        unfolding as Michael steps onto the tier, at the opposite end from
        him, with the whole width of the shelf between them. It is the only
        fight in the level that starts at a distance and closes slowly, which
        makes it the one place the pistol gets to be a rifle for a moment. The
        tier is wide enough that the approach takes real seconds, and the
        player has to decide whether to spend them closing distance or
        shooting. Both work. The beat exists because every other fight in the
        level starts at arm's length, and one encounter with room in it makes
        the pistol feel like a different tool.
        """,
        ("ledge", 0, 0, 420), ("jar", 380, -30, 120, -70),
        ("anchor", 210, -200), ("anchor", -20, -140))

    beat("z7g", 3620, 1516, """
        A vent burning in the middle of that tier, between Michael and the jar.
        It is the reason the slow approach is not simply free: closing the
        distance to shoot means crossing the heat, and holding position means
        letting the sentinel choose when to cross it instead. Either way
        somebody has to walk through fire, and the design intent is that the
        player works out it does not have to be them.
        """,
        ("vent", 0, 0, 110, 70))

    beat("z7h", 2960, 1840, """
        A lower, cooler tier with a clear view back up the stack the player
        has just climbed. It is a decompression beat and a vantage point: from
        here the sequence of vents and shelves above reads as a single
        structure rather than as a series of obstacles, which is when players
        start planning routes instead of reacting to ledges. It is a
        decompression beat: nothing threatens, nothing is hidden, and the
        player can look back at the sequence of vents and shelves they just
        crossed and see it as one structure. That shift, from reacting to
        ledges to planning routes, is what the whole kiln stack has been
        building toward, and it needs a quiet place to happen in.
        """,
        ("ledge", 0, 0, 380), ("anchor", 190, -190))

    beat("z7i", 3560, 2120, """
        The bottom of the kiln stack, with an assembler between Michael and
        the eastern wall and its trigger set behind him so it rises as he
        passes. This is the beat that stops the stack being a one-way climb:
        anyone descending it in a hurry runs into something that has already
        stood up behind them, and the two anchors here are the escape they
        will want. The two anchors are the escape a player will want and they
        point in opposite directions, so retreating is itself a decision
        rather than a reflex. Anyone descending the stack in a hurry meets
        this at speed, which is most people, since the roof shortcut drops
        them in at the top.
        """,
        ("ledge", 0, 0, 340), ("pit", 260, -30, 40, -70),
        ("anchor", 170, -190), ("anchor", -80, -140))

    beat("z7j", 4200, 900, """
        The high eastern shelf, with a cache at the far end and a jar between
        Michael and it, positioned so its trigger fires only once he has
        committed past the halfway point. The greedy read is to run straight
        for the gold; the sentinel unfolds behind him and he takes the cache
        with something between him and the way back. The shelf is long enough
        that this is survivable and short enough that it is uncomfortable.
        """,
        ("ledge", 0, 0, 420), ("jar", 140, -30, 340, -70), ("cache", 330, -30),
        ("anchor", 210, -190), ("anchor", -20, -140))

    beat("z7k", 4560, 1240, """
        A shelf reachable only by rope, clearly visible from below, holding
        absolutely nothing. Every other hard-to-reach place in this level has
        paid out. This one does not, and it is placed late enough that the
        player has learned to expect a reward for effort. The lesson is not
        cruelty -- it is that the cistern is a real place with empty rooms in
        it, which is what makes the full rooms feel found rather than
        distributed.
        """,
        ("ledge", 0, 0, 360), ("anchor", 180, -180), ("anchor", -40, -130))

    beat("z7l", 4700, 1196, """
        There is a procession guard on the wall of that empty shelf, with its
        trigger at the landing point. The shelf was not empty; it was baited.
        This is the sharpest beat in the kiln stack and it only works because
        of z7k's setup -- the emptiness has to be established as a
        disappointment before it can be revealed as a trap.
        """,
        ("mural", 0, 0, -240, -60))

    beat("z7m", 4260, 1560, """
        A shelf directly below the baited one with a vent on it, so fleeing
        downward from that fight is possible but not free. Every ambush in
        this level has an exit and every exit has a price; the prices are what
        stop the exits from making the ambushes pointless. The vent means
        fleeing downward is possible but not free, which is the rule every
        ambush in this level follows: there is always an exit and the exit
        always has a price. Without the price the ambushes stop mattering;
        without the exit they stop being fair.
        """,
        ("ledge", 0, 0, 300), ("anchor", 150, -180), ("vent", 40, -44, 110, 70),
        ("anchor", -60, -140))

    beat("z7n", 4620, 1880, """
        The lowest eastern shelf, with a cache sitting behind a vent so that
        reaching it on foot costs health and roping it from the side costs
        nothing. By this point in the level the player either knows that pull
        has reach or they have been paying for it repeatedly, and this is the
        last beat that offers the lesson before the level stops teaching. By
        this point the player either knows that pull has reach or they have
        been paying for not knowing it since the shaft. This is the last beat
        that offers the lesson, and it is offered gently, with a cache rather
        than a creature on the far side of the heat.
        """,
        ("ledge", 0, 0, 340), ("cache", 140, -30), ("vent", 260, -44, 110, 70),
        ("anchor", 170, -190))

    # ================================= Z8  THE EAST TIERS AND THE WINCH
    beat("z8a", 3600, 2076, """
        A heavy winch bolted to the eastern tier, roped and hauled to release
        the west vault door -- which is on the far side of the cistern, past
        the shaft, invisible from here, and which the player very likely
        walked past hours ago and could not open. This is the mirror of the
        kiln bar in the west galleries: two switches, each opening something
        in the other half of the level, so that neither half can be finished
        on its own. Nothing here indicates what it opened, and the door is not
        visible from any point on this tier. The player will either remember
        the shut door on the west wall and connect the two, or find it open
        later and quietly assume it always was. Both are acceptable outcomes;
        the first is much better and cannot be forced.
        """,
        ("switch", 0, 0, "pull", "cistern_west_winch"))

    beat("z8b", 3520, 2120, """
        There is a procession guard on the wall directly behind the winch, and
        its trigger covers the exact spot Michael has to stand in to make the
        pull. Hauling a winch is a committed animation; he cannot be facing the
        wall and the guard at the same time. The door across the level
        therefore costs a fight, and the fight happens with his back turned,
        which is the single most deliberate arrangement in the cistern.
        """,
        ("mural", 0, -180, 300, -40))

    beat("z8c", 4180, 2200, """
        The tier the winch fight spills onto -- wide, empty, with anchors at
        both ends. It exists because the previous beat starts a fight in a bad
        position and the player needs somewhere to move to that is not a fall.
        The anchors point in opposite directions so retreating is a choice
        between going up the stack or down toward the water.
        """,
        ("ledge", 0, 0, 380), ("anchor", 190, -190), ("anchor", -30, -130))

    beat("z8d", 4160, 2356, """
        The kiln door, opened by the iron bar back in the west galleries. For
        most players this is the payoff of a pull they made a long time ago in
        a different part of the level and did not understand at the time. If
        they never pulled it, the door is shut and the route beyond it -- the
        shrine and the eastern water -- is closed, and they have to cross the
        entire cistern to open it.
        """,
        ("door", 0, 0, "cistern_kiln_bar"))

    beat("z8e", 4420, 2560, """
        A shrine immediately past the kiln door. The deep east is the furthest
        point in the level from the entry and everything between here and the
        exit is water and assemblers, so this is where the level stops being
        stingy. It is also the reward for the kiln bar, which means the
        long-distance switch pays out in safety rather than in treasure.
        """,
        ("shrine", 0, 0))

    beat("z8f", 4620, 2400, """
        Two anchors out over the deep eastern water, the last rope work before
        the way out. They are placed high and wide, which makes this the
        easiest traversal in the eastern half -- the level is winding down
        rather than escalating into its exit. They are placed high and wide,
        which makes this the easiest rope work in the eastern half of the
        level. That is pacing rather than laziness: the kiln stack and the
        winch have just been the two hardest sequences in the cistern, and the
        approach to the exit should wind down instead of escalating.
        """,
        ("anchor", 0, 0), ("anchor", 260, -40))

    beat("z8g", 3980, 2620, """
        Broken pottery in the eastern shallows, directly beneath the rope
        line. It is the same arrangement as the western waterline at z3j,
        deliberately repeated so that the two ends of the cistern feel like
        the same place rather than two levels joined in the middle. It is the
        same arrangement as the western waterline, deliberately repeated so
        the two ends of the cistern read as one place rather than two levels
        joined in the middle. Repetition across distance is how a space
        acquires a vocabulary, and shards under a rope line are this level's
        clearest word.
        """,
        ("vent", 0, 0, 180, 90))

    beat("z8h", 4600, 2676, """
        An assembler in the last stretch of water before the exit, with its
        trigger set west of it so it rises while Michael is still crossing.
        The exit is visible behind it. This is the level's final fight and it
        is deliberately an ordinary one -- no new element, no arrangement, just
        a creature between the player and the door, because a big finish here
        would compete with the drowned shrine for the level's ending.
        """,
        ("pit", 0, 0, -180, -60))

    beat("z8i", 4340, 856, """
        A jar high on the eastern wall above the cache shelf, with its trigger
        placed so that it wakes when Michael is at the cache rather than when
        he arrives on the shelf. The sentinel unfolds above and behind him
        while he is standing still collecting. It is the clearest single use of
        deliberate trigger placement in the level: the same jar in the same
        spot with a default trigger would simply be an enemy on a shelf.
        """,
        ("jar", 0, 0, 240, -60))

    beat("z8j", 4780, 1560, """
        Two anchors stacked at the far eastern edge of the map. Without them
        the eastern wall is the one place in the cistern where a player could
        get onto a shelf and have no way off it except a long fall. They exist
        purely so the level has no dead ends, which is worth stating plainly
        rather than pretending every element is a designed moment.
        """,
        ("anchor", 0, 0), ("anchor", 0, 300))

    beat("z8k", 4880, 2000, """
        The same again in the south-eastern corner, for the same reason. A
        corner is the most likely place for a player to strand themselves,
        because it is where two walls remove options at once, and it is the
        cheapest thing in level design to get wrong and the cheapest to fix. A
        corner is the likeliest place for a player to strand themselves,
        because it removes options in two directions at once and leaves
        nothing to swing back toward. It is among the cheapest things in level
        design to get wrong and to fix, and it is worth saying plainly that
        this beat is maintenance rather than drama.
        """,
        ("anchor", 0, 0), ("anchor", 0, 260))

    beat("z8l", 4980, 2640, """
        The crack in the eastern wall that leads on into Burial Works, at the
        deepest and furthest point from where Michael came in. Reaching it
        means having crossed the entire cistern, and it is placed here rather
        than near the entry so that the level cannot be skipped by a player
        who pokes their head in and leaves. Reaching it means having crossed
        the entire cistern, which is why it is here rather than near the
        entry: a player who pokes their head into this level and turns around
        should not be able to finish it by accident. The crack is visible from
        the last stretch of floor, so the ending is legible before it arrives.
        """,
        ("exit", 0, 0))

    # ======================== Z9  THE WATER AND THE DROWNED SHRINE
    beat("z9a", 2600, FLOOR_Y, """
        The floor of the cistern proper: a long slab standing out of the black
        water in the middle of the level, with the shaft above it and the
        drowned shrine on it. Everything that falls in this level ends up
        here, which is why it is the widest solid ground at the bottom and why
        the level's moral centre is placed on it rather than somewhere the
        player has to seek out. Everything that falls in this level ends up
        here, which is why it is the widest solid ground at the bottom and why
        the moral centre of the cistern sits on it rather than somewhere the
        player has to seek out. The two anchors above mean arriving by
        accident is survivable and leaving is always possible.
        """,
        ("ledge", 0, 0, 640, 160), ("anchor", 320, -200), ("anchor", 580, -160))

    beat("z9b", 2660, 2676, """
        A dead supplicant stands on a slab above the waterline, intact, still
        holding her token -- one of the temple's own, exactly the kind of
        remains the Keeper's entire domain is about. She does nothing. She is
        not a puzzle, she does not block the route, and she cannot be talked
        to. She is simply present, and everything the player does in this
        corner of the level happens in front of her.
        """,
        ("urn", 0, 0))

    beat("z9c", 2900, 2676, """
        A burial-pit assembler stands between Michael and the supplicant, and
        it is closer to her than to him. Its trigger fires on his approach, so
        by the time he can act it is already up and already nearer to her than
        he is. Nothing in the level says she can be harmed and nothing says she
        must be protected. The arrangement is the entire instruction.
        """,
        ("pit", 0, 0, -300, -60))

    beat("z9d", 2740, 2634, """
        A shrine on the same slab, a few steps from her. It is the most
        generously placed checkpoint in the level, because the beat it serves
        is one the player is meant to be able to attempt badly, watch go wrong,
        and try again differently. A moral choice that can only be made once by
        accident is not a choice.
        """,
        ("shrine", 0, 0))

    beat("z9e", 2760, 2676, """
        An offering cache lies at her feet, in easy reach, taking nothing from
        her and requiring nothing of the player. Grabbing it while an assembler
        closes on her is entirely possible and entirely legal. The level does
        not comment. It is the cheapest way it has of asking what Michael is
        actually here for.
        """,
        ("cache", 0, 0))

    beat("z9f", 2480, 2560, """
        The anchor a player will instinctively rope to cross the last stretch
        of water is set directly above her slab, which means the natural
        traversal move drags the rope across her. Roping her instead of the
        anchor -- easy to do in a hurry, since the auto-target favours whatever
        is nearest -- pulls her off the slab and into the water, and she is
        gone, and the Keeper has a line about it. The best design in this level
        is that the wrong thing here is not a mistake the player makes with the
        wrong button. It is the right button used carelessly.
        """,
        ("anchor", 0, 0))

    beat("z9g", 0, FLOOR_Y, """
        The western floor, with the first water gap immediately at its eastern
        end so that the bottom of the cistern reads as broken ground from the
        moment the player lands on it. Two anchors above make the gaps
        crossable without precision, because the floor is where players arrive
        after failing at something else and it should not immediately demand
        more. Two anchors above make the gaps crossable without precision,
        because the floor is where players arrive after failing at something
        else and it should not immediately demand more of them. The gap at its
        eastern end is the first thing they see on landing, which sets the
        expectation that the bottom of the cistern is broken ground.
        """,
        ("ledge", 0, 0, 760, 160), ("anchor", 380, -190), ("anchor", 660, -240))

    beat("z9h", 900, FLOOR_Y, """
        A floor island with broken pottery on both approaches, so crossing it
        on foot costs health from either direction while the rope line above
        passes over it for free. It is the floor's version of the lesson the
        kiln stack teaches vertically: the ground is the slow, expensive route
        and it is always available. It is the floor's version of the lesson
        the kiln stack teaches vertically: the ground is the slow, expensive
        route and it is always available. A player crossing the whole floor on
        foot arrives at the drowned shrine down a third of their health, which
        changes how that beat feels without changing anything in it.
        """,
        ("ledge", 0, 0, 520, 160), ("vent", 60, -120, 180, 90),
        ("anchor", 260, -190), ("anchor", 40, -240))

    beat("z9i", 1560, FLOOR_Y, """
        A smaller island with the same shards, tightening the same problem.
        Crossing the cistern floor from west to east is its own traversal
        sequence rather than a walk, and it is the sequence a player who has
        fallen will have to solve while short of health. Crossing the floor
        west to east is therefore a traversal sequence rather than a walk, and
        it is the sequence a player who has fallen down the shaft has to solve
        while already hurt. The rope line overhead is the answer and it is
        visible from the water, so the solution is never in doubt. Only
        whether they still have the nerve to swing.
        """,
        ("ledge", 0, 0, 380, 160), ("vent", 60, -120, 180, 90),
        ("anchor", 190, -190), ("anchor", 380, -250))

    beat("z9j", 2120, FLOOR_Y, """
        The narrowest island, directly beneath the shaft, which makes it where
        most falls land -- and it has shards on it. Falling the shaft is
        survivable and it is not free, and the cost is applied at the exact
        moment the player is already frustrated. Two anchors sit above it so
        the recovery is immediate.
        """,
        ("ledge", 0, 0, 300, 160), ("vent", 60, -120, 180, 90),
        ("anchor", 150, -190), ("anchor", -60, -250))

    beat("z9k", 3400, FLOOR_Y, """
        The eastern floor begins with an assembler already standing, triggered
        from the west so it is up before Michael is across. It is the first
        thing that happens after the drowned shrine and it is deliberately
        loud: whatever the player just decided back there, the level moves on
        and does not discuss it. It is the first thing that happens after the
        drowned shrine and it is deliberately loud: whatever the player
        decided back there, the level moves on immediately and does not
        comment. A quiet beat after a moral choice invites reflection, which
        is what the Keeper is for. The level itself should just keep going.
        """,
        ("ledge", 0, 0, 420, 160), ("pit", 160, -44, -120, -70),
        ("anchor", 210, -190), ("anchor", 20, -250))

    beat("z9l", 4420, FLOOR_Y, """
        The last run of floor before the exit, deliberately wide, empty and
        clear of hazards. There is nothing here. After the kiln stack, the
        winch ambush and the water, the level stops asking, and the walk to the
        crack in the eastern wall is quiet on purpose.
        """,
        ("ledge", 0, 0, 700, 160), ("anchor", 350, -190), ("anchor", 620, -230))

    beat("z9m", 3180, 2600, """
        A jar half-submerged at the waterline between the drowned shrine and
        the eastern floor, with its trigger on the western approach. It is the
        only ceramic source at the bottom of the level, and it is here so that
        the crossing away from the supplicant has something in it -- a player
        who did the right thing back there should not get a free walk out as
        the reward, or the choice starts to feel like an obedience test. A
        player who did the right thing at the shrine should not get a free
        walk out as the reward, or the choice starts to feel like an obedience
        test with a prize attached. The jar sits on the western approach so it
        wakes behind anyone leaving the supplicant, and it is the only ceramic
        source at the bottom of the level.
        """,
        ("jar", 0, 0, -200, -80))

    # ==================================================== Z10 CONNECTIVE
    beat("z10a", 660, 1856, """
        The west vault door, held shut until the winch is hauled on the far
        eastern tier. It sits directly on the west wing's main descent, so
        every player passes it early, tries it, and cannot open it. It is the
        level's way of putting a question in the player's head hours before it
        hands them the answer.
        """,
        ("door", 0, 0, "cistern_west_winch"))

    beat("z10b", 180, 1856, """
        Behind the vault door is a slab and a cache and nothing else. It is not
        a room, it is not a passage, and it does not connect to anything -- the
        winch across the level opens a cupboard. That is the right size of
        reward for a switch that costs a fight and a crossing, because the
        satisfaction was in understanding the mechanism, and a corridor of
        further content here would bury it.
        """,
        ("ledge", -60, 44, 320), ("cache", 0, 0))

    beat("z10c", 3980, 2660, """
        An island shelf in the eastern water, placed so that the crossing to
        the exit is possible for a player with no rope skill at all. Every
        major route in this level has one of these. It is what makes the swing
        an expression of skill rather than a toll gate.
        """,
        ("ledge", 0, 0, 300), ("anchor", 150, -180), ("anchor", -70, -220))

    beat("z10d", 1300, 1000, """
        A vertical rope line between the west wing and the shaft, three
        anchors tall. It exists so the two halves of the western level are one
        place instead of two, and so a player who commits to the shaft early
        can get back to the galleries without climbing all the way to the
        entry. It exists so the two halves of the western level are one place
        instead of two, and so a player who committed to the shaft early can
        get back up to the galleries without climbing all the way to the entry
        ledge. Connective rope like this is invisible when it works and the
        level feels like a maze when it is missing.
        """,
        ("anchor", 0, 0), ("anchor", 0, 400), ("anchor", 0, 800))

    beat("z10e", 2560, 620, """
        The high crossing between the shaft and the kiln stack. It is the
        shortest link between the level's two halves and the most exposed,
        strung across open air near the roof with the entire cistern beneath
        it. A missed grab here is the longest fall available in the cistern,
        though the shaft's rope line catches it, so the cost is the loss of
        the crossing rather than the loss of progress. Most players find this
        one last, after using the middle and lower crossings, because looking
        up is a habit the level takes a while to teach.
        """,
        ("anchor", 0, 0), ("anchor", 200, 40), ("anchor", 400, -20))

    beat("z10f", 2700, 1120, """
        The middle crossing, at the height of the kiln stack's main shelves.
        Three crossings at three heights is what stops the shaft being a wall:
        wherever the player is vertically, east and west are reachable without
        backtracking to a single authored bridge. Three crossings at three
        heights is what stops the shaft being a wall: wherever the player is
        vertically, east and west are reachable without backtracking to one
        authored bridge. This is the crossing most people use, because it sits
        level with the kiln stack's main shelves and with the galleries
        opposite.
        """,
        ("anchor", 0, 0), ("anchor", 240, 30), ("anchor", 480, -20))

    beat("z10g", 2760, 2120, """
        The lowest crossing, near the water, where a failed swing costs almost
        nothing because the drop is short and the floor is right there. It is
        the crossing the level expects most players to use, and the two above
        it are for people in a hurry. It is the crossing a cautious player
        will use, and the two above it are for people in a hurry or people
        showing off. Having all three means the choice of crossing is a
        statement of confidence rather than a puzzle with one answer.
        """,
        ("anchor", 0, 0), ("anchor", 250, 0), ("anchor", 500, 0))

    beat("z10h", 1120, 620, """
        A rope line back up to the entry ledge from the top of the west wing,
        so that the cistern is never one-way. A player can always get back to
        where they came in and out to the Procession Hall, which matters
        because this level is a branch off the main route and trapping someone
        in an optional area is the worst thing an optional area can do. A
        player can always get back to where they came in and out to the
        Procession Hall, which matters more here than anywhere else in the
        game: this level is an optional branch, and trapping someone in an
        optional area is the worst thing an optional area can do. The line
        sits at the top of the west wing so it is on the way to the entry
        rather than a detour.
        """,
        ("anchor", 0, 0), ("anchor", 0, -240))

    # ============================== Z11  THE SCAFFOLD (jumpable step runs)
    beat("z11a", 1040, 520, """
        A run of broken scaffold boards steps up from the shelf east of the
        entry to the lip of the roof walkway, each board close enough above the
        last that Michael can jump it without touching the rope. Until now the
        roof has been a promise seen from the entry and reachable only by a long
        swing, which meant a player with no rope skill could look at it and
        never stand on it. The boards do not make the swing pointless: taking
        them costs four separate jumps and a walk, where the rope crosses the
        same distance in one arc. This is the level's traversal contract stated
        as geometry -- jumping is always available and always slower.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 144, -112, 60),
        ("ledge", 216, -168, 60))

    beat("z11b", 2780, 250, """
        The roof walkway is not one slab but a run of planks laid across the
        gap between the wide vantage slab and the eastern walkway, sagging a
        little further with each one. Each plank is a short hop from the last,
        so a player who came up here at all can simply walk east, which is what
        the eastern roof beats have always assumed and what the geometry never
        actually allowed. Two anchors overhead let a confident player cross the
        whole span in one arc instead of six hops. The planks are the floor of
        the roof: they make the top of the level a place you can be rather than
        a set of islands you can only reach by rope.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, 14, 60), ("ledge", 144, 28, 60),
        ("ledge", 216, 42, 60), ("ledge", 288, 56, 60), ("ledge", 360, 70, 60),
        ("anchor", 120, -130), ("anchor", 300, -110))

    beat("z11c", 3720, 336, """
        The planking continues past the eastern walkway and steps gently down
        toward the last roof slab above the kiln stack, each board a little
        lower than the one before. Walking it is free and takes about ten
        seconds; the two anchors above it turn the same distance into a single
        swing for anyone who would rather. It matters that the descent is
        gradual rather than a drop, because the slab at the end of it is the
        entrance to the most consequential shortcut in the cistern, and a
        player should arrive there having chosen to walk east rather than
        having fallen east.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, 16, 60), ("ledge", 144, 32, 60),
        ("ledge", 216, 48, 60), ("ledge", 288, 64, 60),
        ("anchor", 140, -106), ("anchor", 320, -76))

    beat("z11d", 860, 1876, """
        A collapsed pillar in the west galleries has left its drum sections
        stacked and offset, alternating left and right up the wall like a
        spiral stair with the middle missing. Each drum is one jump above the
        last, so the galleries can be climbed back up without a single throw of
        the rope -- slowly, six jumps at a time, where the anchors beside it do
        the same climb in two. It is placed on the natural fail-back route from
        the mural shelf, because the player who most needs a rope-free way up
        is the one who has just been knocked off something.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("anchor", -60, -140), ("anchor", 140, -300))

    beat("z11e", 1560, 1454, """
        The same collapse repeated on the shaft's western wall, where the
        stepped ledges are three hundred pixels apart and a player without the
        rope simply could not climb the middle of the level. Eight offset drums
        close that spacing to a jump each, so the shaft becomes a staircase for
        anyone patient enough to take it one drum at a time. The vents are on
        the east wall and the drums are on the west, which means the slow route
        is also the safe one and the fast route is still the rope.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("ledge", 0, -336, 60), ("ledge", 72, -392, 60),
        ("anchor", -80, -210), ("anchor", 140, -210))

    beat("z11f", 3176, 1812, """
        Kiln bricks fallen out of the stack's inner wall make a climbable
        column between the lowest cool tier and the shelf that threads the kiln
        mouths, alternating side to side for ten courses. The stack was built
        to be fought upward through and until now it could only be climbed by
        rope, which meant a player who lost the rope's rhythm lost the zone.
        The bricks are hot ground in a hot zone and they are slow, so taking
        them keeps Michael beside the vents for longer than a swing would --
        the free route costs time in the one place where time is expensive.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("ledge", 0, -336, 60), ("ledge", 72, -392, 60), ("ledge", 0, -448, 60),
        ("ledge", 72, -504, 60),
        ("anchor", -40, -260), ("anchor", 120, -380))

    beat("z11g", 4040, 2604, """
        A ladder of broken tier-edges climbs out of the eastern water onto the
        wide tier above, offset course by course so that each is a jump rather
        than a haul. Without it the eastern floor is a place the player can
        arrive at by falling and leave only by rope, which is the worst
        arrangement in a level whose floor is where failure lands. It is
        deliberately at the end of the level rather than the beginning: by now
        the player knows the rope, and this is not a lesson but an insurance
        policy for the run where the rope has stopped going right.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("ledge", 0, -336, 60), ("ledge", 72, -392, 60),
        ("anchor", 50, -204), ("anchor", 140, -324))

    beat("z11h", 472, 1264, """
        Shelving pulled off the gallery wall has fallen in a staggered heap
        that reaches from the cache shelf below the jars all the way up to the
        stepped ledges under the entry. It is the west wing's spine for anyone
        not using the rope: nine short jumps and the whole gallery is a loop
        rather than a one-way descent. Because it lands beside the jar shelf it
        also gives a player who fled the sentinels a way back to them on their
        own terms, which turns the gallery's one fight into something that can
        be come at twice.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("ledge", 0, -336, 60), ("ledge", 72, -392, 60), ("ledge", 0, -448, 60))

    beat("z11i", 3396, 1552, """
        Broken firebrick courses climb the inside of the kiln stack from the
        wide tier up to the safe shelf between the heats, ten of them, offset
        so each is a single jump. The stack was designed to be fought upward
        through and its shelves are a rope's length apart, which made the whole
        zone unavailable to a player having a bad night with the lasso. These
        make the climb possible on foot and slow enough that anything already
        awake on the tiers gets time to meet him halfway.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("ledge", 0, -336, 60), ("ledge", 72, -392, 60), ("ledge", 0, -448, 60),
        ("ledge", 72, -504, 60))

    beat("z11j", 700, 2546, """
        Fallen masonry stacked against the west wall climbs out of the shallows
        to the wide ledge halfway up the descent, so the bottom of the west
        wing is not a place a failed swing strands you in. Ten jumps is a long
        way to come back up and it is always available, which is exactly the
        trade this level makes everywhere: the rope is two swings and a nerve,
        the stone is a minute and no risk. The single anchor beside it is there
        so the climb can be abandoned halfway rather than only completed.
        """,
        ("ledge", 0, 0, 60), ("ledge", 72, -56, 60), ("ledge", 0, -112, 60),
        ("ledge", 72, -168, 60), ("ledge", 0, -224, 60), ("ledge", 72, -280, 60),
        ("ledge", 0, -336, 60), ("ledge", 72, -392, 60), ("ledge", 0, -448, 60),
        ("ledge", 72, -504, 60), ("anchor", 160, -260))
