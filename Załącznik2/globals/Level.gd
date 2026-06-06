extends Node

var player_pos := Vector2.ZERO
var player_window_pos := Vector2i.ZERO
var tool_pos := Vector2i.ZERO
var cam_pos := Vector2.ZERO

@onready
var peer := ENetMultiplayerPeer.new()

## Gdy scena jest gotowa
func _ready() -> void:
	var err := peer.create_server(8082) ## utwórz lokalny serwer ENetMultiplayerPeer
	if err: ## jeśli się nie udało
		print("Nie udało się: ",err) ## poinformuj w konsoli
	multiplayer.multiplayer_peer = peer ## zapisz peer w multiplayer.multiplayer_peer
	
@rpc("any_peer") ## wywoływane przez klientów
func sync_player_position(p_position, p_window_position, player_cam_pos):
	## p - gracz (player), p_window - okno w którym znajduje się gracz oraz cam - kamera
	player_pos = p_position ## zapisz pozycję gracza w ukrytej trze
	cam_pos = player_cam_pos ## zapisz pozycję kamery w ukrytej grze
	player_window_pos = p_window_position ## zapisz pozycję okna gracza w ukrytej grze
	tool_pos = ToolMenu.position ## zapisz pozycję Narzędzia w grze głównej
	sync_tool_position.rpc(tool_pos) ## wywołaj funkcję synchronizacji pozycji Narzędzia
	
@rpc("authority") ## tylko host może użyć
func sync_tool_position(t_position):
	tool_pos = t_position ## zapisz pozycję narzędzia w zmiennej

@rpc("any_peer")
func level_finished(star_id : int) -> void:
	print(star_id, " finished")
	if len(Globals.unlocked_levels[4])<=3:
		for i in range(0,4):
			if !Globals.unlocked_levels[4].has(i):
				Globals.unlocked_levels[4].append(i)
	if !Globals.completed_levels[4].has(star_id):
		Globals.completed_levels[4].append(star_id)
	Globals.save()
