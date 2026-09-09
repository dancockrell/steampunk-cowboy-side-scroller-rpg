class_name DialoguePlayer
extends RefCounted
## Bridges an authored DialogueScript scene into the Dialogue UI and the
## RelationshipBook, and back out again.
##
## Nothing else in the game reads DialogueScript directly. This is the one
## place a scene ID becomes an on-screen conversation, so the gating rule from
## docs/relationships.md stays enforced in exactly one place: a condition can
## decide whether a scene is OFFERED, never what a chosen answer means.

signal scene_finished(scene_id: StringName, choice_id: StringName)

var script_by_speaker: Dictionary = {}
var dialogue: Dialogue
var relationships: RelationshipBook

var _current_scene: DialogueScript.Scene
var _current_speaker: StringName
var _line_index: int = 0

func _init(p_dialogue: Dialogue, p_relationships: RelationshipBook) -> void:
	dialogue = p_dialogue
	relationships = p_relationships
	if dialogue != null:
		dialogue.choice_made.connect(_on_choice_made)
		dialogue.advanced.connect(_on_advanced)

func register(speaker_id: StringName, script: DialogueScript) -> void:
	if script == null:
		push_error("DialoguePlayer.register: no script for '%s'" % speaker_id)
		return
	script_by_speaker[speaker_id] = script

## Whether the scene is currently offerable, per the heroine's relationship
## state. Callers (a shrine, an NPC, the room) check this before presenting.
func is_available(speaker_id: StringName, scene_id: StringName) -> bool:
	var script: DialogueScript = script_by_speaker.get(speaker_id)
	if script == null or relationships == null:
		return false
	var state := relationships.state(speaker_id)
	return script.is_available(scene_id, state)

## Starts a scene. Marks the heroine encountered, the first time any scene
## with her plays, so an alliance offer can require it later. Returns false
## and shows nothing if the scene is not currently offerable or has no lines.
func play(speaker_id: StringName, scene_id: StringName) -> bool:
	if dialogue == null or not is_available(speaker_id, scene_id):
		return false
	var script: DialogueScript = script_by_speaker[speaker_id]
	var scene := script.scene(scene_id)
	if scene == null or scene.lines.is_empty():
		return false

	relationships.mark_encountered(speaker_id)
	_current_scene = scene
	_current_speaker = speaker_id
	_line_index = 0
	_present_current_line()
	return true

func is_playing() -> bool:
	return _current_scene != null

func _present_current_line() -> void:
	var is_last_line := _line_index == _current_scene.lines.size() - 1
	var choices: Array = []
	if is_last_line and _current_scene.has_choices():
		for c: Dictionary in _current_scene.choices:
			choices.append({"id": c["id"], "kind": c["id"], "text": c["text"]})
	dialogue.present(_speaker_display_name(), _current_scene.lines[_line_index], choices)

func _speaker_display_name() -> String:
	var heroine := relationships.heroine(_current_speaker) if relationships != null else null
	return heroine.display_name if heroine != null else String(_current_speaker)

func _on_advanced() -> void:
	if _current_scene == null:
		return
	var is_last_line := _line_index == _current_scene.lines.size() - 1
	if is_last_line and _current_scene.has_choices():
		# The last line of an offer waits for a choice; advancing does nothing.
		return
	if is_last_line:
		_finish(&"")
		return
	_line_index += 1
	_present_current_line()

func _on_choice_made(choice_id: StringName) -> void:
	if _current_scene == null:
		return
	var choice := _current_scene.choice(choice_id)
	if choice.is_empty():
		return
	# Show her reply, then close: a choice's response is itself one more line,
	# never skipped past.
	dialogue.present(_speaker_display_name(), String(choice["response"]), [])
	var finishing_scene := _current_scene.id
	_current_scene = null
	scene_finished.emit(finishing_scene, choice_id)

func _finish(choice_id: StringName) -> void:
	var finishing_scene := _current_scene.id
	_current_scene = null
	dialogue.close()
	scene_finished.emit(finishing_scene, choice_id)
