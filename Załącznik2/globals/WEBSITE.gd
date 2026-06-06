extends Node

signal POST_received(data : Variant)

var server := TCPServer.new()
var port := 8080

var data_for_json := {"works":"initiated","start":true}
var file_path_to_dl : String

var submit_password := ""

signal unlock(name : String)

## Gdy scena będzie gotowa uruchom serwer na porcie  - domyślnie 8080
func _ready():
	var err = server.listen(port)
	if err != OK:
		print("Błąd uruchamiania serwera")
		get_tree().root.queue_free.call_deferred()
	else:
		print("Działa na http://127.0.0.1:%d" % port)


func _process(_delta):
	if server.is_connection_available(): ## jeśli połączenie jest dostępne
		handle_client(server.take_connection()) ## obsłuż klienta
		## Jeśli przyszły jakieś żądania, to handle_client() to obsłuży

## Obsługa requestów
func handle_client(client: StreamPeerTCP):
	client.poll()
	## jeśli nie ma żadnych danych
	var raw = client.get_utf8_string(client.get_available_bytes())
	if raw.is_empty():
		return ## zakończ

	## podziel nagłówki i ciało
	var split = raw.split("\r\n\r\n", false, 1)
	
	if split.size() < 1: ## jeśli split jest pusty
		send(client, 400, "text/plain", "Bad Request")
		return ## zakończ

	var header_text = split[0] ## tekst nagłówków
	var body = split[1] if split.size() > 1 else "" ## tekst ciała (jeśli nie ma zostaw puste)

	var lines = header_text.split("\r\n") ## podziel nagłówki na linijki
	var request_line = lines[0].split(" ") ## pierwsza linijka jest rodzajem requesta

	if request_line.size() < 2: ## jeśli linijka requestu jest za krótka
		send(client, 400, "text/plain", "Bad Request")
		return ## zakończ

	var method = request_line[0] ## metoda requestu (Get/Post)
	var path = request_line[1] ## ścieżka requestu (np. /api, /index.html)
	## wykorzystywana do przekierowywania
	var headers = {}
	for i in range(1, lines.size()):
		if lines[i].find(":") != -1:
			var kv = lines[i].split(":", false, 1)
			headers[kv[0].to_lower()] = kv[1].strip_edges()

	# Ensure full POST body
	if method == "POST":
		var content_length = int(headers.get("content-length", "0"))

		while body.to_utf8_buffer().size() < content_length:
			client.poll()
			body += client.get_utf8_string(client.get_available_bytes())

	## Ciasteczka + autentykacja
	var cookies = parse_cookies(headers)
	var is_admin_request = cookies.get("admin_access", "") == "true"

	## przekierowywanie - co ma otrzymać strona internetowa gdy wysyła dany request
	match path:
		"/", "/index.html":
			serve_file(client, "res://website/index.html", "text/html")
		"/tips.html":
			serve_file(client, "res://website/tips.html", "text/html")
		"/levelH2.html":
			serve_file(client, "res://website/levelH2.html", "text/html")
		"/WrongCSS.html":
			serve_file(client, "res://website/levelWrongCss.html", "text/html")
		"/game.html":
			serve_file(client, "res://website/game.html", "text/html")
		"/Chunk32.html", "/chunk32.html":
			serve_file(client, "res://website/chunk32.html", "text/html")
		"/password.jpg":
			serve_image(client, "res://website/password.jpg", "jpeg")
		"/admin.html", "/login.html":
			if is_admin_request:
				serve_file(client, "res://website/admin.html", "text/html")
			else:
				serve_file(client, "res://website/login.html", "text/html")
		"/fake_wrong.html":
			serve_file(client, "res://website/fake_wrong_level.html", "text/html")
		"/godot_sync.js":
			serve_file(client, "res://website/godot_sync.js", "application/javascript")
		"/admin.js":
			serve_file(client, "res://website/admin.js", "application/javascript")
		"/login.js":
			serve_file(client, "res://website/login.js", "application/javascript")
		"/levels.js":
			serve_file(client, "res://website/levels.js", "application/javascript")
		"/style.css":
			serve_file(client, "res://website/style.css", "text/css")
		"/admin.css":
			serve_file(client, "res://website/admin.css", "text/css")
		"/hard03.css":
			serve_file(client, "res://website/hard03.css", "text/css")
		"/savefile.txt":
			serve_file(client, "user://savefile.mlog", "text/plain")

	if path.begins_with("/api"):
		send(client, 200, "application/json", JSON.stringify(data_for_json))
	if path.begins_with("/game_api"):
		send(client, 200, "application/json", JSON.stringify({"position":"x: -272 y: -688", "player":Level.player_pos}))
	elif path.begins_with("/level"):
		serve_file(client, "res://website/wrong_level.html", "text/html")

	elif method == "POST" and path == "/submit":
		handle_post(client, headers, body)

	elif method == "POST" and path.begins_with("/overlay_unlock"):
		print(body)
		var values : Dictionary = JSON.parse_string(body)
		unlock.emit(values.get("unlock_button"))
		
	elif method == "POST" and path == "/login":
		handle_post(client, headers, body)
		
	elif method == "POST" and path == "/save":
		var file = FileAccess.open("user://savefile.mlog", FileAccess.WRITE)
		file.store_string(body)
		file.close()
		var response = "HTTP/1.1 200 OK\r\n"
		response += "Content-Type: text/plain\r\n"
		response += "Access-Control-Allow-Origin: *\r\n"
		response += "\r\n"
		response += "saved"
		client.put_data(response.to_utf8_buffer())

	elif method == "GET" and path == "/download" and file_path_to_dl != null:
		send_download(client, file_path_to_dl)

	elif method == "GET" and path == "/download_game" and file_path_to_dl != null:
		send_download(client, "res://downloadable/Game.zip")
		
	elif method == "GET" and path == "/download_mlog" and file_path_to_dl != null:
		send_download(client, "user://savefile.mlog")
	

	else:
		send(client, 404, "text/plain", "Not Found")
		
	client.disconnect_from_host()

