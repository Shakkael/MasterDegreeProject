extends Button
class_name UnlockButton

signal unlockButton

## Choose a Node which should appear if the used password is not correct.
@export var TipNode : Node
@export_group("Password info")
## @experimental: ?????????????????????
@export var ButtonName := ""
## Choose a LineEdit node of which input will be compared to the password
@export var InputCheck : LineEdit
## Type in a password that will be checked in InputCheck.
@export var Password := "Odblokuj"
@export_group("Unlock info")
## Choose a button to unlock if it is in the same scene.
@export var ButtonToUnlock : Button
## Type in a String value that will be emitted when the button is pressed
@export var ButtonSignal := ""

## Gdy obiekt jest gotowy
func _ready() -> void:
	## ustaw tryb akcji na ...BUTTON_PRESS -> sygnał naciśnięcia guziku jest emitowany tylko po naciśnięciu przycisku
	## nie jest natomiast emitowany przy przytrzymywaniu ani przy puszczaniu przycisku
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	## połącz sygnał pressed do funkcji _on_pressed
	pressed.connect(_on_pressed)

## check_password to zmienna zawierająca hasło do sprawdzenia
func _on_pressed() -> void: 
	var check_password = "" ## Domyślnie nie ma hasła
	if InputCheck: ## Jeśli zostało do przycisku przypisane pole input
		check_password = InputCheck.text ## hasło do sprawdzenia to zawartość pola input
	else:
		check_password = Password ## w przeciwnym razie nadaj wartość poprawnego hasła
	if check_password == Password: ## jeśli hasła się zgadzają - są poprawne
		unlockButton.emit() ## wyemituj sygnał odblokowywania przycisku
		if ButtonToUnlock and ButtonToUnlock.disabled: ## ButtonToUnlock -> to jest przycisk do odblokowywania
			## Jeśli jest przypisany przycisk do odblokowoania i jest zablokowany - odblokuj go
			ButtonToUnlock.disabled = false
	## Jeśli jest przypisany sygnał przcysku obsłuż do zaktualizowania API
		if ButtonSignal:
			var body = JSON.stringify({
				"unlock_button" : str(ButtonSignal)
			})
			var result = %HTTPRequest.request(
				"http://127.0.0.1:%d/overlay_unlock2" % Website.port,
				["Content-Type: application/json"],
				HTTPClient.METHOD_POST,
				body
			)
			print("wynik: ",result, HTTPRequest.RESULT_SUCCESS)
	else: ## jeśli hasła nie zgadzają się
		disabled = true
		if not TipNode == null:
			TipNode.visible = true ## jeśli istnieje węzeł ze wskazówką wyświetl wskazówkę
		await get_tree().create_timer(3).timeout ## 3 sekundy przerwy między próbami
		disabled = false
