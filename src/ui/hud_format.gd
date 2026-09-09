class_name HudFormat
extends RefCounted
## Every string the HUD shows, built here so it can be checked without a window.
##
## The single rule this file exists to enforce: NOTHING is signalled by colour
## alone (docs/gameplay-pillars.md). Strip every colour out of the HUD and the
## equipped slot, an empty magazine, low health and an unavailable intervention
## must all still be readable as words. That is a property the tests assert by
## comparing the plain strings, so a later restyle cannot quietly remove it.
##
## The tool order and the tool ids come from Verbs.TOOL_VERB. This file does not
## keep a second list of tools.

## docs/weapon-tool-kit.md: the lasso has "no ammunition". That is different from
## a magazine that happens to be empty, and the HUD must not render them the same
## way.
const NO_AMMUNITION: Array[StringName] = [&"lasso"]

const INTERVENTION_NAME := "Recall to Clay"
const NO_REASON_GIVEN := "reason not given"

## Tool ids in slot order, taken from the canonical tool table.
static func slot_order() -> Array[StringName]:
	var ids: Array[StringName] = []
	for key: Variant in Verbs.TOOL_VERB.keys():
		ids.append(StringName(String(key)))
	return ids

static func slot_index(tool_id: StringName) -> int:
	return slot_order().find(tool_id)

static func has_ammunition(tool_id: StringName) -> bool:
	return not NO_AMMUNITION.has(tool_id)

## The equipped slot is marked by brackets and capitals as well as by colour, so
## it survives a colour-blind player and a washed-out dark-room screen.
static func slot_label(tool_id: StringName, equipped: bool) -> String:
	var index := slot_index(tool_id)
	var number := str(index + 1) if index >= 0 else "?"
	var name := String(tool_id)
	if equipped:
		return "[%s %s]" % [number, name.to_upper()]
	return " %s %s " % [number, name]

static func health_line(current: int, max_health: int) -> String:
	var safe_max := maxi(max_health, 0)
	var safe_current := clampi(current, 0, safe_max)
	if safe_max <= 0:
		return "HEALTH  unknown"
	if safe_current <= 0:
		return "HEALTH  0 / %d  DOWN" % safe_max
	if safe_current * 3 <= safe_max:
		return "HEALTH  %d / %d  LOW" % [safe_current, safe_max]
	return "HEALTH  %d / %d" % [safe_current, safe_max]

## Filled and empty pips. A value shape rather than a colour bar, so the reading
## survives at 640x360 and in shadow.
static func health_pips(current: int, max_health: int) -> String:
	var safe_max := clampi(max_health, 0, 40)
	var safe_current := clampi(current, 0, safe_max)
	return "*".repeat(safe_current) + ".".repeat(safe_max - safe_current)

static func ammo_line(tool_id: StringName, loaded: int, capacity: int) -> String:
	var name := String(tool_id).to_upper()
	if not has_ammunition(tool_id):
		return "%s  no ammunition" % name
	var safe_capacity := maxi(capacity, 0)
	var safe_loaded := clampi(loaded, 0, safe_capacity)
	if safe_capacity <= 0:
		return "%s  unknown" % name
	if safe_loaded <= 0:
		return "%s  0 / %d  EMPTY - reload" % [name, safe_capacity]
	return "%s  %d / %d" % [name, safe_loaded, safe_capacity]

## docs/relationships.md: "Michael gets a visible preview and clear unavailable
## feedback." Unavailable with no reason supplied is a bug in the caller, so it
## reads as unavailable AND says the reason is missing. It never renders as
## blank, and it never quietly renders as available.
static func intervention_line(available: bool, reason: String) -> String:
	if available:
		return "%s  READY" % INTERVENTION_NAME
	var trimmed := reason.strip_edges()
	if trimmed == "":
		trimmed = NO_REASON_GIVEN
	return "%s  UNAVAILABLE - %s" % [INTERVENTION_NAME, trimmed]

## Words, not a meter. docs/relationships.md forbids exposing "a romance
## optimization spreadsheet", so the HUD names the standing of the alliance and
## never a number.
static func alliance_line(arc_name: String, alliance_accepted: bool) -> String:
	if alliance_accepted:
		return "The Keeper walks with you."
	match arc_name:
		"unknown":
			return ""
		"encountered":
			return "The Keeper has noticed you."
		"tested":
			return "The Keeper is weighing you."
		_:
			return ""
