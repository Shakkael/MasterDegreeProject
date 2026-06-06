extends LevelHandler

## gdy scena się załaduje
func _ready() -> void:
	update_password() ## zaktualizuj hasło
	super()

## Zaktualizuj haslo
func update_password() -> void:
	var no_password := "brak pliku password.txt" ## Jeśli nie ma pliku hasła domyślnie tekst informuje o braku pliku
	var password := "" ## Hasło domyślnie jest puste
	if FileAccess.file_exists("res://level_files/Med05/password.txt"): ## Jeśłi plik password.txt istnieje
		var content = FileAccess.open("res://level_files/Med05/password.txt", FileAccess.READ).get_as_text() ## zapisz tekst
		password = content ## zapisz zawartość pliku jako hasło, bez względu na zawartość pliku
		%UnlockButton.Password = password.strip_edges() ## ustaw hasło przycisku i upewnij się,
														## żeby nie zawierał pustych znaków (\r\t\n)
		%UnlockButton.disabled = false ## odblokuj przycisk odblokowujący zaliczenie poziomu
	else:
		password = no_password ## zmienna password zawiera informację o braku pliku hasła
		%UnlockButton.disabled = true  ## zablokuj przycisk odblokowujący zaliczenie poziomu
		## żeby nie dało się odblokować poziomu bez pliku tekstowego
	## zaktualizuj zawartość tekstu na poziomie
	%Password.text = "Ostatnie hasło. To jest: %s" % password
	pass

func _on_main_button_pressed() -> void:
	Globals.unlock_level(2,5)


func _on_timer_timeout() -> void:
	update_password()
