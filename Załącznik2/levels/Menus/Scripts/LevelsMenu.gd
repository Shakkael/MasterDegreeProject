extends Control

func _ready() -> void:
	Website.data_for_json = {"current" : -1}
	for category in Globals.unlocked_levels.keys():
		var cat : VBoxContainer = %LevelsVBox.get_node("%Cat{category}".format({"category" : category}))
		if Globals.unlocked_levels[category]:
			cat.visible = true
		else:
			cat.visible = false
	pass

func _on_quit_pressed() -> void:
	Globals.go_to_scene()

func _on_hide_pressed() -> void:
	for dif_level : Control in %LevelsVBox.get_children():
		dif_level.on_difficulty_toggled(false)

func _go_to_level_pressed(category : int, level : int) -> void:
	print("Attempt to start level: %d from category %s" % [level, Globals.categories[category]])
	print(get_tree().change_scene_to_file(Globals.levels[category][level]))
