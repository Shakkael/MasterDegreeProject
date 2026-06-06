extends LevelHandler

func _ready() -> void:
	update_sound()
	super()

func update_sound() -> void:
	var path_begin = OS.get_executable_path().get_base_dir()
	if FileAccess.file_exists(path_begin + "/level_files/Med03/Med3P1.mp3"):
		%Rec1.stream = Globals.load_external_mp3(path_begin + "/level_files/Med03/Med3P1.mp3")
	if FileAccess.file_exists(path_begin + "/level_files/Med03/Med3P2.mp3"):
		%Rec2.stream = Globals.load_external_mp3(path_begin + "/level_files/Med03/Med3P2.mp3")
		


func _on_main_button_pressed() -> void:
	Globals.unlock_level(2,3)


func _on_sounds_button_pressed() -> void:
	update_sound()
	%Rec1.play()
	%Rec2.play()
