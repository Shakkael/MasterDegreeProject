extends LevelHandler

var password : String = str(randi())

func _on_main_button_pressed() -> void:
	Globals.unlock_level(1,2)

func _ready() -> void:
	puzzle_output = "Hasło to: "+ password
	super()
	Globals.cur_password = password
