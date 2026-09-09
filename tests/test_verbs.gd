extends TestCase
## Cosmetic props must not secretly inherit interactions, so the verb table is
## checked for the one-tool-one-verb property it is supposed to guarantee.

func test_every_tool_maps_to_a_known_verb() -> void:
	for tool_id: StringName in Verbs.TOOL_VERB:
		assert_true(Verbs.is_known(Verbs.TOOL_VERB[tool_id]),
			"tool '%s' maps to a verb in the known set" % tool_id)

func test_all_four_tools_are_present() -> void:
	for tool_id: StringName in [&"lasso", &"pistol", &"shotgun", &"rifle"]:
		assert_true(Verbs.TOOL_VERB.has(tool_id), "tool '%s' has an authored verb" % tool_id)

func test_the_three_firearms_emit_distinct_verbs() -> void:
	var seen: Array[StringName] = []
	for tool_id: StringName in [&"pistol", &"shotgun", &"rifle"]:
		var verb: StringName = Verbs.TOOL_VERB[tool_id]
		assert_false(seen.has(verb), "firearm '%s' has its own physical verb, not a shared one" % tool_id)
		seen.append(verb)

func test_an_invented_verb_is_not_known() -> void:
	assert_false(Verbs.is_known(&"disintegrate"), "the verb set is closed")
