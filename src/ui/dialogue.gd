class_name Dialogue
extends Control
## Speaker, body text, an optional full-window portrait seam, and the choices.
##
## Composition: this scene belongs to the FULL-WINDOW UI layer, never inside the
## 640x360 world SubViewport. `%PortraitSeam` therefore sets its own
## `texture_filter` to a linear mode rather than inheriting the project's
## nearest-neighbour default, because docs/art-direction.md requires "no forced
## low-resolution filter on the portrait layer" and the goddess portraits must
## not collapse to world pixels. tests/ui/test_dialogue.gd asserts that.
##
## The scene EMITS INTENT. It never resolves an offer: it reports the id the
## player chose and the relationship controller decides what that means
## (docs/architecture/engine-decision.md ownership table).
##
## NO ART EXISTS. `%PortraitSeam` is an empty TextureRect kept as a named seam
## for portrait art that has not been made, and it is not an approved asset.

signal choice_made(choice_id: StringName)
signal advanced()
signal closed()

@onready var _scrim: Panel = %Scrim
@onready var _portrait_seam: TextureRect = %PortraitSeam
@onready var _box: PanelContainer = %DialogueBox
@onready var _speaker_label: Label = %SpeakerLabel
@onready var _body_label: Label = %BodyLabel
@onready var _choice_list: VBoxContainer = %ChoiceList
@onready var _advance_hint: Label = %AdvanceHint
@onready var _caption_label: Label = %CaptionLabel

var _services: Services
var _choices: Array[DialogueChoice] = []
var _buttons: Dictionary = {}
var _text_scale: float = 1.0
var _subtitles_enabled: bool = true

func _ready() -> void:
	visible = false
	_portrait_seam.visible = _portrait_seam.texture != null
	_caption_label.visible = false
	_style()

func bind(services: Services) -> void:
	_services = services

# --- public API ---------------------------------------------------------------

## Shows one dialogue beat. `choices` is an array of dictionaries shaped
## {"id": StringName, "kind": StringName, "text": String}; `kind` is one of
## DialogueChoice's CONTINUE / ACCEPT / DEFER / DECLINE.
##
## Returns false and shows NOTHING when the choice set is invalid, because a
## half-presented offer is worse than a missing one: docs/relationships.md
## requires that every offer allow accept, defer and decline, and a UI that
## quietly dropped one would look like an authored refusal to offer it.
func present(speaker: String, body: String, choices: Array = []) -> bool:
	var built := DialogueChoice.build_list(choices)
	if built.size() != choices.size():
		push_error("Dialogue.present: %d of %d choices failed to build. Nothing shown."
			% [choices.size() - built.size(), choices.size()])
		return false
	var error := DialogueChoice.validation_error(built)
	if error != "":
		push_error("Dialogue.present: refusing to show this beat. %s" % error)
		return false

	_choices = built
	_speaker_label.text = speaker
	_speaker_label.visible = speaker.strip_edges() != ""
	_body_label.text = body
	_rebuild_choice_buttons()
	visible = true
	_advance_hint.visible = built.is_empty()
	_focus_first()
	return true

func close() -> void:
	visible = false
	_choices.clear()
	_clear_choice_buttons()
	closed.emit()

## The optional portrait. Passing null leaves the seam empty and hidden, which is
## the current state of the project: no portrait art exists.
func set_portrait(texture: Texture2D) -> void:
	_portrait_seam.texture = texture
	_portrait_seam.visible = texture != null

func has_portrait() -> bool:
	return _portrait_seam.texture != null

## Activates a choice by id, the same path a click or a gamepad press takes.
## Returns false for an id that is not on screen, so a stale id cannot silently
## resolve an offer.
func select_choice(choice_id: StringName) -> bool:
	for choice: DialogueChoice in _choices:
		if choice.id == choice_id:
			choice_made.emit(choice_id)
			return true
	push_error("Dialogue.select_choice: '%s' is not one of the presented choices" % choice_id)
	return false

