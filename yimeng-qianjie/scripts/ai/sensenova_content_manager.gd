extends Node

## 高层封装：把《一梦千劫》的业务数据转成商汤请求，减少各系统重复写提示词。

signal npc_generated(success: bool, content: String)
signal item_generated(success: bool, content: String)
signal skill_generated(success: bool, content: String)
signal background_generated(success: bool, local_path: String)
signal portrait_generated(success: bool, local_path: String)
signal item_icon_generated(success: bool, local_path: String)
signal skill_icon_generated(success: bool, local_path: String)
signal encounter_generated(success: bool, content: String)
signal image_generated(success: bool, local_path: String)
signal generation_failed(kind: String, message: String)

var _api: Node = null
var _registry: Node = null
var _pending_image_kind: String = ""
var _pending_record_kind: String = ""
var _pending_record_key: String = ""
var _pending_record_data: Dictionary = {}


func _ready() -> void:
	call_deferred("_connect_services")


func _connect_services() -> void:
	_api = get_node_or_null("/root/SenseNovaAPI")
	_registry = get_node_or_null("/root/SenseNovaContentRegistry")
	if _api != null:
		if _api.has_signal("chat_finished") and not _api.chat_finished.is_connected(_on_chat_finished):
			_api.chat_finished.connect(_on_chat_finished)
		if _api.has_signal("image_saved") and not _api.image_saved.is_connected(_on_image_saved):
			_api.image_saved.connect(_on_image_saved)
		if _api.has_signal("request_failed") and not _api.request_failed.is_connected(_on_request_failed):
			_api.request_failed.connect(_on_request_failed)


func is_ready() -> bool:
	return _api != null and _api.has_method("is_configured") and bool(_api.call("is_configured"))


func register_content(kind: String, key: String, data: Dictionary, local_path: String = "", extra_paths: Array[String] = []) -> void:
	if _registry != null and _registry.has_method("upsert_generated_content"):
		_registry.call("upsert_generated_content", kind, key, data, local_path, extra_paths)


func remove_content(kind: String, key: String, delete_files: bool = true) -> bool:
	if _registry != null and _registry.has_method("remove_record"):
		return bool(_registry.call("remove_record", kind, key, delete_files))
	return false


func list_content(kind: String = "") -> Array[Dictionary]:
	if _registry != null and _registry.has_method("list_records"):
		var value: Variant = _registry.call("list_records", kind)
		if value is Array:
			return value
	return []


func clear_content(kind: String = "", delete_files: bool = true) -> int:
	if _registry == null:
		return 0
	if kind.strip_edges() == "":
		if _registry.has_method("clear_all"):
			return int(_registry.call("clear_all", delete_files))
		return 0
	if _registry.has_method("clear_kind"):
		return int(_registry.call("clear_kind", kind, delete_files))
	return 0


func request_npc(name: String, realm: String = "", personality: String = "", background: String = "", sex: String = "") -> void:
	if not is_ready():
		generation_failed.emit("npc", "SenseNova is not configured.")
		return
	_pending_record_kind = "npc"
	_pending_record_key = name
	_pending_record_data = {
		"name": name,
		"realm": realm,
		"personality": personality,
		"background": background,
		"sex": sex,
	}
	_api.call("request_chat", AIPromptFactory.npc_profile_prompt(name, realm, personality, background, sex))


func request_portrait(name: String, realm: String = "", personality: String = "", appearance: String = "", sex: String = "", posture: String = "站立半身像") -> void:
	if not is_ready():
		generation_failed.emit("portrait", "SenseNova is not configured.")
		return
	_pending_image_kind = "portrait"
	_pending_record_kind = "portrait"
	_pending_record_key = name
	_pending_record_data = {
		"name": name,
		"realm": realm,
		"personality": personality,
		"appearance": appearance,
		"sex": sex,
		"posture": posture,
	}
	_api.call("request_image", AIPromptFactory.portrait_prompt(name, realm, personality, appearance, sex, posture))


func request_item(item_name: String, item_type: String = "装备", grade: String = "", effect_hint: String = "") -> void:
	if not is_ready():
		generation_failed.emit("item", "SenseNova is not configured.")
		return
	_pending_record_kind = "item"
	_pending_record_key = item_name
	_pending_record_data = {
		"name": item_name,
		"type": item_type,
		"grade": grade,
		"effect_hint": effect_hint,
	}
	_api.call("request_chat", AIPromptFactory.item_profile_prompt(item_name, item_type, grade, effect_hint))


func request_item_icon(item_name: String, item_type: String = "装备", grade: String = "", style_hint: String = "") -> void:
	if not is_ready():
		generation_failed.emit("item_icon", "SenseNova is not configured.")
		return
	_pending_image_kind = "item_icon"
	_pending_record_kind = "item_icon"
	_pending_record_key = item_name
	_pending_record_data = {
		"name": item_name,
		"type": item_type,
		"grade": grade,
		"style_hint": style_hint,
	}
	_api.call("request_image", AIPromptFactory.item_icon_prompt(item_name, item_type, grade, style_hint))


