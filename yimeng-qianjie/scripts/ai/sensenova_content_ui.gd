extends Node
class_name SenseNovaContentUI

## 轻量级内容管理界面：查看、录入、删除《一梦千劫》的 AI / 手工内容。
## 作为自动加载节点挂在游戏里，不改主场景也能直接使用。

const KIND_OPTIONS: Array[String] = [
	"全部",
	"npc",
	"portrait",
	"item",
	"item_icon",
	"skill",
	"skill_icon",
	"background",
	"encounter",
]

var _registry: Node = null
var _layer: CanvasLayer
var _toggle_button: Button
var _panel: PanelContainer
var _kind_filter: OptionButton
var _search_edit: LineEdit
var _record_list: ItemList
var _details: RichTextLabel
var _status_label: Label
var _manual_kind: OptionButton
var _manual_key: LineEdit
var _manual_text: TextEdit
var _manual_save: Button
var _delete_button: Button
var _clear_button: Button
var _refresh_button: Button

func _ready() -> void:
	call_deferred("_build_ui")


func _build_ui() -> void:
	if _layer != null:
		return
	_registry = get_node_or_null("/root/SenseNovaContentRegistry")
	_layer = CanvasLayer.new()
	_layer.layer = 120
	add_child(_layer)

	var root := Control.new()
	root.name = "ContentManagerOverlay"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(root)

	_toggle_button = Button.new()
	_toggle_button.text = "内容管理"
	_toggle_button.custom_minimum_size = Vector2(112, 34)
	_toggle_button.anchor_left = 1.0
	_toggle_button.anchor_top = 1.0
	_toggle_button.anchor_right = 1.0
	_toggle_button.anchor_bottom = 1.0
	_toggle_button.offset_left = -126
	_toggle_button.offset_top = -54
	_toggle_button.offset_right = -14
	_toggle_button.offset_bottom = -20
	_toggle_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_toggle_button.pressed.connect(_toggle_panel)
	root.add_child(_toggle_button)

	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -430
	_panel.offset_top = -280
	_panel.offset_right = 430
	_panel.offset_bottom = 280
	root.add_child(_panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 14)
	panel_margin.add_theme_constant_override("margin_right", 14)
	panel_margin.add_theme_constant_override("margin_top", 12)
	panel_margin.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(panel_margin)

	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 8)
	panel_margin.add_child(main)

	main.add_child(_build_header())
	main.add_child(_build_toolbar())
	main.add_child(_build_body())
	main.add_child(_build_manual_section())

	_refresh_all()


func _build_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 1)
	row.add_child(title_box)

	var title := Label.new()
	title.text = "内容管理"
	title.add_theme_font_size_override("font_size", 22)
	title_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "查看、添加、删除已生成内容，并同步清理缓存文件。"
	subtitle.add_theme_font_size_override("font_size", 10)
	title_box.add_child(subtitle)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(84, 32)
	close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_button.pressed.connect(_toggle_panel)
	row.add_child(close_button)
	return row


func _build_toolbar() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	_kind_filter = OptionButton.new()
	_kind_filter.custom_minimum_size = Vector2(120, 32)
	for idx: int in range(KIND_OPTIONS.size()):
		_kind_filter.add_item(KIND_OPTIONS[idx], idx)
	_kind_filter.select(0)
	_kind_filter.item_selected.connect(_on_filter_changed)
	row.add_child(_kind_filter)

	_search_edit = LineEdit.new()
	_search_edit.placeholder_text = "搜索名称 / 关键字"
	_search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_edit.text_changed.connect(_on_search_changed)
	row.add_child(_search_edit)

	_refresh_button = Button.new()
	_refresh_button.text = "刷新"
	_refresh_button.custom_minimum_size = Vector2(64, 32)
	_refresh_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_refresh_button.pressed.connect(_refresh_all)
	row.add_child(_refresh_button)

	_delete_button = Button.new()
	_delete_button.text = "删除选中"
	_delete_button.custom_minimum_size = Vector2(92, 32)
	_delete_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_delete_button.pressed.connect(_delete_selected)
	row.add_child(_delete_button)

	_clear_button = Button.new()
	_clear_button.text = "清空当前类"
	_clear_button.custom_minimum_size = Vector2(100, 32)
	_clear_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_clear_button.pressed.connect(_clear_current_kind)
	row.add_child(_clear_button)

	return row


