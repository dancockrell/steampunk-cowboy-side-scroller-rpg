class_name HitReceiver
extends Area2D
## Anything a tool verb can land on.
##
## A receiver declares the verbs it accepts. A cosmetic prop declares none and
## therefore cannot secretly inherit every interaction just because it sits in
## the world (docs/weapon-tool-kit.md).
##
## Subclasses override _on_hit. They never override receive(), which owns the
## verb check and the rejection signal so no subclass can quietly skip it.

signal hit_accepted(hit: Hit)
signal hit_rejected(hit: Hit, reason: String)

@export var receiver_id: StringName
## Authored subset of Verbs.ALL. Empty means decorative.
@export var allowed_verbs: Array[StringName] = []
## When false the receiver is present but no longer interactive, e.g. an anchor
## that has already broken. It still explains itself rather than ignoring input.
@export var interactive: bool = true

func accepts(verb: StringName) -> bool:
	return interactive and allowed_verbs.has(verb)

## Returns true when the verb was applied. A false return is a readable refusal,
## not a silent no-op: tool preview and impact feedback explain an invalid use.
func receive(hit: Hit) -> bool:
	if not Verbs.is_known(hit.verb):
		hit_rejected.emit(hit, "unknown verb")
		push_error("HitReceiver '%s' received unknown verb '%s'" % [receiver_id, hit.verb])
		return false
	if not interactive:
		hit_rejected.emit(hit, "inert")
		return false
	if not allowed_verbs.has(hit.verb):
		hit_rejected.emit(hit, "wrong tool")
		return false
	if not _on_hit(hit):
		hit_rejected.emit(hit, "refused")
		return false
	hit_accepted.emit(hit)
	return true

## Override point. Return false to refuse this particular hit even though the
## verb is allowed, for example a mechanism already in its final state.
func _on_hit(_hit: Hit) -> bool:
	return true

## Where a lasso attaches or an interaction visually lands. Defaults to centre.
func interaction_point() -> Vector2:
	var marker := get_node_or_null(^"InteractionPoint") as Marker2D
	return marker.global_position if marker != null else global_position
