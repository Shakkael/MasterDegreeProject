extends CharacterBody2D
class_name Player2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

## Funkcja wywoływana co klatkę procesu fizycznego
func _physics_process(delta: float) -> void:
	## Działanie grawitacji na postać jeśli znajduje się na ziemi
	if not is_on_floor() or get_gravity().y<0:
		velocity += get_gravity() * delta

	## Obsługa zdarzenia akcji "ui_accept" - akcji wbudowanej natywnie w silnik
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): ## jeśli jest na ziemi
		velocity.y = JUMP_VELOCITY ## to odpowiada za efekt skoku

	## Na podstawie siły wydarzeń ustal kierunek ruchu. Jest to dobra praktyka,
	## która pozwala na dokładniejsze sterowanie na kontrolerze, który pozwala na zakres ruchu od 0 do 1
	## Dla klawiatury nie ma tak dużego znaczenia, bo albo przycisk jest naciśnięty (1) albo nie (0)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction: ## jeśli kierunek jest ustalony (nie jest równy Vector2(0,0)
		velocity.x = direction * SPEED ## nadaj prędkość równą stałej SPEED pomnożonej przez kierunek
	else: ## w przeciwnym wypadku
		velocity.x = move_toward(velocity.x, 0, SPEED) ## dąż do zatrzymania

	move_and_slide() ## wywołaj wbudowaną funkcję ruchu
