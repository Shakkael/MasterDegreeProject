extends Panel

func _ready() -> void:
	await get_tree().process_frame
	Website.unlock.connect(unlock)
	%UnlockButton.Password = Globals.cur_password

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_tab"):
		if !%HiddenContainer.select_next_available():
			%HiddenContainer.current_tab = 0
			
# F26?A!@

func unlock(unlock_name : String):
	print("Unlock:", unlock_name)
	if unlock_name.to_upper() == "ES02Tool".to_upper():
		%MainButton.disabled = false


func _on_main_button_pressed() -> void:
	Globals.unlock_level(2,0)
