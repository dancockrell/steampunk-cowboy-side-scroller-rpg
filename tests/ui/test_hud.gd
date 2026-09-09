extends TestCase
## The HUD scene, driven through its public setters exactly as the owner will.
##
## The HUD is a mirror: nothing here gives it state of its own, and every
## assertion asks what is on the labels rather than what the script remembers.

var hud: Hud

func before_each() -> void:
	hud = UiScenes.instantiate(UiScenes.HUD) as Hud
	# This repo's runner executes inside SceneTree._initialize, where the root
	# Window is not itself in the tree yet, so nothing added anywhere gets a
	# SceneTree and _ready never fires on its own. Notifying the node directly
	# runs exactly what the engine runs: the @onready resolution and the _ready
	# body. What CANNOT be checked this way is anything needing a live tree -
	# focus actually landing, and get_tree().paused - and those are named where
	# they come up rather than quietly asserted around.
	hud.notification(Node.NOTIFICATION_READY)

func after_each() -> void:
	if hud != null:
		hud.free()
		hud = null

func test_the_hud_shows_a_slot_for_each_of_the_four_tools() -> void:
	for tool_id: StringName in HudFormat.slot_order():
		assert_ne(hud.slot_text(tool_id), "", "'%s' has a slot on screen" % tool_id)

func test_only_the_equipped_tool_is_marked() -> void:
	hud.set_equipped(&"shotgun")
	assert_eq(hud.slot_text(&"shotgun"), HudFormat.slot_label(&"shotgun", true), "the shotgun is marked")
	for tool_id: StringName in HudFormat.slot_order():
		if tool_id == &"shotgun":
			continue
		assert_eq(hud.slot_text(tool_id), HudFormat.slot_label(tool_id, false),
			"'%s' is not also marked" % tool_id)

func test_switching_tools_moves_the_mark() -> void:
	hud.set_equipped(&"pistol")
	hud.set_equipped(&"rifle")
	assert_eq(hud.slot_text(&"pistol"), HudFormat.slot_label(&"pistol", false),
		"the previous tool stops being marked, so two tools never look equipped at once")

func test_the_ammo_readout_follows_the_equipped_firearm() -> void:
	hud.set_ammo(&"pistol", 4, 6)
	hud.set_ammo(&"rifle", 1, 4)
	hud.set_equipped(&"pistol")
	assert_eq(hud.ammo_text(), "PISTOL  4 / 6", "the equipped pistol's magazine is shown")
	hud.set_equipped(&"rifle")
	assert_eq(hud.ammo_text(), "RIFLE  1 / 4", "switching shows the rifle's, not a stale pistol count")

func test_equipping_the_lasso_shows_no_magazine() -> void:
	hud.set_equipped(&"lasso")
	assert_true(hud.ammo_text().contains("no ammunition"),
		"the identity tool has none, and that is not an empty magazine: %s" % hud.ammo_text())

func test_a_tool_the_project_does_not_have_cannot_be_equipped() -> void:
	hud.set_equipped(&"pistol")
	hud.set_equipped(&"flamethrower")
	assert_eq(String(hud.equipped()), "pistol",
		"an unknown tool id is refused and the previous tool stays equipped")

func test_the_intervention_shows_its_reason_when_it_is_unavailable() -> void:
	hud.set_intervention_available(false, "no eligible dead in reach")
	assert_true(hud.intervention_text().contains("no eligible dead in reach"),
		"docs/relationships.md requires clear unavailable feedback on screen: %s" % hud.intervention_text())
	assert_true(hud.intervention_text().contains("UNAVAILABLE"), "and it says so in a word")

func test_the_intervention_reads_as_ready_when_it_is_available() -> void:
	hud.set_intervention_available(true, "")
	assert_true(hud.intervention_text().contains("READY"), "an available ability says READY")
	assert_false(hud.intervention_text().contains("UNAVAILABLE"), "and does not also say the opposite")

func test_the_intervention_preview_seam_is_empty_because_no_portrait_art_exists() -> void:
	var seam: TextureRect = hud.get_node("%InterventionPreviewSeam")
	assert_not_null(seam, "the seam is present and named, ready for art that has not been made")
	assert_null(seam.texture, "and it is empty: nothing here is an approved asset")

func test_the_preview_words_stand_in_for_the_art_that_does_not_exist() -> void:
	hud.set_intervention_preview("Returns one weakened dead to its vessel for a moment.")
	assert_true(hud.get_node("%InterventionPreviewLabel").visible,
		"until preview art exists, the preview is words and it is shown")

func test_health_reaches_the_screen_with_its_pips() -> void:
	hud.set_health(2, 5)
	assert_eq(hud.health_text(), HudFormat.health_line(2, 5), "the health line is on screen")
	assert_eq(hud.get_node("%HealthPips").text, "**...", "and the pip shape with it")

func test_the_hud_never_swallows_the_players_clicks() -> void:
	assert_eq(hud.mouse_filter, Control.MOUSE_FILTER_IGNORE,
		"the HUD sits over the world and must not eat an aimed shot")

func test_the_keepers_standing_appears_in_words_once_she_is_bound() -> void:
	var services := Services.new()
	var keeper := Heroine.load_from_file("res://narrative/characters/keeper_of_the_clay_dead.json")
	services.relationships.register(keeper)
	hud.bind(services)
	services.relationships.mark_encountered(keeper.id)
	assert_true(hud.standing_text().contains("Keeper"),
		"a met goddess is named in words: '%s'" % hud.standing_text())
	services.free()

func test_scaling_the_text_does_not_change_what_it_says() -> void:
	hud.set_equipped(&"pistol")
	hud.set_ammo(&"pistol", 6, 6)
	var before := hud.ammo_text()
	hud.set_text_scale(2.0)
	assert_eq(hud.ammo_text(), before, "larger type shows the same reading, not a different one")
