extends LevelHandler

## Jeśli przycisk MainButton zostanie wciśnięty
func _on_main_button_pressed() -> void:
	Globals.unlock_level(0,1)

## Jeśli zostanie naciśnięty jakiś klawisz na klawiaturze
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_tab"): ## Jeśli ten klawisz to akcja 'next_tab' (klawisz "x")
		if !%HiddenContainer.select_next_available(): ## Przełącz do następnej zakładki
			%HiddenContainer.current_tab = 0
