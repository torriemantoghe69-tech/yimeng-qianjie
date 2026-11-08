extends Node

signal chat_finished(success: bool, content: String, raw: Dictionary)
signal image_finished(success: bool, image_url: String, raw: Dictionary)
signal image_saved(success: bool, local_path: String, raw: Dictionary)
signal request_failed(kind: String, message: String)

const CONFIG_PATH := "user://sensenova_config.json"
const FALLBACK_CONFIG_PATH := "res://sensenova_config.example.json"
const CACHE_DIR := "user://ai_cache"

var api_key: String = ""
var base_url: String = "https://token.sensenova.cn/v1"
var chat_path: String = "/chat/completions"
var image_path: String = "/images/generations"
var chat_model: String = ""
var image_model: String = ""
var timeout_sec: int = 60


func _ready() -> void:
	_ensure_cache_dir()
	load_config()


func is_configured() -> bool:
	return api_key.strip_edges() != ""


func load_config() -> void:
	var data: Dictionary = _read_json_from_path(CONFIG_PATH)
	if data.is_empty():
		data = _read_json_from_path(FALLBACK_CONFIG_PATH)
	if data.is_empty():
		return
	_apply_config(data)


func save_config() -> bool:
	var data: Dictionary = {
		"api_key": api_key,
		"base_url": base_url,
		"chat_path": chat_path,
		"image_path": image_path,
		"chat_model": chat_model,
		"image_model": image_model,
		"timeout_sec": timeout_sec,
	}
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		request_failed.emit("config", "Unable to write config file: %s" % CONFIG_PATH)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


func request_chat(prompt: String, system_prompt: String = "", temperature: float = 0.7, max_tokens: int = 1024) -> void:
	var messages: Array[Dictionary] = []
	if system_prompt.strip_edges() != "":
		messages.append({
			"role": "system",
			"content": system_prompt,
		})
	messages.append({
		"role": "user",
		"content": prompt,
	})
	request_chat_messages(messages, temperature, max_tokens)


func request_chat_messages(messages: Array[Dictionary], temperature: float = 0.7, max_tokens: int = 1024) -> void:
	if not is_configured():
		request_failed.emit("chat", "SenseNova API key is missing.")
		return
	if messages.is_empty():
		request_failed.emit("chat", "Chat messages are empty.")
		return

	var payload: Dictionary = {
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
	}
	if chat_model.strip_edges() != "":
		payload["model"] = chat_model

	_send_json_request("chat", _join_url(base_url, chat_path), payload)


func request_image(prompt: String, size: String = "1024x1024") -> void:
	if not is_configured():
		request_failed.emit("image", "SenseNova API key is missing.")
		return
	if prompt.strip_edges() == "":
		request_failed.emit("image", "Image prompt is empty.")
		return

	var payload: Dictionary = {
		"prompt": prompt,
		"size": size,
		"n": 1,
		"response_format": "b64_json",
		"watermark": false,
		"prompt_extend": true,
	}
	if image_model.strip_edges() != "":
		payload["model"] = image_model

	_send_json_request("image", _join_url(base_url, image_path), payload, _cache_key_from_prompt(prompt))


func download_image_to_cache(image_url: String, cache_name: String = "") -> void:
	if image_url.strip_edges() == "":
		request_failed.emit("image", "Image URL is empty.")
		return

	var http := HTTPRequest.new()
	add_child(http)
	http.timeout = float(timeout_sec)
	http.request_completed.connect(_on_download_completed.bind(http, cache_name))
	var err := http.request(image_url)
	if err != OK:
		request_failed.emit("image", "Image download request failed: %s" % error_string(err))
		http.queue_free()


func get_cached_image_path(key: String) -> String:
	return _join_path(CACHE_DIR, "%s.png" % _safe_key(key))


func _send_json_request(kind: String, url: String, payload: Dictionary, cache_key: String = "") -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.timeout = float(timeout_sec)
	http.request_completed.connect(_on_request_completed.bind(kind, http, cache_key))

	var headers: PackedStringArray = PackedStringArray([
		"Authorization: Bearer %s" % api_key.strip_edges(),
		"Content-Type: application/json",
	])
	var err := http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		request_failed.emit(kind, "HTTP request failed: %s" % error_string(err))
		http.queue_free()


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, kind: String, http: HTTPRequest, cache_key: String) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit(kind, "Network error: %d" % result)
		return
	if response_code < 200 or response_code >= 300:
		request_failed.emit(kind, "Server returned HTTP %d" % response_code)
		return

	var response_text := body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(response_text)
	if parsed is not Dictionary:
		request_failed.emit(kind, "Server returned a non-JSON response.")
		return

	var data: Dictionary = parsed
	if kind == "chat":
		var content := _extract_chat_content(data)
		if content.strip_edges() == "":
			request_failed.emit(kind, "Chat response did not contain text content.")
			return
		chat_finished.emit(true, content, data)
		return

	if kind == "image":
		var image_url := _extract_image_url(data)
		if image_url.strip_edges() != "":
			image_finished.emit(true, image_url, data)
			var download_key := cache_key if cache_key.strip_edges() != "" else image_url
			download_image_to_cache(image_url, download_key)
			return

		var image_b64 := _extract_image_base64(data)
		if image_b64.strip_edges() != "":
			var save_key := cache_key if cache_key.strip_edges() != "" else response_text
			var local_path := _save_base64_image_to_cache(image_b64, save_key)
			if local_path != "":
				image_saved.emit(true, local_path, data)
				return

		request_failed.emit(kind, "Image response did not contain URL or base64 data.")


