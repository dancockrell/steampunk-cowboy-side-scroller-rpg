class_name Verbs
extends RefCounted
## Authored interaction verbs. See docs/weapon-tool-kit.md.
##
## A ToolTarget declares which of these it accepts. Cosmetic props declare none
## and therefore cannot secretly inherit an interaction.

const PULL := &"pull"
const PRECISION_HIT := &"precision_hit"
const FORCE_HIT := &"force_hit"
const LONG_PRECISION_HIT := &"long_precision_hit"
const SWING := &"swing"

const ALL: Array[StringName] = [PULL, PRECISION_HIT, FORCE_HIT, LONG_PRECISION_HIT, SWING]

## Which tool emits which verb. One tool, one physical verb.
const TOOL_VERB := {
	&"lasso": PULL,
	&"pistol": PRECISION_HIT,
	&"shotgun": FORCE_HIT,
	&"rifle": LONG_PRECISION_HIT,
}

static func is_known(verb: StringName) -> bool:
	return verb in ALL
