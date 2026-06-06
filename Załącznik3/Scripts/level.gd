extends Node

var player_pos := Vector2.ZERO
var tool_pos := Vector2i.ZERO
var cam_pos := Vector2.ZERO

var messages := {
	0: "Brawo! Udało Ci się dotrzeć do ostatniej kategorii. Pora na Twoją nagrodę: Gwiazdki. Każda gwiazdka to jeden poziom. Żeby zdobyć pozostałe 4 wykorzystaj wiedzę z 3 kategorii.",
	1: "Tak, gwiazdki są ukryte też poza początkowo widoczną strefą. Będzie trzeba się bardzo *blisko przyjrzeć*, by odnaleźć pozostałe gwiazdki. Tylko uważaj. Ta gwiazdka na górze boi się narzędzi. Trzymaj je zdala od niej.",
	2: "Gratuluję! Jeszcze jedna w tym oknie! Może w jakiś projektach poziomów będzie podpowiedź? Albo na jakiejś stronie?",
	3: "Nie ma więcej gwiazdek w tym oknie :) Skoro udało Ci się wykonać wszystkie zadania, to na pewno przewinęło Ci się podczas gry kilka fragmentów do hasła. Ułóż je w całe hasło i użyj tam, gdzie wszystko się zaczęło."
}

func _ready():
	print("Gra platformowa. Prototyp. Gracz może zmieniać układ poziomu używając pliku tekstowego w folderze level_scheme.")
	var peer = ENetMultiplayerPeer.new() ## utwórz obiekt peer
	peer.create_client("127.0.0.1", 8082) ## utwórz klienta i połącz z serwerem lokalnym na porice 8082
	multiplayer.multiplayer_peer = peer ## przydziel peer do wbudowanego multiplayer.multiplayer_peer

## funkcja obsługująca sygnał dotknięcia gwiazdki
func star_achieved(star_id : int) -> void:
	%PointPrompt.text = messages[star_id] ## Wyświetl wiadomość przypisaną do danej gwiazdki
	%Popup.visible = true ## Wyświetl popup z wiadomością
	get_tree().paused = true ## spauzuj grę na czas czytania wiadomości
	rpc("level_finished", star_id) ## wyślij do servera informacje o zdobyciu gwiazdki - ukończeniu poziomu

@rpc("any_peer") ## funkcja dla klienta
func sync_player_position(p_position): ## wyślij pozycję gracza do gry głównej, która przekaże to do API
	var sender_id := multiplayer.get_remote_sender_id()
	print("Gracz ", sender_id, " pozycja: ", p_position)

@rpc("authority") ## funkcja serwera
func sync_tool_position(t_position): ## pobierz i wykorzystaj pozycję narzędzia otrzymaną od gry głównej
	tool_pos = t_position
	@warning_ignore("integer_division")
	%Point2.global_position.y = -800 - ((get_window().position - tool_pos).y/5) ## pozycja 2 gwiazdki jest zależna od odległości
																				## okien w pionie względem siebie
@rpc("any_peer") ## funkcja klienta
func level_finished(star_id : int) -> void:
	print("Level %d finished." % star_id) ## poziom ukończony

func _on_timer_timeout() -> void:
	player_pos = %Player.global_position
	cam_pos = %Player.get_node("Camera2D").global_position
	var err = rpc("sync_player_position", player_pos, get_window().position, cam_pos)
	if err:
		%Connetion.visible = true

func _on_button_pressed() -> void:
	%Popup.visible = false
	get_tree().paused = false
