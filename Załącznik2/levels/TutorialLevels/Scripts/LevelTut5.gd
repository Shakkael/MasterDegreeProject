extends LevelHandler

var password = randi()

func _ready() -> void:
	if puzzle_input:
		Website.POST_received.connect(_post_receive_attempt)
	super()

func _on_main_button_pressed() -> void:
	Globals.unlock_level(0,5)

func _post_receive_attempt(result : Variant):
	print(result.get("answer"))
	if (result.get("answer")) == submit_password.to_upper():
		%MainButton.disabled = false
