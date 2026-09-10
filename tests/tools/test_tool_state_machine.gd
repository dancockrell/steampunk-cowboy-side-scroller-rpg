extends TestCase
## docs/weapon-tool-kit.md, "Action ownership and conflicts", makes five
## promises. Each one is a test here, because each is the kind of rule that
## quietly stops holding the first time someone adds a state.

const TICK := 1.0 / 60.0

var machine: ToolStateMachine
var tuning: Tuning

func before_each() -> void:
	tuning = Tuning.new()
	machine = ToolStateMachine.new(ToolDefinition.build(tuning))
	machine.request_switch(&"pistol")

## Advances simulated time. Returns the number of ticks actually run.
func _advance(seconds: float) -> int:
	var ticks := int(ceil(seconds / TICK))
	for i in ticks:
		machine.step(TICK)
	return ticks

## A deliberately slow tool, injected rather than taken from the shipped kit.
## Neither authored tool has aim time now that the kit is lasso + pistol (D14),
## so without this the AIMING branch would be unreachable -- and a branch nobody
## can execute on purpose is a branch nobody can prove they fixed. These tests
## assert the PROPERTY (a tool with aim time must be held on target), which is
## what they were always really about, rather than one weapon that had it.
func _machine_with_slow_tool() -> ToolStateMachine:
	var defs := ToolDefinition.build(tuning)
	var slow := ToolDefinition.new()
	slow.id = &"test_slow_tool"
	slow.display_name = "Slow Tool"
	slow.verb = Verbs.PRECISION_HIT
	slow.range_px = 400.0
	slow.aim_ms = 380
	slow.commit_ms = 110
	slow.recovery_ms = 420
	slow.reload_ms = 1600
	slow.magazine = 4
	slow.damage = 2
	defs[slow.id] = slow
	var m := ToolStateMachine.new(defs)
	m.request_switch(&"pistol")
	return m

func _run_to_ready(limit_s: float = 5.0) -> bool:
	var elapsed := 0.0
	while machine.state != ToolStateMachine.State.READY and elapsed < limit_s:
		machine.step(TICK)
		elapsed += TICK
	return machine.state == ToolStateMachine.State.READY

func test_every_authored_tool_is_defined_with_its_own_verb() -> void:
	var seen: Array[StringName] = []
	for id: StringName in Verbs.TOOL_VERB:
		var def: ToolDefinition = machine.definitions.get(id)
		assert_not_null(def, "tool %s is defined" % id)
		assert_false(seen.has(def.verb), "tool %s has its own physical verb" % id)
		seen.append(def.verb)

func test_a_commit_spends_exactly_one_round() -> void:
	var before := machine.loaded()
	machine.request_use()
	assert_eq(machine.loaded(), before - 1, "committing spends one round")
	_advance(2.0)
	assert_eq(machine.loaded(), before - 1, "and running the action to completion spends no more")

func test_the_commit_event_fires_once_per_shot() -> void:
	var commits: Array[StringName] = []
	machine.committed.connect(func(id: StringName, _d: ToolDefinition) -> void: commits.append(id))
	machine.request_use()
	_advance(2.0)
	assert_eq(commits.size(), 1, "one committed action emits exactly one simulation event")

func test_a_tool_cannot_fire_while_busy() -> void:
	machine.request_use()
	var after_first := machine.loaded()
	assert_false(machine.request_use(), "a second use during recovery is refused")
	assert_eq(machine.loaded(), after_first, "and spends nothing")

func test_an_empty_tool_refuses_to_fire_with_a_reason() -> void:
	var reasons: Array[String] = []
	machine.rejected.connect(func(_id: StringName, reason: String) -> void: reasons.append(reason))
	for i in tuning.pistol_magazine:
		machine.request_use()
		_run_to_ready()
	assert_eq(machine.loaded(), 0, "the magazine is empty")
	assert_false(machine.request_use(), "an empty tool refuses")
	assert_true(reasons.has("empty"), "and explains why rather than silently doing nothing")

