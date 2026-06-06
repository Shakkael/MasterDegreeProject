extends Control
class_name LevelHandler

@export var level := 0
@export_enum("Tutorial", "Łatwe", "Średnie", "Zaawansowane", "Ostatnia próba") var level_category := "Tutorial"
@export_multiline() var tip := ""
@export_group("Data")
@export var signal_unlock := ""
@export var subsite := ""
@export var tool_name := "NLvlTool.tscn"
@export var glass_name := "NLvlGlass.tscn"
@export_subgroup("Input\\Output")
@export var puzzle_output := ""
@export var puzzle_input := false
@export var submit_password := ""
@export_subgroup("Download")
@export var download_path : String = ""

## Gdy scena jest gotowa
func _ready() -> void:
	Globals.save() ## Wywołaj funkcję zapisania gry
	randomize() ## Potrzebne dla potwierdzenia losowości generatora liczb losowych
	print("Załadowano poziom: ",level_category," 0",level+1) ## Info o załadowaniu poziomu, dla deva - zbędne w projekcie
	Website.submit_password = submit_password ## Gdy API będzie otrzymywać hasło, będzie je porównywać z tą zmienną
	Website.data_for_json = {"category": level_category} ## Zapisz do API obecna kategorię
	Website.data_for_json.set("levels_unlocked", Globals.unlocked_levels)  ## Zapisz do API odblokowane poziomy
	Website.data_for_json.set("levels_completed", Globals.completed_levels) ## Zapisz do API ukończone poziomy
	Website.data_for_json.set("current", level) ## Zapisz do API obecny poziom
	Website.data_for_json.set("puzzle_tip", tip) ## Zapisz do API podpowiedź do obecnego poziomu
	Website.data_for_json.set("puzzle_output", puzzle_output) ## Zapisz do API wskazówkę do obecnego poziomu
	Website.data_for_json.set("puzzle_input", puzzle_input) ## Zapisz do API hasło do pola w przeglądarce
	if len(download_path) > 0: ## Jeśli istnieje ścieżka pobierania
		Website.data_for_json.set("download_available", true) ## Zapisz w API że pobieranie jest dostępne
		Website.file_path_to_dl = download_path               ## Wyślij do API ścieżkę 
	else: ## W przeciwnym razie
		Website.data_for_json.set("download_available", false) ## Zapisz w API że pobieranie nie jest dostępne
		Website.file_path_to_dl = ""                          ## Na wszelki wypadek usuń ścieżkę pobierania w API
	## Jeśli poziom ma przypięty sygnał podepnij go do funkcji, która go obsłuzy
	if signal_unlock:
		Website.unlock.connect(unlock)
	
	Globals.change_tool.emit(tool_name)      ## Wyemituj w globalnym skrypcie sygnał zmiany Panelu w Narzędziu
	Globals.change_glass.emit(glass_name)    ## Wyemituj w globalnym skrypcie sygnał zmiany Lupy w Narzędziu
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://levels/Menus/LevelsMenu.tscn")
	elif event.is_action_pressed("website"):
		OS.shell_open("http://127.0.0.1:8080"+subsite)


func unlock(unlock_name : String):
	if unlock_name.to_upper() == signal_unlock.to_upper():
		%MainButton.disabled = false

func _exit_tree() -> void:
	if signal_unlock:
		Website.unlock.disconnect(unlock)
	Globals.change_glass.emit("NLvlGlass.tscn")
	Globals.change_tool.emit("NLvlTool.tscn")
