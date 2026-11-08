class_name MaterialOverlayUI
extends CanvasLayer

## 独立的材料经济覆盖层。
## 不改动主界面结构，直接在游戏运行时提供材料总览、炼化与精华消耗入口。

const PANEL_WIDTH := 760
const PANEL_HEIGHT := 640
const BUTTON_WIDTH := 92
const BUTTON_HEIGHT := 34

var root_ui: Control
var toggle_button: Button
var panel: PanelContainer
var panel_body: VBoxContainer
var status_label: Label
var category_filter: String = "全部"
var essence_amount: int = 1

func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_refresh_visibility()

func _process(_delta: float) -> void:
	_refresh_visibility()
	if panel != null and panel.visible:
		var state := _get_state()
		if state != null:
			_refresh_panel(state)

func _build_ui() -> void:
	root_ui = Control.new()
	root_ui.name = "MaterialOverlayRoot"
	root_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ui)

	var top_bar := HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.add_theme_constant_override("separation", 8)
	root_ui.add_child(top_bar)
	top_bar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_bar.anchor_left = 1.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = -146
	top_bar.offset_right = -16
	top_bar.offset_top = 16
	top_bar.offset_bottom = 16

	toggle_button = Button.new()
	toggle_button.text = "材料"
	toggle_button.custom_minimum_size = Vector2(78, 36)
	toggle_button.pressed.connect(_toggle_panel)
	top_bar.add_child(toggle_button)

	panel = PanelContainer.new()
	panel.name = "MaterialPanel"
	panel.visible = false
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -PANEL_WIDTH * 0.5
	panel.offset_right = PANEL_WIDTH * 0.5
	panel.offset_top = 72
	panel.offset_bottom = 72 + PANEL_HEIGHT
	root_ui.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	margin.add_child(outer)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.modulate = Color(0.55, 0.49, 0.40, 1.0)
	status_label.text = ""
	outer.add_child(status_label)

	panel_body = VBoxContainer.new()
	panel_body.add_theme_constant_override("separation", 8)
	outer.add_child(panel_body)

func _refresh_visibility() -> void:
	var state := _get_state()
	var can_show := state != null and _is_game_mode()
	if root_ui != null:
		root_ui.visible = can_show
	if toggle_button != null:
		toggle_button.visible = can_show
	if panel != null and not can_show:
		panel.visible = false

func _toggle_panel() -> void:
	if panel == null:
		return
	panel.visible = not panel.visible
	if panel.visible:
		var state := _get_state()
		if state != null:
			_refresh_panel(state)

func _close_panel() -> void:
	if panel != null:
		panel.visible = false

func _get_state() -> GameState:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var value: Variant = scene.get("state")
	if value is GameState:
		return value
	return null

func _is_game_mode() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false
	var mode: Variant = scene.get("ui_mode")
	return String(mode) == "game"

func _refresh_panel(state: GameState) -> void:
	for child in panel_body.get_children():
		child.queue_free()

	panel_body.add_child(_make_header("材 料 经 济", "材料分类、炼化与精华消耗"))
	panel_body.add_child(_make_text("把打怪、探索和州域掉落连成一条线：材料可以炼成精华，精华再直接滋养修行。"))
	panel_body.add_child(_make_text("当前灵石：%d · 材料种类：%d · 精华总数：%d" % [state.stones, _nonzero_count(state.materials), _essence_total(state.materials)], Color(0.27, 0.43, 0.37, 1.0)))

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 6)
	panel_body.add_child(controls)
	for label in ["全部", "灵材", "兽元", "器纹", "魂煞", "沧海"]:
		var category_name: String = String(label)
		var btn: Button = _make_small_button(category_name, category_filter == category_name)
		btn.pressed.connect(func() -> void:
			category_filter = category_name
			_refresh_panel(_get_state())
		)
		controls.add_child(btn)

	panel_body.add_child(_make_section_title("常见来源"))
	var source_box := VBoxContainer.new()
	source_box.add_theme_constant_override("separation", 4)
	panel_body.add_child(source_box)
	for category in ["灵材", "兽元", "器纹", "魂煞", "沧海"]:
		source_box.add_child(_source_card(String(category)))
	panel_body.add_child(_make_text("来源提示与材料图鉴共用同一份说明表。", Color(0.55, 0.49, 0.40, 1.0)))

	panel_body.add_child(_make_section_title("材料总览"))
	var summary: Array[Dictionary] = MaterialEconomySystem.material_summary(state.materials)
	for entry: Dictionary in summary:
		if category_filter != "全部" and String(entry.get("category", "")) != category_filter:
			continue
		panel_body.add_child(_material_card(entry))

	panel_body.add_child(_make_section_title("精华炼化"))
	panel_body.add_child(_make_text("选择一种材料分类，消耗对应材料点数炼化成精华。"))
	var essence_row := HFlowContainer.new()
	essence_row.add_theme_constant_override("h_separation", 8)
	essence_row.add_theme_constant_override("v_separation", 8)
	panel_body.add_child(essence_row)
	for essence_name: String in MaterialEconomySystem.essence_names():
		var essence_id := essence_name
		var count := int(state.materials.get(essence_id, 0))
		var refine_btn := _make_button("%s ×%d" % [essence_id, count], count > 0)
		refine_btn.custom_minimum_size = Vector2(158, 38)
		refine_btn.disabled = not MaterialEconomySystem.can_refine_essence(state.materials, essence_id, essence_amount)
		refine_btn.pressed.connect(func() -> void:
			var result: Dictionary = MaterialEconomySystem.refine_essence(state, essence_id, essence_amount)
			_after_action(result)
		)
		essence_row.add_child(refine_btn)

	panel_body.add_child(_make_section_title("精华消耗"))
	panel_body.add_child(_make_text("精华比普通材料更适合直接入体，能快速补足战斗与修行消耗。"))
	var consume_row := HFlowContainer.new()
	consume_row.add_theme_constant_override("h_separation", 8)
	consume_row.add_theme_constant_override("v_separation", 8)
	panel_body.add_child(consume_row)
	for essence_name: String in MaterialEconomySystem.essence_names():
		var essence_id := essence_name
		var count := int(state.materials.get(essence_id, 0))
		var consume_btn := _make_button("服用%s ×%d" % [essence_id, count], count > 0)
		consume_btn.custom_minimum_size = Vector2(158, 38)
		consume_btn.disabled = count <= 0
		consume_btn.pressed.connect(func() -> void:
			var result: Dictionary = MaterialEconomySystem.consume_essence(state, essence_id)
			_after_action(result)
		)
		consume_row.add_child(consume_btn)

	panel_body.add_child(_make_section_title("快捷操作"))
	var quick_row := HBoxContainer.new()
	quick_row.add_theme_constant_override("separation", 8)
	panel_body.add_child(quick_row)
	var inventory_btn := _make_small_button("储物袋", false)
	inventory_btn.pressed.connect(func() -> void:
		var scene := get_tree().current_scene
		if scene != null and scene.has_method("_open_inventory"):
			scene.call("_open_inventory")
	)
	quick_row.add_child(inventory_btn)
	var alchemy_btn := _make_small_button("丹器百工坊", false)
	alchemy_btn.pressed.connect(func() -> void:
		var scene := get_tree().current_scene
		if scene != null and scene.has_method("_open_alchemy"):
			scene.call("_open_alchemy")
	)
	quick_row.add_child(alchemy_btn)
	var close_btn := _make_small_button("关闭", false)
	close_btn.pressed.connect(_close_panel)
	quick_row.add_child(close_btn)

	panel_body.add_child(_make_text("提示：如果你更喜欢从原本的储物袋或丹器坊进入，这里也只是同一套材料经济的另一个入口。", Color(0.55, 0.49, 0.40, 1.0)))