func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, cache_name: String) -> void:
	http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("image", "Image download failed with network error %d" % result)
		return
	if response_code < 200 or response_code >= 300:
		request_failed.emit("image", "Image download returned HTTP %d" % response_code)
		return

	var file_name := cache_name.strip_edges()
	if file_name == "":
		file_name = "image_%s.png" % str(Time.get_unix_time_from_system())
	elif not file_name.ends_with(".png") and not file_name.ends_with(".jpg") and not file_name.ends_with(".jpeg") and not file_name.ends_with(".webp"):
		file_name += ".png"
	var local_path := _join_path(CACHE_DIR, file_name)
	var file := FileAccess.open(local_path, FileAccess.WRITE)
	if file == null:
		request_failed.emit("image", "Unable to write image cache file: %s" % local_path)
		return
	file.store_buffer(body)
	image_saved.emit(true, local_path, {})


func _apply_config(data: Dictionary) -> void:
	api_key = str(data.get("api_key", api_key))
	base_url = str(data.get("base_url", base_url))
	if base_url == "https://api.sensenova.cn" or base_url == "https://token.sensenova.cn":
		base_url = "https://token.sensenova.cn/v1"
	chat_path = str(data.get("chat_path", chat_path))
	image_path = str(data.get("image_path", image_path))
	chat_model = str(data.get("chat_model", chat_model))
	image_model = str(data.get("image_model", image_model))
	timeout_sec = int(data.get("timeout_sec", timeout_sec))
	if timeout_sec <= 0:
		timeout_sec = 60


func _read_json_from_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _extract_chat_content(data: Dictionary) -> String:
	if data.has("choices") and data["choices"] is Array:
		var choices: Array = data["choices"]
		if not choices.is_empty() and choices[0] is Dictionary:
			var first: Dictionary = choices[0]
			if first.has("message") and first["message"] is Dictionary:
				var message: Dictionary = first["message"]
				if message.has("content"):
					return str(message["content"])
				if message.has("text"):
					return str(message["text"])
				if message.has("delta") and message["delta"] is Dictionary:
					var delta: Dictionary = message["delta"]
					if delta.has("content"):
						return str(delta["content"])
				if first.has("text"):
					return str(first["text"])
				if first.has("content"):
					return str(first["content"])
	if data.has("content"):
		return str(data["content"])
	if data.has("text"):
		return str(data["text"])
	return ""


func _extract_image_url(data: Dictionary) -> String:
	if data.has("data") and data["data"] is Array:
		var items: Array = data["data"]
		if not items.is_empty() and items[0] is Dictionary:
			var first: Dictionary = items[0]
			if first.has("url"):
				return str(first["url"])
			if first.has("image_url"):
				return str(first["image_url"])
	if data.has("url"):
		return str(data["url"])
	if data.has("image_url"):
		return str(data["image_url"])
	if data.has("output") and data["output"] is Dictionary:
		var output: Dictionary = data["output"]
		if output.has("url"):
			return str(output["url"])
	return ""


func _extract_image_base64(data: Dictionary) -> String:
	if data.has("data") and data["data"] is Array:
		var items: Array = data["data"]
		if not items.is_empty() and items[0] is Dictionary:
			var first: Dictionary = items[0]
			if first.has("b64_json"):
				return str(first["b64_json"])
			if first.has("base64"):
				return str(first["base64"])
	if data.has("b64_json"):
		return str(data["b64_json"])
	if data.has("base64"):
		return str(data["base64"])
	return ""


func _save_base64_image_to_cache(image_b64: String, cache_key: String) -> String:
	var bytes: PackedByteArray = Marshalls.base64_to_raw(image_b64)
	if bytes.is_empty():
		request_failed.emit("image", "Decoded base64 image is empty.")
		return ""
	var local_path := get_cached_image_path(cache_key)
	var file := FileAccess.open(local_path, FileAccess.WRITE)
	if file == null:
		request_failed.emit("image", "Unable to write decoded image cache file: %s" % local_path)
		return ""
	file.store_buffer(bytes)
	return local_path


func _ensure_cache_dir() -> void:
	var absolute_cache_dir := ProjectSettings.globalize_path(CACHE_DIR)
	DirAccess.make_dir_recursive_absolute(absolute_cache_dir)


func _cache_key_from_prompt(text: String) -> String:
	return text.strip_edges().md5_text()


func _safe_key(text: String) -> String:
	var key := text.strip_edges()
	if key == "":
		return "empty"
	var normalized := key.to_lower().replace(" ", "_")
	normalized = normalized.replace("/", "_")
	normalized = normalized.replace("\\", "_")
	normalized = normalized.replace(":", "_")
	return normalized.md5_text()


func _join_url(left: String, right: String) -> String:
	var base := left.strip_edges()
	if base.ends_with("/"):
		base = base.substr(0, base.length() - 1)
	var route := right.strip_edges()
	if not route.begins_with("/"):
		route = "/" + route
	return base + route


func _join_path(left: String, right: String) -> String:
	var base := left.strip_edges()
	var suffix := right.strip_edges()
	if base.ends_with("/"):
		base = base.substr(0, base.length() - 1)
	if suffix.begins_with("/"):
		suffix = suffix.substr(1, suffix.length() - 1)
	return base + "/" + suffix
