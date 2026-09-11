extends TestCase
## The UI's action list must be a mirror of project.godot, not a second opinion.
##
## Diffed in BOTH directions on purpose. Checking only that every offered action
## exists would pass happily while an action the project defines has no remap row
## at all, which is the half that goes unnoticed (docs/gameplay-pillars.md asks
## for remapping, not for remapping of most things).

func test_every_offered_action_exists_in_the_project() -> void:
	var missing: PackedStringArray = PackedStringArray()
	for action: StringName in GameActions.ALL:
		if not InputMap.has_action(action):
			missing.append(String(action))
	assert_eq(GameActions.ALL.size(), 13, "the project defines thirteen gameplay actions")
	assert_eq(", ".join(missing), "", "the UI must not offer an action the project does not define")

func test_every_project_action_is_offered_for_remapping() -> void:
	var offered: Array[String] = []
	for action: StringName in GameActions.ALL:
		offered.append(String(action))
	offered.sort()
	var declared: Array[String] = []
	for action: StringName in GameActions.project_actions():
		declared.append(String(action))
	declared.sort()
	assert_true(declared.size() >= 13, "the running project really does declare its actions (%d found)" % declared.size())
	assert_eq(offered, declared, "an action the project defines must have a remap row, not be silently skipped")

func test_the_groups_cover_every_action_exactly_once() -> void:
	var grouped: Array[String] = []
	for group: Dictionary in GameActions.GROUPS:
		for action: Variant in group["actions"] as Array:
			grouped.append(String(action))
	assert_eq(grouped.size(), GameActions.ALL.size(), "no action is grouped twice and none is dropped")
	grouped.sort()
	var expected: Array[String] = []
	for action: StringName in GameActions.ALL:
		expected.append(String(action))
	expected.sort()
	assert_eq(grouped, expected, "the remap screen's groups reach every action")

func test_every_action_has_a_readable_label() -> void:
	for action: StringName in GameActions.ALL:
		var label := GameActions.label_for(action)
		assert_ne(label, String(action), "'%s' has a human label, not its raw id" % action)

func test_releasing_lets_go_of_an_action_that_was_being_held() -> void:
	Input.action_press(GameActions.JUMP)
	assert_true(Input.is_action_pressed(GameActions.JUMP),
		"positive control: the action really was held before the release")
	GameActions.release_all()
	assert_false(Input.is_action_pressed(GameActions.JUMP),
		"no sticky input: a held action is let go, so it cannot fire when play resumes")

func test_releasing_lets_go_of_every_action_not_only_the_first() -> void:
	for action: StringName in GameActions.ALL:
		Input.action_press(action)
	GameActions.release_all()
	var still_held: PackedStringArray = PackedStringArray()
	for action: StringName in GameActions.ALL:
		if Input.is_action_pressed(action):
			still_held.append(String(action))
	assert_eq(", ".join(still_held), "", "every gameplay action is released, not just one of them")
