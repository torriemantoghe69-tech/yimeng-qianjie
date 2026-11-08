extends CanvasLayer

## 轻量级材料来源提示悬浮层。
## 不改主界面结构，只负责把材料来源、用途和示例州域展示给玩家。

const PANEL_WIDTH := 560
const PANEL_HEIGHT := 500

var root_ui: Control
var toggle_button: Button
var panel: PanelContainer
var panel_body: VBoxContainer
var status_label: Label

func _ready() -> void:
	layer = 121
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
	root_ui.name = "MaterialSourceHintsRoot"
	root_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ui)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 8)
	root_ui.add_child(top_bar)
	top_bar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_bar.anchor_left = 1.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = -152
	top_bar.offset_right = -16
	top_bar.offset_top = 58
	top_bar.offset_bottom = 58

	toggle_button = Button.new()
	toggle_button.text = "来源"
	toggle_button.custom_minimum_size = Vector2(78, 36)
	toggle_button.pressed.connect(_toggle_panel)
	top_bar.add_child(toggle_button)

	panel = PanelContainer.new()
	panel.name = "MaterialSourceHintsPanel"
	panel.visible = false
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -PANEL_WIDTH * 0.5
	panel.offset_right = PANEL_WIDTH * 0.5
	panel.offset_top = 122
	panel.offset_bottom = 122 + PANEL_HEIGHT
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

	var title := Label.new()
	title.text = "材 料 来 源"
	title.add_theme_font_size_override("font_size", 26)
	panel_body.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "掉落、秘境、战后奖励与材料用途共用同一套说明。"
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.modulate = Color(0.42, 0.38, 0.31, 1.0)
	panel_body.add_child(subtitle)

	if state != null:
		status_label.text = "当前州域：%s · 材料种类：%d · 灵石：%d" % [String(state.current_region), _nonzero_count(state.materials), state.stones]
	else:
		status_label.text = ""

	panel_body.add_child(_section_title("分类说明"))
	for category in ["灵材", "兽元", "器纹", "魂煞", "沧海"]:
		panel_body.add_child(_category_card(category))

	panel_body.add_child(_section_title("当前提示"))
	panel_body.add_child(_make_text("材料图鉴、掉落提示与任务奖励以后都会引用这套说明。你也可以把它当成当前玩法的材料索引。"))

	var close_row := HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_END
	panel_body.add_child(close_row)
	var close_btn := Button.new()
	close_btn.text = "关闭"
	close_btn.custom_minimum_size = Vector2(90, 36)
	close_btn.pressed.connect(_close_panel)
	close_row.add_child(close_btn)

func _category_card(category: String) -> VBoxContainer:
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 2)
	var head := Label.new()
	head.text = category
	head.add_theme_font_size_override("font_size", 14)
	card.add_child(head)

	var source := Label.new()
	source.text = "来源：%s" % MaterialSourceGuide.category_source_text(category, 2)
	source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source.add_theme_font_size_override("font_size", 12)
	source.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
	card.add_child(source)

	var usage := Label.new()
	usage.text = "用途：%s" % MaterialSourceGuide.category_usage_text(category)
	usage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	usage.add_theme_font_size_override("font_size", 12)
	usage.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
	card.add_child(usage)

	var spot := Label.new()
	spot.text = "示例州域：%s" % MaterialSourceGuide.category_spot_text(category)
	spot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spot.add_theme_font_size_override("font_size", 12)
	spot.add_theme_color_override("font_color", Color(0.420, 0.376, 0.306, 1.0))
	card.add_child(spot)
	return card

func _section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	return label

func _make_text(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = Color(0.42, 0.38, 0.31, 1.0)
	label.add_theme_font_size_override("font_size", 11)
	return label

func _nonzero_count(materials: Dictionary) -> int:
	var total := 0
	for key: Variant in materials.keys():
		if int(materials[key]) > 0:
			total += 1
	return total
