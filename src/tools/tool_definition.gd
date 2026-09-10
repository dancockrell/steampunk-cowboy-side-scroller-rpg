class_name ToolDefinition
extends Resource
## Authored tool record. Fields follow the ToolDefinition contract in
## docs/data-contracts.md. Numbers come from Tuning, not from prose.

enum AmmoPolicy {
	## The lasso costs nothing and cannot be exhausted.
	NONE,
	## A magazine that is spent per commit and refilled by an explicit reload.
	MAGAZINE,
}

@export var id: StringName
@export var display_name: String
## The single physical verb this tool emits. One tool, one verb.
@export var verb: StringName
@export var range_px: float = 0.0
## Time held on target before the shot commits. Zero commits immediately, which
## is what makes the pistol feel quick; a tool authored with aim time feels
## deliberate instead. Neither shipped tool uses it, so the aim path is proved
## by an injected definition in tests/tools/test_tool_state_machine.gd.
@export var aim_ms: int = 0
@export var commit_ms: int = 100
@export var recovery_ms: int = 150
@export var reload_ms: int = 0
@export var ammo_policy: AmmoPolicy = AmmoPolicy.MAGAZINE
@export var magazine: int = 0
@export var damage: int = 1
@export var force: float = 0.0
## Cone half-angle in degrees for a spread verb; 0 means a single ray.
@export var cone_degrees: float = 0.0
## Presentation clip IDs. Empty until an art pack is admitted; the simulation
## never depends on these resolving.
@export var clip_ids: Dictionary = {}

static func build(tuning: Tuning) -> Dictionary:
	var lasso := ToolDefinition.new()
	lasso.id = &"lasso"
	lasso.display_name = "Lasso"
	lasso.verb = Verbs.PULL
	lasso.range_px = tuning.lasso_range_px
	lasso.commit_ms = tuning.lasso_commit_ms
	lasso.recovery_ms = tuning.lasso_recovery_ms
	lasso.ammo_policy = AmmoPolicy.NONE
	lasso.damage = 0

	var pistol := ToolDefinition.new()
	pistol.id = &"pistol"
	pistol.display_name = "Pistol"
	pistol.verb = Verbs.PRECISION_HIT
	pistol.range_px = tuning.pistol_range_px
	pistol.commit_ms = tuning.pistol_commit_ms
	pistol.recovery_ms = tuning.pistol_recovery_ms
	pistol.reload_ms = tuning.pistol_reload_ms
	pistol.magazine = tuning.pistol_magazine
	pistol.damage = 1

	return {
		&"lasso": lasso,
		&"pistol": pistol,
	}
