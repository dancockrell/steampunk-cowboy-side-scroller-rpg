class_name UiScenes
extends RefCounted
## Where the UI layer's scenes live, in one place.
##
## The application root instantiates these into its FULL-WINDOW UI layer, beside
## the 640x360 world SubViewport and never inside it
## (docs/architecture/engine-decision.md, "Composition contract").
##
## tests/ui/test_ui_scenes.gd diffs this list against the files actually in
## scenes/ui in both directions, so a scene added without a constant, or a
## constant left pointing at a deleted scene, fails rather than going unnoticed.

const DIRECTORY := "res://scenes/ui"

const HUD := "res://scenes/ui/hud.tscn"
const DIALOGUE := "res://scenes/ui/dialogue.tscn"
const PAUSE_MENU := "res://scenes/ui/pause_menu.tscn"
const INPUT_REMAP := "res://scenes/ui/input_remap.tscn"
const ACCESSIBILITY_OPTIONS := "res://scenes/ui/accessibility_options.tscn"

const ALL: Array[String] = [HUD, DIALOGUE, PAUSE_MENU, INPUT_REMAP, ACCESSIBILITY_OPTIONS]

## Loads and instantiates one UI scene. Returns null and says which scene failed,
## rather than handing back a half-built node.
static func instantiate(path: String) -> Control:
	var packed: Resource = load(path)
	if packed == null or not (packed is PackedScene):
		push_error("UiScenes.instantiate: %s did not load as a PackedScene" % path)
		return null
	var node: Node = (packed as PackedScene).instantiate()
	var control := node as Control
	if control == null:
		push_error("UiScenes.instantiate: %s does not have a Control root" % path)
		if node != null:
			node.free()
		return null
	return control
