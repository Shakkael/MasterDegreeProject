extends LevelHandler

func _on_main_button_pressed() -> void:
	Globals.unlock_level(0,4)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_tab"):
		Website.data_for_json.set("puzzle_output", "Możesz wrócić klikając 'x' ponownie.")
		if !%HiddenContainer.select_next_available():
			%HiddenContainer.current_tab = 0
			

func _on_button_unlock_button() -> void:
	%VBoxOrder.visible = true
