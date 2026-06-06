extends LevelHandler

## zignoruj ostrzeżenie o nieużytym parametrze delta
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	## zapisz w zmiennej difference różnicę pozycji na ekranie okna Narzędzia i gry głównej
	var difference = Globals.tool_level_pos - get_window().position
	Website.data_for_json.set("puzzle_output", str(difference)) ## Wyślij difference do API jako wskazówkę
	
	## Odblokuj przycisk jeśli różnica w pozycji okien zawiera się w danym zakresie
	if difference.x >= 10 and difference.x <= 60 and difference.y >= -150 and difference.y <=-75:
		%MainButton.disabled = false
	else:
		%MainButton.disabled = true

func _on_main_button_pressed() -> void:
	Globals.unlock_level(1,4)
