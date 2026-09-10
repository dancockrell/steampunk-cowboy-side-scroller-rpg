class_name Tuning
extends Resource
## Central tuning proposal.
##
## Every number here is a PROVISIONAL hypothesis to be measured in playtest, not
## an approved production constraint (docs/weapon-tool-kit.md, docs/gameplay-pillars.md).
## Values live in one resource so a tuning change is one reviewable diff.

@export_group("Movement")
@export var run_speed: float = 150.0
@export var ground_accel: float = 1200.0
@export var ground_friction: float = 1400.0
@export var air_accel: float = 700.0
@export var air_friction: float = 200.0
@export var gravity: float = 1400.0
@export var fall_gravity_multiplier: float = 1.35
@export var terminal_fall_speed: float = 700.0
@export var jump_velocity: float = -420.0
@export var jump_cut_multiplier: float = 0.45
@export var coyote_time_s: float = 0.12
@export var jump_buffer_s: float = 0.12
@export var land_recovery_s: float = 0.08

@export_group("Health")
@export var max_health: int = 5
@export var hurt_stun_s: float = 0.35
@export var invulnerable_s: float = 0.9
@export var knockback_speed: float = 140.0
## Distance below a room's authored bounds before falling counts as a death.
## docs/gameplay-pillars.md: "Falling/defeat returns to the latest checkpoint
## snapshot." A missed lasso swing over a gap has to be recoverable, not a
## silent, permanent loss of control.
@export var fall_death_margin_px: float = 96.0

@export_group("Lasso")
@export var lasso_range_px: float = 190.0
@export var lasso_throw_speed_px_s: float = 900.0
@export var lasso_commit_ms: int = 240
@export var lasso_recovery_ms: int = 180
@export var lasso_miss_recovery_ms: int = 260
@export var lasso_pull_speed_px_s: float = 90.0
@export var swing_gravity: float = 1100.0
@export var swing_damping: float = 0.995
@export var swing_release_boost: float = 1.12
@export var swing_min_length_px: float = 28.0

@export_group("Firearms")
@export var pistol_range_px: float = 220.0
@export var pistol_commit_ms: int = 90
@export var pistol_recovery_ms: int = 150
@export var pistol_reload_ms: int = 900
@export var pistol_magazine: int = 6

@export var shotgun_range_px: float = 96.0
@export var shotgun_cone_degrees: float = 34.0
@export var shotgun_commit_ms: int = 140
@export var shotgun_recovery_ms: int = 420
@export var shotgun_reload_ms: int = 1400
@export var shotgun_magazine: int = 2
@export var shotgun_knockback_px_s: float = 200.0

@export var rifle_range_px: float = 520.0
@export var rifle_aim_ms: int = 380
@export var rifle_commit_ms: int = 110
@export var rifle_recovery_ms: int = 420
@export var rifle_reload_ms: int = 1600
@export var rifle_magazine: int = 4

@export_group("Emergence")
@export var tell_duration_ms: int = 900
@export var awakening_duration_ms: int = 500
@export var emerging_duration_ms: int = 1400
@export var active_settle_ms: int = 420
@export var blocked_spawn_retry_ms: int = 350
@export var blocked_spawn_retell_ms: int = 900

@export_group("Intervention")
@export var recall_cooldown_ms: int = 12000
@export var recall_duration_ms: int = 1600
@export var recall_uses_per_checkpoint: int = 2
@export var recall_health_fraction: float = 0.5
