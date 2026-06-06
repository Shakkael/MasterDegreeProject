extends Panel

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_tab"):
		if !%HiddenContainer.select_next_available():
			%HiddenContainer.current_tab = 0
			
