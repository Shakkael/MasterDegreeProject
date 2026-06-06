extends Window
class_name ToolLevel

var windows_size := DisplayServer.screen_get_size( self.current_screen )

## Gdy scena jest gotowa
func _ready() -> void:
	Globals.change_tool.connect(change_tool) ## połącz sygnały z globalnego skryptu
	Globals.change_glass.connect(change_glass) ## z odpowiadającymi im funkcjami
	self.visibility_changed.connect(_hidden) ## połącz sygnał o zmianie widoczności z funkcją obsługującą
	multiplayer.peer_connected.connect(_show_tab) ## jeśli ukryta gra się połączy odkryj panel gry w narzędziu
	hide()

func _show_tab() -> void:
	%ToolContainer.set("tab_2/hidden", false)
func _process(_delta: float) -> void:
	#%Control.set_deferred("global_position", Globals.main_level_pos - position)
	Globals.tool_level_pos = self.position
	%Lupka.set_deferred("global_position", Globals.main_level_pos - position)
	%Lupka.set_deferred("scale", Globals.main_level_scale)
	%Gra.set_deferred("global_position", Globals.main_level_pos - position + Vector2i(Level.cam_pos))
	#%Gra.set_deferred("scale", Globals.main_level_scale)
func _on_close_requested() -> void:
	hide()

## Funkcja zmieniająca zawartość Panelu
func change_tool(tool_name : String): ## tool_name to string będący częścią ścieżki do sceny panelu
	%Control.remove_child(%Control.get_child(0)) ## Usuń obecną scenę panelu
	var new_tool : Control = load("res://levels/ToolLevels/%s" % tool_name).instantiate()
	%Control.add_child(new_tool) ## Dodaj nową scenę panelu
	new_tool.mouse_filter = Control.MOUSE_FILTER_IGNORE ## trzeba się upewnić, że filtr jest ustawiony właściwie

func change_glass(glass_name : String): ## glass_name to string będący częścią ścieżki do sceny lupki
	%Lupka.remove_child(%Lupka.get_child(0)) ## Usuń obecną scenę lupy
	var new_glass = load("res://levels/ToolLevels/%s" % glass_name).instantiate()
	%Lupka.add_child(new_glass) ## Dodaj nową scenę lupy
	new_glass.mouse_filter = Control.MOUSE_FILTER_IGNORE ## trzeba się upewnić, że filtr jest ustawiony właściwie

func _hidden():
	%ToolContainer.visible = self.visible
	print(self.visible)