func choice_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for choice: DialogueChoice in _choices:
		ids.append(choice.id)
	return ids

func choice_button_texts() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for choice: DialogueChoice in _choices:
		var button: Button = _buttons.get(choice.id)
		if button != null:
			out.append(button.text)
	return out

func speaker_text() -> String:
	return _speaker_label.text

func body_text() -> String:
	return _body_label.text

## A caption for a non-speech cue - a scrape behind a wall, a bell still ringing.
## This is the thing the "subtitles" accessibility setting actually governs;
## spoken lines are always shown, because there is no voice track to read them
## from. Setting subtitles off hides captions and nothing else.
func set_caption(text: String) -> void:
	_caption_label.text = text
	_caption_label.visible = _subtitles_enabled and text.strip_edges() != ""

func caption_text() -> String:
	return _caption_label.text

func caption_visible() -> bool:
	return _caption_label.visible

func apply_accessibility(settings: AccessibilitySettings) -> void:
	if settings == null:
		return
	_subtitles_enabled = settings.subtitles_enabled
	set_caption(_caption_label.text)
	set_text_scale(settings.dialogue_text_scale)

func set_text_scale(scale: float) -> void:
	_text_scale = clampf(scale, AccessibilitySettings.TEXT_SCALE_MIN, AccessibilitySettings.TEXT_SCALE_MAX)
	_style()
	_restyle_buttons()

func text_scale() -> float:
	return _text_scale

# --- input --------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not event.is_action_pressed(GameActions.DIALOGUE_ADVANCE):
		return
	# A beat carrying choices is answered by choosing, never by advancing past it.
	if not _choices.is_empty():
		return
	get_viewport().set_input_as_handled()
	advanced.emit()

# --- internals ----------------------------------------------------------------

func _scaled(size: int) -> int:
	return maxi(int(round(float(size) * _text_scale)), 8)

func _style() -> void:
	_scrim.add_theme_stylebox_override("panel", UiPalette.scrim())
	_box.add_theme_stylebox_override("panel", UiPalette.plate())
	UiPalette.apply_label_style(_speaker_label, UiPalette.BRASS, _scaled(UiPalette.FONT_SIZE_TITLE))
	UiPalette.apply_label_style(_body_label, UiPalette.BONE, _scaled(UiPalette.FONT_SIZE_BODY))
	UiPalette.apply_label_style(_advance_hint, UiPalette.ASH, _scaled(UiPalette.FONT_SIZE_SMALL))
	UiPalette.apply_label_style(_caption_label, UiPalette.ASH, _scaled(UiPalette.FONT_SIZE_SMALL))
	_advance_hint.text = "%s to continue" % BindingStore.describe_action(GameActions.DIALOGUE_ADVANCE)

func _clear_choice_buttons() -> void:
	for child: Node in _choice_list.get_children():
		_choice_list.remove_child(child)
		child.queue_free()
	_buttons.clear()

func _rebuild_choice_buttons() -> void:
	_clear_choice_buttons()
	for choice: DialogueChoice in _choices:
		var button := Button.new()
		button.name = "Choice_%s" % choice.id
		button.text = choice.button_text()
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		UiPalette.apply_button_style(button)
		button.add_theme_font_size_override("font_size", _scaled(UiPalette.FONT_SIZE_BODY))
		var id := choice.id
		button.pressed.connect(func() -> void: choice_made.emit(id))
		_choice_list.add_child(button)
		_buttons[choice.id] = button

func _restyle_buttons() -> void:
	for id: StringName in _buttons.keys():
		var button: Button = _buttons[id]
		button.add_theme_font_size_override("font_size", _scaled(UiPalette.FONT_SIZE_BODY))

## Keyboard and gamepad first: something is always focused, so a player who never
## touches the mouse can answer. Godot's own focus neighbours walk the VBox.
func _focus_first() -> void:
	if _choices.is_empty():
		return
	var first: Button = _buttons.get(_choices[0].id)
	if first != null and first.is_inside_tree():
		first.grab_focus()
