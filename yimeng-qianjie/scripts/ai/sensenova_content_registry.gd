extends Node

## 内容索引：用于保存、查找、删除《一梦千劫》里由商汤或人工录入的内容。
## 以后无论是 NPC、装备、功法还是背景图，都可以统一登记到这里。

const INDEX_PATH := "user://ai_content_index.json"
const BACKUP_DIR := "user://ai_content_backups"
const AI_CACHE_PREFIX := "user://ai_cache/"
const DEFAULT_VERSION := 1

var _index: Dictionary = {
	"version": DEFAULT_VERSION,
	"items": {},
}


func _ready() -> void:
	load_index()


func load_index() -> void:
	var data := _read_json(INDEX_PATH)
	if data.is_empty():
		_index = {
			"version": DEFAULT_VERSION,
			"items": {},
		}
		return
	if not data.has("items") or not (data["items"] is Dictionary):
		data["items"] = {}
	if not data.has("version"):
		data["version"] = DEFAULT_VERSION
	_index = data


func save_index() -> bool:
	_ensure_parent_dir(INDEX_PATH)
	var file := FileAccess.open(INDEX_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(_index, "\t"))
	return true


func set_record(kind: String, key: String, data: Dictionary, local_path: String = "", extra_paths: Array[String] = []) -> void:
	var kind_key := _safe_key(kind)
	var item_key := _safe_key(key)
	if kind_key == "" or item_key == "":
		return
	var items := _ensure_items_bucket(kind_key)
	if items.has(item_key):
		_backup_record(kind, key, items[item_key])
	var record: Dictionary = {
		"kind": kind,
		"key": key,
		"data": data.duplicate(true),
		"local_path": local_path,
		"extra_paths": extra_paths.duplicate(),
		"updated_at": Time.get_unix_time_from_system(),
	}
	items[item_key] = record
	_index["items"][kind_key] = items
	save_index()


func get_record(kind: String, key: String) -> Dictionary:
	var kind_key := _safe_key(kind)
	var item_key := _safe_key(key)
	if kind_key == "" or item_key == "":
		return {}
	var items: Dictionary = _index.get("items", {})
	if not items.has(kind_key):
		return {}
	var bucket: Dictionary = items[kind_key]
	if not bucket.has(item_key):
		return {}
	var record: Dictionary = bucket[item_key]
	return record.duplicate(true)


func has_record(kind: String, key: String) -> bool:
	return not get_record(kind, key).is_empty()


func list_records(kind: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var items: Dictionary = _index.get("items", {})
	if kind.strip_edges() == "":
		for bucket_key in items.keys():
			var bucket: Dictionary = items[bucket_key]
			for entry_key in bucket.keys():
				result.append((bucket[entry_key] as Dictionary).duplicate(true))
			
		return result
	var kind_key := _safe_key(kind)
	if not items.has(kind_key):
		return result
	var bucket2: Dictionary = items[kind_key]
	for entry_key2 in bucket2.keys():
		result.append((bucket2[entry_key2] as Dictionary).duplicate(true))
	return result


func remove_record(kind: String, key: String, delete_files: bool = true) -> bool:
	var kind_key := _safe_key(kind)
	var item_key := _safe_key(key)
	if kind_key == "" or item_key == "":
		return false
	var items: Dictionary = _index.get("items", {})
	if not items.has(kind_key):
		return false
	var bucket: Dictionary = items[kind_key]
	if not bucket.has(item_key):
		return false
	var record: Dictionary = bucket[item_key]
	_backup_record(kind, key, record)
	if delete_files:
		_delete_record_files(record)
	bucket.erase(item_key)
	items[kind_key] = bucket
	_index["items"] = items
	save_index()
	return true


func clear_kind(kind: String, delete_files: bool = true) -> int:
	var kind_key := _safe_key(kind)
	if kind_key == "":
		return 0
	var items: Dictionary = _index.get("items", {})
	if not items.has(kind_key):
		return 0
	var bucket: Dictionary = items[kind_key]
	var count := 0
	for entry_key in bucket.keys():
		_backup_record(kind, str(bucket[entry_key].get("key", entry_key)), bucket[entry_key])
		var record: Dictionary = bucket[entry_key]
		if delete_files:
			_delete_record_files(record)
		count += 1
	items.erase(kind_key)
	_index["items"] = items
	save_index()
	return count


func clear_all(delete_files: bool = true) -> int:
	var total := 0
	var items: Dictionary = _index.get("items", {})
	for kind_key in items.keys():
		var bucket: Dictionary = items[kind_key]
		for entry_key in bucket.keys():
			_backup_record(str(bucket[entry_key].get("kind", kind_key)), str(bucket[entry_key].get("key", entry_key)), bucket[entry_key])
			if delete_files:
				_delete_record_files(bucket[entry_key])
			total += 1
	_index["items"] = {}
	save_index()
	return total


func upsert_generated_content(kind: String, key: String, data: Dictionary, local_path: String = "", extra_paths: Array[String] = []) -> void:
	set_record(kind, key, data, local_path, extra_paths)


func get_index_snapshot() -> Dictionary:
	return _index.duplicate(true)


func _ensure_items_bucket(kind_key: String) -> Dictionary:
	var items: Dictionary = _index.get("items", {})
	if not items.has(kind_key) or not (items[kind_key] is Dictionary):
		items[kind_key] = {}
	return items[kind_key]


func _delete_record_files(record: Dictionary) -> void:
	var paths: Array[String] = []
	var local_path := str(record.get("local_path", ""))
	if local_path.strip_edges() != "":
		paths.append(local_path)
	var extra_paths := record.get("extra_paths", [])
	if extra_paths is Array:
		for path_value in extra_paths:
			var p := str(path_value)
			if p.strip_edges() != "":
				paths.append(p)
	for path_value in paths:
		_delete_file(path_value)


func _delete_file(path: String) -> void:
	# 仅允许删除本工具生成的缓存；绝不删除 res:// 工程资源或其他 user:// 文件。
	if not path.begins_with(AI_CACHE_PREFIX):
		return
	var absolute := ProjectSettings.globalize_path(path)
	var cache_absolute := ProjectSettings.globalize_path(AI_CACHE_PREFIX)
	if not absolute.begins_with(cache_absolute):
		return
	if FileAccess.file_exists(absolute):
		var err := DirAccess.remove_absolute(absolute)
		if err != OK:
			push_warning("无法删除 AI 缓存文件：%s" % path)


func _backup_record(kind: String, key: String, record: Variant) -> void:
	var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(BACKUP_DIR))
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		push_warning("无法创建 AI 内容备份目录。")
		return
	var safe_name := _safe_key(kind + "_" + key)
	var backup_path := "%s/%s_%d.json" % [BACKUP_DIR, safe_name, Time.get_unix_time_from_system()]
	var file := FileAccess.open(backup_path, FileAccess.WRITE)
	if file == null:
		push_warning("无法写入 AI 内容备份：%s" % backup_path)
		return
	file.store_string(JSON.stringify({"kind": kind, "key": key, "record": record}, "\t"))


func _ensure_parent_dir(path: String) -> void:
	var global_path := ProjectSettings.globalize_path(path)
	var dir := global_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _safe_key(text: String) -> String:
	var key := text.strip_edges()
	if key == "":
		return ""
	var normalized := key.to_lower().replace(" ", "_")
	normalized = normalized.replace("/", "_")
	normalized = normalized.replace("\\", "_")
	normalized = normalized.replace(":", "_")
	return normalized.md5_text()
