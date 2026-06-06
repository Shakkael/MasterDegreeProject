extends Control

func _ready() -> void:
	Website.data_for_json = {"current" : -1}

func _on_test_pressed() -> void:
	Globals.go_to_scene(1)

func _on_quit_pressed() -> void:
	get_tree().quit()

## Wbudowana funkcja obsługująca nieobsłużone sygnały input klawiszy na klawiaturze
func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("website"): ## akcja 'website' przypisana jest pod klawisz 'w'
		_on_website_pressed()

## obsługa wydarzenia wciśniętego klawisza akcji 'website' ('w')
func _on_website_pressed() -> void:
	## uruchom lokalną stronę internetową
	OS.shell_open("http://127.0.0.1:8080")


func _on_tool_pressed() -> void:
	ToolMenu.visible = true
