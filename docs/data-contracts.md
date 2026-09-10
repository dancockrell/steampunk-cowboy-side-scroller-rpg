# Authored data and implementation contracts

These are field contracts, not implemented loaders or validated runtime schemas. Claude/Grok should implement only fields needed by the assigned slice task. Use stable lowercase IDs; display names may change without breaking saves. Times are milliseconds, distances world pixels, dimensions pixels. Reject duplicate IDs, missing required references and unknown enum values with actionable errors.

## AnimationClip

Required: `id`, `entity_id`, `action`, `facing` (left/right/front), `cell_px` (positive integer pair), `pivot_px` (pair within cell), `frames` (ordered nonempty paths), `durations_ms` (positive value per frame), `loop`, `sockets` (named position per relevant frame), `events` (frame index and named presentation marker), `asset_revision`, `review_status`.

Frame files must exist and have the agreed dimensions; durations must match frame count; indices must be in bounds. `muzzle`, `hand_lasso` and `feet` socket semantics are shared across actions. Markers align presentation with authoritative actions; replaying a clip cannot spend ammo or deal damage twice.

## EmergenceSource

Required: `id`, `room_id`, `source_type` (ceramic/mural/inscription/door/pit), `family_id`, `trigger_id`, `spawn_point_id`, `tell_clip_id`, `emerge_clip_id`, `resolved_visual_id`, `interrupt_rule`, `blocked_spawn_policy`, `reward_event_id`.

Sources refer to existing room/clip/marker IDs. The encounter owns one actor at most. `blocked_spawn_policy` is wait or authored_fallback; fallback requires a valid safe marker. Persist result by source ID. Unrecognized interrupt rules fail content validation instead of defaulting to damage.

## ToolTarget and ToolDefinition

ToolTarget: `id`, `room_id`, nonempty `allowed_verbs`, `interaction_point`, `reset_policy`, optional `anchor_break_rule`. ToolDefinition: `id` (lasso/pistol, per D21), `verbs`, `range_px`, `commit_ms`, `recovery_ms`, `ammo_policy`, clip IDs, optional rope/force fields. Numeric bounds and tuning are introduced through the controller test scene, not invented in data now.

## Heroine and RelationshipState

Heroine: `id`, `adult: true`, `display_name`, `domain`, `agenda`, `boundaries`, `portrait_set_id`, `manifestation_set_id`, `judgment_rules`, `offer_scene_ids`, optional `intervention_id`. Identity approval and rights admission also apply to portraits.

RelationshipState: `heroine_id`, `arc_state`, `romance_state`, `witnessed_event_ids` (unique), `choice_flags`, `trust`, `respect`, `fascination`, `alliance_accepted`. Arc and romance enums are defined in relationships.md. Consent comes from explicit authored choices, never thresholds alone. Intervention access may require alliance but cannot require romance for the critical route.

## CheckpointSnapshot (version 1 proposed)

Required: `schema_version`, `checkpoint_id`, `room_id`, `player_spawn_id`, `player_state`, `ammo_state`, `puzzle_states`, `encounter_results`, `relationship_states`, `consumed_event_ids`. Snapshot includes all dependent systems atomically. On failed or unsupported load, keep the previous valid save and explain the problem; do not partly restore a room. Save transient action states only by resetting to a documented safe idle at the checkpoint.

## AssetRecord

Required: `id`, `kind`, `status`, `source`, `sha256`, `rights`, `reference_ids`, `export_paths`, `revision`, `technical_review`, `visual_review`, `evidence_paths`. The unavailable-reference register is a separate record type: it deliberately has no fake hash or export path.
