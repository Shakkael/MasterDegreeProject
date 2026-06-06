extends Control

func _ready() -> void:
	Website.data_for_json = {"current":-1}
	Globals.go_to_scene()

func _on_levels_menu_main() -> void:
	%MainMenu.visible = true

func _on_main_menu_test() -> void:
	%LevelsMenu.visible = true
