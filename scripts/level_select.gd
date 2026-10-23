extends Control


func _ready() -> void:
	var items: Array = []
	# Original had no per-level scenes (LoadScene("") TODO), so every level loads the same one
	for i in range(1, 4):
		items.append(UI.button("MainMenu-Selectlevel%d" % i, func() -> void: get_tree().change_scene_to_file("res://scenes/game.tscn")))
	items.append(UI.button("MainMenu-Back", func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu.tscn")))
	add_child(UI.page(items))
