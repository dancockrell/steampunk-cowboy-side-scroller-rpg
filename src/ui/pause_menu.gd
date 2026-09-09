class_name PauseMenu
extends Control
## Pause. Stops the tree, and lets go of every held action while it does.
##
## Two separate requirements meet here:
##
## - docs/gameplay-pillars.md: "Pause stops combat, emergence timers and aiming."
##   That is `get_tree().paused`, plus this node's own process_mode of
##   WHEN_PAUSED so the menu keeps running while everything else does not.
## - docs/weapon-tool-kit.md: "No sticky input after pause or focus loss." A key
##   held at the moment of pausing stays pressed on its own and fires the instant
##   play resumes, so the menu releases every gameplay action when it opens, when
##   it closes, and when the window loses focus. Focus loss is handled through a
##   MainLoop notification, which reaches this node even while it is not
##   processing.
##
## OPENING IS NOT THIS NODE'S JOB. With process_mode WHEN_PAUSED it cannot see
## input while the game is running, so whoever owns the tree calls `toggle()` on
## the pause action. The menu owns closing itself.
##
## NO ART EXISTS. Plate and buttons are StyleBoxFlat from UiPalette.

const INPUT_REMAP_PANEL := &"input_remap"
const ACCESSIBILITY_PANEL := &"accessibility"

signal paused()
signal resumed()
signal options_requested(panel: StringName)
signal quit_requested()

@onready var _scrim: Panel = %Scrim
@onready var _plate: PanelContainer = %MenuPlate
@onready var _title: Label = %TitleLabel
@onready var _resume_button: Button = %ResumeButton
@onready var _controls_button: Button = %ControlsButton
@onready var _accessibility_button: Button = %AccessibilityButton
@onready var _quit_button: Button = %QuitButton

var _services: Services

func _ready() -> void:
	visible = false
	_style()
	_resume_button.pressed.connect(close)
	_controls_button.pressed.connect(func() -> void: options_requested.emit(INPUT_REMAP_PANEL))
	_accessibility_button.pressed.connect(func() -> void: options_requested.emit(ACCESSIBILITY_PANEL))
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())

func bind(services: Services) -> void:
	_services = services

# --- public API ---------------------------------------------------------------

## Returns whether the GAME was actually stopped, not whether the menu appeared.
## A menu that is showing while the world keeps running is the failure worth
## hearing about, and it is silent otherwise.
func open() -> bool:
	if visible:
		return _game_is_stopped()
	# Release BEFORE pausing: a held action must not survive into the paused tree.
	GameActions.release_all()
	visible = true
	var stopped := _set_tree_paused(true)
	if _resume_button.is_inside_tree():
		_resume_button.grab_focus()
	paused.emit()
	return stopped

## Returns whether the game was actually started again.
func close() -> bool:
	if not visible:
		return not _game_is_stopped()
	visible = false
	var started := _set_tree_paused(false)
	# Release AFTER unpausing too: whatever the player was holding while the menu
	# was up must not arrive as a fresh press on the first unpaused frame.
	GameActions.release_all()
	resumed.emit()
	return started

func toggle() -> bool:
	if visible:
		return close()
	return open()

func _game_is_stopped() -> bool:
	return is_inside_tree() and get_tree().paused

## The one place the world is stopped and started. Says so loudly when it cannot,
## because "the menu is up" and "the game is paused" are different facts and only
## the second one protects the player.
func _set_tree_paused(value: bool) -> bool:
	if not is_inside_tree():
		push_warning("PauseMenu: not inside a SceneTree, so the game was NOT %s."
			% ["paused" if value else "resumed"])
		return false
	get_tree().paused = value
	return true

func is_open() -> bool:
	return visible

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(GameActions.PAUSE):
		get_viewport().set_input_as_handled()
		close()

## Losing the window is the other way an action gets stuck down. The player never
## sends a release for a key they let go of while alt-tabbed.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			GameActions.release_all()

# --- internals ----------------------------------------------------------------

func _style() -> void:
	_scrim.add_theme_stylebox_override("panel", UiPalette.scrim())
	_plate.add_theme_stylebox_override("panel", UiPalette.plate())
	UiPalette.apply_label_style(_title, UiPalette.BRASS, UiPalette.FONT_SIZE_TITLE)
	for button: Button in [_resume_button, _controls_button, _accessibility_button, _quit_button]:
		UiPalette.apply_button_style(button)
		button.focus_mode = Control.FOCUS_ALL
