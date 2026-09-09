class_name DialogueScript
extends RefCounted
## Loads authored dialogue scenes and decides which are currently offerable.
##
## This owns WHAT is said and WHEN it is available. It does not own how any of it
## looks: the UI layer renders a scene it is handed. Nothing here reads a
## portrait path or a text size.
##
## The gating rule that matters: a condition can decide whether an offer is
## OFFERED. It can never decide the answer. Every choice in an offer stays
## available once the scene opens, so consent is always the player's explicit
## selection and never a threshold (docs/relationships.md).

class Scene extends RefCounted:
	var id: StringName
	var speaker_id: StringName
	var lines: PackedStringArray = PackedStringArray()
	## Each entry: {"id": StringName, "text": String, "response": String}
	var choices: Array[Dictionary] = []
	var requires: Dictionary = {}

	func has_choices() -> bool:
		return not choices.is_empty()

	func choice(choice_id: StringName) -> Dictionary:
		for c: Dictionary in choices:
			if StringName(String(c["id"])) == choice_id:
				return c
		return {}

var speaker_id: StringName
var _scenes: Dictionary = {}

static func load_from_file(path: String) -> DialogueScript:
	if not FileAccess.file_exists(path):
		push_error("DialogueScript: missing file %s" % path)
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueScript: %s is not a JSON object" % path)
		return null

	var data: Dictionary = parsed
	var script := DialogueScript.new()
	script.speaker_id = StringName(String(data.get("speaker_id", "")))
	if script.speaker_id == &"":
		push_error("DialogueScript: %s has no speaker_id" % path)
		return null

	var scenes: Variant = data.get("scenes", {})
	if typeof(scenes) != TYPE_DICTIONARY:
		push_error("DialogueScript: %s has no scenes object" % path)
		return null

	for scene_key: String in scenes:
		var raw: Variant = scenes[scene_key]
		if typeof(raw) != TYPE_DICTIONARY:
			push_error("DialogueScript: scene '%s' is not an object" % scene_key)
			return null
		var scene := Scene.new()
		scene.id = StringName(scene_key)
		scene.speaker_id = script.speaker_id
		for line: Variant in (raw as Dictionary).get("lines", []):
			scene.lines.append(String(line))
		if scene.lines.is_empty():
			push_error("DialogueScript: scene '%s' has no lines" % scene_key)
			return null
		scene.requires = (raw as Dictionary).get("requires", {})

		var seen_ids: Array[String] = []
		for choice: Variant in (raw as Dictionary).get("choices", []):
			var c: Dictionary = choice
			for field: String in ["id", "text", "response"]:
				if not c.has(field):
					push_error("DialogueScript: a choice in '%s' has no '%s'" % [scene_key, field])
					return null
			if seen_ids.has(String(c["id"])):
				push_error("DialogueScript: scene '%s' has duplicate choice id '%s'" % [scene_key, c["id"]])
				return null
			seen_ids.append(String(c["id"]))
			scene.choices.append(c)
		script._scenes[scene.id] = scene
	return script

func scene(scene_id: StringName) -> Scene:
	return _scenes.get(scene_id)

func scene_ids() -> Array:
	var ids: Array = _scenes.keys()
	ids.sort()
	return ids

## Whether the scene may be offered given the relationship right now.
func is_available(scene_id: StringName, state: RelationshipState) -> bool:
	var s: Scene = _scenes.get(scene_id)
	if s == null or state == null:
		return false
	var requires := s.requires
	if requires.has("alliance_accepted") and state.alliance_accepted != bool(requires["alliance_accepted"]):
		return false
	if requires.has("arc_state_at_least"):
		var needed := RelationshipState.ARC_NAMES.find(String(requires["arc_state_at_least"]))
		if needed < 0:
			push_error("DialogueScript: scene '%s' requires unknown arc state" % scene_id)
			return false
		if state.arc_state < needed:
			return false
	for dimension: String in ["trust", "respect", "fascination"]:
		var key := "%s_at_least" % dimension
		if requires.has(key) and int(state.get(dimension)) < int(requires[key]):
			return false
	return true

## An offer, once open, always presents every authored answer. There is no
## condition under which a refusal is unavailable.
func answers(scene_id: StringName) -> Array[StringName]:
	var s: Scene = _scenes.get(scene_id)
	var ids: Array[StringName] = []
	if s == null:
		return ids
	for c: Dictionary in s.choices:
		ids.append(StringName(String(c["id"])))
	return ids
