extends Node
class_name SenseNovaContentManager

## 高层封装：把《一梦千劫》的业务数据转成商汤请求，减少各系统重复写提示词。

signal npc_generated(success: bool, content: String)
signal item_generated(success: bool, content: String)
signal skill_generated(success: bool, content: String)
signal background_generated(success: bool, content: String)
signal encounter_generated(success: bool, content: String)
signal image_generated(success: bool, local_path: String)
signal generation_failed(kind: String, message: String)

func _ready() -> void:
	if Engine.has_singleton("SenseNovaAPI"):
		SenseNovaAPI.chat_finished.connect(_on_chat_finished)
		SenseNovaAPI.image_saved.connect(_on_image_saved)
		SenseNovaAPI.request_failed.connect(_on_request_failed)


func is_ready() -> bool:
	return Engine.has_singleton("SenseNovaAPI") and SenseNovaAPI.is_configured()


func request_npc(name: String, realm: String = "", personality: String = "", background: String = "", sex: String = "") -> void:
	if not is_ready():
		generation_failed.emit("npc", "SenseNova is not configured.")
		return
	SenseNovaAPI.request_chat(AIPromptFactory.npc_profile_prompt(name, realm, personality, background, sex))


func request_item(item_name: String, item_type: String = "装备", grade: String = "", effect_hint: String = "") -> void:
	if not is_ready():
		generation_failed.emit("item", "SenseNova is not configured.")
		return
	SenseNovaAPI.request_chat(AIPromptFactory.item_profile_prompt(item_name, item_type, grade, effect_hint))


func request_skill(skill_name: String, skill_type: String = "功法", realm: String = "", effect_hint: String = "") -> void:
	if not is_ready():
		generation_failed.emit("skill", "SenseNova is not configured.")
		return
	SenseNovaAPI.request_chat(AIPromptFactory.skill_profile_prompt(skill_name, skill_type, realm, effect_hint))


func request_background(location_name: String, atmosphere: String = "", scene_type: String = "") -> void:
	if not is_ready():
		generation_failed.emit("background", "SenseNova is not configured.")
		return
	SenseNovaAPI.request_image(AIPromptFactory.background_prompt(location_name, atmosphere, scene_type))


func request_encounter(event_name: String, context: String = "") -> void:
	if not is_ready():
		generation_failed.emit("encounter", "SenseNova is not configured.")
		return
	SenseNovaAPI.request_chat(AIPromptFactory.encounter_prompt(event_name, context))


func _on_chat_finished(success: bool, content: String, raw: Dictionary) -> void:
	var lower := content.left(80)
	if content.find("姓名：") != -1 or content.find("名称：") != -1:
		npc_generated.emit(success, content)
	elif content.find("类型：") != -1 and content.find("主要效果：") != -1:
		item_generated.emit(success, content)
	elif content.find("定位：") != -1 and content.find("核心机制：") != -1:
		skill_generated.emit(success, content)
	elif content.find("标题：") != -1 and content.find("选择A：") != -1:
		encounter_generated.emit(success, content)
	else:
		# 无法自动识别时，仍保持可用，便于外部脚本自行接收通用回复。
		encounter_generated.emit(success, content)


func _on_image_saved(success: bool, local_path: String, raw: Dictionary) -> void:
	if success:
		image_generated.emit(true, local_path)


func _on_request_failed(kind: String, message: String) -> void:
	generation_failed.emit(kind, message)
