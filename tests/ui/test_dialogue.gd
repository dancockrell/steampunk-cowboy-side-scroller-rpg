extends TestCase
## The dialogue scene: what it shows, what it refuses to show, what it emits, and
## whether its portrait seam escapes the low-resolution world filter.

var dialogue: Dialogue
var emitted: Array[StringName] = []

func before_each() -> void:
	dialogue = UiScenes.instantiate(UiScenes.DIALOGUE) as Dialogue
	# This repo's runner executes inside SceneTree._initialize, where the root
	# Window is not itself in the tree yet, so nothing added anywhere gets a
	# SceneTree and _ready never fires on its own. Notifying the node directly
	# runs exactly what the engine runs: the @onready resolution and the _ready
	# body. What CANNOT be checked this way is anything needing a live tree -
	# focus actually landing, and get_tree().paused - and those are named where
	# they come up rather than quietly asserted around.
	dialogue.notification(Node.NOTIFICATION_READY)
	emitted = []
	dialogue.choice_made.connect(func(id: StringName) -> void: emitted.append(id))

func after_each() -> void:
	if dialogue != null:
		dialogue.free()
		dialogue = null

func _offer() -> Array:
	return [
		{"id": "accept_alliance", "kind": "accept", "text": "Stand with you."},
		{"id": "defer_alliance", "kind": "defer", "text": "Let me think on it."},
		{"id": "decline_alliance", "kind": "decline", "text": "I walk alone."},
	]

func test_a_complete_offer_is_shown_with_all_three_answers() -> void:
	assert_true(dialogue.present("The Keeper of the Clay Dead", "Will you carry my quarrel?", _offer()),
		"a complete offer is presentable")
	assert_eq(dialogue.choice_ids().size(), 3, "accept, defer and decline all reach the screen")
	assert_eq(dialogue.speaker_text(), "The Keeper of the Clay Dead", "she is named")

func test_the_three_answers_are_told_apart_by_their_words() -> void:
	dialogue.present("The Keeper", "Well?", _offer())
	var texts := dialogue.choice_button_texts()
	assert_eq(texts.size(), 3, "three buttons")
	var unique: Dictionary = {}
	for text: String in texts:
		unique[text] = true
	assert_eq(unique.size(), 3, "no two options read the same: %s" % ", ".join(texts))

func test_choosing_reports_the_id_the_relationship_controller_will_act_on() -> void:
	dialogue.present("The Keeper", "Well?", _offer())
	assert_true(dialogue.select_choice(&"defer_alliance"), "the choice is on screen")
	assert_eq(emitted.size(), 1, "the id is emitted once, not twice")
	assert_eq(String(emitted[0]), "defer_alliance",
		"the id reaches the relationship controller; the dialogue decides nothing itself")

func test_deferring_and_declining_emit_different_ids() -> void:
	# They map to PAUSED and ENDED in RelationshipBook, which are not the same
	# future, so the UI must never collapse them into one answer.
	dialogue.present("The Keeper", "Well?", _offer())
	dialogue.select_choice(&"defer_alliance")
	dialogue.select_choice(&"decline_alliance")
	assert_eq(emitted.size(), 2, "both answers reported")
	assert_ne(emitted[0], emitted[1], "postponing is not refusing")

func test_an_offer_that_cannot_be_refused_is_not_shown_at_all() -> void:
	var partial: Array = [
		{"id": "accept_alliance", "kind": "accept", "text": "Yes."},
		{"id": "defer_alliance", "kind": "defer", "text": "Later."},
	]
	assert_false(dialogue.present("The Keeper", "Well?", partial),
		"docs/relationships.md requires decline; a half offer is refused")
	assert_false(dialogue.visible, "and nothing is put on screen, so it cannot be answered by accident")

func test_a_refused_beat_does_not_leave_the_previous_one_answerable() -> void:
	dialogue.present("The Keeper", "Well?", _offer())
	dialogue.present("The Keeper", "Well?", [{"id": "a", "kind": "accept", "text": "Yes."}])
	assert_eq(dialogue.choice_ids().size(), 3,
		"the refused beat changed nothing, so the beat still on screen is the one still valid")

