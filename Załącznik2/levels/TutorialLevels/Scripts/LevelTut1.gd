extends LevelHandler

var newPassword := str(randi())

func _on_main_button_pressed() -> void:
	Globals.unlock_level(0,1)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_tab"):
		if !%HiddenContainer.select_next_available():
			%HiddenContainer.current_tab = 0

func _on_extra_button_pressed() -> void:
	Globals.unlock_level(1,0)


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "Thanks4TakingPartInThisProject":
		Globals.go_to_scene(2)
