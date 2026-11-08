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


func restore_content_backup(backup_path: String) -> bool:
	if _registry != null and _registry.has_method("restore_backup"):
		return bool(_registry.call("restore_backup", backup_path))
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


func apply_content_to_current_game(kind: String, key: String) -> Dictionary:
	if _registry == null:
		return {"ok": false, "message": "内容索引尚未连接。"}
	var record_value: Variant = _registry.call("get_record", kind, key)
	if not (record_value is Dictionary) or (record_value as Dictionary).is_empty():
		return {"ok": false, "message": "找不到选中的内容。"}
	var record: Dictionary = record_value
	var data_value: Variant = record.get("data", {})
	var data: Dictionary = data_value if data_value is Dictionary else {}
	var content_text := str(data.get("text", data.get("content", ""))).strip_edges()
	var structured: Dictionary = _parse_generated_json(content_text)
	if not structured.is_empty():
		data.merge(structured, true)
	var scene: Node = get_tree().current_scene
	if scene == null:
		return {"ok": false, "message": "当前没有运行中的游戏场景。"}
	var state_value: Variant = scene.get("state")
	if not (state_value is GameState):
		return {"ok": false, "message": "当前没有正在进行的一世存档，请先进入游戏。"}
	var state: GameState = state_value
	match kind:
		"npc":
			var npc_name := str(data.get("name", key)).strip_edges()
			if npc_name.is_empty():
				npc_name = key
			var npc_profile: Dictionary = data.duplicate(true)
			npc_profile["name"] = npc_name
			npc_profile["source"] = "sensenova"
			var found := false
			for index: int in range(state.met_npcs.size()):
				if str(state.met_npcs[index].get("name", "")) == npc_name:
					state.met_npcs[index].merge(npc_profile, true)
					found = true
					break
			if not found:
				state.met_npcs.append(npc_profile)
		"item":
			if not state.treasures.has(key):
				state.treasures.append(key)
			var items_value: Variant = state.flags.get("ai_generated_items", {})
			var items: Dictionary = items_value if items_value is Dictionary else {}
			items[key] = data.duplicate(true)
			state.flags["ai_generated_items"] = items
		"skill":
			if not state.learned_skills.has(key):
				state.learned_skills.append(key)
			var skills_value: Variant = state.flags.get("ai_generated_skills", {})
			var skills: Dictionary = skills_value if skills_value is Dictionary else {}
			skills[key] = data.duplicate(true)
			state.flags["ai_generated_skills"] = skills
		"encounter":
			var event_text := content_text if content_text != "" else str(data.get("description", key))
			state.add_log("【AI 奇遇·%s】%s" % [key, event_text], "story")
		"portrait":
			var portraits_value: Variant = state.flags.get("ai_portraits", {})
			var portraits: Dictionary = portraits_value if portraits_value is Dictionary else {}
			portraits[key] = str(record.get("local_path", ""))
			state.flags["ai_portraits"] = portraits
		"background":
			state.flags["ai_current_background"] = str(record.get("local_path", ""))
		_:
			return {"ok": false, "message": "该类内容暂不支持直接应用到当前存档。"}
	if scene.has_method("_save_run"):
		scene.call("_save_run")
	if scene.has_method("_refresh_game_ui"):
		scene.call("_refresh_game_ui")
	return {"ok": true, "message": "已应用 %s「%s」，并保存当前存档。" % [kind, key]}


func _parse_generated_json(content: String) -> Dictionary:
	if content.is_empty():
		return {}
	var candidate := content.strip_edges()
	if candidate.begins_with("```"):
		candidate = candidate.replace("```json", "").replace("```", "").strip_edges()
	var parsed: Variant = JSON.parse_string(candidate)
	if parsed is Dictionary:
		return parsed
	return {}

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
			var saved_npc: Dictionary = _pending_record_data.duplicate(true)
			saved_npc["text"] = content
			register_content("npc", _pending_record_key, saved_npc, "", [])
	elif text.find("类型：") != -1 and text.find("主要效果：") != -1:
		item_generated.emit(success, content)
		if success:
			var saved_item: Dictionary = _pending_record_data.duplicate(true)
			saved_item["text"] = content
			register_content("item", _pending_record_key, saved_item, "", [])
	elif text.find("定位：") != -1 and text.find("核心机制：") != -1:
		skill_generated.emit(success, content)
		if success:
			var saved_skill: Dictionary = _pending_record_data.duplicate(true)
			saved_skill["text"] = content
			register_content("skill", _pending_record_key, saved_skill, "", [])
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