func test_plain_narration_is_advanced_rather_than_chosen() -> void:
	assert_true(dialogue.present("", "The urns watch you pass.", []), "a line with no choices is valid")
	assert_eq(dialogue.choice_ids().size(), 0, "and offers nothing to choose")
	assert_true(dialogue.get_node("%AdvanceHint").visible, "it says how to move on instead")

func test_a_stale_choice_id_cannot_resolve_an_offer() -> void:
	dialogue.present("The Keeper", "Well?", _offer())
	assert_false(dialogue.select_choice(&"accept_romance"),
		"an id that is not on screen is refused rather than emitted")
	assert_eq(emitted.size(), 0, "and nothing reaches the relationship controller")

func test_every_answer_can_be_reached_without_a_mouse() -> void:
	# That focus actually LANDS is not provable headlessly (no live tree), so
	# what is checked is the part that is: every option accepts focus, which is
	# what keyboard and gamepad navigation walks.
	dialogue.present("The Keeper", "Well?", _offer())
	var list: VBoxContainer = dialogue.get_node("%ChoiceList")
	assert_eq(list.get_child_count(), 3, "three focusable options exist")
	for child: Node in list.get_children():
		var button := child as Button
		assert_not_null(button, "each option is a button, not a label")
		assert_eq(button.focus_mode, Control.FOCUS_ALL,
			"'%s' can be reached by keyboard and gamepad focus" % button.text)

func test_the_portrait_seam_does_not_inherit_the_worlds_nearest_filter() -> void:
	# docs/art-direction.md: "No forced low-resolution filter on the portrait
	# layer." project.godot sets the project-wide default to nearest for the
	# 640x360 world, so inheriting it here is exactly the mistake to catch.
	var seam: TextureRect = dialogue.get_node("%PortraitSeam")
	assert_ne(seam.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST,
		"a high-detail portrait must not be resampled to world pixels")
	assert_ne(seam.texture_filter, CanvasItem.TEXTURE_FILTER_PARENT_NODE,
		"and it must not inherit the project default, which is nearest")

func test_the_portrait_seam_is_empty_because_no_portrait_art_exists() -> void:
	var seam: TextureRect = dialogue.get_node("%PortraitSeam")
	assert_null(seam.texture, "the seam is a named placeholder, not an approved asset")
	assert_false(dialogue.has_portrait(), "and the scene says so rather than implying art is present")

func test_a_portrait_can_be_supplied_later_without_touching_the_scene() -> void:
	var texture := PlaceholderTexture2D.new()
	dialogue.set_portrait(texture)
	assert_true(dialogue.has_portrait(), "the seam accepts art when it exists")
	assert_true(dialogue.get_node("%PortraitSeam").visible, "and shows it")
	dialogue.set_portrait(null)
	assert_false(dialogue.get_node("%PortraitSeam").visible, "and hides again when there is none")

func test_larger_dialogue_text_does_not_change_the_words() -> void:
	dialogue.present("The Keeper", "Will you carry my quarrel?", _offer())
	var before := dialogue.choice_button_texts()
	dialogue.set_text_scale(2.0)
	assert_almost_eq(dialogue.text_scale(), 2.0, 0.001, "the scale is applied")
	assert_eq(dialogue.choice_button_texts(), before, "and every option still says the same thing")

func test_an_absurd_text_scale_is_clamped_rather_than_making_dialogue_unusable() -> void:
	dialogue.set_text_scale(50.0)
	assert_almost_eq(dialogue.text_scale(), AccessibilitySettings.TEXT_SCALE_MAX, 0.001,
		"text scaling has a ceiling")

func test_captions_are_what_the_subtitle_setting_governs_not_the_spoken_line() -> void:
	# There is no voice track, so hiding the spoken line would make the game
	# unplayable. The setting turns off captions for non-speech cues instead.
	var settings := AccessibilitySettings.new("user://test_dialogue_accessibility.json")
	settings.subtitles_enabled = false
	dialogue.apply_accessibility(settings)
	dialogue.present("The Keeper", "You broke it.", [])
	dialogue.set_caption("[clay grinding behind the wall]")
	assert_eq(dialogue.body_text(), "You broke it.", "her line is always readable")
	assert_false(dialogue.caption_visible(), "the sound-cue caption is what turns off")
	settings.subtitles_enabled = true
	dialogue.apply_accessibility(settings)
	assert_true(dialogue.caption_visible(), "and comes back on")
	settings.clear_saved()
