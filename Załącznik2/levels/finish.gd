extends LevelHandler

func _on_main_button_pressed() -> void:
	OS.shell_open("http://127.0.0.1:8080/tips.html")
	Globals.go_to_scene(0)
