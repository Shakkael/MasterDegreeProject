extends Area2D

@export var grabbed := false ## czy gwiazdka została zebrana
@export var star_id := 0 ## id gwiazdki

signal touched(star_id : int) ## sygnał, że gwiazdka została dotknięta

## Obsługa sygnału "zabrania" gwiazdki. Pozwala na korzystanie z funkcji w innych miejscach kodu w razie potrzeby
func check_grabbed() -> void:
	if grabbed:
		var new_texture := load("res://textures/starSilver.png") ## ładuje szarą teksturę i zapisuje w zmiennej
		%Sprite.texture = new_texture ## zmienia teksturę na nową

## Obsługa wbudowanego sygnału "body_entered" wykrywającego ciała wchodzące do obszaru2d
func _on_body_entered(body: Node2D) -> void:
	if body is Player2D: ## jeśli ciało, które weszło do obszaru, ma klasę Player2D
		if !grabbed: ## jeśli gwiazdka nie została jeszcze zebrana
			touched.emit(star_id) ## emituj sygnał dotknięcia gwiadzki i przekaż id gwiazdki
			grabbed = true ## zmień wartośćbool na true
			check_grabbed() ## wywołaj funkcję zmieniającą teksturę gwiazdki
			set_deferred("monitoring", false) ## przestań obserwować zdarzenia gwiazdki
		print("Brawo!") ## dodatkowy komunikat w konsoli o sukcesie zebrania gwiazdki 
