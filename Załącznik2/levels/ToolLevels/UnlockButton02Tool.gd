extends UnlockButton

func _on_pressed() -> void:
	if InputCheck.text == "F26?A!@L":
		%MainButton.disabled = false
		Website.data_for_json.set("puzzle_output", "Przycisk odblokowania kategorii w zakładce Narzędzia (B side) został odblokowany")
	else:
		super()
