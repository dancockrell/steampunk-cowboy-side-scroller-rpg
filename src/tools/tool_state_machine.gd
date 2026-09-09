class_name ToolStateMachine
extends RefCounted
## The action-ownership rules from docs/weapon-tool-kit.md, in one place.
##
## One state machine covers all four tools rather than a firearm version and a
## lasso version. The rules that matter (a commit spends ammo exactly once, a
## switch queues instead of cancelling a spent shot, hurt interrupts aiming and
## reload) are identical for every tool, and two copies of them would drift.
## The lasso simply declares AmmoPolicy.NONE and is the only tool that reaches
## ATTACHED.
##
## Pure logic: no nodes, no physics, no timers. Time is advanced by step(),
## which is what lets the whole contract be asserted headlessly.

signal committed(tool_id: StringName, definition: ToolDefinition)
signal state_changed(tool_id: StringName, state: State)
signal reload_finished(tool_id: StringName)
signal rejected(tool_id: StringName, reason: String)

enum State {
	READY,
	AIMING,
	COMMITTED,
	## Lasso only: rope is on a target and the player is pulling or swinging.
	ATTACHED,
	RECOVERING,
	RELOADING,
}

const STATE_NAMES: Array[String] = ["ready", "aiming", "committed", "attached", "recovering", "reloading"]

var definitions: Dictionary = {}
var equipped_id: StringName = &"lasso"
var state: State = State.READY

## tool_id -> rounds currently loaded.
var ammo: Dictionary = {}
## A switch asked for mid-action. Applied when the action finishes, so a spent
## shot is never cancelled into another free action.
var pending_switch: StringName = &""

var _timer_s: float = 0.0
var _aim_held: bool = false

func _init(tool_definitions: Dictionary = {}) -> void:
	definitions = tool_definitions
	for id: StringName in definitions:
		var def: ToolDefinition = definitions[id]
		if def.ammo_policy == ToolDefinition.AmmoPolicy.MAGAZINE:
			ammo[id] = def.magazine

func definition() -> ToolDefinition:
	return definitions.get(equipped_id)

func state_name() -> String:
	return STATE_NAMES[state]

func loaded(tool_id: StringName = &"") -> int:
	var id := tool_id if tool_id != &"" else equipped_id
	var def: ToolDefinition = definitions.get(id)
	if def == null or def.ammo_policy == ToolDefinition.AmmoPolicy.NONE:
		return -1
	return int(ammo.get(id, 0))

func is_busy() -> bool:
	return state != State.READY

## True only while a spent shot is still being paid for. Used to decide whether
## a switch must queue.
func is_committed_action() -> bool:
	return state == State.COMMITTED or state == State.RECOVERING

func _set_state(next: State) -> void:
	if state == next:
		return
	state = next
	state_changed.emit(equipped_id, next)

# --- requests -------------------------------------------------------------

## Equips immediately when idle, otherwise queues. Returns true when the switch
## took effect now.
func request_switch(tool_id: StringName) -> bool:
	if not definitions.has(tool_id):
		rejected.emit(tool_id, "no such tool")
		return false
	if tool_id == equipped_id and pending_switch == &"":
		return true
	if state == State.READY:
		equipped_id = tool_id
		pending_switch = &""
		state_changed.emit(equipped_id, state)
		return true
	# Aiming and reloading are abandonable; a committed action is not.
	if state == State.AIMING or state == State.RELOADING:
		_timer_s = 0.0
		_aim_held = false
		equipped_id = tool_id
		pending_switch = &""
		_set_state(State.READY)
		state_changed.emit(equipped_id, state)
		return true
	pending_switch = tool_id
	return false

## Begins using the equipped tool. A tool with aim_ms > 0 must be held on target
## before it commits.
func request_use() -> bool:
	if state != State.READY:
		rejected.emit(equipped_id, "busy: %s" % state_name())
		return false
	var def := definition()
	if def == null:
		rejected.emit(equipped_id, "no definition")
		return false
	if def.ammo_policy == ToolDefinition.AmmoPolicy.MAGAZINE and loaded() <= 0:
		rejected.emit(equipped_id, "empty")
		return false
	_aim_held = true
	if def.aim_ms <= 0:
		_begin_commit()
		return true
	_timer_s = def.aim_ms / 1000.0
	_set_state(State.AIMING)
	return true

