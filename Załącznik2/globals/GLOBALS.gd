extends Node

var unlocked_levels = {
	0: [0],
	1: [],
	2: [],
	3: [],
	4: []
}
var completed_levels = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: []
}
var completed_time = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: []
}

var main_level_pos := Vector2i.ZERO
var main_level_scale := Vector2.ONE
var tool_level_pos := Vector2i.ZERO

var categories : Array[String] = ["Tutorial", "Podstawowe", "Średnie", "Zaawansowane", "Ostatnia próba"]
var cat_shorts : Array[String] = ["TUT", "ES", "MED", "ADV", "SCT"]
var menus = [
	"res://levels/Menus/MainMenu.tscn",
	"res://levels/Menus/LevelsMenu.tscn",
	"res://levels/Finish.tscn"
]
var toolLevels = [
	"res://levels/ToolLevels/ToolEs01.tscn",
]
var levels = [
	[
		"res://levels/TutorialLevels/Tut1.tscn",
		"res://levels/TutorialLevels/Tut2.tscn",
		"res://levels/TutorialLevels/Tut3.tscn",
		"res://levels/TutorialLevels/Tut4.tscn",
		"res://levels/TutorialLevels/Tut5.tscn",
		"res://levels/Menus/LevelsMenu.tscn"
	],
	[
		"res://levels/EasyLevels/Easy1.tscn",
		"res://levels/EasyLevels/Easy2.tscn",
		"res://levels/EasyLevels/Easy3.tscn",
		"res://levels/EasyLevels/Easy4.tscn",
		"res://levels/EasyLevels/Easy5.tscn",
		"res://levels/Menus/LevelsMenu.tscn"
	],
	[
		"res://levels/MediumLevels/Medium1.tscn",
		"res://levels/MediumLevels/Medium2.tscn",
		"res://levels/MediumLevels/Medium3.tscn",
		"res://levels/MediumLevels/Medium4.tscn",
		"res://levels/MediumLevels/Medium5.tscn",
		"res://levels/Menus/LevelsMenu.tscn"
	]
]
var cur_password := ""

var cur_level = -1
@warning_ignore("unused_signal")
signal change_tool(tool_name : String)
@warning_ignore("unused_signal")
signal change_glass(glass_name : String)

func _ready() -> void:
	## Część kodu potrzebnego do zakończenia testu
	print("Part2: TakingPartIn")
	## Zapisz w zmiennej save_file wynik próby otwarcia pliku savefile.mlog
	var save_file := FileAccess.open("user://savefile.mlog", FileAccess.READ)
	if save_file == null: ## Jeśli pliku nie ma - uruchom funkcję zapisu gry
		save() ## Funkcja zapisu gry tworzy plik savefile jeśli ten nie istnieje
		save_file = FileAccess.open("user://savefile.mlog", FileAccess.READ) ## Wczytaj plik, który już istnieje
	var save_dict : Dictionary ## Dane zapisu gry to słownik trzymane w _ready pod nazwą save_dict
	if save_file and save_file.get_length() > 10:
		var save_text = save_file.get_as_text() ## zapisz w save_text zawartość pliku zapisu gry
		save_dict = JSON.parse_string(save_text) ## zapisz w save_dict sparsowany do jsona zapis gry
	if save_dict:	## Poniższe trzy słowniki za klucze korzystają z id kategorii (0-4)
		var ul_lvls = save_dict["unlocked"] ## ul_lvls - unlocked levels | zapisz w zmiennej odblokowane poziomy
		var cl_lvls = save_dict["completed"] ## cl_lvls - completed levels | zapisz ukończone poziomy
		var ct_lvls = save_dict["time_finished"] ## ct_lvls - completion time of levels | zapisz czas ukończenia
		for key in cl_lvls.keys(): ## pętla for iterująca przez klucze (kategorie) w tabeli ukończonych poziomów
			var new_array = [] ## tymczasowa tabela zaczyna pusta
			for record in cl_lvls[key]:  ## pętla for iterująca przez poziomy w tabeli kategorii
				new_array.append(int(record)) ## cały ten fragment jest niezbędny, żeby wczytać wartości zapisywane
											## przez JSON jako stringi i zapisać je jako liczby całkowite
			completed_levels.set(int(key), new_array) ## ustaw tymczasową tabelę dla tej kategorii w completed_levels
		for key in ul_lvls.keys(): ## to samo dla katgeorii w tabeli odblokowanych poziomów
			var new_array = []
			for record in ul_lvls[key]:
				new_array.append(int(record))
			unlocked_levels.set(int(key), new_array)
		completed_time = ct_lvls ## czas ukończenia to zawsze datetime w postaci stringa, więc pętla jest zbędna
	save_file.close()

func _physics_process(_delta: float) -> void:
	main_level_pos = get_window().position
	main_level_scale = Vector2(get_window().size) / Vector2(1366,768)

## Funkcja odpowiedzialna za odblokowywanie następnego poziomu
func unlock_level(category : int, level : int, go_to := true):
	## Sprawdź, czy dany poziom jest już zapisany dla danej kategorii w słowniku:
	## 1. ukończonych poziomów
	if not completed_levels[category].has(level-1) and not level == 0:
		completed_levels[category].append(level-1)
	## 2. odblokowanych poziomów
	if not unlocked_levels[category].has(level) and not level == 5:
		unlocked_levels[category].append(level)
	## Sprawdź, czy tabela danej kategorii w słowniku czasów ukończenia poziomów posiada oczekiwaną ilość wpisów
	if len(completed_time[str(category)]) < level:
		completed_time[str(category)].append(Time.get_datetime_string_from_system())
	save() ## wywołaj funkcję zapisu
	if go_to: ## domyślnie go_to zawsze jest true. Po wykonaniu funkcji przenieś do odblokowanego poziomu
		get_tree().change_scene_to_file(levels[category][level])

## Funkcja odpowiedzialna za zapis postępów w grze głównej
func save() -> void:
	## Otwórz i zapisz do zmiennej plik savefile.mlog używajać WRITE -> powoduje to wyczyszczenie pliku tekstowego do zera
	var savefile := FileAccess.open("user://savefile.mlog", FileAccess.WRITE) ## Jeśli plik nie istnieje,
	var json = JSON.stringify({												## automatycznie zostaje stworzony
		"unlocked":unlocked_levels,
		"completed": completed_levels,
		"time_finished": completed_time})
	savefile.store_string(json) ## zapisz w pliku obiekt JSON w postaci tekstu (stringa)
	savefile.close() ## zamknij otwarty plik

## Funkcja odpowiedzialna za przechodzenie do odpowiedniego menu
func go_to_scene(scene : int = 0):
	get_tree().change_scene_to_file(menus[scene])

## Funkcja odpowiedzialna za załadowywanie pliku MP3 spoza pakowanych zasobów
func load_external_mp3(path:String) -> AudioStreamMP3:
	if !FileAccess.file_exists(path):
		return null

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		return null

	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())

	return sound