func _build_body() -> Control:
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.custom_minimum_size = Vector2(0, 250)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 6)
	body.add_child(left)

	var list_label := Label.new()
	list_label.text = "内容列表"
	list_label.add_theme_font_size_override("font_size", 13)
	left.add_child(list_label)

	_record_list = ItemList.new()
	_record_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_record_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_record_list.allow_rmb_select = true
	_record_list.allow_reselect = true
	_record_list.item_selected.connect(_on_record_selected)
	left.add_child(_record_list)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(290, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	body.add_child(right)

	var det_label := Label.new()
	det_label.text = "详情"
	det_label.add_theme_font_size_override("font_size", 13)
	right.add_child(det_label)

	_details = RichTextLabel.new()
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details.scroll_active = true
	_details.fit_content = true
	_details.bbcode_enabled = true
	_details.custom_minimum_size = Vector2(0, 220)
	right.add_child(_details)

	_status_label = Label.new()
	_status_label.text = ""
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_status_label)

	return body


func _build_manual_section() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 5)
	margin.add_child(main)

	var head := Label.new()
	head.text = "手动录入"
	head.add_theme_font_size_override("font_size", 12)
	main.add_child(head)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	main.add_child(top_row)

	_manual_kind = OptionButton.new()
	_manual_kind.custom_minimum_size = Vector2(120, 30)
	for idx: int in range(1, KIND_OPTIONS.size()):
		_manual_kind.add_item(KIND_OPTIONS[idx], idx)
	_manual_kind.select(0)
	top_row.add_child(_manual_kind)

	_manual_key = LineEdit.new()
	_manual_key.placeholder_text = "名称 / 键值"
	_manual_key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(_manual_key)

	_manual_save = Button.new()
	_manual_save.text = "保存文本"
	_manual_save.custom_minimum_size = Vector2(86, 30)
	_manual_save.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_manual_save.pressed.connect(_save_manual_record)
	top_row.add_child(_manual_save)

	_manual_text = TextEdit.new()
	_manual_text.placeholder_text = "输入要保存的文本内容"
	_manual_text.custom_minimum_size = Vector2(0, 72)
	_manual_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_manual_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_manual_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	main.add_child(_manual_text)

	return panel


func _toggle_panel() -> void:
	_build_ui()
	_panel.visible = not _panel.visible
	if _panel.visible:
		_refresh_all()


func _on_filter_changed(_index: int) -> void:
	_refresh_all()


func _on_search_changed(_text: String) -> void:
	_refresh_all()


func _on_record_selected(_index: int) -> void:
	_show_selected_details()


func _refresh_all() -> void:
	if _registry == null or not is_instance_valid(_panel):
		if _status_label != null:
			_status_label.text = "内容索引尚未准备好。"
		return
	_refresh_record_list()
	_show_selected_details()
	_update_status()


func _refresh_record_list() -> void:
	_record_list.clear()
	var kind := _current_kind_filter()
	var query := _search_edit.text.strip_edges().to_lower()
	var records: Array[Dictionary] = _get_records(kind)
	for record: Dictionary in records:
		var display := _record_display_text(record)
		if not query.is_empty():
			var haystack := display.to_lower() + " " + String(record.get("kind", "")).to_lower() + " " + String(record.get("key", "")).to_lower()
			if haystack.find(query) == -1:
				continue
		_record_list.add_item(display)
		_record_list.set_item_metadata(_record_list.item_count - 1, record)
	if _record_list.item_count > 0 and _record_list.get_selected_items().is_empty():
		_record_list.select(0)
		_show_selected_details()


func _show_selected_details() -> void:
	var record := _selected_record()
	if record.is_empty():
		_details.text = "请选择左侧条目。"
		return
	var kind := String(record.get("kind", ""))
	var key := String(record.get("key", ""))
	var updated_at := int(record.get("updated_at", 0))
	var local_path := String(record.get("local_path", ""))
	var extra_paths: Array = record.get("extra_paths", [])
	var data := record.get("data", {})
	var head := "[b]%s[/b]\n键值：%s\n更新时间：%s\n" % [kind, key, _time_text(updated_at)]
	if not local_path.is_empty():
		head += "缓存：%s\n" % local_path
	if extra_paths is Array and not extra_paths.is_empty():
		head += "附加文件：%s\n" % ", ".join(PackedStringArray(extra_paths))
	head += "\n[b]数据[/b]\n"
	_details.bbcode_text = head + _json_text(data)
	_status_label.text = "当前选中：%s / %s" % [kind, key]


