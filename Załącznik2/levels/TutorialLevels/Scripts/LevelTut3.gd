extends LevelHandler

var password = str(randi())

func _ready() -> void:
	## puzzle_output to zmienna klasy LevelHandler
	puzzle_output = "Hasło to: "+ password
	%UnlockButton.Password = password
	super()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("website"):
		OS.shell_open("http://127.0.0.1:8080/tips.html")
		

func _on_main_button_pressed() -> void:
	Globals.unlock_level(0,3)

func _on_button_unlock_button() -> void:
	%MainButton.disabled = false


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == puzzle_output:
		Website.data_for_json.set("puzzle_output", "Wpisałeś poprawne hasło, teraz kliknij 'Odblokuj'.")
	else:
		Website.data_for_json.set("puzzle_output", password)
