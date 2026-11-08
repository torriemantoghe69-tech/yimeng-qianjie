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


func refresh_from_disk() -> int:
	# 重新读取磁盘索引，并把曾经生成成功、但尚未写入索引的本地图片补登记。
	load_index()
	var imported := 0
	var dir := DirAccess.open(AI_CACHE_PREFIX)
	if dir == null:
		return 0
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var extension := file_name.get_extension().to_lower()
			if extension in ["png", "jpg", "jpeg", "webp"]:
				var absolute_path := AI_CACHE_PREFIX + file_name
				var already_indexed := false
				for record: Dictionary in list_records():
					if str(record.get("local_path", "")) == absolute_path:
						already_indexed = true
						break
				if not already_indexed:
					set_record("local_image", file_name.get_basename(), {"source": "local_cache_scan", "note": "从本地图片缓存自动发现；原始名称未知。"}, absolute_path)
					imported += 1
		file_name = dir.get_next()
	dir.list_dir_end()
	return imported


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


func restore_backup(backup_path: String) -> bool:
	if not backup_path.begins_with(BACKUP_DIR + "/"):
		return false
	var backup := _read_json(backup_path)
	if backup.is_empty():
		return false
	var kind := str(backup.get("kind", ""))
	var key := str(backup.get("key", ""))
	var record_value: Variant = backup.get("record", {})
	if kind == "" or key == "" or not (record_value is Dictionary):
		return false
	var record: Dictionary = record_value
	var data_value: Variant = record.get("data", {})
	if not (data_value is Dictionary):
		return false
	var extras: Array[String] = []
	var extras_value: Variant = record.get("extra_paths", [])
	if extras_value is Array:
		for path_value in extras_value:
			extras.append(str(path_value))
	set_record(kind, key, data_value, str(record.get("local_path", "")), extras)
	return true


func upsert_generated_content(kind: String, key: String, data: Dictionary, local_path: String = "", extra_paths: Array = []) -> void:
	# call() 传入的 [] 是普通 Array，不能直接匹配 Array[String]。
	var typed_extra_paths: Array[String] = []
	for path_value in extra_paths:
		typed_extra_paths.append(str(path_value))
	set_record(kind, key, data, local_path, typed_extra_paths)


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
	var stamp := Time.get_unix_time_from_system()
	var backup_record: Dictionary = (record as Dictionary).duplicate(true) if record is Dictionary else {}
	var source_path := str(backup_record.get("local_path", ""))
	if source_path.begins_with(AI_CACHE_PREFIX) and FileAccess.file_exists(source_path):
		var saved_path := _copy_to_backup(source_path, safe_name, stamp)
		if saved_path != "":
			backup_record["local_path"] = saved_path
	var extra_value: Variant = backup_record.get("extra_paths", [])
	if extra_value is Array:
		var saved_extras: Array[String] = []
		for extra_path_value in extra_value:
			var extra_path := str(extra_path_value)
			if extra_path.begins_with(AI_CACHE_PREFIX) and FileAccess.file_exists(extra_path):
				var saved_extra := _copy_to_backup(extra_path, safe_name, stamp)
				saved_extras.append(saved_extra if saved_extra != "" else extra_path)
			else:
				saved_extras.append(extra_path)
		backup_record["extra_paths"] = saved_extras
	var backup_path := "%s/%s_%d.json" % [BACKUP_DIR, safe_name, stamp]
	var file := FileAccess.open(backup_path, FileAccess.WRITE)
	if file == null:
		push_warning("无法写入 AI 内容备份：%s" % backup_path)
		return
	file.store_string(JSON.stringify({"kind": kind, "key": key, "record": backup_record}, "\t"))


func _copy_to_backup(source_path: String, safe_name: String, stamp: int) -> String:
	var source_file := FileAccess.open(source_path, FileAccess.READ)
	if source_file == null:
		return ""
	var extension := source_path.get_extension()
	var file_name := "%s_%d.%s" % [safe_name, stamp, extension if extension != "" else "bin"]
	var destination := "%s/%s" % [BACKUP_DIR, file_name]
	var destination_file := FileAccess.open(destination, FileAccess.WRITE)
	if destination_file == null:
		return ""
	destination_file.store_buffer(source_file.get_buffer(source_file.get_length()))
	return destination


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
