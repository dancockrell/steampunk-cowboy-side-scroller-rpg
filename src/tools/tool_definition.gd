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
## is what makes the pistol feel quick and the rifle feel deliberate.
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

	var shotgun := ToolDefinition.new()
	shotgun.id = &"shotgun"
	shotgun.display_name = "Shotgun"
	shotgun.verb = Verbs.FORCE_HIT
	shotgun.range_px = tuning.shotgun_range_px
	shotgun.commit_ms = tuning.shotgun_commit_ms
	shotgun.recovery_ms = tuning.shotgun_recovery_ms
	shotgun.reload_ms = tuning.shotgun_reload_ms
	shotgun.magazine = tuning.shotgun_magazine
	shotgun.damage = 2
	shotgun.force = tuning.shotgun_knockback_px_s
	shotgun.cone_degrees = tuning.shotgun_cone_degrees

	var rifle := ToolDefinition.new()
	rifle.id = &"rifle"
	rifle.display_name = "Rifle"
	rifle.verb = Verbs.LONG_PRECISION_HIT
	rifle.range_px = tuning.rifle_range_px
	rifle.aim_ms = tuning.rifle_aim_ms
	rifle.commit_ms = tuning.rifle_commit_ms
	rifle.recovery_ms = tuning.rifle_recovery_ms
	rifle.reload_ms = tuning.rifle_reload_ms
	rifle.magazine = tuning.rifle_magazine
	rifle.damage = 2

	return {
		&"lasso": lasso,
		&"pistol": pistol,
		&"shotgun": shotgun,
		&"rifle": rifle,
	}