## Releasing the input before a slow tool has committed cancels the aim. Nothing
## is spent, because nothing committed.
func release_use() -> void:
	_aim_held = false
	if state == State.AIMING:
		_timer_s = 0.0
		_set_state(State.READY)

func request_reload() -> bool:
	var def := definition()
	if def == null or def.ammo_policy == ToolDefinition.AmmoPolicy.NONE:
		rejected.emit(equipped_id, "nothing to reload")
		return false
	if state != State.READY and state != State.AIMING:
		rejected.emit(equipped_id, "busy: %s" % state_name())
		return false
	if loaded() >= def.magazine:
		rejected.emit(equipped_id, "already full")
		return false
	_aim_held = false
	_timer_s = def.reload_ms / 1000.0
	_set_state(State.RELOADING)
	return true

## Called when the rope reaches a valid anchor. Only the lasso can be here.
func notify_attached() -> bool:
	if state != State.COMMITTED and state != State.RECOVERING:
		return false
	_timer_s = 0.0
	_set_state(State.ATTACHED)
	return true

func notify_released() -> void:
	if state != State.ATTACHED:
		return
	var def := definition()
	_timer_s = (def.recovery_ms if def != null else 0) / 1000.0
	_set_state(State.RECOVERING)

## Taking damage interrupts aiming and reload. It does NOT refund a shot that
## already committed, and it does not shorten the recovery being paid for.
func interrupt_hurt() -> void:
	match state:
		State.AIMING, State.RELOADING:
			_timer_s = 0.0
			_aim_held = false
			_set_state(State.READY)
		State.ATTACHED:
			notify_released()
		_:
			pass

## Pause, room change, defeat and destroyed anchors all release cleanly rather
## than leaving a rope attached to something that no longer exists.
func force_release_to_ready() -> void:
	_timer_s = 0.0
	_aim_held = false
	pending_switch = &""
	_set_state(State.READY)

# --- time -----------------------------------------------------------------

func step(delta: float) -> void:
	if state == State.READY or state == State.ATTACHED:
		return
	_timer_s -= delta
	if _timer_s > 0.0:
		return
	match state:
		State.AIMING:
			if _aim_held:
				_begin_commit()
			else:
				_set_state(State.READY)
		State.COMMITTED:
			var def := definition()
			_timer_s = (def.recovery_ms if def != null else 0) / 1000.0
			_set_state(State.RECOVERING)
		State.RECOVERING:
			_finish_action()
		State.RELOADING:
			var def := definition()
			if def != null:
				ammo[equipped_id] = def.magazine
			reload_finished.emit(equipped_id)
			_finish_action()
		_:
			pass

func _begin_commit() -> void:
	var def := definition()
	# Ammo is spent here and nowhere else, so a replayed animation or a second
	# presentation event cannot spend it again.
	if def.ammo_policy == ToolDefinition.AmmoPolicy.MAGAZINE:
		ammo[equipped_id] = maxi(0, loaded() - 1)
	_timer_s = def.commit_ms / 1000.0
	_set_state(State.COMMITTED)
	committed.emit(equipped_id, def)

func _finish_action() -> void:
	_timer_s = 0.0
	_aim_held = false
	_set_state(State.READY)
	if pending_switch != &"":
		var next := pending_switch
		pending_switch = &""
		equipped_id = next
		state_changed.emit(equipped_id, state)

# --- persistence ----------------------------------------------------------

## Saving is restricted to safe checkpoints, so a transient action state is
## never serialised: the tool resets to a documented safe idle.
func serialize_ammo() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in ammo:
		out[String(id)] = ammo[id]
	return out

func restore_ammo(data: Dictionary) -> void:
	force_release_to_ready()
	for key: String in data:
		var id := StringName(key)
		if definitions.has(id):
			ammo[id] = int(data[key])

## Required ammunition cannot be permanently exhausted, so a checkpoint shrine
## can always top a tool back up (docs/gameplay-pillars.md).
func replenish_all() -> void:
	for id: StringName in definitions:
		var def: ToolDefinition = definitions[id]
		if def.ammo_policy == ToolDefinition.AmmoPolicy.MAGAZINE:
			ammo[id] = def.magazine