func test_switching_during_recovery_queues_and_does_not_cancel_the_spent_shot() -> void:
	machine.request_use()
	var spent := machine.loaded()
	assert_true(machine.is_committed_action(), "the shot is committed")
	assert_false(machine.request_switch(&"lasso"), "the switch does not take effect immediately")
	assert_eq(machine.equipped_id, &"pistol", "the pistol is still equipped through its recovery")
	assert_eq(machine.loaded(&"pistol"), spent, "the spent round is not refunded by switching")
	_run_to_ready()
	assert_eq(machine.equipped_id, &"lasso", "the queued switch applies once the action finishes")

func test_switching_while_idle_is_immediate() -> void:
	assert_true(machine.request_switch(&"lasso"), "an idle switch takes effect at once")
	assert_eq(machine.equipped_id, &"lasso", "the lasso is equipped")

func test_switching_away_mid_reload_abandons_it_without_refilling() -> void:
	machine.request_use()
	_run_to_ready()
	var before := machine.loaded(&"pistol")
	machine.request_reload()
	machine.step(TICK)
	machine.request_switch(&"lasso")
	assert_eq(machine.equipped_id, &"lasso", "the switch is allowed mid-reload")
	assert_eq(machine.loaded(&"pistol"), before, "an abandoned reload does not quietly complete")

func test_reload_refills_the_magazine() -> void:
	machine.request_use()
	_run_to_ready()
	assert_true(machine.request_reload(), "a partly empty tool can reload")
	_run_to_ready()
	assert_eq(machine.loaded(), tuning.pistol_magazine, "reload refills to capacity")

func test_reload_is_refused_when_already_full() -> void:
	assert_false(machine.request_reload(), "a full tool has nothing to reload")

func test_the_lasso_has_no_ammunition_and_cannot_be_exhausted() -> void:
	machine.request_switch(&"lasso")
	assert_eq(machine.loaded(), -1, "the lasso reports no magazine at all")
	for i in 20:
		assert_true(machine.request_use(), "lasso throw %d is permitted" % i)
		machine.notify_attached()
		machine.notify_released()
		_run_to_ready()

func test_hurt_interrupts_aiming() -> void:
	machine = _machine_with_slow_tool()
	machine.request_switch(&"test_slow_tool")
	machine.request_use()
	assert_eq(machine.state, ToolStateMachine.State.AIMING, "a slow tool aims before it fires")
	var before := machine.loaded()
	machine.interrupt_hurt()
	assert_eq(machine.state, ToolStateMachine.State.READY, "hurt interrupts the aim")
	assert_eq(machine.loaded(), before, "an interrupted aim spends nothing")

func test_hurt_interrupts_reload_without_refilling() -> void:
	machine.request_use()
	_run_to_ready()
	var before := machine.loaded()
	machine.request_reload()
	machine.step(TICK)
	machine.interrupt_hurt()
	assert_eq(machine.state, ToolStateMachine.State.READY, "hurt interrupts the reload")
	assert_eq(machine.loaded(), before, "and the magazine is not refilled by the interruption")

func test_hurt_during_recovery_does_not_refund_the_shot() -> void:
	machine.request_use()
	var spent := machine.loaded()
	machine.interrupt_hurt()
	assert_eq(machine.loaded(), spent, "damage never refunds a round that was already committed")

func test_releasing_the_input_cancels_a_slow_aim_before_it_commits() -> void:
	machine = _machine_with_slow_tool()
	machine.request_switch(&"test_slow_tool")
	var before := machine.loaded()
	machine.request_use()
	machine.step(TICK)
	machine.release_use()
	assert_eq(machine.state, ToolStateMachine.State.READY, "letting go cancels the aim")
	assert_eq(machine.loaded(), before, "nothing was spent because nothing committed")

func test_holding_a_slow_aim_long_enough_does_commit() -> void:
	machine = _machine_with_slow_tool()
	machine.request_switch(&"test_slow_tool")
	var before := machine.loaded()
	machine.request_use()
	_advance(0.38 + 0.05)
	assert_eq(machine.loaded(), before - 1, "holding it on target commits the shot")