func request_skill(skill_name: String, skill_type: String = "功法", realm: String = "", effect_hint: String = "") -> void:
	if not is_ready():
		generation_failed.emit("skill", "SenseNova is not configured.")
		return
	_pending_record_kind = "skill"
	_pending_record_key = skill_name
	_pending_record_data = {
		"name": skill_name,
		"type": skill_type,
		"realm": realm,
		"effect_hint": effect_hint,
	}
	_api.call("request_chat", AIPromptFactory.skill_profile_prompt(skill_name, skill_type, realm, effect_hint))


func request_skill_icon(skill_name: String, skill_type: String = "功法", element: String = "", style_hint: String = "") -> void:
	if not is_ready():
		generation_failed.emit("skill_icon", "SenseNova is not configured.")
		return
	_pending_image_kind = "skill_icon"
	_pending_record_kind = "skill_icon"
	_pending_record_key = skill_name
	_pending_record_data = {
		"name": skill_name,
		"type": skill_type,
		"element": element,
		"style_hint": style_hint,
	}
	_api.call("request_image", AIPromptFactory.skill_icon_prompt(skill_name, skill_type, element, style_hint))


func request_background(location_name: String, atmosphere: String = "", scene_type: String = "") -> void:
	if not is_ready():
		generation_failed.emit("background", "SenseNova is not configured.")
		return
	_pending_image_kind = "background"
	_pending_record_kind = "background"
	_pending_record_key = location_name
	_pending_record_data = {
		"name": location_name,
		"atmosphere": atmosphere,
		"scene_type": scene_type,
	}
	_api.call("request_image", AIPromptFactory.background_prompt(location_name, atmosphere, scene_type))


func request_encounter(event_name: String, context: String = "") -> void:
	if not is_ready():
		generation_failed.emit("encounter", "SenseNova is not configured.")
		return
	_pending_record_kind = "encounter"
	_pending_record_key = event_name
	_pending_record_data = {
		"name": event_name,
		"context": context,
	}
	_api.call("request_chat", AIPromptFactory.encounter_prompt(event_name, context))


func _on_chat_finished(success: bool, content: String, raw: Dictionary) -> void:
	if _pending_record_key.strip_edges().is_empty():
		return
	var text := content.strip_edges()
	if text.find("姓名：") != -1 or text.find("名称：") != -1:
		npc_generated.emit(success, content)
		if success:
			register_content("npc", _pending_record_key, _pending_record_data, "", [])
	elif text.find("类型：") != -1 and text.find("主要效果：") != -1:
		item_generated.emit(success, content)
		if success:
			register_content("item", _pending_record_key, _pending_record_data, "", [])
	elif text.find("定位：") != -1 and text.find("核心机制：") != -1:
		skill_generated.emit(success, content)
		if success:
			register_content("skill", _pending_record_key, _pending_record_data, "", [])
	elif text.find("标题：") != -1 and text.find("选择A：") != -1:
		encounter_generated.emit(success, content)
		if success:
			register_content("encounter", _pending_record_key, {"name": _pending_record_key, "content": content, "context": _pending_record_data.get("context", "")}, "", [])
	else:
		# 无法自动识别时，仍保持可用，便于外部脚本自行接收通用回复。
		encounter_generated.emit(success, content)
		if success:
			register_content("encounter", _pending_record_key, {"name": _pending_record_key, "content": content, "context": _pending_record_data.get("context", "")}, "", [])
	_clear_pending_record()


func _on_image_saved(success: bool, local_path: String, raw: Dictionary) -> void:
	if _pending_image_kind.is_empty():
		return
	if not success:
		_clear_pending_record()
		return
	image_generated.emit(true, local_path)
	match _pending_image_kind:
		"portrait":
			portrait_generated.emit(true, local_path)
			register_content("portrait", _pending_record_key, _pending_record_data, local_path, [])
		"item_icon":
			item_icon_generated.emit(true, local_path)
			register_content("item_icon", _pending_record_key, _pending_record_data, local_path, [])
		"skill_icon":
			skill_icon_generated.emit(true, local_path)
			register_content("skill_icon", _pending_record_key, _pending_record_data, local_path, [])
		"background":
			background_generated.emit(true, local_path)
			register_content("background", _pending_record_key, _pending_record_data, local_path, [])
		_:
			pass
	_clear_pending_record()


func _on_request_failed(kind: String, message: String) -> void:
	_clear_pending_record()
	generation_failed.emit(kind, message)


func _clear_pending_record() -> void:
	_pending_image_kind = ""
	_pending_record_kind = ""
	_pending_record_key = ""
	_pending_record_data = {}
