extends TileMapLayer

var level_file := FileAccess.open("level_scheme/current_level.txt", FileAccess.READ)

func _ready() -> void:
	load_level()

func load_level() -> void:
	var text = level_file.get_as_text().split("\n")
	if len(text) > 13:
		print("Tylko 12 linijek jest wykorzystanych. Pozostałe są ignorowane.")
	var max_chars := 0
	var l = -6
	for line in text:
		var c = -12
		max_chars = max(max_chars, len(line))
		for character in line:
			if c > 12:
				break
			else:
				if character == "c":
					%Map.set_cell(Vector2i(c,l),0,Vector2i.ZERO)
				elif character == "j":
					var coords : Vector2i = %Map.to_global(%Map.map_to_local(Vector2i(c,l)))
					var new_jp := preload("res://Scenes/Jumppad.tscn").instantiate()
					new_jp.set_deferred("global_position", coords)
					add_child.call_deferred(new_jp)
				c+=1
		if l > 6:
			break
		else:
			l+=1
	if max_chars > 25:
		print("Tylko 25 znaków w linijce jest wykorzystywanych. Pozostałe są ignorowane.")

##### WYKORZYSTANIE TOOLa Z TAMTEJ GRY