func _after_action(result: Dictionary) -> void:
	var scene := get_tree().current_scene
	if scene != null:
		if scene.has_method("_save_run"):
			scene.call("_save_run")
		if scene.has_method("_refresh_game_ui"):
			scene.call("_refresh_game_ui")
	if status_label != null:
		status_label.text = String(result.get("message", "处理完成。"))
	_refresh_panel(_get_state())

func _make_header(title: String, subtitle: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 28)
	box.add_child(title_label)
	var sub := Label.new()
	sub.text = subtitle
	sub.add_theme_font_size_override("font_size", 11)
	sub.modulate = Color(0.42, 0.38, 0.31, 1.0)
	box.add_child(sub)
	return box

func _make_section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	return label

func _make_text(text: String, color: Color = Color(0.42, 0.38, 0.31, 1.0)) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = color
	label.add_theme_font_size_override("font_size", 11)
	return label

func _make_small_button(text: String, toggled: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.toggle_mode = true
	button.button_pressed = toggled
	button.custom_minimum_size = Vector2(72, 34)
	return button

func _make_button(text: String, enabled: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(BUTTON_WIDTH, BUTTON_HEIGHT)
	button.disabled = not enabled
	return button

func _material_card(entry: Dictionary) -> VBoxContainer:
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 2)
	var head := Label.new()
	head.text = "%s · 总点数 %d · 共 %d 件" % [String(entry.get("category", "")), int(entry.get("points", 0)), int(entry.get("count", 0))]
	card.add_child(head)
	var mats := Array(entry.get("materials", []))
	for mat_value: Variant in mats:
		if not mat_value is Dictionary:
			continue
		var mat: Dictionary = mat_value
		var info: Dictionary = MaterialEconomySystem.material_info(String(mat.get("name", "")))
		var line := Label.new()
		line.text = "  - %s ×%d（阶位%d，点数%d）" % [String(mat.get("name", "")), int(mat.get("count", 0)), int(mat.get("tier", 1)), int(mat.get("points", 1))]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 11)
		card.add_child(line)
		var source := Label.new()
		source.text = "    来源：%s" % String(info.get("source", ""))
		source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		source.add_theme_font_size_override("font_size", 12)
		source.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
		card.add_child(source)
		var usage := Label.new()
		usage.text = "    用途：%s" % String(info.get("usage", info.get("desc", "")))
		usage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		usage.add_theme_font_size_override("font_size", 12)
		usage.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
		card.add_child(usage)
	return card

func _source_card(category: String) -> VBoxContainer:
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 1)
	var title := Label.new()
	title.text = "%s" % category
	title.add_theme_font_size_override("font_size", 12)
	card.add_child(title)
	var source := Label.new()
	source.text = "  来源：%s" % MaterialSourceGuide.category_source_text(category, 1)
	source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source.add_theme_font_size_override("font_size", 12)
	source.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
	card.add_child(source)
	var usage := Label.new()
	usage.text = "  用途：%s" % MaterialSourceGuide.category_usage_text(category)
	usage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	usage.add_theme_font_size_override("font_size", 12)
	usage.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
	card.add_child(usage)
	return card

func _nonzero_count(materials: Dictionary) -> int:
	var total := 0
	for key: Variant in materials.keys():
		if int(materials[key]) > 0:
			total += 1
	return total

func _essence_total(materials: Dictionary) -> int:
	var total := 0
	for essence_name: String in MaterialEconomySystem.essence_names():
		total += int(materials.get(essence_name, 0))
	return total
