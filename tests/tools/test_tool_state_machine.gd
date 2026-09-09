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

func _run_to_ready(limit_s: float = 5.0) -> bool:
	var elapsed := 0.0
	while machine.state != ToolStateMachine.State.READY and elapsed < limit_s:
		machine.step(TICK)
		elapsed += TICK
	return machine.state == ToolStateMachine.State.READY

func test_all_four_tools_are_defined_with_distinct_verbs() -> void:
	var seen: Array[StringName] = []
	for id: StringName in [&"lasso", &"pistol", &"shotgun", &"rifle"]:
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
	assert_false(machine.request_switch(&"shotgun"), "the switch does not take effect immediately")
	assert_eq(machine.equipped_id, &"pistol", "the pistol is still equipped through its recovery")
	assert_eq(machine.loaded(&"pistol"), spent, "the spent round is not refunded by switching")
	_run_to_ready()
	assert_eq(machine.equipped_id, &"shotgun", "the queued switch applies once the action finishes")

func test_switching_while_idle_is_immediate() -> void:
	assert_true(machine.request_switch(&"rifle"), "an idle switch takes effect at once")
	assert_eq(machine.equipped_id, &"rifle", "the rifle is equipped")

func test_switching_away_mid_reload_abandons_it_without_refilling() -> void:
	machine.request_use()
	_run_to_ready()
	var before := machine.loaded(&"pistol")
	machine.request_reload()
	machine.step(TICK)
	machine.request_switch(&"shotgun")
	assert_eq(machine.equipped_id, &"shotgun", "the switch is allowed mid-reload")
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
	machine.request_switch(&"rifle")
	machine.request_use()
	assert_eq(machine.state, ToolStateMachine.State.AIMING, "the rifle aims before it fires")
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
	machine.request_switch(&"rifle")
	var before := machine.loaded()
	machine.request_use()
	machine.step(TICK)
	machine.release_use()
	assert_eq(machine.state, ToolStateMachine.State.READY, "letting go cancels the aim")
	assert_eq(machine.loaded(), before, "nothing was spent because nothing committed")

func test_holding_a_slow_aim_long_enough_does_commit() -> void:
	machine.request_switch(&"rifle")
	var before := machine.loaded()
	machine.request_use()
	_advance(tuning.rifle_aim_ms / 1000.0 + 0.05)
	assert_eq(machine.loaded(), before - 1, "holding the rifle on target commits the shot")

func test_the_rifle_takes_longer_to_commit_than_the_pistol() -> void:
	var pistol_ticks := 0
	machine.request_use()
	while machine.state == ToolStateMachine.State.AIMING:
		machine.step(TICK)
		pistol_ticks += 1
	machine.force_release_to_ready()

	machine.request_switch(&"rifle")
	var rifle_ticks := 0
	machine.request_use()
	while machine.state == ToolStateMachine.State.AIMING:
		machine.step(TICK)
		rifle_ticks += 1
	assert_true(rifle_ticks > pistol_ticks,
		"the deliberate tool must feel slower to commit than the quick one (%d vs %d ticks)"
			% [rifle_ticks, pistol_ticks])

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
	machine.request_use()
	_run_to_ready()
	machine.request_switch(&"shotgun")
	machine.request_use()
	_run_to_ready()
	machine.replenish_all()
	assert_eq(machine.loaded(&"pistol"), tuning.pistol_magazine, "the pistol is topped up")
	assert_eq(machine.loaded(&"shotgun"), tuning.shotgun_magazine, "so is the shotgun")

func test_switching_to_an_unknown_tool_is_refused() -> void:
	assert_false(machine.request_switch(&"dynamite"), "an undefined tool cannot be equipped")
	assert_eq(machine.equipped_id, &"pistol", "and the equipped tool is unchanged")
