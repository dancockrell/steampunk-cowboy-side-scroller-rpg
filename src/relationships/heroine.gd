class_name Heroine
extends RefCounted
## Authored heroine record. Fields follow docs/data-contracts.md.
##
## `adult` is required to be true and is validated on load rather than assumed:
## every romanceable character in this project is an explicitly adult woman
## (docs/relationships.md, AGENTS.md).

var id: StringName
var display_name: String
var domain: String
var agenda: String
var boundaries: PackedStringArray = PackedStringArray()
var portrait_set_id: StringName
var manifestation_set_id: StringName
var intervention_id: StringName
var offer_scene_ids: Dictionary = {}
## event_id -> {"trust": int, "respect": int, "fascination": int, "line_id": String}
var judgment_rules: Dictionary = {}

static func load_from_file(path: String) -> Heroine:
	if not FileAccess.file_exists(path):
		push_error("Heroine.load_from_file: missing file %s" % path)
		return null
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Heroine.load_from_file: %s is not a JSON object" % path)
		return null
	return from_dictionary(parsed as Dictionary, path)

static func from_dictionary(data: Dictionary, source: String = "<inline>") -> Heroine:
	for required: String in ["id", "adult", "display_name", "domain", "agenda", "judgment_rules"]:
		if not data.has(required):
			push_error("Heroine %s: missing required field '%s'" % [source, required])
			return null
	if data["adult"] != true:
		push_error("Heroine %s: 'adult' must be true. Refusing to load." % source)
		return null

	var h := Heroine.new()
	h.id = StringName(String(data["id"]))
	h.display_name = String(data["display_name"])
	h.domain = String(data["domain"])
	h.agenda = String(data["agenda"])
	h.portrait_set_id = StringName(String(data.get("portrait_set_id", "")))
	h.manifestation_set_id = StringName(String(data.get("manifestation_set_id", "")))
	h.intervention_id = StringName(String(data.get("intervention_id", "")))
	for b: Variant in data.get("boundaries", []):
		h.boundaries.append(String(b))
	for key: String in data.get("offer_scene_ids", {}):
		h.offer_scene_ids[StringName(key)] = String(data["offer_scene_ids"][key])

	var rules: Variant = data["judgment_rules"]
	if typeof(rules) != TYPE_DICTIONARY:
		push_error("Heroine %s: judgment_rules must be an object" % source)
		return null
	for event_key: String in rules:
		var rule: Variant = rules[event_key]
		if typeof(rule) != TYPE_DICTIONARY:
			push_error("Heroine %s: judgment rule '%s' must be an object" % [source, event_key])
			return null
		var rule_dict: Dictionary = rule
		if not rule_dict.has("line"):
			push_error("Heroine %s: judgment rule '%s' has no spoken line" % [source, event_key])
			return null
		h.judgment_rules[StringName(event_key)] = rule_dict
	return h

func judgment_for(event_id: StringName) -> Dictionary:
	return judgment_rules.get(event_id, {})
