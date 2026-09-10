class_name Verbs
extends RefCounted
## Authored interaction verbs. See docs/weapon-tool-kit.md.
##
## A ToolTarget declares which of these it accepts. Cosmetic props declare none
## and therefore cannot secretly inherit an interaction.

const PULL := &"pull"
const PRECISION_HIT := &"precision_hit"
const SWING := &"swing"

const ALL: Array[StringName] = [PULL, PRECISION_HIT, SWING]

## Which tool emits which verb. The kit is two tools (D21): the lasso, whose
## verb depends on what it catches -- an anchor gives SWING, anything else
## gives PULL -- and the pistol.
const TOOL_VERB := {
	&"lasso": PULL,
	&"pistol": PRECISION_HIT,
}

static func is_known(verb: StringName) -> bool:
	return verb in ALL
