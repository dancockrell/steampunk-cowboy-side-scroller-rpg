class_name GameActions
extends RefCounted
## The gameplay actions project.godot actually defines, plus the labels the
## remap screen shows for them.
##
## This list is a MIRROR of project.godot, never a second source of truth. UI
## must not invent an action name, and it must not quietly omit one, so
## tests/ui/test_game_actions.gd diffs this list against the live InputMap in
## both directions: nothing here that the project lacks, nothing in the project
## that is missing here.
##
## `release_all` exists because docs/weapon-tool-kit.md requires "no sticky input
## after pause or focus loss". A held action survives a pause on its own; the
## pause menu has to let go of it explicitly.

const MOVE_LEFT := &"move_left"
const MOVE_RIGHT := &"move_right"
const JUMP := &"jump"
const TOOL_USE := &"tool_use"
const TOOL_CANCEL := &"tool_cancel"
const TOOL_LASSO := &"tool_lasso"
const TOOL_PISTOL := &"tool_pistol"
const INTERACT := &"interact"
const RELOAD := &"reload"
const INTERVENTION := &"intervention"
const PAUSE := &"pause"
const DIALOGUE_ADVANCE := &"dialogue_advance"

const ALL: Array[StringName] = [
	MOVE_LEFT, MOVE_RIGHT, JUMP,
	TOOL_USE, TOOL_CANCEL,
	TOOL_LASSO, TOOL_PISTOL,
	INTERACT, RELOAD, INTERVENTION,
	PAUSE, DIALOGUE_ADVANCE,
]

## Grouping for the remap screen only. Every action appears in exactly one group
## and every group member is in ALL; the test checks both, so a new action cannot
## be added to one structure and forgotten in the other.
const GROUPS: Array[Dictionary] = [
	{"title": "Movement", "actions": [MOVE_LEFT, MOVE_RIGHT, JUMP]},
	{"title": "Tools", "actions": [TOOL_USE, TOOL_CANCEL, TOOL_LASSO, TOOL_PISTOL]},
	{"title": "Interaction", "actions": [INTERACT, RELOAD, INTERVENTION]},
	{"title": "System", "actions": [PAUSE, DIALOGUE_ADVANCE]},
]

const LABELS: Dictionary = {
	MOVE_LEFT: "Move left",
	MOVE_RIGHT: "Move right",
	JUMP: "Jump",
	TOOL_USE: "Aim / use equipped tool",
	TOOL_CANCEL: "Lasso release / cancel",
	TOOL_LASSO: "Equip lasso",
	TOOL_PISTOL: "Equip pistol",
	INTERACT: "Interact",
	RELOAD: "Reload",
	INTERVENTION: "Divine intervention",
	PAUSE: "Pause",
	DIALOGUE_ADVANCE: "Advance dialogue",
}

static func label_for(action: StringName) -> String:
	return String(LABELS.get(action, String(action)))

## Every non-built-in action the running project declares. Godot's own `ui_*`
## actions are the engine's, not the game's, and are deliberately excluded from
## remapping.
##
## Returned in InputMap order and deliberately NOT sorted: StringName's `<`
## compares by internal pointer, so sorting these produces an order that looks
## alphabetical in some runs and not in others. Callers that need an order sort
## the Strings.
static func project_actions() -> Array[StringName]:
	var found: Array[StringName] = []
	for action: StringName in InputMap.get_actions():
		if String(action).begins_with("ui_"):
			continue
		found.append(action)
	return found

## Releases every gameplay action. Called when the pause menu opens and when the
## window loses focus, so a key held at that moment cannot stay pressed while the
## tree is paused and fire the instant play resumes.
static func release_all() -> void:
	for action: StringName in ALL:
		if InputMap.has_action(action):
			Input.action_release(action)
