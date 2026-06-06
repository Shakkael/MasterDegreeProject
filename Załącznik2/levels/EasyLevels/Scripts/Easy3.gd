extends LevelHandler

func _ready() -> void:
	if puzzle_input:
		Website.POST_received.connect(_post_receive_attempt)
	super()
	
func _post_receive_attempt(result : Variant):
	if str(result.get("answer")).to_upper() == "893HA".to_upper():
		Website.data_for_json.set("correct", true)
		%MainButton.disabled = false
		Website.data_for_json.set("puzzle_output", "Gratulacje, skończyłeś kategorię. Jak myślisz, czy to koniec?")
	else:
		Website.data_for_json.set("correct", false)


func _on_main_button_pressed() -> void:
	Globals.unlock_level(1,3)