func _save_manual_record() -> void:
	if _registry == null:
		_status_label.text = "内容索引未准备好。"
		return
	var kind := _current_manual_kind()
	var key := _manual_key.text.strip_edges()
	var text := _manual_text.text.strip_edges()
	if kind.is_empty() or key.is_empty() or text.is_empty():
		_status_label.text = "请先填完整类目、名称和内容。"
		return
	if _registry.has_method("upsert_generated_content"):
		_registry.call("upsert_generated_content", kind, key, {"text": text, "source": "manual"}, "", [])
		_status_label.text = "已保存：%s / %s" % [kind, key]
		_refresh_all()
		_select_by_key(kind, key)


func _delete_selected() -> void:
	var record := _selected_record()
	if record.is_empty() or _registry == null:
		return
	var kind := String(record.get("kind", ""))
	var key := String(record.get("key", ""))
	if _registry.has_method("remove_record"):
		var ok: bool = bool(_registry.call("remove_record", kind, key, true))
		_status_label.text = "已删除：%s / %s" % [kind, key] if ok else "删除失败"
		_refresh_all()


func _clear_current_kind() -> void:
	if _registry == null:
		return
	var kind := _current_kind_filter()
	if kind == "全部":
		if _registry.has_method("clear_all"):
			_registry.call("clear_all", true)
			_status_label.text = "已清空全部内容。"
	else:
		if _registry.has_method("clear_kind"):
			_registry.call("clear_kind", kind, true)
			_status_label.text = "已清空类目：%s" % kind
	_refresh_all()


func _selected_record() -> Dictionary:
	var selected := _record_list.get_selected_items()
	if selected.is_empty():
		return {}
	var idx := int(selected[0])
	var meta: Variant = _record_list.get_item_metadata(idx)
	if meta is Dictionary:
		return meta
	return {}


func _select_by_key(kind: String, key: String) -> void:
	for i: int in range(_record_list.item_count):
		var meta: Variant = _record_list.get_item_metadata(i)
		if not meta is Dictionary:
			continue
		var record: Dictionary = meta
		if String(record.get("kind", "")) == kind and String(record.get("key", "")) == key:
			_record_list.select(i)
			_show_selected_details()
			return


func _update_status() -> void:
	if _registry == null:
		_status_label.text = "内容索引未连接。"
		return
	var snapshot: Dictionary = {}
	if _registry.has_method("get_index_snapshot"):
		snapshot = _registry.call("get_index_snapshot")
	var items: Dictionary = snapshot.get("items", {}) if snapshot is Dictionary else {}
	var total := 0
	for bucket_key: Variant in items.keys():
		var bucket: Dictionary = items[bucket_key]
		total += bucket.size()
	_status_label.text = "当前类目：%s · 共 %d 条" % [_current_kind_filter(), total]


func _current_kind_filter() -> String:
	var idx := _kind_filter.selected if _kind_filter != null else 0
	idx = clampi(idx, 0, KIND_OPTIONS.size() - 1)
	return KIND_OPTIONS[idx]


func _current_manual_kind() -> String:
	var idx := _manual_kind.selected if _manual_kind != null else 0
	idx = clampi(idx + 1, 1, KIND_OPTIONS.size() - 1)
	return KIND_OPTIONS[idx]


func _get_records(kind: String) -> Array[Dictionary]:
	if _registry == null or not _registry.has_method("list_records"):
		return []
	var value: Variant = _registry.call("list_records", "" if kind == "全部" else kind)
	if value is Array:
		return value
	return []


func _record_display_text(record: Dictionary) -> String:
	var kind := String(record.get("kind", ""))
	var key := String(record.get("key", ""))
	var data: Dictionary = record.get("data", {})
	var summary := key
	if data.has("name"):
		summary = String(data.get("name", key))
	elif data.has("text"):
		summary = String(data.get("text", key)).left(26)
	return "%s · %s" % [kind, summary]


func _json_text(data: Variant) -> String:
	if data is Dictionary or data is Array:
		return JSON.stringify(data, "\t")
	return str(data)


func _time_text(unix_time: int) -> String:
	if unix_time <= 0:
		return "未知"
	return Time.get_datetime_string_from_unix_time(unix_time, true)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.96, 0.93, 0.86, 0.98)
	style.border_color = Color(0.60, 0.52, 0.40, 0.32)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
