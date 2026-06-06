extends LevelHandler

## Gdy scena jest gotowa od razu zaktualizuj obrazki
func _ready() -> void:
	update_picture()
	super() ## wykonaj pozostałą zawartość funkcji _ready z klasy LevelHandler

## funkcja aktualizacji obrazka
func update_picture() -> void:
	var path_begin = OS.get_executable_path().get_base_dir() ## path_begin zawiera ścieżkę do folderu zawierającego grę
	var no_picture := load("res://NoPicture.png") ## Jeśli nie zostanie znaleziony obrazek, domyślnie załaduj ten obrazek
	if FileAccess.file_exists(path_begin + "/level_files/Med01/Med1P1.png"): ## Jeśli ten plik istnieje
		%PicturePart1.texture = ImageTexture.create_from_image(Image.load_from_file(path_begin + "/level_files/Med01/Med1P1.png")) ## Ustaw teksturę węzła PictureRect o nazwie PicturePart1 jako ten obrazek
	else: ## w przeciwnym wypadku
		%PicturePart1.texture = no_picture ## Ustaw teksturę na domyślną
	if FileAccess.file_exists(path_begin + "/level_files/Med01/Med1P2.png"): ## powtórz to samo dla PicturePart2
		%PicturePart2.texture = ImageTexture.create_from_image(Image.load_from_file(path_begin + "/level_files/Med01/Med1P2.png"))
	else:
		%PicturePart2.texture = no_picture
		
## funkcja obsługuje sygnał 'timeout' Timera, który jest ustawiony na wysyłanie sygnału co 2 sekundy
func _on_timer_timeout() -> void:
	update_picture()

func _on_main_button_pressed() -> void:
	Globals.unlock_level(2,1)
