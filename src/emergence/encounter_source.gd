class_name EncounterSource
extends Resource
## One authored EmergenceSource record (docs/data-contracts.md).
##
## The enum-valued fields are kept as authored StringNames rather than engine
## enums on purpose. An enum export cannot hold an unrecognised value, so it
## would make the "unrecognised interrupt rules fail content validation instead
## of defaulting to damage" rule untestable and, worse, unenforceable against
## data that arrives from a JSON author rather than from the inspector.

enum SourceType { CERAMIC, MURAL, INSCRIPTION, DOOR, PIT }
enum InterruptRule { NONE, TO_RESOLVED, TO_STAGGERED_ACTIVE }
enum BlockedSpawnPolicy { WAIT, AUTHORED_FALLBACK }

const SOURCE_TYPE_NAMES: Array[String] = ["ceramic", "mural", "inscription", "door", "pit"]
const INTERRUPT_RULE_NAMES: Array[String] = ["none", "to_resolved", "to_staggered_active"]
const BLOCKED_SPAWN_POLICY_NAMES: Array[String] = ["wait", "authored_fallback"]

const CERAMIC_SENTINEL := &"ceramic_sentinel"
const PAINTED_PROCESSION_GUARD := &"painted_procession_guard"
const BURIAL_PIT_ASSEMBLER := &"burial_pit_assembler"

## The three slice families (docs/temple-emergence.md). Door and inscription
## sources are supported source TYPES; they are not extra enemy families owed by
## this milestone, so they reuse one of these three actors.
const FAMILY_SCENES := {
	CERAMIC_SENTINEL: "res://scenes/actors/enemies/ceramic_sentinel_graybox.tscn",
	PAINTED_PROCESSION_GUARD: "res://scenes/actors/enemies/painted_procession_guard_graybox.tscn",
	BURIAL_PIT_ASSEMBLER: "res://scenes/actors/enemies/burial_pit_assembler_graybox.tscn",
}

@export var id: StringName
@export var room_id: StringName
## One of SOURCE_TYPE_NAMES.
@export var source_type: StringName = &"ceramic"
## One of FAMILY_SCENES' keys.
@export var family_id: StringName = CERAMIC_SENTINEL
@export var trigger_id: StringName
@export var spawn_point_id: StringName
@export var tell_clip_id: StringName
@export var emerge_clip_id: StringName
@export var resolved_visual_id: StringName
## One of INTERRUPT_RULE_NAMES. "none" means this source authors no interrupt at
## all, which is a refusal, never a licence to route to an attack.
@export var interrupt_rule: StringName = &"none"
## One of BLOCKED_SPAWN_POLICY_NAMES.
@export var blocked_spawn_policy: StringName = &"wait"
@export var reward_event_id: StringName

func source_type_index() -> int:
	return SOURCE_TYPE_NAMES.find(String(source_type))

func interrupt_rule_index() -> int:
	return INTERRUPT_RULE_NAMES.find(String(interrupt_rule))

func blocked_spawn_policy_index() -> int:
	return BLOCKED_SPAWN_POLICY_NAMES.find(String(blocked_spawn_policy))

func family_scene_path() -> String:
	return String(FAMILY_SCENES.get(family_id, ""))

## Spawn ownership transfers exactly once per source, so the transfer is itself a
## ledger event and survives a reload like any other one-shot fact.
func spawn_event_id() -> StringName:
	return StringName("%s:spawn" % id)

## Environmental collateral is a DISTINCT authored fact, recorded at the moment
## the source is destroyed. Nothing downstream has to guess it back out of what
## the rubble happens to look like (docs/temple-emergence.md).
func collateral_event_id() -> StringName:
	return StringName("%s:collateral" % id)

## Empty string means valid. Anything else is an actionable content error.
func validation_error() -> String:
	if id == &"":
		return "EmergenceSource requires a stable id"
	var required := {
		"room_id": room_id,
		"trigger_id": trigger_id,
		"spawn_point_id": spawn_point_id,
		"tell_clip_id": tell_clip_id,
		"emerge_clip_id": emerge_clip_id,
		"resolved_visual_id": resolved_visual_id,
		"reward_event_id": reward_event_id,
	}
	var field_names: Array = required.keys()
	field_names.sort()
	for field: String in field_names:
		if StringName(required[field]) == &"":
			return "source '%s' is missing required field '%s'" % [id, field]
	if source_type_index() < 0:
		return "source '%s' has unknown source_type '%s'; known values are %s" % [
			id, source_type, ", ".join(SOURCE_TYPE_NAMES)]
	if not FAMILY_SCENES.has(family_id):
		var families: Array = FAMILY_SCENES.keys()
		families.sort()
		return "source '%s' has unknown family_id '%s'; known families are %s" % [
			id, family_id, ", ".join(families.map(func(f: StringName) -> String: return String(f)))]
	if interrupt_rule_index() < 0:
		return "source '%s' has unrecognised interrupt_rule '%s'; known rules are %s" % [
			id, interrupt_rule, ", ".join(INTERRUPT_RULE_NAMES)]
	if blocked_spawn_policy_index() < 0:
		return "source '%s' has unknown blocked_spawn_policy '%s'; known values are %s" % [
			id, blocked_spawn_policy, ", ".join(BLOCKED_SPAWN_POLICY_NAMES)]
	return ""
