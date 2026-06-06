extends Control

@export_group("Levels properties")
@export_enum("Tutorial", "Podstawowe", "Średnie", "Zaawansowane", "Ostatnia próba") var level_category := 0

signal go_to_level(level : int)

## Wbudowana funkcja. Wywoływana jest w momencie, gdy węzeł jest gotowy w scenie
func _ready() -> void:
	var i = 0
	## c_completed - od category completed.
	## Jeśli w dana kategoria posiada 5 skończonych poziomów uznawana jest za zakończoną
	var c_completed = " V" if len(Globals.completed_levels[level_category]) >= 5 else ""
	## Domyślnie c_completed jest puste (więc w if'ie zwraca false) ale jeśli kategoria jest skończona,
	## to posiada wartość " V". Jest wtedy jednocześnie używane do zmiany nazwy i sprawdzenia warunku
	%Difficulty.self_modulate = Color(0.51, 1.0, 0.275) if c_completed else Color.WHITE
	%Difficulty.text = "--- %s (%s)  ---" % [Globals.categories[level_category].to_upper(),
											Globals.cat_shorts[level_category]
											] + c_completed
	for button : Button in %ButtonsContainer.get_children():
		var buts_ar : Array = Globals.unlocked_levels[level_category]
		## buts_ar to tabela odblokowanych poziomów dla przypisanej kategorii
		## Jeśli dany poziom znajduje się w tej tabeli to zostaje ujawniony na liście
		if buts_ar.has(i):
			## Jeśli dana lista poziomów jest przypisana do poziomów poza grą główną przyciski są zablokowane
			if level_category >= 3:
				button.disabled = true
			button.visible = true
		else:
			button.visible = false
		## l_completed funkcjonuje podobnie do c_completed. Domyślnie jest pusty - false. Jeśli poziom jest
		## ukończony to zmienna dostaje wartość " v" żeby jednocześnie zmienić nazwę i służyć za boolean true 
		var l_completed = " V" if Globals.completed_levels[level_category].has(i) else ""
		button.self_modulate = Color(0.51, 1.0, 0.275) if l_completed else Color.WHITE
		button.text = "Poziom: "+Globals.cat_shorts[level_category]+".0"+str(i+1)+l_completed
		i+=1 ## dla pętli for

func on_difficulty_toggled(toggled_on: bool) -> void:
	%MarginContainer.visible = toggled_on

func _on_button_pressed(level: int) -> void:
	go_to_level.emit(level_category, level)
