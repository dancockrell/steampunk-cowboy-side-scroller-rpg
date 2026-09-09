extends TestCase
## The UI scenes themselves load, instantiate and carry the script they claim to.
##
## tools/check-gdscript.sh parses .gd files and cannot see a .tscn at all, so a
## scene with a renamed node, a missing unique name or a broken script path would
## pass every other check in this repo and fail only when someone ran the game.
## Instantiating each scene here is what closes that gap: every root's _ready
## resolves its own %Names, so a scene that has drifted from its script fails
## loudly at test time.

func test_every_named_scene_loads_and_instantiates() -> void:
	assert_eq(UiScenes.ALL.size(), 5, "five UI scenes are under test")
	for path: String in UiScenes.ALL:
		var node := UiScenes.instantiate(path)
		assert_not_null(node, "%s loads as a Control" % path)
		if node != null:
			node.free()

func test_the_scene_list_matches_the_files_on_disk_in_both_directions() -> void:
	# One direction alone would pass while a scene sat in the folder that nothing
	# ever instantiates or tests.
	var on_disk: Array[String] = []
	for file_name: String in DirAccess.get_files_at(UiScenes.DIRECTORY):
		if file_name.ends_with(".tscn"):
			on_disk.append(UiScenes.DIRECTORY.path_join(file_name))
	on_disk.sort()
	assert_true(on_disk.size() >= 5, "the folder really was read (%d scenes found)" % on_disk.size())
	var declared: Array[String] = UiScenes.ALL.duplicate()
	declared.sort()
	assert_eq(declared, on_disk, "no scene is missing from the list and none is listed but absent")

func test_each_scene_root_is_the_class_the_owner_will_wire() -> void:
	var expectations: Dictionary = {
		UiScenes.HUD: "Hud",
		UiScenes.DIALOGUE: "Dialogue",
		UiScenes.PAUSE_MENU: "PauseMenu",
		UiScenes.INPUT_REMAP: "InputRemap",
		UiScenes.ACCESSIBILITY_OPTIONS: "AccessibilityOptions",
	}
	for path: String in expectations.keys():
		var node := UiScenes.instantiate(path)
		assert_not_null(node, "%s instantiates" % path)
		if node == null:
			continue
		assert_eq(node.name, String(expectations[path]),
			"%s has the root node name the composition contract expects" % path)
		assert_true(node.has_method("bind"),
			"%s takes its services by typed reference, since there is no autoload" % path)
		node.free()
