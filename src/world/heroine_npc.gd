class_name HeroineNpc
extends Area2D
## An in-world presence a heroine's authored dialogue plays through.
##
## Decides WHICH scene to offer from her relationship state (introduction once,
## then judgment, then the alliance and romance offers once each is eligible)
## and translates a finished offer's choice into the RelationshipBook call that
## choice actually means. That mapping is authored here, once, rather than
## copied into every scene that might want to talk to her.

@export var heroine_id: StringName
@export var interact_range_px: float = 56.0

var player: DialoguePlayer
var relationships: RelationshipBook
var _pending_scene: StringName = &""
var _player_body: Player

func bind(dialogue_player: DialoguePlayer, p_relationships: RelationshipBook) -> void:
	player = dialogue_player
	relationships = p_relationships
	if not player.scene_finished.is_connected(_on_scene_finished):
		player.scene_finished.connect(_on_scene_finished)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(func(b: Node2D) -> void: if b is Player: _player_body = b)
	body_exited.connect(func(b: Node2D) -> void: if b == _player_body: _player_body = null)

func _unhandled_input(event: InputEvent) -> void:
	if _player_body == null or player == null or player.is_playing():
		return
	if event.is_action_pressed(&"interact"):
		_offer_next_scene()

## The one place scene choice is decided from relationship state, so a caller
## never has to know the heroine's authored scene IDs.
func _offer_next_scene() -> void:
	var state := relationships.state(heroine_id)
	if state == null:
		return
	if state.arc_state == RelationshipState.Arc.UNKNOWN:
		_try(&"keeper_intro")
		return
	if not bool(state.flag(&"alliance_offer_answered", false)) and state.arc_state >= RelationshipState.Arc.TESTED:
		_try(&"keeper_alliance_offer")
		return
	if state.alliance_accepted and not bool(state.flag(&"romance_offer_answered", false)):
		if _try(&"keeper_romance_offer"):
			return
	_try(&"keeper_judgment")

func _try(scene_id: StringName) -> bool:
	if player.play(heroine_id, scene_id):
		_pending_scene = scene_id
		return true
	return false

## Turns "which offer, which answer" into the one RelationshipBook call it
## means. A plain line with no choices (intro, judgment) needs none of this.
func _on_scene_finished(scene_id: StringName, choice_id: StringName) -> void:
	if scene_id != _pending_scene:
		return
	_pending_scene = &""
	if choice_id == &"":
		return
	match scene_id:
		&"keeper_alliance_offer":
			match choice_id:
				&"accept":
					relationships.resolve_alliance_offer(heroine_id, true)
				&"decline":
					relationships.resolve_alliance_offer(heroine_id, false)
				&"defer":
					pass # Neither accepted nor refused; the offer stays open.
		&"keeper_romance_offer":
			relationships.resolve_romance_offer(heroine_id, choice_id)