# =========================
# POST PARSING
# =========================
func handle_post(client, headers, body):
	var content_type = headers.get("content-type", "")
	var result := {}
	if content_type.begins_with("application/x-www-form-urlencoded"):
		result = parse_form(body)

	elif content_type.begins_with("application/json"):
		var parsed = JSON.parse_string(body)
		if parsed != null:
			result = parsed

	if(result.get("password") == "ADMIN" and result.get("username") == "PASSWORD"):
		send(client, 200, "application/json", JSON.stringify({"status":"ok","received":result,"password_correct":true,"admin":true}))
		return
	
	if (result.get("answer", "")).to_upper() == submit_password.to_upper():
		POST_received.emit(result)
		send(client, 200, "application/json", JSON.stringify({"status":"ok","received":result,"correct":true}))
	else:
		send(client, 200, "application/json", JSON.stringify({"status":"ok","received":result,"correct":false}))


# =========================
# COOKIE PARSER
# =========================
func parse_cookies(headers: Dictionary) -> Dictionary:
	var cookie_header = headers.get("cookie", "")
	var cookies := {}

	for part in cookie_header.split(";"):
		var kv = part.strip_edges().split("=", false, 1)
		if kv.size() == 2:
			cookies[kv[0]] = kv[1]

	return cookies

## Parsowanie formularza do czytelnego słownika 'data'
func parse_form(body: String) -> Dictionary:
	print(body)
	var data = {}

	for pair in body.split("&"):
		var kv = pair.split("=", false, 1)
		if kv.size() == 2:
			data[kv[0].uri_decode()] = kv[1].uri_decode()

	return data

## Funkcja do wysyłania danych do http
func send(client, code:int, content_type:String, body:String):
	var body_bytes = body.to_utf8_buffer() ## oblicz bajty zawartości
	## utwórz odpowiedź do https z żądaną odpowiedzią
	var response = "HTTP/1.1 %d OK\r\n" % code
	response += "Content-Type: %s\r\n" % content_type
	response += "Content-Length: %d\r\n" % body_bytes.size()
	response += "Connection: close\r\n"
	response += "\r\n"

	client.put_data(response.to_utf8_buffer())
	client.put_data(body_bytes)

## Wersja funkcji send dostosowana do wysyłania plików
func serve_file(client, path, content_type):
	if not FileAccess.file_exists(path):
		send(client, 404, "text/plain", "Not Found")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		send(client, 500, "text/plain", "File error")
		return
	var bytes = file.get_buffer(file.get_length())

	var header = "HTTP/1.1 200 OK\r\n"
	header += "Content-Type: %s\r\n" % content_type
	header += "Content-Length: %d\r\n" % bytes.size()
	header += "Connection: close\r\n"
	header += "\r\n"

	client.put_data(header.to_utf8_buffer())
	client.put_data(bytes)

## Wersja serve_file dostosowana do wysyłania obrazów
func serve_image(client, path, type):
	var bytes
	var og_image : CompressedTexture2D = load(path)
	var image = og_image.get_image()
	if type == "jpg" or type == "jpeg":
		bytes = image.save_jpg_to_buffer()
	elif type == "png":
		bytes = image.save_png_to_buffer()
	else:
		print("Niewspierany typ pliku.")
		return

	#var bytes = file.get_buffer(file.get_length())

	var header = ""
	header += "HTTP/1.1 200 OK\r\n"
	header += "Content-Type: image/%s\r\n" % type
	header += "Content-Length: %d\r\n" % bytes.size()
	header += "Connection: close\r\n"
	header += "\r\n"

	client.put_data(header.to_utf8_buffer())
	client.put_data(bytes)

## Wersja funkcji send dostosowana do wysyłania plików do pobrania
func send_download(client, path):
	if not FileAccess.file_exists(path):
		send(client, 404, "text/plain", "File not found")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		send(client, 500, "text/plain", "Cannot open file")
		return

	var bytes = file.get_buffer(file.get_length())
	var filename = path.get_file()

	var header = "HTTP/1.1 200 OK\r\n"
	header += "Content-Type: application/zip\r\n"
	header += "Content-Disposition: attachment; filename=\"%s\"\r\n" % filename
	header += "Content-Length: %d\r\n" % bytes.size()
	header += "Connection: close\r\n"
	header += "\r\n"

	client.put_data(header.to_utf8_buffer())
	client.put_data(bytes)