func test_a_tool_with_aim_time_takes_longer_to_commit_than_one_without() -> void:
	machine = _machine_with_slow_tool()
	var pistol_ticks := 0
	machine.request_use()
	while machine.state == ToolStateMachine.State.AIMING:
		machine.step(TICK)
		pistol_ticks += 1
	machine.force_release_to_ready()

	machine.request_switch(&"test_slow_tool")
	var slow_ticks := 0
	machine.request_use()
	while machine.state == ToolStateMachine.State.AIMING:
		machine.step(TICK)
		slow_ticks += 1
	assert_true(slow_ticks > pistol_ticks,
		"the deliberate tool must feel slower to commit than the quick one (%d vs %d ticks)"
			% [slow_ticks, pistol_ticks])

func test_a_destroyed_anchor_releases_cleanly_rather_than_leaving_a_rope_attached() -> void:
	machine.request_switch(&"lasso")
	machine.request_use()
	machine.notify_attached()
	assert_eq(machine.state, ToolStateMachine.State.ATTACHED, "the rope is attached")
	machine.force_release_to_ready()
	assert_eq(machine.state, ToolStateMachine.State.READY, "losing the anchor returns to ready, not a stuck state")

func test_ammo_round_trips_and_resets_to_a_safe_idle() -> void:
	machine.request_use()
	var payload := machine.serialize_ammo()
	var reloaded := ToolStateMachine.new(ToolDefinition.build(tuning))
	reloaded.request_switch(&"pistol")
	reloaded.request_use()
	reloaded.restore_ammo(payload)
	assert_eq(reloaded.loaded(&"pistol"), machine.loaded(&"pistol"), "ammo survives the round trip")
	assert_eq(reloaded.state, ToolStateMachine.State.READY,
		"a restore resets to a documented safe idle rather than restoring a mid-action state")

func test_replenish_restores_every_magazine() -> void:
	# Two magazines are needed to tell "every magazine" apart from "the equipped
	# one", and the shipped kit now has only the pistol -- so the second comes
	# from the injected tool rather than the test quietly checking one.
	machine = _machine_with_slow_tool()
	machine.request_use()
	_run_to_ready()
	machine.request_switch(&"test_slow_tool")
	machine.request_use()
	_run_to_ready()
	machine.replenish_all()
	assert_eq(machine.loaded(&"pistol"), tuning.pistol_magazine, "the pistol is topped up")
	assert_eq(machine.loaded(&"test_slow_tool"), 4, "so is the other magazine")

func test_switching_to_an_unknown_tool_is_refused() -> void:
	assert_false(machine.request_switch(&"dynamite"), "an undefined tool cannot be equipped")
	assert_eq(machine.equipped_id, &"pistol", "and the equipped tool is unchanged")

# --- what the rope chooses to grab ------------------------------------------

func test_the_rope_prefers_what_michael_is_facing_over_what_is_merely_closest() -> void:
	# The Sunken Cistern seeds 146 swing anchors. With pure nearest-wins a
	# player standing in front of a winch roped an anchor behind their shoulder
	# instead, so the mechanism never moved and the level's four gates could not
	# be opened at all. Distance still decides between similar candidates --
	# D18 forbids turning the rope into an aim test -- but ahead beats behind.
	var ahead := ToolController.anchor_score(120.0, 1.0)
	var behind := ToolController.anchor_score(80.0, -1.0)
	assert_true(ahead < behind,
		"a target 120px ahead beats one 80px behind (%.0f vs %.0f)" % [ahead, behind])

func test_facing_bias_does_not_beat_a_large_difference_in_distance() -> void:
	# The other half of the same rule: the rope stays organic. Something very
	# close and slightly off-axis must still win, or every swing becomes a
	# precision check.
	var near_off_axis := ToolController.anchor_score(40.0, 0.0)
	var far_ahead := ToolController.anchor_score(300.0, 1.0)
	assert_true(near_off_axis < far_ahead,
		"40px to the side still beats 300px dead ahead (%.0f vs %.0f)" % [near_off_axis, far_ahead])

func test_two_candidates_dead_ahead_are_decided_by_distance_alone() -> void:
	assert_true(ToolController.anchor_score(100.0, 1.0) < ToolController.anchor_score(140.0, 1.0),
		"with nothing to separate them on facing, nearer wins")
