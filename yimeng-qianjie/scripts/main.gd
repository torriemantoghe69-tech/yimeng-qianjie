extends Control

## 《一梦千劫》——界面、流程与存档。
## 美术全部由代码绘制，字体使用系统中文字体，不依赖外部素材。

const SAVE_RUN := "user://run_save.json"
const SAVE_SOUL := "user://soul_save.json"
const SAVE_DISPLAY := "user://display_save.json"
const SAVE_AUDIO := "user://audio_save.json"
const MAX_VISIBLE_LOGS := 60
const WINDOW_PRESETS := [Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1440, 810), Vector2i(1280, 720)]

const INK := Color(0.173, 0.157, 0.129, 1.0)
const INK_SOFT := Color(0.420, 0.376, 0.306, 1.0)
const INK_FAINT := Color(0.596, 0.545, 0.455, 1.0)
const PAPER := Color(0.957, 0.922, 0.851, 1.0)
const PAPER_DEEP := Color(0.906, 0.855, 0.757, 1.0)
const WARM_WHITE := Color(0.984, 0.961, 0.910, 1.0)
const CINNABAR := Color(0.635, 0.227, 0.165, 1.0)
const CINNABAR_DARK := Color(0.498, 0.169, 0.125, 1.0)
const JADE := Color(0.271, 0.427, 0.373, 1.0)
const GOLD := Color(0.604, 0.482, 0.247, 1.0)
const LINE := Color(0.780, 0.714, 0.580, 1.0)
const MUTED := Color(0.545, 0.494, 0.404, 1.0)

var rng := RandomNumberGenerator.new()
var soul: Dictionary = {}
var state: GameState = null
var ui_mode: String = "menu"
var current_life_number: int = 1
var display_fullscreen: bool = true
var windowed_size: Vector2i = Vector2i(1440, 810)
var music: MusicManager
var audio_enabled: bool = true
var audio_volume: float = 0.35

var font_body: SystemFont
var font_title: SystemFont

var menu_screen: Control
var game_screen: Control
var modal_root: Control
var modal_open: bool = false
var modal_dismissible: bool = false
var modal_on_close: Callable = Callable()
var modal_instant_open: bool = false

var continue_button: Button
var new_life_button: Button
var menu_stats_label: Label
var menu_sub_stats_label: Label

var top_life_label: Label
var top_points_label: Label
var narrative_meta_label: Label
var log_rich: RichTextLabel
var log_scroll: ScrollContainer
var action_cards: Dictionary = {}
var breakthrough_button: Button
var action_hint_label: Label

var char_name_label: Label
var char_sub_label: Label
var char_realm_label: Label
var char_life_label: Label
var age_label: Label
var progress_bar: ProgressBar
var progress_text: Label
var injury_label: Label
var battle_resource_label: Label
var talent_flow: HFlowContainer
var stat_widgets: Dictionary = {}
var stat_caption_label: Label
var combat_stats_label: Label
var stones_label: Label
var karma_label: Label
var treasure_flow: HFlowContainer
var treasure_empty_label: Label
var treasure_count_label: Label
var equipment_slot_widgets: Dictionary = {}

var last_log_seq: int = -1
var pending_death_breakdown: Dictionary = {}
var battle_active: bool = false
var battle_turn_index: int = 0
var battle_enemy: Dictionary = {}
var battle_logs: Array[String] = []
var battle_cooldowns: Dictionary = {}
var inventory_category: String = "全部"

func _ready() -> void:
	rng.randomize()
	get_tree().auto_accept_quit = false
	if DisplayServer.get_name() != "headless":
		_load_display_settings()
		_apply_window_identity()
	_setup_fonts()
	_load_soul()
	music = MusicManager.new()
	add_child(music)
	_load_audio_settings()
	music.set_volume(audio_volume)
	music.set_enabled(audio_enabled)
	_build_root()
	_show_menu()

func _apply_window_identity() -> void:
	var window_icon: Resource = load("res://icon.svg")
	DisplayServer.window_set_title("一梦千劫")
	if window_icon is Texture2D:
		DisplayServer.set_icon((window_icon as Texture2D).get_image())
	# 直接从引擎运行时，编辑器构建会在启动后补上“(DEBUG)”后缀；
	# 延迟一次重设，保持发行包窗口标题干净。
	await get_tree().create_timer(0.6).timeout
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_title("一梦千劫")

func _load_display_settings() -> void:
	display_fullscreen = true
	windowed_size = Vector2i(1440, 810)
	if FileAccess.file_exists(SAVE_DISPLAY):
		var file := FileAccess.open(SAVE_DISPLAY, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				var data: Dictionary = parsed
				display_fullscreen = bool(data.get("fullscreen", true))
				var saved_size := Vector2i(int(data.get("width", 1440)), int(data.get("height", 810)))
				var usable: Rect2i = DisplayServer.screen_get_usable_rect()
				if saved_size.x >= 960 and saved_size.y >= 540 and saved_size.x <= usable.size.x and saved_size.y + 70 <= usable.size.y:
					windowed_size = saved_size
	if DisplayServer.get_name() == "headless":
		return
	if display_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		_apply_windowed_size()

func _apply_windowed_size() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(windowed_size)
	var usable: Rect2i = DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_position(usable.position + (usable.size - windowed_size) / 2)

func _save_display_settings() -> void:
	var file := FileAccess.open(SAVE_DISPLAY, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"fullscreen": display_fullscreen,
			"width": windowed_size.x,
			"height": windowed_size.y,
		}, "\t"))

func _load_audio_settings() -> void:
	audio_enabled = true
	audio_volume = 0.35
	if FileAccess.file_exists(SAVE_AUDIO):
		var file := FileAccess.open(SAVE_AUDIO, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				var data: Dictionary = parsed
				audio_enabled = bool(data.get("enabled", true))
				audio_volume = clampf(float(data.get("volume", 0.35)), 0.0, 1.0)

func _save_audio_settings() -> void:
	var file := FileAccess.open(SAVE_AUDIO, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"enabled": audio_enabled,
			"volume": audio_volume,
		}, "\t"))

func _choose_display_fullscreen() -> void:
	if DisplayServer.get_name() != "headless":
		display_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_save_display_settings()
	_close_modal()

func _choose_display_window(size: Vector2i) -> void:
	if DisplayServer.get_name() != "headless":
		display_fullscreen = false
		windowed_size = size
		_apply_windowed_size()
		_save_display_settings()
	_close_modal()

func _open_audio_settings() -> void:
	var box := _open_modal(Vector2(640, 0), true, Callable())
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	box.add_child(head)
	var head_text := VBoxContainer.new()
	head_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_text.add_theme_constant_override("separation", 1)
	head.add_child(head_text)
	head_text.add_child(_label("声 音 设 置", 11, GOLD))
	head_text.add_child(_label("音 律", 34, INK, font_title))
	head_text.add_child(_label("一梦之中，亦有声息。音乐由程序合成，无外部素材。", 11, INK_SOFT))
	var seal := _make_seal("音", 48, 22)
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(seal)
	box.add_child(_hairline())

	var toggle_row := HBoxContainer.new()
	toggle_row.add_theme_constant_override("separation", 12)
	box.add_child(toggle_row)
	var toggle := _make_button("音乐：开启" if audio_enabled else "音乐：关闭", audio_enabled, 150, 40)
	toggle.pressed.connect(_toggle_audio)
	toggle_row.add_child(toggle)
	var track_label := _label("当前场景：%s · %s" % [music.current_title(), music.current_context()], 11, JADE)
	track_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	track_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	track_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toggle_row.add_child(track_label)

	var volume_head := HBoxContainer.new()
	box.add_child(volume_head)
	volume_head.add_child(_label("音量", 11, INK_SOFT))
	var volume_spacer := Control.new()
	volume_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_head.add_child(volume_spacer)
	var volume_value := _label("%d%%" % int(round(audio_volume * 100.0)), 11, MUTED)
	volume_head.add_child(volume_value)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = audio_volume * 100.0
	slider.custom_minimum_size = Vector2(0, 24)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_audio_volume_changed.bind(volume_value))
	box.add_child(slider)

	box.add_child(_hairline())
	box.add_child(_label("场 景 音 乐", 10, MUTED))
	for info: Dictionary in music.track_titles():
		var is_current: bool = String(info["key"]) == music.current_key()
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		box.add_child(row)
		var name_label := _label(("◆ " if is_current else "　") + String(info["title"]), 12, CINNABAR if is_current else INK)
		name_label.custom_minimum_size = Vector2(110, 0)
		row.add_child(name_label)
		var context_label := _label(String(info["context"]), 10, MUTED)
		context_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(context_label)

	var note := _label("主菜单、修行、机缘与终章会自动切换曲目；F11 与灵境设置不受影响。", 10, MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(footer)
	var close := _make_button("关闭", false, 100, 38)
	close.pressed.connect(_close_modal)
	footer.add_child(close)

func _toggle_audio() -> void:
	audio_enabled = not audio_enabled
	music.set_enabled(audio_enabled)
	_save_audio_settings()
	_open_audio_settings()

func _on_audio_volume_changed(value: float, value_label: Label) -> void:
	audio_volume = clampf(value / 100.0, 0.0, 1.0)
	music.set_volume(audio_volume)
	value_label.text = "%d%%" % int(round(value))
	_save_audio_settings()

func _toggle_fullscreen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode: int = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		display_fullscreen = false
		_apply_windowed_size()
	else:
		var current_size: Vector2i = DisplayServer.window_get_size()
		if current_size.x >= 960 and current_size.y >= 540:
			windowed_size = current_size
		display_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_save_display_settings()

func _open_display_settings() -> void:
	var box := _open_modal(Vector2(660, 0), true, Callable())
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	box.add_child(head)
	var head_text := VBoxContainer.new()
	head_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_text.add_theme_constant_override("separation", 1)
	head.add_child(head_text)
	head_text.add_child(_label("显 示 设 置", 11, GOLD))
	head_text.add_child(_label("画 面", 34, INK, font_title))
	head_text.add_child(_label("全屏使用显示器原生分辨率；窗口模式会立即缩放界面并保存。", 11, INK_SOFT))
	var seal := _make_seal("显", 48, 22)
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(seal)
	box.add_child(_hairline())

	var is_headless: bool = DisplayServer.get_name() == "headless"
	var screen_size: Vector2i = Vector2i(1920, 1080)
	var usable: Rect2i = Rect2i(Vector2i.ZERO, screen_size)
	var current_size: Vector2i = windowed_size
	if not is_headless:
		screen_size = DisplayServer.screen_get_size()
		usable = DisplayServer.screen_get_usable_rect()
		current_size = DisplayServer.window_get_size()
	var status_text: String = "全屏 · %d × %d" % [screen_size.x, screen_size.y]
	if not display_fullscreen:
		status_text = "窗口 · %d × %d" % [current_size.x, current_size.y]
	var status := _label("当前：%s" % status_text, 12, JADE)
	box.add_child(status)

	var full_button := _make_button("全屏 · 使用显示器分辨率（%d × %d）" % [screen_size.x, screen_size.y], display_fullscreen, 0, 44)
	full_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	full_button.pressed.connect(_choose_display_fullscreen)
	box.add_child(full_button)

	var window_caption := _label("窗口模式", 11, MUTED)
	box.add_child(window_caption)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for preset: Vector2i in WINDOW_PRESETS:
		var fits: bool = preset.x <= usable.size.x and preset.y + 70 <= usable.size.y
		if not fits and (display_fullscreen or preset != windowed_size):
			continue
		var is_current: bool = not display_fullscreen and preset == windowed_size
		var button := _make_button("%d × %d%s" % [preset.x, preset.y, " · 当前" if is_current else ""], is_current, 0, 42)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_choose_display_window.bind(preset))
		grid.add_child(button)

	var note := _label("全屏使用显示器原生分辨率；窗口分辨率用于桌面模式。F11 可随时快速切换。", 10, MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(footer)
	var close := _make_button("关闭", false, 100, 38)
	close.pressed.connect(_close_modal)
	footer.add_child(close)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if state != null:
			if state.alive:
				_save_run()
			elif not state.death_handled:
				# 事件结算后可能已身死但终章尚未打开；先结清轮回点再退出。
				_handle_death()
		_save_soul()
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key_event := event as InputEventKey
	if key_event.keycode == KEY_F11:
		_toggle_fullscreen()
		return
	if key_event.keycode == KEY_ESCAPE:
		if modal_open and modal_dismissible:
			_close_modal()
		elif ui_mode == "game" and not modal_open:
			_on_return_to_menu()
		return
	if modal_open or ui_mode != "game" or state == null or not state.alive:
		return
	if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_4:
		var ids: Array = [GameState.ACTION_CULTIVATE, GameState.ACTION_COMPREHEND, GameState.ACTION_WANDER, GameState.ACTION_RECOVER]
		_on_action(String(ids[key_event.keycode - KEY_1]))
	elif key_event.keycode == KEY_SPACE:
		_on_breakthrough()

# ---------------------------------------------------------------------------
# 字体与根界面
# ---------------------------------------------------------------------------

func _setup_fonts() -> void:
	font_body = SystemFont.new()
	font_body.font_names = PackedStringArray([
		"Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC",
		"Source Han Sans SC", "PingFang SC", "SimHei", "WenQuanYi Micro Hei", "sans-serif"
	])
	font_body.allow_system_fallback = true
	font_body.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	font_body.multichannel_signed_distance_field = false

	font_title = SystemFont.new()
	font_title.font_names = PackedStringArray([
		"KaiTi", "STKaiti", "Kaiti SC", "FangSong", "STFangsong",
		"Noto Serif CJK SC", "Source Han Serif SC", "Microsoft YaHei UI", "serif"
	])
	font_title.allow_system_fallback = true
	font_title.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	font_title.multichannel_signed_distance_field = false

	var app_theme := Theme.new()
	app_theme.default_font = font_body
	app_theme.default_font_size = 16
	theme = app_theme

func _build_root() -> void:
	var background := InkBackground.new()
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	menu_screen = Control.new()
	add_child(menu_screen)
	menu_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	game_screen = Control.new()
	add_child(game_screen)
	game_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_screen.visible = false

	modal_root = Control.new()
	add_child(modal_root)
	modal_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_root.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_root.z_index = 50
	modal_root.visible = false

	_build_menu()
	_build_game()

# ---------------------------------------------------------------------------
# 主菜单
# ---------------------------------------------------------------------------

func _build_menu() -> void:
	var outer := MarginContainer.new()
	menu_screen.add_child(outer)
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 70)
	outer.add_theme_constant_override("margin_right", 64)
	outer.add_theme_constant_override("margin_top", 48)
	outer.add_theme_constant_override("margin_bottom", 42)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 54)
	outer.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override("separation", 15)
	row.add_child(left)

	var kicker := HBoxContainer.new()
	kicker.add_theme_constant_override("separation", 14)
	left.add_child(kicker)
	var seal := _make_seal("梦", 38, 20)
	kicker.add_child(seal)
	var kicker_label := _label("一 梦 千 劫　·　文 字 修 仙", 14, GOLD)
	kicker_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kicker.add_child(kicker_label)
	var ai_button := _make_text_button("商汤 AI", 12)
	ai_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ai_button.pressed.connect(_open_sensenova_panel)
	kicker.add_child(ai_button)

	var title := _label("一 梦 千 劫", 92, INK, font_title)
	title.add_theme_color_override("font_shadow_color", Color(0.30, 0.24, 0.16, 0.14))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.add_theme_constant_override("shadow_outline_size", 1)
	left.add_child(title)

	var subtitle := _label("一 念 成 仙　·　一 念 成 劫", 19, CINNABAR)
	left.add_child(subtitle)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 18)
	left.add_child(gap)

	var quote_row := HBoxContainer.new()
	quote_row.add_theme_constant_override("separation", 16)
	left.add_child(quote_row)
	var red_line := ColorRect.new()
	red_line.color = Color(CINNABAR.r, CINNABAR.g, CINNABAR.b, 0.78)
	red_line.custom_minimum_size = Vector2(2, 96)
	red_line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	quote_row.add_child(red_line)
	var quote_box := VBoxContainer.new()
	quote_box.add_theme_constant_override("separation", 5)
	quote_row.add_child(quote_box)
	var q1 := _label("一世不够，便向天再借一世。", 23, INK_SOFT, font_title)
	quote_box.add_child(q1)
	var q2 := _label("可借来的，还是同一颗心吗？", 23, INK_SOFT, font_title)
	quote_box.add_child(q2)
	var q3 := _label("你死过很多次。每一次醒来，都以为这是第一世。", 13, MUTED)
	quote_box.add_child(q3)

	var bottom_gap := Control.new()
	bottom_gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(bottom_gap)

	var menu_panel := PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(405, 0)
	menu_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.965, 0.934, 0.870, 0.90), Color(0.62, 0.53, 0.38, 0.36), 8, 1, true))
	row.add_child(menu_panel)

	var menu_margin := MarginContainer.new()
	menu_margin.add_theme_constant_override("margin_left", 28)
	menu_margin.add_theme_constant_override("margin_right", 28)
	menu_margin.add_theme_constant_override("margin_top", 26)
	menu_margin.add_theme_constant_override("margin_bottom", 24)
	menu_panel.add_child(menu_margin)
	var menu_box := VBoxContainer.new()
	menu_box.add_theme_constant_override("separation", 10)
	menu_margin.add_child(menu_box)

	var menu_head := HBoxContainer.new()
	menu_head.add_theme_constant_override("separation", 12)
	menu_box.add_child(menu_head)
	var mini_seal := _make_seal("入\n梦", 42, 15)
	menu_head.add_child(mini_seal)
	var head_box := VBoxContainer.new()
	head_box.add_theme_constant_override("separation", 1)
	menu_head.add_child(head_box)
	head_box.add_child(_label("轮 回 之 门", 21, INK, font_title))
	head_box.add_child(_label("此生已矣，来世可期。", 12, INK_SOFT))

	menu_box.add_child(_hairline())
	var button_gap := Control.new()
	button_gap.custom_minimum_size = Vector2(0, 2)
	menu_box.add_child(button_gap)

	continue_button = _make_menu_button("前尘续梦", "续写尚未走完的这一世")
	continue_button.pressed.connect(_on_continue_run)
	menu_box.add_child(continue_button)

	new_life_button = _make_menu_button("再入轮回", "放下此世，开启一段新的仙途", true)
	new_life_button.pressed.connect(_on_new_life_pressed)
	menu_box.add_child(new_life_button)

	var meta_button := _make_menu_button("轮回传承", "使用轮回点强化下一世")
	meta_button.pressed.connect(_on_menu_upgrades)
	menu_box.add_child(meta_button)

	var chronicle_button := _make_menu_button("前世记录", "查看历世经历与结局")
	chronicle_button.pressed.connect(_on_menu_chronicle)
	menu_box.add_child(chronicle_button)

	var display_button := _make_menu_button("灵境设置", "调整全屏、窗口与分辨率")
	display_button.pressed.connect(_open_display_settings)
	menu_box.add_child(display_button)

	var audio_button := _make_menu_button("天籁设置", "调整音乐开关与音量")
	audio_button.pressed.connect(_open_audio_settings)
	menu_box.add_child(audio_button)

	var help_button := _make_menu_button("天道指引", "查看修行之路与诸般规则")
	help_button.pressed.connect(_open_help)
	menu_box.add_child(help_button)
	
	var clear_save_button: = _make_menu_button("斩断因果", "抹去今生进度与所有轮回记录")
	clear_save_button.pressed.connect(_show_clear_save_confirm)
	menu_box.add_child(clear_save_button)
	var quit_button := _make_menu_button("归于虚无", "离开一梦千劫")
	quit_button.pressed.connect(_on_quit)
	menu_box.add_child(quit_button)

	var menu_spacer := Control.new()
	menu_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_box.add_child(menu_spacer)
	menu_box.add_child(_hairline())

	menu_stats_label = _label("尚未入世", 13, INK_SOFT)
	menu_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_box.add_child(menu_stats_label)
	menu_sub_stats_label = _label("轮回点 0 · 最高境界 炼气一层", 11, MUTED)
	menu_sub_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_box.add_child(menu_sub_stats_label)
	var auto_label := _label("自动存档 · 无需登录", 10, Color(MUTED.r, MUTED.g, MUTED.b, 0.72))
	menu_box.add_child(auto_label)

func _make_menu_button(title_text: String, subtitle: String, primary: bool = false) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 54)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true

	var margin := MarginContainer.new()
	button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 6)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_theme_constant_override("separation", 0)
	row.add_child(texts)
	var title_label := _label(title_text, 18, INK)
	texts.add_child(title_label)
	var sub_label := _label(subtitle, 11, INK_SOFT)
	texts.add_child(sub_label)
	var arrow := _label("›", 22, INK, font_title)
	arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(arrow)
	button.set_meta("title_label", title_label)
	button.set_meta("sub_label", sub_label)
	button.set_meta("arrow", arrow)
	_paint_menu_button(button, primary)
	return button

func _paint_menu_button(button: Button, primary: bool) -> void:
	var normal_bg: Color
	var hover_bg: Color
	var title_color: Color
	var sub_color: Color
	var border_color: Color
	if primary:
		normal_bg = CINNABAR
		hover_bg = CINNABAR_DARK
		title_color = WARM_WHITE
		sub_color = Color(1.0, 0.95, 0.88, 0.72)
		border_color = Color(0.45, 0.16, 0.11, 0.65)
	else:
		normal_bg = Color(0.94, 0.90, 0.82, 0.34)
		hover_bg = Color(0.99, 0.96, 0.90, 0.94)
		title_color = INK
		sub_color = INK_SOFT
		border_color = Color(0.66, 0.57, 0.41, 0.20)
	button.add_theme_stylebox_override("normal", _panel_style(normal_bg, border_color, 4, 1))
	button.add_theme_stylebox_override("hover", _panel_style(hover_bg, Color(GOLD.r, GOLD.g, GOLD.b, 0.45), 4, 1))
	button.add_theme_stylebox_override("pressed", _panel_style(hover_bg.darkened(0.06), border_color, 4, 1))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", _panel_style(normal_bg, border_color, 4, 1))
	var title_label := button.get_meta("title_label") as Label
	var sub_label := button.get_meta("sub_label") as Label
	var arrow := button.get_meta("arrow") as Label
	if title_label != null:
		title_label.add_theme_color_override("font_color", title_color)
	if sub_label != null:
		sub_label.add_theme_color_override("font_color", sub_color)
	if arrow != null:
		arrow.add_theme_color_override("font_color", title_color)
	button.set_meta("primary_style", primary)

func _refresh_menu() -> void:
	var has_run: bool = _has_run_save()
	continue_button.visible = has_run
	if has_run:
		_paint_menu_button(continue_button, true)
		_paint_menu_button(new_life_button, false)
	else:
		_paint_menu_button(new_life_button, true)
	var lives: int = int(soul.get("lives", 0))
	var points: int = int(soul.get("points", 0))
	var best: int = int(soul.get("best_realm", 0))
	var ascensions: int = int(soul.get("ascensions", 0))
	if lives <= 0:
		menu_stats_label.text = "尚未入世 · 一切从第一缕灵气开始"
	else:
		menu_stats_label.text = "已历 %d 世 · 最高境界 %s" % [lives, GameData.realm_name(best)]
	var extra := "轮回点 %d" % points
	if has_run:
		extra += " · 今世未了，可续前缘"
	elif lives > 0:
		extra += " · 道果可点化传承"
	if ascensions > 0:
		extra += " · 已飞升 %d 次" % ascensions
	menu_sub_stats_label.text = extra

func _on_new_life_pressed() -> void:
	if _has_run_save():
		_show_new_life_confirm()
	else:
		_start_new_life()

func _show_new_life_confirm() -> void:
	var box := _open_modal(Vector2(560, 300), true, Callable())
	_add_modal_heading(box, "旧梦未散", "舍弃今生？", "你还有一段未走完的路。踏入新的轮回，将使此生进度烟消云散。")
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	box.add_child(spacer)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(buttons)
	var cancel := _make_button("继续今生", false, 120)
	cancel.pressed.connect(_close_modal)
	buttons.add_child(cancel)
	var confirm := _make_button("舍身重入", true, 140)
	confirm.pressed.connect(_on_confirm_new_life)
	buttons.add_child(confirm)

func _on_confirm_new_life() -> void:
	_clear_modal(false)
	_delete_run()
	_start_new_life()

# ---------------------------------------------------------------------------
# 游戏界面
# ---------------------------------------------------------------------------

func _build_game() -> void:
	var outer := MarginContainer.new()
	game_screen.add_child(outer)
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 26)
	outer.add_theme_constant_override("margin_right", 26)
	outer.add_theme_constant_override("margin_top", 20)
	outer.add_theme_constant_override("margin_bottom", 20)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	outer.add_child(page)

	var topbar := HBoxContainer.new()
	topbar.custom_minimum_size = Vector2(0, 50)
	topbar.add_theme_constant_override("separation", 12)
	page.add_child(topbar)

	var top_seal := _make_seal("梦", 36, 17)
	top_seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topbar.add_child(top_seal)
	var brand := VBoxContainer.new()
	brand.add_theme_constant_override("separation", 0)
	brand.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topbar.add_child(brand)
	brand.add_child(_label("一梦千劫", 23, INK, font_title))
	top_life_label = _label("第 1 世 · 文字修仙轮回录", 10, MUTED)
	brand.add_child(top_life_label)
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topbar.add_child(top_spacer)
	top_points_label = _label("轮回点 0", 12, GOLD)
	top_points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	topbar.add_child(top_points_label)
	var display_button := _make_text_button("灵境", 12)
	display_button.pressed.connect(_open_display_settings)
	display_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topbar.add_child(display_button)
	var audio_button := _make_text_button("天籁", 12)
	audio_button.pressed.connect(_open_audio_settings)
	audio_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topbar.add_child(audio_button)
	var help_button := _make_text_button("天道", 12)
	help_button.pressed.connect(_open_help)
	help_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topbar.add_child(help_button)
	var menu_button := _make_text_button("轮回殿", 13)
	menu_button.pressed.connect(_on_return_to_menu)
	menu_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topbar.add_child(menu_button)

	page.add_child(_hairline())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	page.add_child(body)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 12)
	body.add_child(left)

	_build_narrative_panel(left)
	_build_action_panel(left)
	_build_sidebar(body)

func _build_narrative_panel(parent: VBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.972, 0.945, 0.888, 0.93), Color(0.62, 0.53, 0.38, 0.34), 7, 1, true))
	parent.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 9)
	box.add_child(head)
	var line := ColorRect.new()
	line.color = CINNABAR
	line.custom_minimum_size = Vector2(3, 20)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(line)
	head.add_child(_label("此 生 行 迹", 20, INK, font_title))
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_spacer)
	narrative_meta_label = _label("十六岁 · 初入仙途", 11, MUTED)
	narrative_meta_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(narrative_meta_label)
	box.add_child(_hairline())

	log_scroll = ScrollContainer.new()
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	log_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	box.add_child(log_scroll)

	var log_margin := MarginContainer.new()
	log_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_margin.add_theme_constant_override("margin_right", 12)
	log_margin.add_theme_constant_override("margin_top", 2)
	log_scroll.add_child(log_margin)
	log_rich = RichTextLabel.new()
	log_rich.bbcode_enabled = true
	log_rich.fit_content = true
	log_rich.scroll_active = false
	log_rich.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_rich.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_rich.add_theme_font_override("normal_font", font_body)
	log_rich.add_theme_font_override("bold_font", font_body)
	log_rich.add_theme_font_size_override("normal_font_size", 16)
	log_rich.add_theme_font_size_override("bold_font_size", 16)
	log_rich.add_theme_constant_override("line_separation", 7)
	log_rich.add_theme_color_override("default_color", INK)
	log_margin.add_child(log_rich)

func _build_action_panel(parent: VBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_SHRINK_END
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.958, 0.924, 0.855, 0.86), Color(0.65, 0.56, 0.40, 0.32), 7, 1))
	parent.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	box.add_child(head)
	var line := ColorRect.new()
	line.color = CINNABAR
	line.custom_minimum_size = Vector2(3, 17)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(line)
	head.add_child(_label("择 路", 17, INK, font_title))
	action_hint_label = _label("起念即过一年 · 数字键 1-4", 10, MUTED)
	action_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	action_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(action_hint_label)

	# 操作区独立滚动：展开任意分类只增加内部内容，不再挤压或覆盖上方行迹面板。
	var action_scroll := ScrollContainer.new()
	action_scroll.custom_minimum_size = Vector2(0, 218)
	action_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	action_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	action_scroll.follow_focus = true
	action_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	box.add_child(action_scroll)

	var action_content := VBoxContainer.new()
	action_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_content.add_theme_constant_override("separation", 7)
	action_scroll.add_child(action_content)

	var daily_cards: Array[Dictionary] = [
		{"id": GameState.ACTION_CULTIVATE, "title": "打坐炼气", "accent": JADE, "desc": ""},
		{"id": GameState.ACTION_COMPREHEND, "title": "参悟道法", "accent": GOLD, "desc": ""},
		{"id": GameState.ACTION_RECOVER, "title": "吐纳疗伤", "accent": Color(0.35, 0.43, 0.47, 1.0), "desc": ""},
	]
	_add_action_group(action_content, "日常修行", daily_cards, true)

	# 常用功能直接平铺，避免先展开分类、再进入子菜单。
	# 探索入口直接打开对应系统，不再强制经过“行走天下”中转页。
	var quick_cards: Array[Dictionary] = [
		{"id": "utility_skills", "title": "功法武技", "accent": GOLD, "desc": "典籍学习 · 战斗技能", "key": "典", "tooltip": "直接打开功法典籍", "action": Callable(self, "_open_skill_library")},
		{"id": "utility_market", "title": "坊市万宝阁", "accent": GOLD, "desc": "购买兵器 · 添置法器", "key": "市", "tooltip": "直接打开坊市", "action": Callable(self, "_open_weapon_shop")},
		{"id": "utility_red_dust", "title": "红尘历练", "accent": JADE, "desc": "探索游历 · 有选项的奇遇", "key": "游", "tooltip": "开始红尘历练，触发可选择的正式奇遇", "action": Callable(self, "_on_action").bind(GameState.ACTION_WANDER)},
		{"id": "utility_seek_enemy", "title": "寻敌斗法", "accent": CINNABAR, "desc": "主动寻敌 · 回合制战斗", "key": "战", "tooltip": "主动寻找妖兽、邪修或敌对修士", "action": Callable(self, "_on_seek_enemy")},
		{"id": "utility_world_map", "title": "九州地图", "accent": JADE, "desc": "州域探索 · 地方特产", "key": "州", "tooltip": "直接打开九州地图", "action": Callable(self, "_open_world_map")},
		{"id": "utility_secret_realm", "title": "秘境探索", "accent": CINNABAR, "desc": "遗迹寻宝 · 古修传承", "key": "境", "tooltip": "直接进入秘境探索", "action": Callable(self, "_open_secret_realm")},
		{"id": "utility_factions", "title": "天下势力", "accent": CINNABAR, "desc": "宗门 · 皇朝 · 世家 · 妖盟", "key": "势", "tooltip": "直接查看天下势力", "action": Callable(self, "_open_faction_hall")},
		{"id": "utility_spirits", "title": "灵宠坐骑", "accent": JADE, "desc": "收服伙伴 · 乘骑采集", "key": "灵", "tooltip": "直接管理灵宠与坐骑", "action": Callable(self, "_open_spirit_companion")},
		{"id": "utility_alchemy", "title": "丹器百工坊", "accent": JADE, "desc": "炼丹 · 炼器 · 丹药服用", "key": "丹器", "tooltip": "统一管理炼丹与炼器", "action": Callable(self, "_open_alchemy")},
		{"id": "utility_inventory", "title": "储物袋", "accent": Color(0.48, 0.43, 0.34, 1.0), "desc": "材料 · 丹药 · 装备", "key": "囊", "tooltip": "直接打开储物袋", "action": Callable(self, "_open_inventory")},
	]
	_add_action_group(action_content, "常用功能直达", quick_cards, true)

	breakthrough_button = Button.new()
	breakthrough_button.custom_minimum_size = Vector2(0, 46)
	breakthrough_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	breakthrough_button.focus_mode = Control.FOCUS_NONE
	breakthrough_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	breakthrough_button.add_theme_font_override("font", font_body)
	breakthrough_button.add_theme_font_size_override("font_size", 16)
	breakthrough_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	breakthrough_button.pressed.connect(_on_breakthrough)
	breakthrough_button.tooltip_text = "修为圆满时可冲击下一境界。成算受悟性、道心、气运、伤势与境界影响。"
	action_content.add_child(breakthrough_button)

func _add_action_group(parent: VBoxContainer, group_title: String, cards: Array[Dictionary], expanded: bool) -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 4)
	parent.add_child(group)

	var header := Button.new()
	header.custom_minimum_size = Vector2(0, 34)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.focus_mode = Control.FOCUS_NONE
	header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.add_theme_font_override("font", font_body)
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", INK)
	header.add_theme_color_override("font_hover_color", CINNABAR)
	header.add_theme_stylebox_override("normal", _card_style(Color(0.91, 0.86, 0.75, 0.48), Color(0.68, 0.59, 0.43, 0.28)))
	header.add_theme_stylebox_override("hover", _card_style(Color(0.96, 0.91, 0.81, 0.78), Color(0.68, 0.49, 0.32, 0.48)))
	header.add_theme_stylebox_override("pressed", _card_style(Color(0.89, 0.83, 0.71, 0.82), Color(0.68, 0.49, 0.32, 0.58)))
	group.add_child(header)

	var content := GridContainer.new()
	content.columns = 2
	content.add_theme_constant_override("h_separation", 8)
	content.add_theme_constant_override("v_separation", 6)
	content.visible = expanded
	group.add_child(content)

	for data: Dictionary in cards:
		var card_id := String(data.get("id", ""))
		var card := _make_action_card(card_id, String(data.get("title", "")), Color(data.get("accent", GOLD)), data.get("action", Callable()))
		var desc_label: Label = card.get_meta("desc_label") as Label
		var key_label: Label = card.get_meta("key_label") as Label
		desc_label.text = String(data.get("desc", ""))
		key_label.text = String(data.get("key", ""))
		card.tooltip_text = String(data.get("tooltip", "快捷入口"))
		content.add_child(card)
		if card_id in [GameState.ACTION_CULTIVATE, GameState.ACTION_COMPREHEND, GameState.ACTION_WANDER, GameState.ACTION_RECOVER]:
			action_cards[card_id] = card

	var update_header := func() -> void:
		header.text = ("▾  " if content.visible else "▸  ") + group_title + "  ·  " + str(cards.size()) + "项"
	update_header.call()
	header.pressed.connect(func() -> void:
		content.visible = not content.visible
		update_header.call()
	)

func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _make_action_card(action_id: String, title_text: String, accent: Color, custom_action: Callable = Callable()) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 60)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true
	button.add_theme_stylebox_override("normal", _card_style(Color(0.985, 0.957, 0.902, 0.78), Color(0.68, 0.59, 0.43, 0.24)))
	button.add_theme_stylebox_override("hover", _card_style(Color(1.0, 0.979, 0.932, 0.98), Color(accent.r, accent.g, accent.b, 0.58)))
	button.add_theme_stylebox_override("pressed", _card_style(Color(0.94, 0.90, 0.82, 0.96), Color(accent.r, accent.g, accent.b, 0.7)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", _card_style(Color(0.92, 0.89, 0.82, 0.50), Color(0.68, 0.59, 0.43, 0.18)))
	button.tooltip_text = "快捷键 %d" % (action_cards.size() + 1)

	var margin := MarginContainer.new()
	button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 11)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 6)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	margin.add_child(row)
	var accent_line := ColorRect.new()
	accent_line.color = Color(accent.r, accent.g, accent.b, 0.82)
	accent_line.custom_minimum_size = Vector2(2, 30)
	accent_line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(accent_line)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_theme_constant_override("separation", 0)
	row.add_child(texts)
	var title_label := _label(title_text, 17, INK)
	texts.add_child(title_label)
	var desc_label := _label("", 11, INK_SOFT)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_constant_override("line_spacing", 1)
	texts.add_child(desc_label)
	var key_label := _label("", 16, Color(accent.r, accent.g, accent.b, 0.7), font_title)
	key_label.name = "KeyLabel"
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(key_label)
	button.set_meta("desc_label", desc_label)
	button.set_meta("key_label", key_label)
	if custom_action.is_valid():
		button.pressed.connect(custom_action)
	else:
		button.pressed.connect(_on_action.bind(action_id))
	return button

func _build_sidebar(parent: HBoxContainer) -> void:
	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(302, 0)
	side.add_theme_constant_override("separation", 10)
	parent.add_child(side)

	# 命格
	var char_panel := PanelContainer.new()
	char_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.970, 0.941, 0.879, 0.92), Color(0.62, 0.53, 0.38, 0.32), 7, 1, true))
	side.add_child(char_panel)
	var char_margin := MarginContainer.new()
	char_margin.add_theme_constant_override("margin_left", 16)
	char_margin.add_theme_constant_override("margin_right", 16)
	char_margin.add_theme_constant_override("margin_top", 14)
	char_margin.add_theme_constant_override("margin_bottom", 16)
	char_panel.add_child(char_margin)
	var char_box := VBoxContainer.new()
	char_box.add_theme_constant_override("separation", 6)
	char_margin.add_child(char_box)

	var name_head := HBoxContainer.new()
	name_head.add_theme_constant_override("separation", 10)
	char_box.add_child(name_head)
	var char_seal := _make_seal("道", 38, 18)
	name_head.add_child(char_seal)
	var name_box := VBoxContainer.new()
	name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_box.add_theme_constant_override("separation", 0)
	name_head.add_child(name_box)
	char_name_label = _label("沈青崖", 25, INK, font_title)
	name_box.add_child(char_name_label)
	char_sub_label = _label("山野弃婴 · 真灵根·金木水", 11, MUTED)
	char_sub_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_box.add_child(char_sub_label)
	char_life_label = _label("第 1 世", 10, CINNABAR)
	char_life_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_head.add_child(char_life_label)

	var realm_row := HBoxContainer.new()
	realm_row.add_theme_constant_override("separation", 6)
	char_box.add_child(realm_row)
	char_realm_label = _label("炼气一层", 18, CINNABAR, font_title)
	realm_row.add_child(char_realm_label)
	var realm_spacer := Control.new()
	realm_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	realm_row.add_child(realm_spacer)
	age_label = _label("寿元 16 / 82", 11, INK_SOFT)
	age_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	realm_row.add_child(age_label)

	progress_bar = _make_bar(CINNABAR, 7)
	char_box.add_child(progress_bar)
	var progress_row := HBoxContainer.new()
	char_box.add_child(progress_row)
	progress_row.add_child(_label("修为", 10, MUTED))
	var p_spacer := Control.new()
	p_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_row.add_child(p_spacer)
	progress_text = _label("0 / 72", 10, INK_SOFT)
	progress_row.add_child(progress_text)

	var status_row := HBoxContainer.new()
	status_row.add_theme_constant_override("separation", 8)
	char_box.add_child(status_row)
	injury_label = _label("身无伤痕", 10, JADE)
	status_row.add_child(injury_label)
	battle_resource_label = _label("气血 100 · 灵力 40", 10, CINNABAR)
	char_box.add_child(battle_resource_label)
	var affiliation_label := _label("散修 · 无门无派", 10, MUTED)
	affiliation_label.name = "AffiliationLabel"
	char_box.add_child(affiliation_label)
	var st_spacer := Control.new()
	st_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_child(st_spacer)
	var talent_caption := _label("天赋", 10, MUTED)
	status_row.add_child(talent_caption)
	talent_flow = HFlowContainer.new()
	talent_flow.custom_minimum_size = Vector2(0, 20)
	talent_flow.add_theme_constant_override("h_separation", 4)
	talent_flow.add_theme_constant_override("v_separation", 4)
	char_box.add_child(talent_flow)

	# 属性
	var stat_panel := PanelContainer.new()
	stat_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.965, 0.934, 0.871, 0.88), Color(0.62, 0.53, 0.38, 0.28), 7, 1))
	side.add_child(stat_panel)
	var stat_margin := MarginContainer.new()
	stat_margin.add_theme_constant_override("margin_left", 16)
	stat_margin.add_theme_constant_override("margin_right", 16)
	stat_margin.add_theme_constant_override("margin_top", 12)
	stat_margin.add_theme_constant_override("margin_bottom", 12)
	stat_panel.add_child(stat_margin)
	var stat_box := VBoxContainer.new()
	stat_box.add_theme_constant_override("separation", 7)
	stat_margin.add_child(stat_box)
	var stat_head := HBoxContainer.new()
	stat_box.add_child(stat_head)
	stat_head.add_child(_label("根 骨 灵 性", 14, INK, font_title))
	var stat_head_spacer := Control.new()
	stat_head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_head.add_child(stat_head_spacer)
	stat_caption_label = _label("灵性上限 120", 9, MUTED)
	stat_head.add_child(stat_caption_label)
	stat_box.add_child(_hairline())
	var stats: Array = [
		{"key": "body", "label": "根骨", "color": Color(0.46, 0.39, 0.27, 1.0)},
		{"key": "insight", "label": "悟性", "color": Color(0.29, 0.42, 0.47, 1.0)},
		{"key": "luck", "label": "气运", "color": Color(0.64, 0.49, 0.25, 1.0)},
		{"key": "daoheart", "label": "道心", "color": Color(0.49, 0.30, 0.26, 1.0)},
	]
	for info: Dictionary in stats:
		_make_stat_row(stat_box, String(info["key"]), String(info["label"]), Color(info["color"]))
	stat_box.add_child(_hairline())
	combat_stats_label = _label("攻击 0 · 防御 0 · 暴击 0% · 闪避 0%", 10, INK_SOFT)
	combat_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_box.add_child(combat_stats_label)
	var res_row := HBoxContainer.new()
	stat_box.add_child(res_row)
	res_row.add_child(_label("灵石", 11, MUTED))
	var res_spacer := Control.new()
	res_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_row.add_child(res_spacer)
	stones_label = _label("0", 14, GOLD)
	res_row.add_child(stones_label)
	var karma_row := HBoxContainer.new()
	stat_box.add_child(karma_row)
	karma_row.add_child(_label("因果", 11, MUTED))
	var karma_spacer := Control.new()
	karma_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	karma_row.add_child(karma_spacer)
	karma_label = _label("尘世凡人 0", 12, INK_SOFT)
	karma_row.add_child(karma_label)

	# 随身之物
	var treasure_panel := PanelContainer.new()
	treasure_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	treasure_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.950, 0.917, 0.851, 0.82), Color(0.62, 0.53, 0.38, 0.25), 7, 1))
	side.add_child(treasure_panel)
	var tr_margin := MarginContainer.new()
	tr_margin.add_theme_constant_override("margin_left", 16)
	tr_margin.add_theme_constant_override("margin_right", 16)
	tr_margin.add_theme_constant_override("margin_top", 11)
	tr_margin.add_theme_constant_override("margin_bottom", 11)
	treasure_panel.add_child(tr_margin)
	var tr_box := VBoxContainer.new()
	tr_box.add_theme_constant_override("separation", 6)
	tr_margin.add_child(tr_box)
	var tr_head := HBoxContainer.new()
	tr_box.add_child(tr_head)
	tr_head.add_child(_label("法 器", 14, INK, font_title))
	var tr_spacer := Control.new()
	tr_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tr_head.add_child(tr_spacer)
	tr_head.add_child(_label("点物可佩带", 9, MUTED))
	tr_box.add_child(_hairline())

	var slot_row := HBoxContainer.new()
	slot_row.add_theme_constant_override("separation", 6)
	tr_box.add_child(slot_row)
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var slot_button := _make_equipment_slot_button(slot)
		slot_row.add_child(slot_button)
	tr_box.add_child(_hairline())

	var collection_head := HBoxContainer.new()
	tr_box.add_child(collection_head)
	collection_head.add_child(_label("收 藏", 10, INK_SOFT))
	var collection_spacer := Control.new()
	collection_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_head.add_child(collection_spacer)
	treasure_count_label = _label("0 件", 9, MUTED)
	collection_head.add_child(treasure_count_label)

	var tr_scroll := ScrollContainer.new()
	tr_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tr_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tr_box.add_child(tr_scroll)
	var tr_content := MarginContainer.new()
	tr_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tr_content.add_theme_constant_override("margin_top", 2)
	tr_scroll.add_child(tr_content)
	var tr_flow_box := VBoxContainer.new()
	tr_content.add_child(tr_flow_box)
	treasure_empty_label = _label("两袖清风，唯有一身因果。", 11, MUTED)
	treasure_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tr_flow_box.add_child(treasure_empty_label)
	treasure_flow = HFlowContainer.new()
	treasure_flow.add_theme_constant_override("h_separation", 5)
	treasure_flow.add_theme_constant_override("v_separation", 5)
	tr_flow_box.add_child(treasure_flow)

func _make_stat_row(parent: VBoxContainer, key: String, label_text: String, color: Color) -> void:
	var wrapper := VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", 2)
	parent.add_child(wrapper)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("h_separation", 3)
	wrapper.add_child(head)
	head.add_child(_label(label_text, 11, INK_SOFT))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	var value := _label("32", 11, color)
	value.custom_minimum_size = Vector2(24, 0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(value)
	var bonus := _label("", 9, GOLD)
	bonus.custom_minimum_size = Vector2(32, 0)
	head.add_child(bonus)
	var bar := _make_bar(color, 5)
	bar.max_value = 120
	wrapper.add_child(bar)
	stat_widgets[key] = {"bar": bar, "value": value, "bonus": bonus}

func _make_equipment_slot_button(slot: Dictionary) -> Button:
	var slot_id: String = String(slot["id"])
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _card_style(Color(0.96, 0.925, 0.855, 0.72), Color(0.67, 0.58, 0.42, 0.24)))
	button.add_theme_stylebox_override("hover", _card_style(Color(1.0, 0.974, 0.922, 0.95), Color(GOLD.r, GOLD.g, GOLD.b, 0.55)))
	button.add_theme_stylebox_override("pressed", _card_style(Color(0.93, 0.89, 0.80, 0.95), Color(GOLD.r, GOLD.g, GOLD.b, 0.66)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.tooltip_text = "点击选择佩带于%s的法器" % String(slot["name"])
	button.pressed.connect(_open_equipment_slot.bind(slot_id))

	var margin := MarginContainer.new()
	button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	margin.add_child(box)
	var top_row := HBoxContainer.new()
	box.add_child(top_row)
	var slot_label := _label(String(slot["name"]), 9, MUTED)
	top_row.add_child(slot_label)
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(top_spacer)
	top_row.add_child(_label(String(slot["short"]), 10, Color(GOLD.r, GOLD.g, GOLD.b, 0.65), font_title))
	var name_label := _label("未佩带", 11, MUTED)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.custom_minimum_size = Vector2(0, 15)
	box.add_child(name_label)
	equipment_slot_widgets[slot_id] = {"button": button, "name": name_label}
	return button

func _make_bar(fill_color: Color, height: int) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, height)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = 100
	var background := _panel_style(Color(0.78, 0.72, 0.60, 0.26), Color(0, 0, 0, 0), 4, 0)
	background.corner_radius_top_left = 4
	var fill := _panel_style(fill_color, Color(0, 0, 0, 0), 4, 0)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	return bar

func _refresh_game_ui() -> void:
	if state == null:
		return
	var life_number: int = current_life_number
	top_life_label.text = "第 %d 世 · 文字修仙轮回录" % life_number
	top_points_label.text = "轮回点 %d" % int(soul.get("points", 0))
	char_name_label.text = state.player_name
	char_sub_label.text = "%s · %s·%s" % [String(state.origin.get("name", "无名")), String(state.root.get("grade_name", "伪灵根")), String(state.root.get("name", "五行"))]
	char_sub_label.tooltip_text = "%s\n%s\n灵根只分伪、真、双、天与变异。属性越少，修炼越快。\n当前归属：%s（%s）" % [String(state.origin.get("desc", "")), String(state.root.get("desc", "")), state.faction_name, state.faction_rank]
	char_life_label.text = "第 %d 世" % life_number
	var affiliation_label := find_child("AffiliationLabel", true, false)
	if affiliation_label is Label:
		affiliation_label.text = "%s · %s\n所在：%s" % [state.faction_name, state.faction_rank, state.current_region]
		affiliation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	char_realm_label.text = state.realm_name()
	var life_color: Color = CINNABAR if state.age >= state.lifespan - 15 else INK_SOFT
	age_label.text = "寿元 %d / %d" % [state.age, state.lifespan]
	age_label.add_theme_color_override("font_color", life_color)
	progress_bar.max_value = state.threshold()
	progress_bar.value = state.cultivation
	progress_text.text = "%d / %d" % [int(state.cultivation), int(state.threshold())]
	narrative_meta_label.text = "%s岁 · %s" % [_cn_number(state.age), state.realm_name()]

	if state.injury > 0:
		injury_label.text = "伤势 %d" % state.injury
		injury_label.add_theme_color_override("font_color", CINNABAR)
	else:
		injury_label.text = "身无伤痕"
		injury_label.add_theme_color_override("font_color", JADE)
	battle_resource_label.text = "气血 %d/%d · 灵力 %d/%d" % [state.hp, state.max_hp(), state.mp, state.max_mp()]
	battle_resource_label.add_theme_color_override("font_color", CINNABAR if state.hp < state.max_hp() * 0.35 else JADE)

	_fill_talent_tags()
	for key: String in stat_widgets.keys():
		var widget: Dictionary = stat_widgets[key]
		var base_value: int = int(state.get(key))
		var total_value: int = state.effective_stat(key)
		var bonus_value: int = total_value - base_value
		(widget["bar"] as ProgressBar).value = total_value
		var value_label := widget["value"] as Label
		value_label.text = str(total_value)
		var bonus_label := widget["bonus"] as Label
		bonus_label.text = "器%+d" % bonus_value if bonus_value != 0 else ""
		if bonus_value != 0:
			bonus_label.add_theme_color_override("font_color", GOLD if bonus_value > 0 else CINNABAR)
		value_label.tooltip_text = "基础 %d · 法器 %+d" % [base_value, bonus_value]
	stat_caption_label.text = "数值已含法器" if not state.equipment_lines().is_empty() else "灵性上限 120"
	combat_stats_label.text = "攻击 %d · 防御 %d · 速度 %d · 暴击 %.1f%% · 闪避 %.1f%%\n功法威力 %+d%% · 气血上限 %d · 灵力上限 %d" % [state.attack_power(), state.defense_power(), state.speed_power(), state.critical_rate() * 100.0, state.evasion_rate() * 100.0, int(round(state.skill_power_bonus() * 100.0)), state.max_hp(), state.max_mp()]

	stones_label.text = str(state.stones)
	var karma: int = state.karma
	var k_info: Dictionary = state.karma_info()
	karma_label.text = "%s  %+d" % [String(k_info["name"]), karma]
	karma_label.add_theme_color_override("font_color", Color(String(k_info["color"])) if Color.html_is_valid(String(k_info["color"])) else INK_SOFT)
	_fill_equipment_slots()
	_fill_treasure_tags()
	_refresh_action_cards()
	_refresh_breakthrough_button()
	_render_log()

func _fill_talent_tags() -> void:
	_clear_children(talent_flow)
	for talent: Dictionary in state.talents:
		var tag := _make_tag(String(talent.get("name", "天赋")), Color(0.56, 0.45, 0.27, 0.9), 10)
		tag.tooltip_text = String(talent.get("desc", ""))
		talent_flow.add_child(tag)

func _fill_equipment_slots() -> void:
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var slot_id: String = String(slot["id"])
		var widget: Dictionary = equipment_slot_widgets.get(slot_id, {})
		if widget.is_empty():
			continue
		var button := widget["button"] as Button
		var name_label := widget["name"] as Label
		var item_name: String = state.equipped_item(slot_id)
		if item_name.is_empty():
			name_label.text = "未佩带"
			name_label.add_theme_color_override("font_color", MUTED)
			button.add_theme_stylebox_override("normal", _card_style(Color(0.96, 0.925, 0.855, 0.72), Color(0.67, 0.58, 0.42, 0.24)))
			button.tooltip_text = "点击选择佩带于%s的法器" % String(slot["name"])
		else:
			var info: Dictionary = GameData.treasure_info(item_name)
			var rarity_color: Color = _treasure_rarity_color(String(info.get("rarity", "凡品")))
			name_label.text = item_name
			name_label.add_theme_color_override("font_color", rarity_color)
			button.add_theme_stylebox_override("normal", _card_style(Color(0.96, 0.925, 0.855, 0.82), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.44)))
			button.tooltip_text = "已佩带【%s】 · 点击更换或卸下" % item_name

func _fill_treasure_tags() -> void:
	_clear_children(treasure_flow)
	treasure_empty_label.visible = state.treasures.is_empty()
	treasure_count_label.text = "%d 件" % state.treasures.size()
	for item: Variant in state.treasures:
		treasure_flow.add_child(_make_treasure_button(String(item)))

func _make_treasure_button(item_name: String) -> Button:
	var info: Dictionary = GameData.treasure_info(item_name)
	var color: Color = _treasure_rarity_color(String(info.get("rarity", "凡品")))
	var button := Button.new()
	button.text = item_name
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", font_body)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color.darkened(0.18))
	button.add_theme_color_override("font_pressed_color", color.darkened(0.25))
	var normal := _panel_style(Color(color.r, color.g, color.b, 0.08), Color(color.r, color.g, color.b, 0.24), 3, 1)
	normal.content_margin_left = 7
	normal.content_margin_right = 7
	normal.content_margin_top = 3
	normal.content_margin_bottom = 3
	var hover := _panel_style(Color(color.r, color.g, color.b, 0.16), Color(color.r, color.g, color.b, 0.55), 3, 1)
	hover.content_margin_left = 7
	hover.content_margin_right = 7
	hover.content_margin_top = 3
	hover.content_margin_bottom = 3
	var pressed := _panel_style(Color(color.r, color.g, color.b, 0.22), Color(color.r, color.g, color.b, 0.65), 3, 1)
	pressed.content_margin_left = 7
	pressed.content_margin_right = 7
	pressed.content_margin_top = 3
	pressed.content_margin_bottom = 3
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.tooltip_text = "点击查看「%s」的详情并佩带" % item_name
	if state != null and state.is_equipped(item_name):
		button.text = "◆ " + item_name
	button.pressed.connect(_open_treasure_detail.bind(item_name))
	return button

func _treasure_rarity_color(rarity: String) -> Color:
	match rarity:
		"仙品":
			return Color(0.43, 0.28, 0.48, 1.0)
		"天品":
			return CINNABAR
		"玄品":
			return GOLD
		"灵品":
			return JADE
		_:
			return MUTED

func _item_stat_text(info: Dictionary) -> String:
	var stats: Dictionary = info.get("stats", {})
	var labels: Dictionary = {"body": "根骨", "insight": "悟性", "luck": "气运", "daoheart": "道心"}
	var parts := PackedStringArray()
	for key: Variant in stats.keys():
		var value: int = int(stats[key])
		if value != 0:
			parts.append("%s %+d" % [String(labels.get(String(key), String(key))), value])
	return "　".join(parts)

func _item_mod_text(info: Dictionary) -> String:
	var mods: Dictionary = info.get("mods", {})
	var parts := PackedStringArray()
	if int(mods.get("breakthrough", 0)) != 0:
		parts.append("突破成算 +%d%%" % int(mods["breakthrough"]))
	if int(mods.get("cultivation", 0)) != 0:
		parts.append("修炼速度 +%d%%" % int(mods["cultivation"]))
	if int(mods.get("injury_reduction", 0)) != 0:
		parts.append("受伤减免 +%d%%" % int(mods["injury_reduction"]))
	if int(mods.get("attack", 0)) != 0:
		parts.append("攻击 +%d" % int(mods["attack"]))
	if int(mods.get("defense", 0)) != 0:
		parts.append("防御 +%d" % int(mods["defense"]))
	if int(mods.get("skill_power", 0)) != 0:
		parts.append("功法威力 +%d%%" % int(mods["skill_power"]))
	if int(mods.get("critical_rate", 0)) != 0:
		parts.append("暴击率 +%d%%" % int(mods["critical_rate"]))
	if int(mods.get("evasion", 0)) != 0:
		parts.append("闪避率 +%d%%" % int(mods["evasion"]))
	if int(mods.get("speed", 0)) != 0:
		parts.append("速度 %+d" % int(mods["speed"]))
	return "　".join(parts)

func _item_effect_short(info: Dictionary) -> String:
	var parts := PackedStringArray()
	var stat_text: String = _item_stat_text(info)
	if not stat_text.is_empty():
		parts.append(stat_text.replace("　", " "))
	var mod_text: String = _item_mod_text(info)
	if not mod_text.is_empty():
		parts.append(mod_text.replace("　", " "))
	return " · ".join(parts)

func _open_treasure_detail(item_name: String, notice: String = "") -> void:
	var info: Dictionary = GameData.treasure_info(item_name)
	var rarity: String = String(info.get("rarity", "凡品"))
	var color: Color = _treasure_rarity_color(rarity)
	var slot_id: String = String(info.get("slot", ""))
	var box := _open_modal(Vector2(640, 0), true, Callable())

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	box.add_child(head)
	var head_text := VBoxContainer.new()
	head_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_text.add_theme_constant_override("separation", 1)
	head.add_child(head_text)
	var equipped: bool = state != null and state.is_equipped(item_name)
	var kicker := _label("随 身 之 物　·　%s" % rarity, 11, color)
	head_text.add_child(kicker)
	head_text.add_child(_label(item_name, 34, INK, font_title))
	var sub_text: String = "%s · 第 %d 世收藏" % [String(info.get("kind", "旧物")), current_life_number]
	if not slot_id.is_empty():
		sub_text = "%s · 可佩带于%s" % [String(info.get("kind", "旧物")), GameData.slot_name(slot_id)]
	if equipped:
		sub_text += " · 已佩带"
	var subtitle := _label(sub_text, 11, JADE if equipped else INK_SOFT)
	head_text.add_child(subtitle)
	var seal := _make_seal(String(info.get("glyph", "物")), 48, 22)
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(seal)
	box.add_child(_hairline())
	if not notice.is_empty():
		var notice_label := _label(notice, 11, JADE)
		notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(notice_label)

	var desc := _rich_label(String(info.get("desc", "")), 15, INK, 3)
	desc.custom_minimum_size = Vector2(0, 68)
	box.add_child(desc)

	var lore_panel := PanelContainer.new()
	lore_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.94, 0.90, 0.82, 0.62), Color(0.66, 0.57, 0.42, 0.22), 4, 1))
	box.add_child(lore_panel)
	var lore_margin := MarginContainer.new()
	lore_margin.add_theme_constant_override("margin_left", 14)
	lore_margin.add_theme_constant_override("margin_right", 14)
	lore_margin.add_theme_constant_override("margin_top", 9)
	lore_margin.add_theme_constant_override("margin_bottom", 9)
	lore_panel.add_child(lore_margin)
	var lore_box := VBoxContainer.new()
	lore_box.add_theme_constant_override("separation", 3)
	lore_margin.add_child(lore_box)
	lore_box.add_child(_label("来 历", 10, color))
	var lore := _label(String(info.get("lore", "")), 12, INK_SOFT)
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lore_box.add_child(lore)

	var equip_panel := PanelContainer.new()
	equip_panel.add_theme_stylebox_override("panel", _panel_style(Color(color.r, color.g, color.b, 0.055), Color(color.r, color.g, color.b, 0.26), 4, 1))
	box.add_child(equip_panel)
	var equip_margin := MarginContainer.new()
	equip_margin.add_theme_constant_override("margin_left", 14)
	equip_margin.add_theme_constant_override("margin_right", 14)
	equip_margin.add_theme_constant_override("margin_top", 8)
	equip_margin.add_theme_constant_override("margin_bottom", 8)
	equip_panel.add_child(equip_margin)
	var equip_box := VBoxContainer.new()
	equip_box.add_theme_constant_override("separation", 2)
	equip_margin.add_child(equip_box)
	var equip_head := HBoxContainer.new()
	equip_box.add_child(equip_head)
	var passive_name: String = String(info.get("passive_name", "凡物"))
	equip_head.add_child(_label("器 韵 · %s" % passive_name, 11, color))
	var equip_spacer := Control.new()
	equip_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equip_head.add_child(equip_spacer)
	equip_head.add_child(_label("可佩带于%s" % GameData.slot_name(slot_id) if not slot_id.is_empty() else "不可佩带", 9, MUTED))
	var stat_text: String = _item_stat_text(info)
	var mod_text: String = _item_mod_text(info)
	if stat_text.is_empty() and mod_text.is_empty():
		equip_box.add_child(_label("此物不提供常驻属性加成。", 11, INK_SOFT))
	else:
		if not stat_text.is_empty():
			equip_box.add_child(_label(stat_text, 12, INK))
		if not mod_text.is_empty():
			equip_box.add_child(_label(mod_text, 11, Color(GOLD.r, GOLD.g, GOLD.b, 0.95)))

	var relic_passive: Dictionary = GameData.relic_passive_info(item_name)
	if not relic_passive.is_empty():
		var relic_panel := PanelContainer.new()
		relic_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.90, 0.94, 0.88, 0.95), Color(0.27, 0.43, 0.37, 0.38), 4, 1))
		box.add_child(relic_panel)
		var relic_margin := MarginContainer.new()
		for margin_key: String in ["margin_left", "margin_right"]: relic_margin.add_theme_constant_override(margin_key, 12)
		relic_margin.add_theme_constant_override("margin_top", 8)
		relic_margin.add_theme_constant_override("margin_bottom", 8)
		relic_panel.add_child(relic_margin)
		var relic_box := VBoxContainer.new()
		relic_box.add_theme_constant_override("separation", 3)
		relic_margin.add_child(relic_box)
		relic_box.add_child(_label("常驻被动 · %s" % String(relic_passive.get("name", "遗物灵效")), 12, JADE, font_title))
		var relic_desc := _label(String(relic_passive.get("desc", "持有时生效。")), 11, INK_SOFT)
		relic_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		relic_box.add_child(relic_desc)
		relic_box.add_child(_label("无需佩带，收入收藏即永久生效", 10, MUTED))
	var active_info: Dictionary = GameData.treasure_active_info(item_name)
	var used_treasures: Array = state.flags.get("used_treasures", []) if state != null else []
	var active_used: bool = used_treasures.has(item_name)
	if not active_info.is_empty():
		var active_panel := PanelContainer.new()
		active_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.271, 0.427, 0.373, 0.07), Color(0.271, 0.427, 0.373, 0.28), 4, 1))
		box.add_child(active_panel)
		var active_margin := MarginContainer.new()
		active_margin.add_theme_constant_override("margin_left", 12)
		active_margin.add_theme_constant_override("margin_right", 12)
		active_margin.add_theme_constant_override("margin_top", 8)
		active_margin.add_theme_constant_override("margin_bottom", 8)
		active_panel.add_child(active_margin)
		var active_box := VBoxContainer.new()
		active_box.add_theme_constant_override("separation", 3)
		active_margin.add_child(active_box)
		active_box.add_child(_label("灵 韵 · %s" % String(active_info.get("name", "主动效果")), 11, JADE))
		var active_desc := _label(String(active_info.get("desc", "")), 11, INK_SOFT)
		active_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		active_box.add_child(active_desc)
		active_box.add_child(_label("本世灵韵已耗尽" if active_used else "每一世可启用一次", 10, MUTED))

	var facts := HBoxContainer.new()
	facts.add_theme_constant_override("separation", 8)
	box.add_child(facts)
	facts.add_child(_death_fact("品阶", rarity))
	facts.add_child(_death_fact("类型", String(info.get("kind", "旧物"))))
	facts.add_child(_death_fact("佩带位", GameData.slot_name(slot_id) if not slot_id.is_empty() else "不可佩带"))
	var acquired_age: int = int(state.treasure_ages.get(item_name, 0)) if state != null else 0
	facts.add_child(_death_fact("收纳", "%d 岁" % acquired_age if acquired_age > 0 else "来历已远"))

	var note := _label("身死结算时，每件遗物仍折算 2 点轮回道果；带有常驻被动的旧物，收入收藏后即生效。法器加成仍只在佩带时生效。", 10, MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	footer.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(footer)
	var close := _make_button("放回袖中", false, 120, 40)
	close.pressed.connect(_close_modal)
	footer.add_child(close)
	if not slot_id.is_empty() and state != null:
		var toggle := _make_button("已佩带 · 卸下" if equipped else "佩带于%s" % GameData.slot_name(slot_id), true, 156, 40)
		toggle.pressed.connect(_on_equipment_toggle.bind(item_name))
		footer.add_child(toggle)
	if not active_info.is_empty() and state != null:
		var activate_button := _make_button("灵韵已耗尽" if active_used else "启用灵韵", not active_used, 120, 40)
		activate_button.disabled = active_used
		activate_button.pressed.connect(_on_inventory_action.bind("use_treasure", item_name))
		footer.add_child(activate_button)

func _on_equipment_toggle(item_name: String) -> void:
	if state == null or not state.treasures.has(item_name):
		return
	var info: Dictionary = GameData.treasure_info(item_name)
	var slot_id: String = String(info.get("slot", ""))
	if slot_id.is_empty():
		return
	if state.is_equipped(item_name):
		state.unequip_item(item_name)
		_refresh_game_ui()
		_open_treasure_detail(item_name, "已卸下【%s】" % item_name)
		return
	var previous: String = state.equip_item(item_name)
	_refresh_game_ui()
	var notice: String = "已佩带【%s】" % item_name
	if not previous.is_empty():
		notice += "，替换了【%s】" % previous
	_open_treasure_detail(item_name, notice)

func _open_equipment_slot(slot_id: String, notice: String = "") -> void:
	if state == null:
		return
	var slot: Dictionary = {}
	for candidate: Dictionary in GameData.EQUIP_SLOTS:
		if String(candidate["id"]) == slot_id:
			slot = candidate
			break
	if slot.is_empty():
		return
	var box := _open_modal(Vector2(720, 0), true, Callable())
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	box.add_child(head)
	var head_text := VBoxContainer.new()
	head_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_text.add_theme_constant_override("separation", 1)
	head.add_child(head_text)
	head_text.add_child(_label("法 器 · 佩 带", 11, GOLD))
	head_text.add_child(_label(String(slot["name"]), 34, INK, font_title))
	head_text.add_child(_label(String(slot["desc"]), 11, INK_SOFT))
	var seal := _make_seal(String(slot["short"]), 48, 22)
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(seal)
	box.add_child(_hairline())
	if not notice.is_empty():
		var notice_label := _label(notice, 11, JADE)
		notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(notice_label)

	var current_item: String = state.equipped_item(slot_id)
	if not current_item.is_empty():
		var current := HBoxContainer.new()
		current.add_theme_constant_override("separation", 8)
		box.add_child(current)
		current.add_child(_label("当前佩带：%s" % current_item, 12, _treasure_rarity_color(String(GameData.treasure_info(current_item).get("rarity", "凡品")))))
		var current_spacer := Control.new()
		current_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		current.add_child(current_spacer)
		var unequip := _make_button("卸下", false, 76, 32)
		unequip.pressed.connect(_on_slot_unequip.bind(slot_id, current_item))
		current.add_child(unequip)

	var owned: Array = []
	for item: Variant in state.treasures:
		var info: Dictionary = GameData.treasure_info(String(item))
		if String(info.get("slot", "")) == slot_id:
			owned.append(String(item))
	if owned.is_empty():
		var empty := _label("你尚未得到可佩带于此的法器。\n红尘中还有未遇的机缘。", 13, MUTED)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.custom_minimum_size = Vector2(0, 100)
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(empty)
	else:
		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 7)
		box.add_child(list)
		for item_name: String in owned:
			list.add_child(_make_equipment_row(slot_id, item_name))

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var hint := _label("每个法器位只能佩带一件。点击「收藏」中的物品也可查看详情与佩带。", 10, MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(hint)
	var close := _make_button("返回", false, 100, 38)
	close.pressed.connect(_close_modal)
	footer.add_child(close)

func _make_equipment_row(slot_id: String, item_name: String) -> PanelContainer:
	var info: Dictionary = GameData.treasure_info(item_name)
	var rarity: String = String(info.get("rarity", "凡品"))
	var color: Color = _treasure_rarity_color(rarity)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.962, 0.931, 0.865, 0.70), Color(0.66, 0.57, 0.41, 0.22), 4, 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 1)
	row.add_child(text_box)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("h_separation", 8)
	text_box.add_child(title_row)
	title_row.add_child(_label(item_name, 16, color, font_title))
	title_row.add_child(_label("%s · %s" % [rarity, String(info.get("kind", "法器"))], 9, MUTED))
	var effect_short: String = _item_effect_short(info)
	if effect_short.is_empty():
		effect_short = "无属性加成"
	text_box.add_child(_label(effect_short, 10, INK_SOFT))
	var equipped: bool = state.is_equipped(item_name)
	var button := _make_button("已佩带" if equipped else "佩带", not equipped, 86, 34)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.disabled = equipped
	if not equipped:
		button.pressed.connect(_on_equip_from_slot.bind(slot_id, item_name))
	row.add_child(button)
	return card

func _on_equip_from_slot(slot_id: String, item_name: String) -> void:
	if state == null:
		return
	var previous: String = state.equip_item(item_name)
	_refresh_game_ui()
	var notice: String = "已佩带【%s】" % item_name
	if not previous.is_empty():
		notice += "，替换了【%s】" % previous
	_open_equipment_slot(slot_id, notice)

func _on_slot_unequip(slot_id: String, item_name: String) -> void:
	if state == null:
		return
	state.unequip_item(item_name)
	_refresh_game_ui()
	_open_equipment_slot(slot_id, "已卸下【%s】" % item_name)

func _refresh_action_cards() -> void:
	var peak: bool = state.is_peak()
	for id: String in action_cards.keys():
		var card: Button = action_cards[id]
		var desc: Label = card.get_meta("desc_label") as Label
		var key_label: Label = card.get_meta("key_label") as Label
		var index: int = 0
		match id:
			GameState.ACTION_CULTIVATE:
				index = 1
				var speed: float = (0.70 + float(state.effective_stat("insight")) / 150.0) * float(state.root.get("speed", 1.0)) * (1.0 - float(state.injury) / 420.0)
				speed *= 1.0 + state.equipment_mod("cultivation") / 100.0
				var gain: int = int(round(state.threshold() * 0.20 * speed))
				desc.text = "气海已满，先破境" if peak else "引气入体 · 约 +%d 修为" % gain
			GameState.ACTION_COMPREHEND:
				index = 2
				desc.text = "观道悟心 · 悟性提升，道心渐稳"
			GameState.ACTION_WANDER:
				index = 3
				desc.text = "红尘寻缘 · 必有一段际遇或劫数"
			GameState.ACTION_RECOVER:
				index = 4
				desc.text = "疗养伤势 · 伤势减轻，根骨 +1" if state.injury > 0 else "静养心神 · 根骨 +1，修为小进"
		key_label.text = _formal_number(index)
		card.tooltip_text = "快捷键 %d  ·  %s" % [index, desc.text]
		card.disabled = not _can_act()

func _refresh_breakthrough_button() -> void:
	var next_index: int = state.realm + 1
	var is_peak: bool = state.is_peak()
	var chance: int = int(round(state.breakthrough_chance()))
	var next_name: String = "飞升"
	if next_index < GameData.REALMS.size():
		next_name = GameData.realm_name(next_index)
	var ready := is_peak and _can_act()
	breakthrough_button.disabled = not ready
	if state.realm >= GameData.REALMS.size() - 1:
		if is_peak:
			breakthrough_button.text = "渡劫飞升　·　成算 %d%%　·　空格" % chance
		else:
			breakthrough_button.text = "渡劫飞升　·　尚需 %d 修为" % int(ceil(state.threshold() - state.cultivation))
	else:
		if is_peak:
			breakthrough_button.text = "冲击「%s」　·　成算 %d%%　·　空格" % [next_name, chance]
		else:
			breakthrough_button.text = "气机未满　·　冲境尚需 %d 修为" % int(ceil(state.threshold() - state.cultivation))

	if ready:
		breakthrough_button.add_theme_stylebox_override("normal", _panel_style(CINNABAR, Color(0.45, 0.15, 0.10, 0.9), 5, 1))
		breakthrough_button.add_theme_stylebox_override("hover", _panel_style(CINNABAR_DARK, Color(0.35, 0.11, 0.07, 0.9), 5, 1))
		breakthrough_button.add_theme_stylebox_override("pressed", _panel_style(Color(0.40, 0.13, 0.09, 1.0), Color(0.35, 0.11, 0.07, 0.9), 5, 1))
		breakthrough_button.add_theme_color_override("font_color", WARM_WHITE)
		breakthrough_button.add_theme_color_override("font_hover_color", WARM_WHITE)
		breakthrough_button.add_theme_color_override("font_pressed_color", WARM_WHITE)
	else:
		var normal := _panel_style(Color(0.87, 0.83, 0.75, 0.54), Color(0.66, 0.57, 0.42, 0.22), 5, 1)
		breakthrough_button.add_theme_stylebox_override("normal", normal)
		breakthrough_button.add_theme_stylebox_override("hover", normal)
		breakthrough_button.add_theme_stylebox_override("pressed", normal)
		breakthrough_button.add_theme_stylebox_override("disabled", normal)
		breakthrough_button.add_theme_color_override("font_color", MUTED)
		breakthrough_button.add_theme_color_override("font_disabled_color", MUTED)

func _render_log() -> void:
	if state == null or log_rich == null:
		return
	if state.log_seq == last_log_seq and not log_rich.text.is_empty():
		return
	var start_index: int = maxi(0, state.logs.size() - MAX_VISIBLE_LOGS)
	var parts := PackedStringArray()
	if start_index > 0:
		parts.append("[color=#8b7a5c]更早的行迹已沉入记忆，此处只呈现最近六十则。[/color]")
	for i: int in range(start_index, state.logs.size()):
		var entry: Dictionary = state.logs[i]
		var age_number: int = int(entry.get("age", state.age))
		var kind: String = String(entry.get("kind", "normal"))
		var color: Color = _log_color(kind)
		var tag: String = _log_tag(kind)
		var text: String = String(entry.get("text", ""))
		parts.append("[color=#%s]%s岁 · %s[/color]\n%s" % [color.to_html(false), _cn_number(age_number), tag, text])
	log_rich.text = "\n\n".join(parts)
	last_log_seq = state.log_seq
	_scroll_log_bottom()

func _log_color(kind: String) -> Color:
	match kind:
		"birth", "story":
			return GOLD
		"event":
			return JADE
		"gain":
			return Color(0.31, 0.48, 0.40, 1.0)
		"hint":
			return Color(0.62, 0.48, 0.26, 1.0)
		"danger", "death":
			return CINNABAR
		"breakthrough", "epiphany", "ascension":
			return CINNABAR
		_:
			return Color(0.56, 0.49, 0.38, 1.0)

func _log_tag(kind: String) -> String:
	match kind:
		"birth": return "入世"
		"story": return "前尘"
		"action": return "行迹"
		"event": return "缘法"
		"gain": return "所得"
		"hint": return "心念"
		"danger": return "劫数"
		"death": return "终章"
		"breakthrough": return "破境"
		"epiphany": return "顿悟"
		"ascension": return "飞升"
		_: return "行迹"

func _scroll_log_bottom() -> void:
	await get_tree().process_frame
	if is_instance_valid(log_scroll):
		var scrollbar := log_scroll.get_v_scroll_bar()
		if scrollbar != null:
			log_scroll.scroll_vertical = int(scrollbar.max_value)
			await get_tree().process_frame
			if is_instance_valid(log_scroll):
				log_scroll.scroll_vertical = int(log_scroll.get_v_scroll_bar().max_value)

# ---------------------------------------------------------------------------
# 游戏流程
# ---------------------------------------------------------------------------

func _open_sensenova_panel() -> void:
	var ai_ui: Node = get_node_or_null("/root/SenseNovaContentUI")
	if ai_ui != null and ai_ui.has_method("open_panel"):
		ai_ui.call("open_panel")
	else:
		push_warning("SenseNovaContentUI 自动加载尚未就绪。")

func _show_menu() -> void:
	_clear_modal(false)
	ui_mode = "menu"
	menu_screen.visible = true
	game_screen.visible = false
	_refresh_menu()
	if music != null:
		music.play_track("menu", 1.8)

func _enter_game() -> void:
	ui_mode = "game"
	menu_screen.visible = false
	game_screen.visible = true
	last_log_seq = -1
	_refresh_game_ui()
	if music != null:
		music.play_track("cultivation", 1.6)

func _on_return_to_menu() -> void:
	if state != null and state.alive:
		_save_run()
	_show_menu()

func _on_continue_run() -> void:
	if not _load_run():
		_refresh_menu()
		return
	_enter_game()
	_save_run()

func _start_new_life() -> void:
	_clear_modal(false)
	current_life_number = int(soul.get("lives", 0)) + 1
	state = GameState.new_life(soul, rng)
	game_screen.visible = true
	menu_screen.visible = false
	ui_mode = "game"
	last_log_seq = -1
	_save_run()
	_refresh_game_ui()
	if music != null:
		music.play_track("cultivation", 1.8)
	_show_intro_modal()

func _root_effect_text() -> String:
	var descriptions := {
		"伪灵根": "修炼最慢 · 防御 +2 · 气血上限 +8",
		"真灵根": "修炼速度普通 · 功法威力 +4% · 灵力上限 +6",
		"双灵根": "修炼较快 · 功法威力 +6% · 暴击率 +1%",
		"天灵根": "修炼极快 · 功法威力 +10% · 灵力上限 +12",
		"变异灵根": "修炼极快 · 攻击 +2 · 功法威力 +10% · 暴击率 +3%",
	}
	var rank := String(state.root.get("rank", state.root.get("grade_name", "伪灵根")))
	var elements := String(state.root.get("name", ""))
	return "灵根：%s·%s\n灵根效果：" % [rank, elements] + String(descriptions.get(rank, "修炼速度 ×%.2f" % float(state.root.get("speed", 1.0))))

func _format_origin_perks(perks: Dictionary) -> String:
	var labels := {"attack": "攻击", "defense": "防御", "critical_rate": "暴击率", "evasion": "闪避率", "skill_power": "功法威力", "max_hp": "气血上限", "max_mp": "灵力上限", "cultivation": "修炼效率", "breakthrough": "突破成算"}
	var parts: Array[String] = []
	for key in labels:
		var value := float(perks.get(key, 0.0))
		if is_zero_approx(value):
			continue
		var suffix := "%+d" % int(round(value))
		if key in ["critical_rate", "evasion", "skill_power", "cultivation", "breakthrough"]:
			suffix += "%"
		parts.append(String(labels[key]) + " " + suffix)
	return "、".join(parts)

func _show_intro_modal() -> void:
	if state == null:
		return
	var box := _open_modal(Vector2(820, 0), false, Callable())
	var life_number: int = current_life_number
	var kicker := _label("第 %d 世 · 转 生" % life_number, 12, CINNABAR)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(kicker)
	var title := _label(state.player_name, 48, INK, font_title)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var birth := _rich_label(String(state.origin.get("birth", "")), 15, INK_SOFT)
	birth.custom_minimum_size = Vector2(0, 66)
	box.add_child(birth)
	var chronicle: Array = soul.get("chronicle", [])
	if not chronicle.is_empty():
		var previous: Dictionary = chronicle[chronicle.size() - 1]
		var echo := _label("前世残影 · 上一个你名叫%s，享年%d岁，止步于%s。偶尔，你仍会在梦里看见他最后的身影。"
			% [String(previous.get("name", "无名")), int(previous.get("age", 0)),
			String(previous.get("realm_name", "凡尘"))], 10, MUTED)
		echo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		echo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(echo)
	box.add_child(_hairline())

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 10)
	box.add_child(grid)
	var origin_perks: Dictionary = state.origin.get("perks", {})
	var origin_effect_text := _format_origin_perks(origin_perks)
	grid.add_child(_info_block("出 身", String(state.origin.get("name", "")), String(state.origin.get("desc", "")) + ("\n\n出身特性：" + origin_effect_text if not origin_effect_text.is_empty() else "")))
	grid.add_child(_info_block("灵 根", String(state.root.get("name", "")), String(state.root.get("desc", "")) + "\n\n" + _root_effect_text()))

	var talent_panel := PanelContainer.new()
	talent_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.93, 0.89, 0.80, 0.62), Color(0.66, 0.57, 0.42, 0.22), 4, 1))
	box.add_child(talent_panel)
	var talent_margin := MarginContainer.new()
	talent_margin.add_theme_constant_override("margin_left", 14)
	talent_margin.add_theme_constant_override("margin_right", 14)
	talent_margin.add_theme_constant_override("margin_top", 9)
	talent_margin.add_theme_constant_override("margin_bottom", 9)
	talent_panel.add_child(talent_margin)
	var talent_box := VBoxContainer.new()
	talent_box.add_theme_constant_override("separation", 4)
	talent_margin.add_child(talent_box)
	var talent_head := HBoxContainer.new()
	talent_box.add_child(talent_head)
	talent_head.add_child(_label("天 赋", 11, MUTED))
	var t_spacer := Control.new()
	t_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	talent_head.add_child(t_spacer)
	var talent_names := PackedStringArray()
	for talent: Dictionary in state.talents:
		var effect_text := PackedStringArray()
		var talent_stats: Dictionary = talent.get("stats", {})
		for stat_key: String in ["body", "insight", "luck", "daoheart"]:
			var amount := int(talent_stats.get(stat_key, 0))
			if amount != 0:
				var stat_name: String = str({"body": "根骨", "insight": "悟性", "luck": "气运", "daoheart": "道心"}.get(stat_key, stat_key))
				effect_text.append("%s%+d" % [stat_name, amount])
		var life_bonus := int(talent.get("lifespan", 0))
		if life_bonus != 0:
			effect_text.append("寿元上限+%d年" % life_bonus)
		var actual_effect := "；实际效果：" + "、".join(effect_text) if not effect_text.is_empty() else "；暂无数值加成"
		talent_names.append("%s（%s%s）" % [String(talent.get("name", "")), String(talent.get("desc", "")), actual_effect])
	talent_head.add_child(_label(" · ".join(talent_names), 11, INK_SOFT))

	var stat_row := HBoxContainer.new()
	stat_row.add_theme_constant_override("separation", 14)
	box.add_child(stat_row)
	stat_row.add_child(_mini_stat("根骨", state.body))
	stat_row.add_child(_mini_stat("悟性", state.insight))
	stat_row.add_child(_mini_stat("气运", state.luck))
	stat_row.add_child(_mini_stat("道心", state.daoheart))
	stat_row.add_child(_mini_stat("灵石", state.stones))
	var age_stat := _mini_stat("初始寿元", state.lifespan)
	stat_row.add_child(age_stat)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(button_row)
	var enter := _make_button("睁眼入世", true, 170, 46)
	enter.pressed.connect(_close_modal)
	button_row.add_child(enter)

func _info_block(kicker: String, title_text: String, desc: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.95, 0.91, 0.83, 0.65), Color(0.66, 0.57, 0.42, 0.20), 4, 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	margin.add_child(box)
	box.add_child(_label(kicker, 10, MUTED))
	box.add_child(_label(title_text, 21, INK, font_title))
	var desc_label := _label(desc, 11, INK_SOFT)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(0, 32)
	box.add_child(desc_label)
	return panel

func _mini_stat(label_text: String, value: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 0)
	var value_label := _label(str(value), 19, INK, font_title)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(value_label)
	var name_label := _label(label_text, 9, MUTED)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_label)
	return box

func _can_act() -> bool:
	return ui_mode == "game" and state != null and state.alive and not modal_open

func _on_action(action_id: String) -> void:
	if not _can_act():
		return
	var result: Dictionary = {}
	match action_id:
		GameState.ACTION_CULTIVATE:
			result = state.cultivate(rng)
		GameState.ACTION_COMPREHEND:
			result = state.comprehend(rng)
		GameState.ACTION_WANDER:
			result = state.wander(rng)
		GameState.ACTION_RECOVER:
			result = state.recover(rng)
		_:
			return

	_refresh_game_ui()
	if state.check_death():
		_handle_death()
		return

	var event_chance: float = float(result.get("event_chance", 0.0))
	if event_chance >= 1.0 or rng.randf() < event_chance:
		var event: Dictionary = EventData.pick_event(state, rng)
		var event_choices: Variant = event.get("choices", [])
		if not event.is_empty() and event_choices is Array and not event_choices.is_empty():
			_save_run()
			_refresh_game_ui()
			_open_event(event)
			return
	_finish_turn()

func _finish_turn() -> void:
	if state == null:
		return
	_save_run()
	_refresh_game_ui()

func _open_travel_hub() -> void:
	if not _can_act() or state == null:
		return
	var box := _open_modal(Vector2(690, 560), true, Callable())
	_add_modal_heading(box, "行走天下", "山河万里，各有去处", "红尘历练专注探索与可选择的正式奇遇；寻敌斗法可主动寻找对手；九州行旅和秘境探索各有专属内容。")

	var red_dust := _make_button("红尘历练　·　探索与可选择的正式奇遇", true, 0, 54)
	red_dust.tooltip_text = "沿途探索并有机会触发带有明确选项和实际结果的正式奇遇；不会随机插入无选项的纯文字遭遇。"
	red_dust.pressed.connect(_enter_red_dust)
	box.add_child(red_dust)
	box.add_child(_label("不指定目的地，专注游历与有选择、有结果的奇遇。寻敌斗法请使用独立入口。", 11, INK_SOFT))

	var world_trip := _make_button("九州行旅　·　选择州域与地方探索", false, 0, 54)
	world_trip.tooltip_text = "查看九州地图，前往不同州域，探索当地资源与势力。"
	world_trip.pressed.connect(_enter_world_map)
	box.add_child(world_trip)
	box.add_child(_label("选择目的地并支付远行花费；不同州域有不同危险、资源与势力。", 11, INK_SOFT))

	var secret_trip := _make_button("秘境探索　·　遗迹、宝物与古修传承", false, 0, 54)
	secret_trip.tooltip_text = "进入无名秘境，可谨慎采集，也可深入遗迹承担风险。"
	secret_trip.pressed.connect(_enter_secret_realm)
	box.add_child(secret_trip)
	box.add_child(_label("独立秘境挑战，选择稳妥采集或深入遗迹，风险与回报并存。", 11, INK_SOFT))

	var close := _make_button("返回", false, 110, 38)
	close.pressed.connect(_close_modal)
	box.add_child(close)

func _enter_red_dust() -> void:
	_clear_modal(false)
	_on_action(GameState.ACTION_WANDER)

func _enter_world_map() -> void:
	_clear_modal(false)
	_open_world_map()

func _enter_secret_realm() -> void:
	_clear_modal(false)
	_open_secret_realm()

func _open_world_map() -> void:
	if not _can_act() or state == null:
		return
	var box := _open_modal(Vector2(760, 680), true, Callable())
	_add_modal_heading(box, "山河万里 · 天下舆图", "踏遍九州，寻访机缘", "远行会消耗灵石与一年光阴；各地危险、灵材与势力影响不同。境界不足不可贸然深入。")
	var map_nav := HBoxContainer.new()
	map_nav.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(map_nav)
	var map_back := _make_button("返回", false, 120, 38)
	map_back.pressed.connect(_close_modal)
	map_nav.add_child(map_back)
	var current := state.region_info()
	var current_panel := PanelContainer.new()
	current_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.94, 0.91, 0.83, 0.9), Color(0.62, 0.53, 0.38, 0.35), 6, 1))
	box.add_child(current_panel)
	var current_box := VBoxContainer.new()
	current_box.add_theme_constant_override("separation", 5)
	current_panel.add_child(current_box)
	current_box.add_child(_label("当前所在 · %s" % state.current_region, 16, CINNABAR, font_title))
	current_box.add_child(_label(String(current.get("desc", "")), 11, INK_SOFT))
	var current_row := HBoxContainer.new()
	current_box.add_child(current_row)
	var explore_button := _make_button("探索当前区域（耗时一年）", true, 210, 38)
	explore_button.pressed.connect(_on_explore_current_region)
	current_row.add_child(explore_button)
	current_row.add_child(_label("危险 %d级 · 已发现 %d / %d 州域" % [int(current.get("danger", 1)), state.discovered_regions.size(), GameState.WORLD_REGIONS.size()], 11, GOLD))
	if not state.rival_npcs.is_empty():
		var rival: Dictionary = state.rival_npcs[0]
		var rival_text := "同代修士：%s · %s · 资质%d · %s" % [String(rival.get("name", "无名")), GameData.realm_name(int(rival.get("realm", 0))), int(rival.get("aptitude", 0)), "仍在修行" if bool(rival.get("alive", true)) else "已陨落"]
		box.add_child(_label(rival_text, 11, JADE))
	box.add_child(_hairline())
	box.add_child(_label("州 域 列 表", 16, INK, font_title))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 390)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	for region: Dictionary in GameState.WORLD_REGIONS:
		var region_name := String(region.get("name", "未知之地"))
		var required := int(region.get("realm", 0))
		var unlocked := state.realm >= required
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list.add_child(row)
		var info_box := VBoxContainer.new()
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_box)
		var marker := "当前所在" if region_name == state.current_region else ("已踏足" if state.discovered_regions.has(region_name) else "未探索")
		info_box.add_child(_label("%s  ·  %s" % [region_name, marker], 13, CINNABAR if region_name == state.current_region else INK, font_title))
		var local_summary := "特产：%s\n妖兽：%s" % [String(region.get("specialty", "暂无")), "、".join(_regional_beast_names(region))]
		info_box.add_child(_label("%s\n归属：%s · 危险：%d级 · 需求：%s\n%s" % [String(region.get("desc", "")), String(region.get("faction", "散修")), int(region.get("danger", 1)), GameData.realm_name(required), local_summary], 10, INK_SOFT))
		var cost := 8 + required * 4
		var travel := _make_button("身在此地" if region_name == state.current_region else "前往 · %d灵石" % cost, false, 132, 34)
		travel.disabled = region_name == state.current_region or not unlocked or state.stones < cost
		travel.pressed.connect(_on_travel_to_region.bind(region_name))
		row.add_child(travel)
		list.add_child(_hairline())

func _regional_beast_names(region: Dictionary) -> PackedStringArray:
	var names := PackedStringArray()
	for beast: Dictionary in region.get("beasts", []):
		names.append(String(beast.get("name", "未知妖兽")))
	return names

func _on_travel_to_region(region_name: String) -> void:
	if state == null:
		return
	var result: Dictionary = state.travel_to_region(region_name)
	_close_modal()
	if bool(result.get("ok", false)) and state.check_death():
		_handle_death()
		return
	_save_run()
	_refresh_game_ui()
	_open_notice_modal(String(result.get("message", "远行结束。")), func() -> void: _open_world_map())

func _on_explore_current_region() -> void:
	if state == null or not state.alive:
		return
	var result: Dictionary = state.explore_current_region(rng)
	if not result.has("enemy"):
		var gathered_by_pet := state.pet_gather(rng)
		if not gathered_by_pet.is_empty():
			result["message"] = String(result.get("message", "探索结束。")) + "\n灵宠协助采集，额外获得%s ×1。" % gathered_by_pet
	_close_modal()
	if state.check_death():
		_handle_death()
		return
	if result.has("enemy"):
		battle_enemy = result["enemy"]
		battle_turn_index = 0
		state.flags.erase("companion_guard")
		battle_logs.clear()
		battle_cooldowns.clear()
		battle_logs.append(String(result.get("message", "你遭遇了地域妖兽。")))
		battle_logs.append(String(battle_enemy.get("desc", "妖兽拦住了去路。")))
		battle_active = true
		_save_run()
		_refresh_game_ui()
		_open_battle_modal()
		return
	_save_run()
	_refresh_game_ui()
	_open_notice_modal(String(result.get("message", "探索结束。")), func() -> void: _open_world_map())

func _pet_stage_title(pet: Dictionary) -> String:
	var stage_names: Array[String] = ["幼年", "成年", "觉醒", "神兽"]
	var stage: int = clampi(int(pet.get("visual_stage", pet.get("evolution", 0))), 0, 3)
	if not String(pet.get("divine_beast", "")).is_empty():
		stage = 3
	var base_name: String = String(pet.get("species", pet.get("name", "灵宠")))
	for prefix: String in stage_names:
		var marker: String = prefix + "·"
		if base_name.begins_with(marker):
			base_name = base_name.trim_prefix(marker)
	return "%s·%s" % [stage_names[stage], base_name]

func _open_beast_codex() -> void:
	if state == null:
		return
	var box := _open_modal(Vector2(790, 720), true, Callable())
	var codex_kicker := _label("万兽神谱 · 上古神兽图鉴", 12, CINNABAR)
	codex_kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(codex_kicker)
	var codex_title := _label("六大神兽血脉 · 四阶形态 · 专属神通", 27, INK, font_title)
	codex_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(codex_title)
	var codex_sub := _label("每只灵宠都能追寻神兽祖脉。达到12级、完成二阶进化并探索对应地域后，收集祭品即可开启独立血脉剧情。", 12, INK_SOFT)
	codex_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	codex_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(codex_sub)
	var codex_nav := HBoxContainer.new()
	codex_nav.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(codex_nav)
	var codex_back := _make_button("返回灵宠", false, 120, 38)
	codex_back.pressed.connect(_open_spirit_companion)
	codex_nav.add_child(codex_back)
	box.add_child(_hairline())
	var active := state.active_pet()
	box.add_child(_label("当前试炼灵宠：%s" % (_pet_stage_title(active) if not active.is_empty() else "未携带灵宠"), 13, JADE, font_title))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 510)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	var codex: Array[Dictionary] = state.divine_beast_codex()
	for idx in range(codex.size()):
		var entry: Dictionary = codex[idx]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _panel_style(Color(0.965, 0.936, 0.866, 1.0), Color(0.72, 0.62, 0.43, 0.72), 7, 1, true))
		list.add_child(card)
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 5)
		card.add_child(content)
		var head := HBoxContainer.new()
		content.add_child(head)
		var stage_badge := PanelContainer.new()
		stage_badge.custom_minimum_size = Vector2(150, 72)
		stage_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stage_badge.add_theme_stylebox_override("panel", _panel_style(Color(0.91, 0.87, 0.76, 1.0), Color(0.67, 0.55, 0.34, 0.75), 5, 1))
		head.add_child(stage_badge)
		var badge_text := VBoxContainer.new()
		badge_text.alignment = BoxContainer.ALIGNMENT_CENTER
		stage_badge.add_child(badge_text)
		var badge_title := _label("四阶成长", 13, GOLD, font_title)
		badge_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_text.add_child(badge_title)
		var badge_stages := _label("幼年 → 成年\n觉醒 → 神兽", 11, JADE)
		badge_stages.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_text.add_child(badge_stages)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(info)
		info.add_child(_label(String(entry.get("title", "未知神兽")), 15, GOLD, font_title))
		info.add_child(_label("祖脉：%s\n专属神通：%s\n图鉴收录：%d只" % [String(entry.get("bloodline", "未知")), String(entry.get("skill", "未知")), int(entry.get("owned_count", 0))], 11, INK_SOFT))
		content.add_child(_label("神兽传说：%s" % String(entry.get("story", "")), 11, INK))
		content.add_child(_label("隐藏任务：%s" % String(entry.get("quest", "")), 11, INK_SOFT))
		content.add_child(_label("神通效果：%s" % String(entry.get("effect", "")), 10, JADE))
		var costs: Dictionary = entry.get("materials", {})
		var cost_text := "祭品："
		for mat: String in costs:
			cost_text += "%s %d/%d  " % [mat, int(state.materials.get(mat, 0)), int(costs[mat])]
		content.add_child(_label(cost_text, 10, GOLD))
		var quest_btn := _make_button("以当前灵宠开启试炼：%s" % String(entry.get("kind", "神兽")), false, 0, 34)
		quest_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		quest_btn.disabled = active.is_empty()
		var beast_id := String(entry.get("id", ""))
		if not active.is_empty():
			var status: Dictionary = state.divine_beast_quest_status(state.active_pet_index, beast_id)
			if bool(status.get("done", false)):
				quest_btn.text = "已完成 · 神兽血脉已觉醒"
				quest_btn.disabled = true
			elif not bool(status.get("ok", false)):
				quest_btn.text = String(status.get("message", "条件未满足"))
				quest_btn.disabled = true
		quest_btn.pressed.connect(func() -> void:
			var result: Dictionary = state.complete_divine_beast_quest(state.active_pet_index, beast_id)
			_save_run()
			_open_beast_codex()
			_open_notice_modal(String(result.get("message", "神兽试炼结束。")))
		)
		content.add_child(quest_btn)
	box.add_child(_label("提示：六条血脉可由普通灵宠逐条挑战；完成后获得对应神兽形态与专属战斗神通。", 10, INK_SOFT))

func _open_spirit_companion() -> void:
	if state == null:
		return
	var box := _open_modal(Vector2(760, 700), true, Callable())
	_add_modal_heading(box, "灵契万兽 · 灵宠与坐骑", "灵宠可协战、采集；坐骑可减免远行消耗", "在当前州域寻访灵兽，缔结灵契；也可在灵市购置坐骑。伙伴数据会随存档保存。")
	if not state.met_npcs.is_empty():
		box.add_child(_label("红尘知交 · 人物伙伴", 15, GOLD, font_title))
		var human_companions := 0
		for npc: Dictionary in state.met_npcs:
			if not bool(npc.get("companion", false)):
				continue
			human_companions += 1
			var affinity := int(npc.get("affinity", 0))
			var relation_color: Color = JADE if affinity >= 0 else CINNABAR
			var npc_panel := PanelContainer.new()
			npc_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.91, 0.87, 0.77, 0.62), Color(0.65, 0.52, 0.34, 0.30), 4, 1))
			box.add_child(npc_panel)
			var npc_info := VBoxContainer.new()
			npc_info.add_theme_constant_override("separation", 2)
			npc_panel.add_child(npc_info)
			npc_info.add_child(_label("%s · %s" % [String(npc.get("name", "无名伙伴")), String(npc.get("identity", "同行之人"))], 14, INK, font_title))
			npc_info.add_child(_label("好感 %d · %s · 已协战 %d 次" % [affinity, String(npc.get("relationship", "伙伴")), int(npc.get("support_count", 0))], 11, relation_color))
			npc_info.add_child(_label("来历：%s · 境界：%s" % [String(npc.get("faction", "不详")), String(npc.get("realm", "不详"))], 10, MUTED))
			var partner_skill_profile: Dictionary = state.companion_skill_profile(npc)
			var partner_skill := String(partner_skill_profile.get("name", npc.get("battle_skill", "待觉醒")))
			var partner_level := maxi(1, int(npc.get("partner_level", 1)))
			var partner_realm := String(npc.get("partner_realm", "炼气"))
			npc_info.add_child(_label("伙伴境界：%s · 成长等级：%d · 专属战技：%s" % [partner_realm, partner_level, partner_skill], 11, JADE))
			npc_info.add_child(_label("战技效果：%s" % String(partner_skill_profile.get("desc", "随羁绊成长的本命技艺。")), 10, INK_SOFT))
			var quest_info: Dictionary = state.npc_personal_quest_info(npc)
			npc_info.add_child(_label("个人剧情：%s\n%s\n目标：%s" % [String(quest_info.get("title", "个人剧情")), String(quest_info.get("story", "")), String(quest_info.get("requirement", ""))], 10, INK_SOFT))
			var quest_btn := _make_button("完成个人剧情阶段" if bool(quest_info.get("ready", false)) else ("个人剧情已完成" if bool(quest_info.get("done", false)) else "继续培养伙伴"), false, 0, 34)
			quest_btn.disabled = not bool(quest_info.get("ready", false))
			var quest_npc_id := String(npc.get("event_id", ""))
			quest_btn.pressed.connect(func() -> void:
				var quest_result: Dictionary = state.claim_npc_personal_quest(quest_npc_id)
				_save_run()
				_open_spirit_companion()
				_open_notice_modal(String(quest_result.get("message", "个人剧情结算完成。")))
			)
			npc_info.add_child(quest_btn)
		if human_companions == 0:
			box.add_child(_label("尚无人愿与你结伴。再次相逢时，善待故人、弥补旧怨，或许能结下同行之缘。", 11, MUTED))
	var codex_btn := _make_button("打开万兽神谱 · 神兽图鉴", false, 0, 42)
	codex_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	codex_btn.pressed.connect(func() -> void: _open_beast_codex())
	box.add_child(codex_btn)
	var pet_nav := HBoxContainer.new()
	pet_nav.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(pet_nav)
	var pet_back_top := _make_button("返回", false, 120, 38)
	pet_back_top.pressed.connect(_close_modal)
	pet_nav.add_child(pet_back_top)
	box.add_child(_label("当前灵宠：%s" % (_pet_stage_title(state.active_pet()) if not state.active_pet().is_empty() else "未携带"), 14, JADE))
	var pet := state.active_pet()
	if not pet.is_empty():
		var showcase := HBoxContainer.new()
		showcase.add_theme_constant_override("separation", 12)
		box.add_child(showcase)
		var hero_info := VBoxContainer.new()
		hero_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		showcase.add_child(hero_info)
		hero_info.add_child(_label("当前形态：%s" % _pet_stage_title(pet), 17, JADE, font_title))
		hero_info.add_child(_label("等级 %d · 协战威力 %d\n血脉：%s · 进化：%d阶\n灵宠气血：%d / %d\n采集目标：%s · 经验 %d" % [int(pet.get("level", 1)), int(pet.get("power", 8)), String(pet.get("bloodline", "凡兽")), int(pet.get("evolution", 0)), int(pet.get("pet_hp", pet.get("pet_max_hp", 80))), int(pet.get("pet_max_hp", 80)), String(pet.get("gather", "灵材")), int(pet.get("exp", 0))], 11, INK_SOFT))
	var pet_scroll := ScrollContainer.new()
	pet_scroll.custom_minimum_size = Vector2(0, 160)
	pet_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(pet_scroll)
	var pet_list := VBoxContainer.new()
	pet_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pet_scroll.add_child(pet_list)
	for i in range(state.pets.size()):
		if i == state.active_pet_index:
			continue # 当前出战灵宠已在上方展示，避免同一只灵宠重复出现。
		var owned: Dictionary = state.pets[i]
		var pet_card := VBoxContainer.new()
		pet_card.add_theme_constant_override("separation", 3)
		pet_list.add_child(pet_card)
		var row := HBoxContainer.new()
		pet_card.add_child(row)
		var pet_name_box := VBoxContainer.new()
		pet_name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(pet_name_box)
		pet_name_box.add_child(_label(_pet_stage_title(owned), 13, JADE, font_title))
		pet_name_box.add_child(_label("Lv.%d · %s" % [int(owned.get("level", 1)), String(owned.get("bloodline", "凡兽"))], 10, INK_SOFT))
		var use_btn := _make_button("出战" if i != state.active_pet_index else "当前出战", false, 0, 34)
		use_btn.disabled = i == state.active_pet_index
		use_btn.pressed.connect(func() -> void: state.set_active_pet(i); _save_run(); _open_spirit_companion())
		row.add_child(use_btn)
		var evolve_btn := _make_button("进化", false, 0, 34)
		evolve_btn.pressed.connect(func() -> void:
			var result: Dictionary = state.evolve_pet(i)
			_save_run(); _open_spirit_companion()
			if not bool(result.get("ok",false)): _open_notice_modal(String(result.get("message","进化失败。")))
			else: _open_notice_modal(String(result.message))
		)
		row.add_child(evolve_btn)
		var awaken_btn := _make_button("觉醒", false, 0, 34)
		awaken_btn.pressed.connect(func() -> void:
			var result: Dictionary = state.awaken_pet_bloodline(i)
			_save_run(); _open_spirit_companion()
			_open_notice_modal(String(result.get("message","血脉觉醒结束。")))
		)
		row.add_child(awaken_btn)
		var pet_info := _label("%s血脉 · %s · 进化%d阶 · 技能：%s · 第%d代%s" % [String(owned.get("bloodline","凡兽")),_pet_stage_title(owned),int(owned.get("evolution",0)),"、".join(PackedStringArray(Array(owned.get("skills",[])))),int(owned.get("generation",1)),"·变异" if bool(owned.get("mutation",false)) else ""], 10, INK_SOFT)
		pet_card.add_child(pet_info)
		var skill_row := GridContainer.new()
		skill_row.columns = 4
		pet_card.add_child(skill_row)
		for skill_id: String in ["裂爪","灵甲","回春","寻宝","雷袭","御风","龙吟","涅槃"]:
			var skill_btn := _make_button("学%s" % skill_id, false, 0, 30)
			skill_btn.pressed.connect(func() -> void:
				var result: Dictionary = state.teach_pet_skill(i, skill_id)
				_save_run(); _open_spirit_companion()
				_open_notice_modal(String(result.get("message","技能学习结束。")))
			)
			skill_row.add_child(skill_btn)
	if state.pets.size() >= 2:
		box.add_child(_label("灵兽繁殖 · 选择两只达到3级的灵宠，消耗100灵石孕育后代", 13, GOLD, font_title))
		for a in range(state.pets.size()):
			for b in range(a + 1, state.pets.size()):
				var breed_btn := _make_button("繁殖：%s × %s" % [String(state.pets[a].get("name","灵兽")),String(state.pets[b].get("name","灵兽"))], false, 0, 34)
				breed_btn.pressed.connect(func() -> void:
					var result: Dictionary = state.breed_pets(a,b)
					_save_run(); _open_spirit_companion()
					_open_notice_modal(String(result.get("message","繁殖结束。")))
				)
				box.add_child(breed_btn)
	var options := state.pet_capture_options()
	box.add_child(_label("当前区域可缔结灵契的灵兽", 15, GOLD, font_title))
	for option: Dictionary in options:
		var capture_btn := _make_button("收服%s · %d灵石\n%s" % [String(option.name), int(option.cost), String(option.desc)], false, 0, 58)
		capture_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		capture_btn.disabled = state.stones < int(option.cost) or state.pets.any(func(p: Dictionary) -> bool: return String(p.get("species", p.get("name", ""))) == String(option.name))
		capture_btn.pressed.connect(func() -> void:
			var result: Dictionary = state.capture_pet(option)
			_save_run()
			_open_spirit_companion()
			if not bool(result.get("ok", false)): _open_notice_modal(String(result.message))
		)
		pet_list.add_child(capture_btn)
	box.add_child(_hairline())
	box.add_child(_label("坐骑灵市", 15, GOLD, font_title))
	box.add_child(_label("坐骑可使远行灵石消耗减少15%至25%，品质越高减免越多；首次缔结灵宠免费。", 11, INK_SOFT))
	for mount_name: String in ["青风灵鹿", "踏云灵鹤", "玄甲地龙"]:
		var prices := {"青风灵鹿":120, "踏云灵鹤":260, "玄甲地龙":520}
		var mount_btn := _make_button("购置%s · %d灵石" % [mount_name, int(prices[mount_name])], false, 0, 38)
		mount_btn.disabled = state.stones < int(prices[mount_name]) or state.mounts.any(func(m: Dictionary) -> bool: return String(m.get("name", "")) == mount_name)
		mount_btn.pressed.connect(func() -> void:
			var result: Dictionary = state.acquire_mount(mount_name)
			_save_run()
			_open_spirit_companion()
			if not bool(result.get("ok", false)): _open_notice_modal(String(result.message))
		)
		box.add_child(mount_btn)
	for i in range(state.mounts.size()):
		var owned_mount: Dictionary = state.mounts[i]
		var ride_btn := _make_button("乘骑：%s" % String(owned_mount.get("name", "坐骑")), false, 0, 34)
		ride_btn.disabled = i == state.active_mount_index
		ride_btn.pressed.connect(func() -> void: state.set_active_mount(i); _save_run(); _open_spirit_companion())
		box.add_child(ride_btn)

func _faction_npc_roster(faction: Dictionary) -> Array[Dictionary]:
	var kind := String(faction.get("kind", "散修"))
	var faction_key := String(faction.get("name", "散修"))
	var ranks: Array[String] = []
	var names: Array[String] = []
	var realms: Array[String] = []
	match kind:
		"宗门", "魔道":
			ranks = ["宗主", "副宗主", "太上长老", "执法长老", "传功长老", "内门弟子", "外门弟子"]
			names = ["顾长渊", "沈怀岳", "玄微子", "厉无咎", "闻道真人", "林清寒", "周小山"]
			realms = ["化神境", "元婴境", "化神境", "元婴境", "元婴境", "金丹境", "筑基境"]
		"皇朝":
			ranks = ["皇帝", "太子", "镇国国师", "兵部尚书", "大将军", "镇边统领", "禁军校尉"]
			names = ["虞承天", "虞景明", "玄机国师", "裴文正", "霍镇岳", "秦破虏", "陆骁"]
			realms = ["渡劫境", "元婴境", "化神境", "元婴境", "化神境", "金丹境", "筑基境"]
		"妖族联盟":
			ranks = ["万妖盟主", "左右护盟", "大部妖王", "祭血长老", "统军妖将", "部族勇士", "新晋妖兵"]
			names = ["吞月天狼", "赤羽鸾王", "玄甲蛟王", "白骨祭司", "裂山熊君", "青角", "小石"]
			realms = ["渡劫境", "化神境", "化神境", "元婴境", "元婴境", "金丹境", "筑基境"]
		"世家":
			ranks = ["家主", "少家主", "太上供奉", "大长老", "执事长老", "嫡系子弟", "外姓门客"]
			names = ["慕容天策", "慕容云昭", "天机老人", "慕容肃", "柳供奉", "慕容雪", "韩砚"]
			realms = ["化神境", "元婴境", "化神境", "元婴境", "金丹境", "筑基境", "筑基境"]
		"联盟":
			ranks = ["盟主", "副盟主", "总坛护法", "情报长老", "分舵长老", "资深成员", "新晋成员"]
			names = ["百晓生", "铁算子", "断江客", "千面狐", "莫问", "陈三", "阿禾"]
			realms = ["化神境", "元婴境", "元婴境", "金丹境", "金丹境", "筑基境", "炼气境"]
		"散修":
			ranks = ["隐世高人", "游方前辈", "坊市客卿", "独行剑修", "采药散人", "年轻修士", "初入仙途"]
			names = ["玄机散人", "陆游方", "白鹤居士", "顾寒舟", "药尘子", "苏见微", "石小六"]
			realms = ["化神境", "元婴境", "金丹境", "金丹境", "筑基境", "筑基境", "炼气境"]
		_:
			return []
	var roster: Array[Dictionary] = []
	for i in range(ranks.size()):
		roster.append({"rank": ranks[i], "name": names[i], "realm": realms[i]})
	if faction_key == state.faction_name:
		roster.append({"rank": state.faction_rank, "name": "玩家", "realm": "当前境界", "player": true})
	return roster


func _npc_relation(npc_name: String, faction_name: String = "") -> String:
	var record := _npc_record(npc_name, faction_name)
	return NpcRelationshipSystem.relationship_title(int(record.get("affinity", 0)))

func _npc_record(npc_name: String, faction_name: String = "") -> Dictionary:
	if state == null:
		return {"name":npc_name, "affinity":0, "relationship":"陌路"}
	return state.npc_relationship_record(npc_name, faction_name)

func _save_npc_record(npc_name: String, record: Dictionary) -> void:
	if state == null:
		return
	state.save_npc_relationship_record(npc_name, record)
	_save_run()

func _open_npc_interaction(member: Dictionary, faction_name: String) -> void:
	if state == null: return
	var npc_name := String(member.get("name", "无名修士"))
	var npc_rank := String(member.get("rank", "成员"))
	var npc_realm := String(member.get("realm", "修为不详"))
	var record := _npc_record(npc_name, faction_name)
	var affinity := int(record.get("affinity", 0))
	var box := _open_modal(Vector2(560, 470), true, Callable())
	_add_modal_heading(box, "%s · %s" % [faction_name, npc_rank], npc_name, "%s · 好感度 %d · 关系：%s" % [npc_realm, affinity, _npc_relation(npc_name, faction_name)])
	var intro := String(record.get("intro", "此人神色平静，正在处理自己的事务。"))
	var intro_label := _label(intro, 13, INK_SOFT)
	intro_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(intro_label)
	var talk := _make_button("交谈 · 了解近况（每日一次）", true, 0, 40)
	talk.pressed.connect(_npc_talk.bind(member, faction_name))
	box.add_child(talk)
	var gift := _make_button("赠送灵石礼物 · 20灵石（好感+5）", false, 0, 38)
	gift.disabled = state.stones < 20
	gift.pressed.connect(_npc_gift.bind(member, faction_name))
	box.add_child(gift)
	var spar := _make_button("友好切磋 · 增进了解", false, 0, 38)
	spar.pressed.connect(_npc_spar.bind(member, faction_name))
	box.add_child(spar)
	var advice := _make_button("请教修行 · 消耗10灵石", false, 0, 38)
	advice.disabled = state.stones < 10
	advice.pressed.connect(_npc_advice.bind(member, faction_name))
	box.add_child(advice)
	var close := _make_button("返回人员名册", false, 0, 36)
	close.pressed.connect(_return_to_faction_hall)
	box.add_child(close)

func _return_to_faction_hall() -> void:
	_clear_modal(false)
	_open_faction_hall()

func _npc_talk(member: Dictionary, faction_name: String) -> void:
	var npc_name := String(member.get("name", "无名修士"))
	var record := _npc_record(npc_name, faction_name)
	var last_talk := int(record.get("last_talk_turn", -999))
	if last_talk == state.turn_count:
		_open_notice_modal("你们今日已经交谈过了。", Callable())
		return
	var lines := ["修行一途，最忌心浮气躁。", "近日天下并不太平，各方势力都在暗中布局。", "若有机缘，还是要亲自走一趟才知道真假。", "境界固然重要，道心与眼界也不可轻忽。"]
	var index: int = absi(npc_name.hash() + state.turn_count) % lines.size()
	record = state.adjust_npc_affinity(npc_name, 1, faction_name, "日常交谈", lines[index])
	record["last_talk_turn"] = state.turn_count
	_save_npc_record(npc_name, record)
	_open_npc_interaction(member, faction_name)

func _npc_gift(member: Dictionary, faction_name: String) -> void:
	if state.stones < 20: return
	var npc_name := String(member.get("name", "无名修士"))
	state.stones -= 20
	var record := state.adjust_npc_affinity(npc_name, 5, faction_name, "赠送灵石礼物", "%s收下你的礼物，态度明显亲近了几分。" % npc_name)
	_save_npc_record(npc_name, record)
	_refresh_game_ui()
	_open_npc_interaction(member, faction_name)

func _npc_spar(member: Dictionary, faction_name: String) -> void:
	var npc_name := String(member.get("name", "无名修士"))
	var npc_realm := String(member.get("realm", "筑基境"))
	var player_realm := GameData.realm_name(state.realm)
	var realm_scores := {"炼气境": 0, "筑基境": 4, "金丹境": 7, "元婴境": 10, "化神境": 13, "渡劫境": 16}
	var npc_score := int(realm_scores.get(npc_realm, 4))
	var won := state.realm >= npc_score
	var affinity_gain := 2 if won else 1
	var intro := "你与%s切磋数招，最终略胜一筹。对方认可了你的实力。" % npc_name if won else "你与%s切磋，虽未占上风，却从对方招式中有所领悟。" % npc_name
	var record := state.adjust_npc_affinity(npc_name, affinity_gain, faction_name, "友好切磋", intro)
	record["last_spar_realm"] = player_realm
	_save_npc_record(npc_name, record)
	_open_npc_interaction(member, faction_name)

func _npc_advice(member: Dictionary, faction_name: String) -> void:
	if state.stones < 10: return
	var npc_name := String(member.get("name", "无名修士"))
	state.stones -= 10
	state.insight = mini(100, state.insight + 2)
	state.cultivation += 5.0
	var record := state.adjust_npc_affinity(npc_name, 2, faction_name, "请教修行", "%s指点你几句修行心得，你的感悟有所提升。" % npc_name)
	_save_npc_record(npc_name, record)
	_refresh_game_ui()
	_open_npc_interaction(member, faction_name)

func _open_faction_hall() -> void:
	if not _can_act():
		return
	var box := _open_modal(Vector2(780, 700), true, Callable())
	# 势力内容较长：将整个页面放入可滚动容器，避免小屏幕/窗口高度不足时看不到后续势力。
	var page_scroll := ScrollContainer.new()
	page_scroll.custom_minimum_size = Vector2(0, 620)
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(page_scroll)
	var page_content := VBoxContainer.new()
	page_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_content.add_theme_constant_override("separation", 9)
	page_scroll.add_child(page_content)
	page_content.add_child(_label("天 下 势 力 · 风 云 录", 23, INK, font_title))
	page_content.add_child(_label("诸方势力并立，门规、资源与立场皆会影响你的修行之路。", 12, INK_SOFT))
	page_content.add_child(_label("当前身份：%s · %s" % [state.faction_name, state.faction_rank], 15, CINNABAR, font_title))
	page_content.add_child(_label("所在州域：%s · 天下纷争：%d起" % [state.current_region, state.world_conflict], 11, INK_SOFT))
	# 固定在势力页面顶部，避免长名册/势力列表把返回与退出按钮挤到屏幕之外。
	var faction_nav := HBoxContainer.new()
	faction_nav.add_theme_constant_override("separation", 10)
	page_content.add_child(faction_nav)
	var home_button := _make_button("返回主界面", false, 140, 38)
	home_button.pressed.connect(func() -> void: _close_modal())
	faction_nav.add_child(home_button)
	if state.faction_name != "散修":
		var exit_faction_button := _make_button("退出当前势力", false, 140, 38)
		exit_faction_button.pressed.connect(func() -> void:
			var leave_result: Dictionary = state.faction_leave()
			_close_modal()
			_refresh_game_ui()
			_save_run()
			var leave_message := String(leave_result.get("message", "你已脱离原势力，恢复散修身份。"))
			_open_notice_modal(leave_message)
		)
		faction_nav.add_child(exit_faction_button)
	if not state.world_events.is_empty():
		var latest_event: Dictionary = state.world_events.back()
		page_content.add_child(_label("最新风云 · 第%d年：%s" % [int(latest_event.get("year", 0)), String(latest_event.get("text", "天下暂安"))], 11, GOLD))
	if state.is_sect_member():
		page_content.add_child(_hairline())
		page_content.add_child(_label("宗 门 内 务", 18, INK, font_title))
		page_content.add_child(_label("贡献 %d（累计功绩 %d） · 聚灵设施 %d / 3级 · 修炼加成 +%.1f%%" % [state.faction_contribution, state.sect_merit, state.sect_facility_level, float(state.sect_facility_level) * 2.5], 12, JADE))
		var task_row := HBoxContainer.new()
		task_row.add_theme_constant_override("separation", 8)
		page_content.add_child(task_row)
		var task_button := _make_button("领取宗门任务", true, 150, 36)
		task_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_claim_task()))
		task_row.add_child(task_button)
		var exchange_button := _make_button("宝库兑换·聚气散（35贡献）", false, 220, 36)
		exchange_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_exchange_pill()))
		task_row.add_child(exchange_button)
		var upgrade_button := _make_button("升级聚灵设施", false, 150, 36)
		upgrade_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_upgrade_facility()))
		task_row.add_child(upgrade_button)
		var donate_row := HBoxContainer.new()
		donate_row.add_theme_constant_override("separation", 8)
		page_content.add_child(donate_row)
		donate_row.add_child(_label("供奉灵石换取贡献：", 11, INK_SOFT))
		for amount: int in [50, 200, 500]:
			var donate_button := _make_button("供奉%d灵石" % amount, false, 112, 32)
			donate_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_donate(amount)))
			donate_row.add_child(donate_button)
		var management_row := HBoxContainer.new()
		management_row.add_theme_constant_override("separation", 8)
		page_content.add_child(management_row)
		var disciple_button := _make_button("弟子名册与教导", true, 170, 36)
		disciple_button.pressed.connect(func() -> void: _open_sect_management("disciples"))
		management_row.add_child(disciple_button)
		var scripture_button := _make_button("藏经阁", false, 130, 36)
		scripture_button.pressed.connect(func() -> void: _open_sect_management("scriptures"))
		management_row.add_child(scripture_button)
		var tournament_button := _make_button("参加宗门大比", true, 150, 36)
		tournament_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_enter_tournament()))
		management_row.add_child(tournament_button)
		page_content.add_child(_label("宗门大比：每十次行动可参加一届。胜者获得灵石、贡献与魁首记录；惜败也有参与奖励。", 11, INK_SOFT))
	else:
		var faction_info: Dictionary = state.faction_info()
		var faction_kind := String(faction_info.get("kind", "势力"))
		var service_title := "朝廷差遣" if faction_kind == "皇朝" else ("部族试炼" if faction_kind == "妖族联盟" else ("家族事务" if faction_kind == "世家" else "联盟委托"))
		var facility_title := "官署修炼资源" if faction_kind == "皇朝" else ("祖地血脉祭坛" if faction_kind == "妖族联盟" else ("家族灵脉" if faction_kind == "世家" else "联盟修炼据点"))
		page_content.add_child(_hairline())
		page_content.add_child(_label("势 力 内 务 · %s" % faction_kind, 18, INK, font_title))
		page_content.add_child(_label("贡献 %d · 累计功绩 %d · %s等级 %d/3 · 修炼效率 +%.1f%%" % [state.faction_contribution, state.sect_merit, facility_title, state.sect_facility_level, float(state.sect_facility_level) * 2.5], 12, JADE))
		var service_row := HBoxContainer.new()
		service_row.add_theme_constant_override("separation", 8)
		page_content.add_child(service_row)
		var task_button := _make_button("领取" + service_title, true, 150, 36)
		task_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_claim_task()))
		service_row.add_child(task_button)
		var donate_button := _make_button("上缴50灵石", false, 125, 36)
		donate_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_donate(50)))
		service_row.add_child(donate_button)
		var upgrade_button := _make_button("建设" + facility_title, false, 165, 36)
		upgrade_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_upgrade_facility()))
		service_row.add_child(upgrade_button)
		var exchange_button := _make_button("兑换势力资源（35贡献）", false, 190, 36)
		exchange_button.pressed.connect(func() -> void: _handle_sect_result(state.sect_exchange_pill()))
		service_row.add_child(exchange_button)
		var explanation := "皇朝成员可通过军功与政务晋升；妖盟成员以部族战功提升地位；世家门客凭贡献获得家族认可；联盟成员可承接跨境委托。"
		page_content.add_child(_label(explanation, 11, INK_SOFT))
	page_content.add_child(_hairline())
	page_content.add_child(_label("势 力 人 员 名 册", 18, INK, font_title))
	page_content.add_child(_label("各方势力均有完整的管理层、核心成员与基层成员；你的身份会显示在对应序列中。", 11, INK_SOFT))
	var roster_scroll := ScrollContainer.new()
	roster_scroll.custom_minimum_size = Vector2(0, 150)
	roster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_content.add_child(roster_scroll)
	var roster_list := VBoxContainer.new()
	roster_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_scroll.add_child(roster_list)
	var current_faction := state.faction_info()
	for member: Dictionary in _faction_npc_roster(current_faction):
		var is_player := bool(member.get("player", false))
		var member_name := String(member.get("name", "无名"))
		var member_text := "%s · %s · %s" % [String(member.get("rank", "成员")), member_name, String(member.get("realm", "修为不详"))]
		if is_player:
			member_text += "（你）"
		var member_row := HBoxContainer.new()
		member_row.add_theme_constant_override("separation", 8)
		roster_list.add_child(member_row)
		var member_label := _label(member_text, 11, GOLD if is_player else INK_SOFT)
		member_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		member_row.add_child(member_label)
		if not is_player:
			var relation := _npc_relation(member_name, String(current_faction.get("name", "天下")))
			var interact_button := _make_button("互动 · %s" % relation, false, 112, 32)
			interact_button.pressed.connect(_open_npc_interaction.bind(member.duplicate(true), String(current_faction.get("name", "天下"))))
			member_row.add_child(interact_button)
	page_content.add_child(_hairline())
	page_content.add_child(_label("天下势力", 17, INK, font_title))
	var faction_scroll := ScrollContainer.new()
	faction_scroll.custom_minimum_size = Vector2(0, 260 if state.faction_name != "散修" else 430)
	faction_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	faction_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_content.add_child(faction_scroll)
	var faction_list := VBoxContainer.new()
	faction_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	faction_scroll.add_child(faction_list)
	for faction: Dictionary in GameState.WORLD_FACTIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		faction_list.add_child(row)
		var faction_key := String(faction["name"])
		var detail := "%s · %s · %s\n%s | 势力影响：%d | 关系：%s" % [faction_key, faction["kind"], faction["rank"], faction["region"], int(state.faction_power_state.get(faction_key, faction["power"])), String(state.faction_relations.get(faction_key, "中立"))]
		var desc := _label(detail, 11, INK_SOFT)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(desc)
		var already_member := state.faction_name == String(faction["name"])
		var join_button := _make_button("当前所属" if already_member else "投身门庭", false, 104, 34)
		join_button.disabled = state.faction_name != "散修"
		join_button.pressed.connect(func() -> void:
			var result: Dictionary = state.join_faction(String(faction["name"]))
			_close_modal()
			_refresh_game_ui()
			_save_run()
			if not bool(result.get("ok", false)):
				_open_notice_modal(String(result.get("message", "暂不可加入。")))
			else:
				_open_notice_modal(String(result.get("message", "已加入势力。")))
		)
		row.add_child(join_button)
		faction_list.add_child(_hairline())

func _open_sect_management(mode: String) -> void:
	if state == null or not state.is_sect_member(): return
	_close_modal()
	var box := _open_modal(Vector2(700, 620), true, Callable())
	if mode == "disciples":
		box.add_child(_label("宗 门 弟 子 名 册", 22, INK, font_title))
		box.add_child(_label("门下弟子 %d / 5 · 亲自教导可提升修为与忠诚。" % state.sect_disciples.size(), 12, INK_SOFT))
		var recruit := _make_button("招收新弟子（消耗灵石）", true, 210, 36)
		recruit.disabled = state.faction_rank not in ["执事", "长老", "太上长老", "宗主"] or state.sect_disciples.size() >= 5
		recruit.pressed.connect(func() -> void: _handle_sect_management_result(state.sect_recruit_disciple(), "disciples"))
		box.add_child(recruit)
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(0, 390)
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(scroll)
		var list := VBoxContainer.new()
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		if state.sect_disciples.is_empty(): list.add_child(_label("门下尚无弟子。晋升执事后即可招收有缘之人。", 13, INK_SOFT))
		for i in range(state.sect_disciples.size()):
			var d: Dictionary = state.sect_disciples[i]
			var row := HBoxContainer.new()
			list.add_child(row)
			var info := "%s · %s%s\n修为：第%d重 · 资质：%d · 忠诚：%d · 培养：%d次" % [d.get("name", "无名"), d.get("root_grade", "九品"), d.get("root_type", "五灵根"), int(d.get("realm", 0)) + 1, int(d.get("aptitude", 0)), int(d.get("loyalty", 0)), int(d.get("training", 0))]
			var label := _label(info, 12, INK_SOFT)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(label)
			var train := _make_button("教导", false, 90, 32)
			var disciple_index := i
			train.pressed.connect(func() -> void: _handle_sect_management_result(state.sect_train_disciple(disciple_index), "disciples"))
			row.add_child(train)
			list.add_child(_hairline())
	else:
		box.add_child(_label("藏 经 阁 · 典 籍 阅 览", 22, INK, font_title))
		box.add_child(_label("身份决定可阅览的典籍阶位；研习消耗灵石与宗门贡献。功法提供常驻加成，武技用于战斗施展。", 12, INK_SOFT))
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(0, 450)
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(scroll)
		var list := VBoxContainer.new()
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		for skill: Dictionary in BattleSystem.all_skills():
			var sid := String(skill.get("id", ""))
			var row := HBoxContainer.new()
			list.add_child(row)
			var learned := state.learned_skills.has(sid)
			var desc := "【%s】%s · %s · %s\n%s | 境界%d | 灵石%d" % [skill.get("category", "武技"), skill.get("name", "无名"), skill.get("rank", ""), skill.get("type", ""), skill.get("desc", ""), int(skill.get("realm", 0)), int(skill.get("cost", 0))]
			var label := _label(desc, 11, INK_SOFT)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(label)
			var learn := _make_button("已掌握" if learned else "研习", false, 90, 32)
			learn.disabled = learned
			learn.pressed.connect(func() -> void: _handle_sect_management_result(state.sect_scripture_learn(sid), "scriptures"))
			row.add_child(learn)
			list.add_child(_hairline())
	var close := _make_button("返回宗门", true, 120, 36)
	close.pressed.connect(func() -> void:
		_close_modal()
		_open_faction_hall()
	)
	box.add_child(close)

func _handle_sect_management_result(result: Dictionary, mode: String) -> void:
	_save_run()
	_refresh_game_ui()
	_open_notice_modal(String(result.get("message", "宗门事务已处理。")), func() -> void:
		_open_sect_management(mode)
	)

func _handle_sect_result(result: Dictionary) -> void:
	_close_modal()
	_refresh_game_ui()
	_save_run()
	_open_notice_modal(String(result.get("message", "宗门事务已处理。")))

func _open_notice_modal(message: String, on_close: Callable = Callable()) -> void:
	var box := _open_modal(Vector2(460, 180), true, on_close)
	box.add_child(_label(message, 14, INK_SOFT))
	var close_button := _make_button("知晓", true, 100, 38)
	close_button.pressed.connect(_close_modal)
	box.add_child(close_button)

func _open_skill_library(category: String = "功法") -> void:
	# 分类切换发生在弹窗已经打开时，不能使用 _can_act()：该函数会因 modal_open=true 而拒绝操作。
	# 这里只检查游戏状态，允许在功法/武技典籍弹窗内切换分类。
	if ui_mode != "game" or state == null or not state.alive:
		return
	var selected_category: String = category if category in ["功法", "武技", "法术", "神通秘术"] else "功法"
	# _open_modal() 内部会清理旧弹窗；此处不再重复清理，避免状态短暂错乱。
	var box := _open_modal(Vector2(720, 600), false, Callable())
	var is_method := selected_category == "功法"
	_add_modal_heading(box, "修炼典籍与斗法技艺", ("功法 %d/%d · 主动技艺 %d/%d" % [state.equipped_methods.size(), state.method_slot_count(), state.equipped_martial.size(), state.martial_slot_count()]), "功法是修炼根基；武技锻炼肉身且不耗法力；法术消耗法力施展；神通秘术是高阶杀招。")
	var tabs := HFlowContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	var method_tab := _make_button("功法典籍", is_method, 0, 34)
	method_tab.pressed.connect(_open_skill_library.bind("功法"))
	tabs.add_child(method_tab)
	var martial_tab := _make_button("武技", selected_category == "武技", 0, 34)
	martial_tab.pressed.connect(_open_skill_library.bind("武技"))
	tabs.add_child(martial_tab)
	var spell_tab := _make_button("法术", selected_category == "法术", 0, 34)
	spell_tab.pressed.connect(_open_skill_library.bind("法术"))
	tabs.add_child(spell_tab)
	var divine_tab := _make_button("神通秘术", selected_category == "神通秘术", 0, 34)
	divine_tab.pressed.connect(_open_skill_library.bind("神通秘术"))
	tabs.add_child(divine_tab)
	box.add_child(tabs)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 390)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for skill: Dictionary in BattleSystem.all_skills():
		if String(skill.get("category", "武技")) != selected_category:
			continue
		var skill_id := String(skill.get("id", ""))
		var learned := state.learned_skills.has(skill_id)
		var equipped := state.is_skill_equipped(skill_id)
		var required_realm := int(skill.get("realm", 0))
		var cost := int(skill.get("cost", 0))
		var mastery: Dictionary = BattleSystem.mastery_info(state.skill_mastery_xp(skill_id))
		var mastery_text := "%s（%d/%d）· 效果 +%d%%" % [String(mastery.get("name", "入门")), int(mastery.get("xp", 0)), int(mastery.get("next_xp", 100)), int(round((float(mastery.get("power_multiplier", 1.0)) - 1.0) * 100.0))]
		var use_hint := " · 装备后常驻生效" if selected_category == "功法" else (" · 不消耗灵力" if selected_category == "武技" else " · 施法消耗：%d灵力" % int(skill.get("mp", 0)))
		var detail := "%s · %s · %s · %s\n属性：%s · 传承：%s\n熟练度：%s\n%s\n需求：%s · 学习：%d 灵石%s" % [String(skill.get("rank", "")), String(skill.get("type", "")), String(skill.get("discipline_name", "基础术法")), String(skill.get("name", "")), String(skill.get("attribute", "无")), String(skill.get("lineage", "散修传承")), mastery_text, String(skill.get("desc", "")), String(GameData.REALMS[required_realm].get("name", "")), cost, use_hint]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list.add_child(row)
		var label := _label(detail, 11, INK)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var action := _make_button("卸下" if equipped else ("装备" if learned else "学习"), false, 0, 42)
		action.custom_minimum_size = Vector2(86, 42)
		if equipped:
			action.text = "卸下"
			action.pressed.connect(_on_skill_manage.bind(skill_id, "unequip"))
		elif learned:
			action.text = "装备"
			var slots_full: bool = state.equipped_methods.size() >= state.method_slot_count() if selected_category == "功法" else state.equipped_martial.size() >= state.martial_slot_count()
			action.disabled = slots_full
			if slots_full:
				action.tooltip_text = "功法栏位已满，请先卸下一门功法" if selected_category == "功法" else "主动技艺栏位已满，请先卸下一项技艺"
			action.pressed.connect(_on_skill_manage.bind(skill_id, "equip"))
		else:
			action.text = "学习"
			action.disabled = state.realm < required_realm or state.stones < cost
			action.pressed.connect(_on_skill_manage.bind(skill_id, "learn"))
		row.add_child(action)
	var close := _make_button("返回", false, 0, 40)
	close.pressed.connect(_close_skill_library)
	box.add_child(close)

func _on_skill_manage(skill_id: String, operation: String) -> void:
	if state == null:
		return
	var success := false
	match operation:
		"learn": success = state.learn_skill(skill_id)
		"equip": success = state.equip_skill(skill_id)
		"unequip": success = state.unequip_skill(skill_id)
	if success:
		_save_run()
		# 当前仍停留在功法弹窗中，只重建列表，不刷新整张游戏界面。
		modal_instant_open = true
	else:
		var reason := "装备栏位已满，请先卸下一项。" if operation == "equip" else "操作未成功：请确认已学习该典籍且条件满足。"
		_open_notice_modal(reason, func() -> void: _open_skill_library(state.skill_category(skill_id)))
		return
	_open_skill_library(state.skill_category(skill_id))

func _close_skill_library() -> void:
	_clear_modal(false)
	_refresh_game_ui()

func _open_weapon_shop() -> void:
	if state == null:
		return
	var box := _open_modal(Vector2(760, 620), true, Callable())
	_add_modal_heading(box, "坊市 · 万宝阁", "兵器丹药 · 灵石交易", "兵器与丹药一站购齐。丹药涵盖疗伤、恢复、淬体、悟道与突破辅助，购买后直接收入储物袋。")
	var balance := _label("当前灵石：%d" % state.stones, 14, GOLD)
	balance.name = "ShopBalance"
	box.add_child(balance)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 390)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	list.add_child(_label("一、兵器法器", 16, CINNABAR, font_title))
	var stock: Array[String] = ["青锋剑", "玄铁重剑", "追风灵剑", "赤纹战刀", "寒魄飞剑", "镇岳长枪", "紫电雷刃", "斩蛟古剑"]
	for item_name: String in stock:
		var info: Dictionary = GameData.treasure_info(item_name)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		list.add_child(row)
		var description := VBoxContainer.new()
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(description)
		description.add_child(_label("%s · %s · %d 灵石" % [item_name, String(info.get("rarity", "凡品")), int(info.get("price", 0))], 14, _treasure_rarity_color(String(info.get("rarity", "凡品")))))
		description.add_child(_label("需求境界：%s · %s" % [GameData.REALMS[int(info.get("realm", 0))].get("name", "凡境"), _item_effect_short(info)], 10, INK_SOFT))
		var buy := _make_button("已拥有" if state.treasures.has(item_name) else "购买", false, 0, 38)
		buy.disabled = state.treasures.has(item_name) or state.stones < int(info.get("price", 0)) or state.realm < int(info.get("realm", 0))
		buy.pressed.connect(_buy_weapon.bind(item_name))
		row.add_child(buy)
		list.add_child(_hairline())
	list.add_child(_label("二、丹药灵药", 16, CINNABAR, font_title))
	for recipe: Dictionary in state.get_pill_recipes():
		var pill_name := String(recipe.get("name", ""))
		var price := int(recipe.get("price", 0))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		list.add_child(row)
		var description := VBoxContainer.new()
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(description)
		description.add_child(_label("%s · %d 灵石 · 持有 %d" % [pill_name, price, int(state.pills.get(pill_name, 0))], 13, INK))
		var requirement := int(recipe.get("realm", 0))
		description.add_child(_label("%s · 需求境界：%s" % [String(recipe.get("effect", "辅助修行")), GameData.realm_name(requirement)], 10, INK_SOFT))
		var buy_pill := _make_button("购买", false, 0, 38)
		buy_pill.disabled = price <= 0 or state.stones < price or state.realm < requirement
		buy_pill.pressed.connect(_buy_shop_pill.bind(pill_name))
		row.add_child(buy_pill)
		list.add_child(_hairline())
	var close := _make_button("返回", true, 0, 42)
	close.pressed.connect(_clear_modal.bind(false))
	box.add_child(close)

func _buy_weapon(item_name: String) -> void:
	if state == null:
		return
	var info: Dictionary = GameData.treasure_info(item_name)
	var price: int = int(info.get("price", 0))
	if state.treasures.has(item_name) or price <= 0 or state.stones < price or state.realm < int(info.get("realm", 0)):
		_open_weapon_shop()
		return
	state.stones -= price
	state.treasures.append(item_name)
	state.treasure_ages[item_name] = state.age
	state.add_log("【坊市购置】你花费%d灵石，在万宝阁购得%s。" % [price, item_name], "gain")
	_save_run()
	_refresh_game_ui()
	_open_weapon_shop()

func _buy_shop_pill(pill_name: String) -> void:
	if state == null:
		return
	var selected: Dictionary = {}
	for recipe: Dictionary in state.get_pill_recipes():
		if String(recipe.get("name", "")) == pill_name:
			selected = recipe
			break
	var price := int(selected.get("price", 0))
	if selected.is_empty() or price <= 0 or state.stones < price or state.realm < int(selected.get("realm", 0)):
		_open_weapon_shop()
		return
	state.stones -= price
	state.pills[pill_name] = int(state.pills.get(pill_name, 0)) + 1
	state.add_log("【万宝阁】你花费%d灵石购得%s。" % [price, pill_name], "gain")
	_save_run()
	_refresh_game_ui()
	_open_weapon_shop()

func _open_alchemy() -> void:
	# 丹药炼制与装备锻造统一放在同一座炼制坊内。
	if ui_mode != "game" or state == null or not state.alive:
		return
	_clear_modal(false)
	var box := _open_modal(Vector2(760, 680), false, Callable())
	_add_modal_heading(box, "丹器合一 · 百工坊", "炼丹与炼器", "药材可炼丹，矿石与兽材可锻造装备；所有配方集中展示，炼成之物自动收入储物袋。")
	var material_text := "材料总览：%d 种 · 灵石 %d" % [_inventory_nonzero_count(state.materials), state.stones]
	box.add_child(_label(material_text, 11, JADE))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 470)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)

	list.add_child(_label("一、丹药炼制", 17, CINNABAR, font_title))
	list.add_child(_label("消耗药材炼制丹药；炼成后可在下方直接服用。", 10, MUTED))
	for recipe: Dictionary in state.get_pill_recipes():
		var pill_name := String(recipe.get("name", ""))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list.add_child(row)
		var info := _label("%s · %s\n%s · 持有 %d" % [pill_name, String(recipe.get("recipe", "")), String(recipe.get("effect", "")), int(state.pills.get(pill_name, 0))], 11, INK)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(info)
		var craft_pill := _make_button("炼丹", false, 82, 40)
		craft_pill.disabled = not _can_craft_pill(pill_name)
		craft_pill.pressed.connect(_on_craft_pill.bind(pill_name))
		row.add_child(craft_pill)

	list.add_child(_hairline())
	list.add_child(_label("二、装备锻造", 17, CINNABAR, font_title))
	list.add_child(_label("矿石铸兵甲，晶石刻法器，兽材强化护具；锻造成功后直接收入储物袋。", 10, MUTED))
	for recipe: Dictionary in state.get_forge_recipes():
		var item_name := String(recipe.get("name", ""))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list.add_child(row)
		var info := _label("%s · %s\n%s\n%s" % [item_name, String(recipe.get("recipe", "")), String(recipe.get("effect", "")), String(recipe.get("desc", ""))], 11, INK)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(info)
		var craft_equipment := _make_button("锻造", false, 82, 40)
		craft_equipment.disabled = not state.can_craft_equipment(item_name)
		craft_equipment.pressed.connect(_on_craft_equipment.bind(item_name))
		row.add_child(craft_equipment)

	list.add_child(_hairline())
	list.add_child(_label("三、丹药行囊 · 点击服用", 15, CINNABAR, font_title))
	var pills_row := HFlowContainer.new()
	pills_row.add_theme_constant_override("h_separation", 7)
	pills_row.add_theme_constant_override("v_separation", 7)
	list.add_child(pills_row)
	for pill_name: String in ["小还丹", "聚气散", "大还丹", "归元丹", "青岚清心丹", "天京玉露丹", "药王续命丹", "荒古血魄丹", "归墟龙元丹", "青岚剑心丹", "天京玉髓丹", "天机破障丹", "荒古淬体丹", "幽冥凝魂丹", "清瘴丹", "洗髓丹", "悟道丹", "破障丹", "凝神丹"]:
		var count := int(state.pills.get(pill_name, 0))
		var use_button := _make_button("%s ×%d" % [pill_name, count], false, 0, 38)
		use_button.disabled = count <= 0
		use_button.pressed.connect(_on_use_pill_from_bag.bind(pill_name))
		pills_row.add_child(use_button)

	var close := _make_button("返回游戏", false, 0, 40)
	close.pressed.connect(func():
		_clear_modal(false)
		_refresh_game_ui()
	)
	box.add_child(close)

func _open_forging() -> void:
	# 保留旧入口与快捷按钮兼容，统一导向丹器合一的炼制坊。
	_open_alchemy()

func _on_craft_equipment(item_name: String) -> void:
	if state == null:
		return
	if state.craft_equipment(item_name):
		state.add_log("【百工坊】你以灵火淬炼灵材，成功锻成%s，已收入储物袋。" % item_name, "gain")
		_save_run()
		_refresh_game_ui()
	_open_alchemy()

func _open_inventory(category: String = "全部") -> void:
	# 背包会在分类切换、使用物品后从已有弹窗内重新打开，因此不能用排斥弹窗状态的 _can_act()。
	if ui_mode != "game" or state == null or not state.alive:
		return
	inventory_category = category
	_clear_modal(false)
	var box := _open_modal(Vector2(760, 640), false, Callable())
	_add_modal_heading(box, "储物袋", "随身珍藏 · 妥善收纳", "材料、丹药、功法、装备与历练所得宝物统一收纳。")
	var categories := HFlowContainer.new()
	categories.add_theme_constant_override("h_separation", 6)
	categories.add_theme_constant_override("v_separation", 6)
	box.add_child(categories)
	for category_name: String in ["全部", "材料", "丹药", "功法", "武技", "法术", "神通秘术", "装备", "宝物", "特殊"]:
		var tab := _make_button(category_name, category_name == inventory_category, 0, 34)
		tab.pressed.connect(_open_inventory.bind(category_name))
		categories.add_child(tab)
	var learned_counts := {"功法": 0, "武技": 0, "法术": 0, "神通秘术": 0}
	for learned_id: String in state.learned_skills:
		var learned_category := state.skill_category(learned_id)
		learned_counts[learned_category] = int(learned_counts.get(learned_category, 0)) + 1
	var counts := _label("材料 %d 种 · 丹药 %d 种 · 功法 %d · 武技 %d · 法术 %d · 神通秘术 %d · 宝物/旧物 %d 件" % [_inventory_nonzero_count(state.materials), _inventory_nonzero_count(state.pills), learned_counts["功法"], learned_counts["武技"], learned_counts["法术"], learned_counts["神通秘术"], state.treasures.size()], 10, MUTED)
	box.add_child(counts)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 420)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	var shown := 0
	if inventory_category == "全部" or inventory_category == "材料":
		for name: Variant in state.materials.keys():
			var amount := int(state.materials[name])
			if amount <= 0: continue
			_add_inventory_row(list, String(name), "材料", "持有 %d 份 · 可用于丹房配方" % amount, "", "")
			shown += 1
	if inventory_category == "全部" or inventory_category == "丹药":
		for name: Variant in state.pills.keys():
			var amount := int(state.pills[name])
			if amount <= 0: continue
			_add_inventory_row(list, String(name), "丹药", "持有 %d 枚 · 可服用获得对应丹药效果" % amount, "use_pill", String(name))
			shown += 1
	if inventory_category in ["全部", "功法", "武技", "法术", "神通秘术"]:
		for skill_id: String in state.learned_skills:
			var skill := BattleSystem.skill_data(skill_id)
			if skill.is_empty(): continue
			var category_name := String(skill.get("category", "武技"))
			if inventory_category != "全部" and inventory_category != category_name: continue
			var equipped := state.is_skill_equipped(skill_id)
			var mastery: Dictionary = BattleSystem.mastery_info(state.skill_mastery_xp(skill_id))
			_add_inventory_row(list, String(skill.get("name", skill_id)), category_name, "%s · %s · %s · 熟练度：%s" % [String(skill.get("rank", "")), String(skill.get("type", "")), "已装备" if equipped else "已收录", String(mastery.get("name", "入门"))], "unequip_skill" if equipped else "equip_skill", skill_id)
			shown += 1
	if inventory_category in ["全部", "装备", "宝物", "特殊"]:
		for item_variant: Variant in state.treasures:
			var item_name := String(item_variant)
			var info: Dictionary = GameData.treasure_info(item_name)
			var slot_id: String = String(info.get("slot", ""))
			var active_info: Dictionary = GameData.treasure_active_info(item_name)
			var item_category: String = "装备" if not slot_id.is_empty() else ("宝物" if not active_info.is_empty() else "特殊")
			if inventory_category not in ["全部", "宝物"] and inventory_category != item_category:
				continue
			var desc: String = String(info.get("desc", info.get("description", "珍藏之物，或有尚未发现的用途。")))
			var action: String = "unequip_item" if state.is_equipped(item_name) else ("equip_item" if not slot_id.is_empty() else ("use_treasure" if not active_info.is_empty() else ""))
			var action_text: String = "已佩带" if state.is_equipped(item_name) else ("可佩带" if not slot_id.is_empty() else ("可启用一次" if not active_info.is_empty() else "收藏/剧情物品"))
			_add_inventory_row(list, item_name, item_category, "%s · %s" % [action_text, desc], action, item_name, true)
			shown += 1
	if shown == 0:
		list.add_child(_label("此分类暂时空空如也。游历、斗法与秘境所得会在此收录。", 12, MUTED))
	var close := _make_button("返回", false, 0, 40)
	close.pressed.connect(func():
		_clear_modal(false)
		_refresh_game_ui()
	)
	box.add_child(close)

func _inventory_nonzero_count(source: Dictionary) -> int:
	var count := 0
	for key: Variant in source.keys():
		if int(source[key]) > 0: count += 1
	return count

func _add_inventory_row(parent: VBoxContainer, item_name: String, category: String, detail: String, action_id: String, payload: String, show_detail: bool = false) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)
	info.add_child(_label("【%s】%s" % [category, item_name], 12, INK, font_title))
	var desc := _label(detail, 10, MUTED)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc)
	if show_detail:
		var detail_button := _make_button("详情", false, 0, 38)
		detail_button.custom_minimum_size = Vector2(64, 38)
		detail_button.pressed.connect(_open_treasure_detail.bind(item_name))
		row.add_child(detail_button)
	if action_id.is_empty(): return
	var button_text := "使用" if action_id in ["use_pill", "use_treasure"] else ("卸下" if action_id in ["unequip_skill", "unequip_item"] else ("装备" if action_id in ["equip_skill", "equip_item"] else "操作"))
	var action := _make_button(button_text, false, 0, 38)
	action.custom_minimum_size = Vector2(72, 38)
	action.pressed.connect(_on_inventory_action.bind(action_id, payload))
	row.add_child(action)

func _on_inventory_action(action_id: String, payload: String) -> void:
	if state == null: return
	var message := ""
	match action_id:
		"use_pill":
			var result := state.use_pill(payload)
			message = String(result.get("message", ""))
		"use_treasure":
			var treasure_result: Dictionary = state.activate_treasure(payload)
			message = String(treasure_result.get("message", "启用失败。"))
		"equip_skill":
			var skill_equipped: bool = state.equip_skill(payload)
			if state.skill_category(payload) == "功法":
				message = "功法已装备。" if skill_equipped else "功法栏位已满或无法装备。"
			else:
				message = "%s已装备。" % state.skill_category(payload) if skill_equipped else "主动技艺栏位已满或无法装备。"
		"unequip_skill":
			var skill_unequipped: bool = state.unequip_skill(payload)
			if state.skill_category(payload) == "功法":
				message = "功法已卸下。" if skill_unequipped else "卸下失败。"
			else:
				message = "%s已卸下。" % state.skill_category(payload) if skill_unequipped else "卸下失败。"
		"equip_item":
			var previous := state.equip_item(payload)
			message = "已装备%s。" % payload if not state.equipped_item(String(GameData.treasure_info(payload).get("slot", ""))).is_empty() else "装备失败。"
			if not previous.is_empty(): message += " 原装备%s已替换。" % previous
		"unequip_item":
			message = "已卸下%s。" % payload if state.unequip_item(payload) else "卸下失败。"
	if not message.is_empty(): state.add_log("【储物袋】" + message, "gain")
	_save_run()
	if action_id not in ["equip_skill", "unequip_skill"]:
		_refresh_game_ui()
	# 列表只在弹窗内部更新；功法/武技装备不重建整张游戏界面。
	modal_instant_open = true
	_open_inventory(inventory_category)

func _can_craft_pill(pill_name: String) -> bool:
	return state != null and state.can_craft_pill(pill_name)

func _on_craft_pill(pill_name: String) -> void:
	if state == null:
		return
	if state.craft_pill(pill_name):
		state.add_log("【丹房】你以灵火温养药材，炼成一枚%s。" % pill_name, "gain")
		_save_run()
		_refresh_game_ui()
	_open_alchemy()

func _on_use_pill_from_bag(pill_name: String) -> void:
	if state == null:
		return
	var result: Dictionary = state.use_pill(pill_name)
	if bool(result.get("ok", false)):
		state.add_log("【服丹】" + String(result.get("message", "")), "gain")
		_save_run()
		_refresh_game_ui()
	_open_alchemy()

func _open_secret_realm() -> void:
	if not _can_act() or state == null:
		return
	var box := _open_modal(Vector2(650, 410), false, Callable())
	_add_modal_heading(box, "无名秘境", "雾锁残碑，灵光隐现", "秘境凶险，不推进常规寿元；每次探索会消耗一年光阴。你可以谨慎采药，也可以深入遗迹赌一场机缘。")
	var safe := _make_button("谨慎采药", false, 0, 46)
	safe.pressed.connect(_resolve_secret_realm.bind("safe"))
	box.add_child(safe)
	var deep := _make_button("深入遗迹", false, 0, 46)
	deep.pressed.connect(_resolve_secret_realm.bind("deep"))
	box.add_child(deep)
	var leave := _make_button("暂且离开", false, 0, 40)
	leave.pressed.connect(func():
		_clear_modal(false)
		_refresh_game_ui()
	)
	box.add_child(leave)

func _resolve_secret_realm(choice: String) -> void:
	if state == null or not state.alive:
		return
	state._advance(1)
	if choice == "safe":
		var first := ["凝露草", "灵芝", "赤焰砂"]
		var picked: String = String(first[rng.randi_range(0, first.size() - 1)])
		state.add_material(picked, 2)
		state.stones += 8 + state.realm * 2
		state.add_log("【秘境采集】你避开深处的妖气，只在外围采得%s两份，并拾得少量灵石。" % picked, "gain")
	else:
		var chance := clampf(0.48 + float(state.effective_stat("luck")) / 260.0 + float(state.realm) * 0.012, 0.48, 0.86)
		if rng.randf() < chance:
			var rare_material := ["灵芝", "妖狼獠牙", "赤焰砂"]
			var picked_rare: String = String(rare_material[rng.randi_range(0, rare_material.size() - 1)])
			state.add_material(picked_rare, 2)
			var stone_gain := 25 + state.realm * 5
			state.stones += stone_gain
			state.add_log("【秘境机缘】你穿过残阵，在石室中寻得%s两份与灵石 %d。" % [picked_rare, stone_gain], "gain")
			if rng.randf() < 0.12 and not state.treasures.has("残缺古修手札"):
				state.treasures.append("残缺古修手札")
				state.treasure_ages["残缺古修手札"] = state.age
				state.add_log("石室深处还留着一册【残缺古修手札】。", "gain")
		else:
			var damage := 12 + state.realm * 3 + rng.randi_range(0, 8)
			state.hp = maxi(1, state.hp - damage)
			state.injury = mini(99, state.injury + 4)
			state.add_log("【秘境凶险】残阵骤然发动，你被灵压震退，气血 -%d，伤势加重。" % damage, "danger")
	_clear_modal(false)
	if state.check_death():
		_handle_death()
		return
	_save_run()
	_refresh_game_ui()

func _on_seek_enemy() -> void:
	if not _can_act() or battle_active:
		return
	battle_enemy = BattleSystem.create_enemy(state.realm, rng)
	battle_turn_index = 0
	state.flags.erase("companion_guard")
	battle_logs.clear()
	battle_cooldowns.clear()
	battle_logs.append("你循着妖气或灵力波动寻去，在荒野深处遇见【%s】。" % String(battle_enemy.get("name", "未知敌人")))
	battle_logs.append(String(battle_enemy.get("desc", "对方已经摆开架势。")))
	battle_active = true
	_open_battle_modal()

func _open_battle_modal() -> void:
	# 战斗界面会在寻敌及每个回合后重绘；禁用弹窗淡入，避免反复闪烁。
	# _open_modal() 内部已经会清理旧弹窗，无需在这里重复清理。
	modal_instant_open = true
	var box := _open_modal(Vector2(680, 560), false, Callable())
	var enemy_tag := "【%s】" % String(battle_enemy.get("name", "敌人"))
	if bool(battle_enemy.get("boss", false)):
		enemy_tag += " · 首领"
	elif bool(battle_enemy.get("elite", false)):
		enemy_tag += " · 精英异变"
	_add_modal_heading(box, "山野遭逢 · 回合制斗法", enemy_tag, String(battle_enemy.get("desc", "")))
	if bool(battle_enemy.get("boss", false)):
		var boss_phase := int(battle_enemy.get("boss_phase", 1))
		var phase_name := "初战" if boss_phase == 1 else ("召援" if boss_phase == 2 else "狂暴")
		var boss_hint := "首领阶段：%s" % phase_name
		if not String(battle_enemy.get("boss_telegraph", "")).is_empty():
			boss_hint += " · 危险：杀招蓄势中！建议防御或使用控制技能打断。"
		box.add_child(_label(boss_hint, 12, CINNABAR if boss_phase >= 3 or not String(battle_enemy.get("boss_telegraph", "")).is_empty() else GOLD))
	var battle_companions: Array[String] = []
	for companion_npc: Dictionary in state.met_npcs:
		if bool(companion_npc.get("companion", false)) and bool(companion_npc.get("companion_alive", true)) and int(companion_npc.get("affinity", 0)) >= 10:
			var companion_skill := state.companion_skill_profile(companion_npc)
			battle_companions.append("%s·%s" % [String(companion_npc.get("name", "伙伴")), String(companion_skill.get("name", "本命绝技"))])
	if not battle_companions.is_empty():
		box.add_child(_label("同行伙伴协战：%s" % "、".join(PackedStringArray(battle_companions)), 11, GOLD))
	var battle_pet := state.active_pet()
	if not battle_pet.is_empty():
		var battle_pet_info := VBoxContainer.new()
		box.add_child(battle_pet_info)
		battle_pet_info.add_child(_label("灵宠协战：%s" % _pet_stage_title(battle_pet), 15, JADE, font_title))
		battle_pet_info.add_child(_label("灵宠气血：%d / %d\n专属形态：%s\n技能：%s" % [int(battle_pet.get("pet_hp", 0)), int(battle_pet.get("pet_max_hp", 80)), String(battle_pet.get("form", "普通灵兽")), " · ".join(PackedStringArray(Array(battle_pet.get("skills", []))))], 11, INK_SOFT))
	var status := _label("你的气血 %d / %d    灵力 %d / %d\n敌方气血 %d / %d\n敌人可能转而攻击你的出战灵宠" % [state.hp, state.max_hp(), state.mp, state.max_mp(), int(battle_enemy.get("hp", 0)), int(battle_enemy.get("max_hp", 0))], 14, CINNABAR)
	box.add_child(status)
	var log_panel := PanelContainer.new()
	log_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.94, 0.90, 0.82, 0.72), Color(0.72, 0.63, 0.48, 0.35), 5, 1))
	box.add_child(log_panel)
	var log := RichTextLabel.new()
	log.bbcode_enabled = true
	log.fit_content = true
	log.custom_minimum_size = Vector2(0, 160)
	var visible_logs := PackedStringArray()
	for i in range(maxi(0, battle_logs.size() - 7), battle_logs.size()):
		visible_logs.append(battle_logs[i])
	log.text = "\n".join(visible_logs)
	log.add_theme_font_size_override("normal_font_size", 14)
	log.add_theme_color_override("default_color", INK)
	log_panel.add_child(log)
	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 8)
	box.add_child(actions)
	_add_battle_action(actions, "普通攻击", "不消耗灵力，造成基础伤害", "attack", true)
	for skill_id: String in state.equipped_martial:
		var skill: Dictionary = BattleSystem.skill_data(skill_id)
		if skill.is_empty():
			continue
		var cooldown_left := int(battle_cooldowns.get(skill_id, 0))
		var skill_hint := "%s · %s" % [String(skill.get("rank", "")), "不耗法力" if String(skill.get("category", "")) == "武技" else "消耗 %d 灵力" % int(skill.get("mp", 0))]
		if cooldown_left > 0:
			skill_hint += " · 冷却 %d 回合" % cooldown_left
		_add_battle_action(actions, String(skill.get("name", "武技")), skill_hint, "skill:" + skill_id, state.mp >= int(skill.get("mp", 0)) and cooldown_left <= 0)
	for pill_name: String in ["小还丹", "聚气散", "大还丹", "归元丹", "青岚清心丹", "天京玉露丹", "药王续命丹", "荒古血魄丹", "归墟龙元丹", "青岚剑心丹", "天京玉髓丹", "天机破障丹", "荒古淬体丹", "幽冥凝魂丹", "清瘴丹", "洗髓丹", "悟道丹", "破障丹", "凝神丹"]:
		var pill_count := int(state.pills.get(pill_name, 0))
		if pill_count > 0:
			_add_battle_action(actions, "服用" + pill_name, "持有 %d · 消耗一回合" % pill_count, "pill:" + pill_name, true)
	_add_battle_action(actions, "凝神防御", "本回合大幅减少受到的伤害", "defend", true)
	_add_battle_action(actions, "脱身逃遁", "尝试脱离战斗", "flee", true)
	var close_hint := _label("战斗中不会推进寿元；战后可继续修炼与游历。", 10, MUTED)
	box.add_child(close_hint)

func _add_battle_action(parent: GridContainer, title_text: String, hint: String, action_id: String, enabled: bool) -> void:
	var button := _make_button(title_text + "\n" + hint, false, 0, 56)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = not enabled
	button.pressed.connect(_on_battle_action.bind(action_id))
	parent.add_child(button)

func _on_battle_action(action_id: String) -> void:
	if not battle_active or state == null or not state.alive:
		return
	var defending := false
	var reflect_ratio := 0.0
	match action_id:
		"attack":
			var result: Dictionary = BattleSystem.player_attack(state, battle_enemy, rng)
			battle_logs.append("你挥出一击，造成 %d 点伤害%s。" % [int(result.damage), "（会心一击）" if bool(result.critical) else ""])
		"defend":
			defending = true
			battle_logs.append("你沉肩敛息，护住周身要害，准备承受敌人的攻势。")
		"flee":
			var chance := clampf(0.48 + float(state.effective_stat("luck")) / 220.0, 0.50, 0.88)
			if rng.randf() < chance:
				battle_logs.append("你借地势掩护抽身而退，成功脱离战斗。")
				_end_battle(false)
				return
			battle_logs.append("敌人看穿你的退意，封住退路！")
		_:
			if action_id.begins_with("pill:"):
				var pill_name := action_id.trim_prefix("pill:")
				var pill_result: Dictionary = state.use_pill(pill_name)
				if not bool(pill_result.get("ok", false)):
					battle_logs.append(String(pill_result.get("message", "服丹失败。")))
					_open_battle_modal()
					return
				battle_logs.append(String(pill_result.get("message", "你服下一枚丹药。")))
			elif action_id.begins_with("skill:"):
				var skill_id := action_id.trim_prefix("skill:")
				var skill_result: Dictionary = BattleSystem.use_skill(skill_id, state, battle_enemy, rng)
				if not bool(skill_result.get("ok", false)):
					battle_logs.append(String(skill_result.get("message", "功法施展失败。")))
					_open_battle_modal()
					return
				var skill_message := String(skill_result.get("message", "功法发动"))
				var damage_done := int(skill_result.get("damage", 0))
				if damage_done > 0:
					skill_message += "，造成 %d 点伤害%s" % [damage_done, "（会心）" if bool(skill_result.get("critical", false)) else ""]
				if int(skill_result.get("healed", 0)) > 0:
					skill_message += "，汲取气血恢复 %d" % int(skill_result.get("healed", 0))
				battle_logs.append(skill_message + "。")
				defending = bool(skill_result.get("defend", false))
				reflect_ratio = float(skill_result.get("reflect", 0.0))
				battle_cooldowns[skill_id] = int(BattleSystem.skill_data(skill_id).get("cooldown", 0))
			else:
				return
	battle_turn_index += 1
	var party_result: Dictionary = state.resolve_party_support_turn(battle_enemy, rng, battle_turn_index)
	var companion_results: Array = party_result.get("companions", [])
	for companion_result_value: Variant in companion_results:
		if not companion_result_value is Dictionary:
			continue
		var companion_result: Dictionary = companion_result_value
		var companion_line := "%s施展【%s】，造成%d点伤害。" % [
			String(companion_result.get("npc_name", "同行伙伴")),
			String(companion_result.get("skill_name", "本命绝技")),
			int(companion_result.get("damage", 0))
		]
		var companion_note := String(companion_result.get("note", ""))
		if not companion_note.is_empty():
			companion_line += companion_note
		battle_logs.append(companion_line)
	if int(battle_enemy.get("hp", 0)) <= 0:
		_end_battle(true)
		return
	var pet_result: Dictionary = party_result.get("pet", {})
	if not pet_result.is_empty():
		battle_logs.append("灵宠%s（%s）施展【%s】，造成%d点伤害！" % [
			String(pet_result.get("name", "灵宠")),
			String(pet_result.get("form", "灵兽形态")),
			String(pet_result.get("move", "协击")),
			int(pet_result.get("damage", 0))
		])
	if int(battle_enemy.get("hp", 0)) <= 0:
		_end_battle(true)
		return
	var status_result: Dictionary = BattleSystem.tick_enemy_status(battle_enemy)
	for status_note: String in status_result.get("notes", []):
		battle_logs.append(status_note + "。")
	if int(battle_enemy.get("hp", 0)) <= 0:
		_end_battle(true)
		return
	var damage := 0
	var enemy_target := "none"
	if bool(status_result.get("stunned", false)):
		battle_logs.append("%s无法行动，错失了反击机会。" % String(battle_enemy.get("name", "敌人")))
	else:
		var enemy_hit: Dictionary = BattleSystem.enemy_turn(state, battle_enemy, defending, rng)
		damage = int(enemy_hit.get("damage", 0))
		enemy_target = String(enemy_hit.get("target", "player"))
		var enemy_action := String(enemy_hit.get("action", "普通攻击"))
		if enemy_action != "普通攻击":
			battle_logs.append("%s施展【%s】！%s" % [String(battle_enemy.get("name", "敌人")), enemy_action, String(enemy_hit.get("note", ""))])
		if enemy_target == "pet":
			var hit_pet := state.active_pet()
			battle_logs.append("%s挡在你身前，承受了%d点伤害！（灵宠气血 %d/%d）" % [_pet_stage_title(hit_pet), damage, int(hit_pet.get("pet_hp", 0)), int(hit_pet.get("pet_max_hp", 80))])
			if bool(enemy_hit.get("pet_down", false)):
				battle_logs.append("灵宠力竭倒地，暂时无法继续协战；敌人将转而攻击你。")
		elif bool(enemy_hit.get("evaded", false)):
			battle_logs.append("你身形一晃，恰好避开了敌人的攻击。")
		if damage > 0 and enemy_target == "player" and reflect_ratio > 0.0:
			var reflected := maxi(1, int(round(float(damage) * reflect_ratio)))
			battle_enemy["hp"] = maxi(0, int(battle_enemy.get("hp", 0)) - reflected)
			battle_logs.append("镜身反照伤害，敌人受到 %d 点反噬。" % reflected)
	for cooldown_id: Variant in battle_cooldowns.keys():
		battle_cooldowns[cooldown_id] = maxi(0, int(battle_cooldowns[cooldown_id]) - 1)
	if bool(status_result.get("stunned", false)):
		pass
	elif enemy_target == "player" and damage > 0:
		battle_logs.append("%s向你发起攻击，你损失 %d 点气血。" % [String(battle_enemy.get("name", "敌人")), damage])
	if int(battle_enemy.get("hp", 0)) <= 0:
		_end_battle(true)
		return
	if state.hp <= 0:
		battle_logs.append("气血耗尽，你眼前一黑，倒在尘土之中。")
		battle_active = false
		_clear_modal(false)
		state.flags.erase("companion_guard")
		state.die("战斗中气血耗尽")
		_handle_death()
		return
	_open_battle_modal()

func _end_battle(victory: bool) -> void:
	battle_active = false
	state.flags.erase("companion_guard")
	_clear_modal(false)
	if victory:
		var stones_gain := int(battle_enemy.get("stones", 0))
		var cult_gain := int(battle_enemy.get("cultivation", 0))
		state.stones += stones_gain
		state.cultivation = minf(state.threshold(), state.cultivation + float(cult_gain))
		state.add_log("【斗法胜利】你击败了%s，获得灵石 %d、修为 %d。" % [String(battle_enemy.get("name", "敌人")), stones_gain, cult_gain], "gain")
		var material_pool: Array[String] = ["凝露草", "灵芝", "妖狼獠牙", "赤焰砂", "寒潭鳞片", "阴魂结晶", "石傀核心", "魔修血晶", "蛟龙逆鳞", "剑宗令牌"]
		var material_drop: String = material_pool[rng.randi_range(0, material_pool.size() - 1)]
		var material_count := 1 if rng.randf() < 0.72 else 2
		state.add_material(material_drop, material_count)
		state.add_log("你从战场附近搜得%s ×%d，可用于炼制丹药。" % [material_drop, material_count], "gain")
		if bool(battle_enemy.get("regional", false)):
			var local_drop := String(battle_enemy.get("region_material", ""))
			if not local_drop.is_empty():
				state.add_material(local_drop, 1)
				state.add_log("【州域特产】你从%s身上取得当地特产%s×1。" % [String(battle_enemy.get("name", "妖兽")), local_drop], "gain")
		# 敌人可能掉落兵器；精英与高阶敌人的掉落概率更高。
		var weapon_drop_chance: float = 0.24
		if bool(battle_enemy.get("elite", false)):
			weapon_drop_chance += 0.18
		if String(battle_enemy.get("kind", "")) in ["秘境守卫", "精英妖兽", "宗门强敌"]:
			weapon_drop_chance += 0.12
		if rng.randf() < weapon_drop_chance:
			var weapon_pool: Array[String] = ["青锋剑", "玄铁重剑", "追风灵剑", "赤纹战刀", "寒魄飞剑", "镇岳长枪", "紫电雷刃", "斩蛟古剑"]
			var available_weapons: Array[String] = []
			var highest_weapon_index: int = mini(weapon_pool.size() - 1, 1 + int(state.realm / 2))
			for weapon_index: int in range(highest_weapon_index + 1):
				var candidate_weapon: String = weapon_pool[weapon_index]
				if not state.treasures.has(candidate_weapon):
					available_weapons.append(candidate_weapon)
			if not available_weapons.is_empty():
				var weapon_name: String = available_weapons[rng.randi_range(0, available_weapons.size() - 1)]
				state.treasures.append(weapon_name)
				state.treasure_ages[weapon_name] = state.age
				state.add_log("【兵器掉落】你从敌人遗物中获得%s！" % weapon_name, "gain")
		if rng.randf() < 0.24:
			var drops := ["妖狼獠牙", "凝露草", "残缺剑诀玉简", "寒潭鳞片", "阴魂结晶", "石傀核心", "魔修血晶", "蛟龙逆鳞", "剑宗令牌"]
			var drop: String = drops[rng.randi_range(0, drops.size() - 1)]
			if not state.treasures.has(drop):
				state.treasures.append(drop)
				state.treasure_ages[drop] = state.age
				state.add_log("搜寻战场，你找到一件战利品：【%s】。" % drop, "gain")
	else:
		state.add_log("【脱离战斗】你暂避锋芒，退回安全之处。", "hint")
	state.recover_active_pet_after_battle()
	_save_run()
	_refresh_game_ui()

func _on_breakthrough() -> void:
	if not _can_act() or state == null or not state.is_peak():
		return
	var result: Dictionary = state.attempt_breakthrough(rng)
	if not bool(result.get("ok", false)):
		_refresh_game_ui()
		return
	if bool(result.get("success", false)):
		_flash(Color(0.99, 0.88, 0.62, 0.30), 0.55)
	else:
		_flash(Color(0.65, 0.12, 0.09, 0.22), 0.35)
	_refresh_game_ui()
	if state.check_death():
		_handle_death()
		return
	_finish_turn()

func _flash(color: Color, duration: float) -> void:
	var flash := ColorRect.new()
	flash.color = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 80
	add_child(flash)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(flash.queue_free)

# ---------------------------------------------------------------------------
# 事件
# ---------------------------------------------------------------------------

func _open_event(event: Dictionary) -> void:
	if music != null:
		music.play_track("event", 0.8)
	var box := _open_modal(Vector2(700, 0), false, Callable())
	var event_meta: Dictionary = EventData.event_metadata(event)
	var category_text := String(event_meta.get("category", "探索"))
	var rarity_text := String(event_meta.get("rarity", "普通"))
	var region_text := String(event_meta.get("region_hint", "九州各地"))
	var kicker := _label("%s · %s机缘 · %s" % [category_text, rarity_text, region_text], 11, CINNABAR)
	box.add_child(kicker)
	var title := _label(String(event.get("title", "无名之事")), 34, INK, font_title)
	box.add_child(title)
	box.add_child(_hairline())
	_add_event_npc_card(box, event)
	var story := _rich_label(String(event.get("text", "")), 15, INK, 2)
	story.custom_minimum_size = Vector2(0, 118)
	box.add_child(story)
	var hint := _label("一念既出，因果自承。", 10, MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(hint)
	var choices := VBoxContainer.new()
	choices.add_theme_constant_override("separation", 7)
	box.add_child(choices)
	var index: int = 0
	for choice: Dictionary in event.get("choices", []):
		index += 1
		var choice_button := _make_choice_button(choice, index)
		choices.add_child(choice_button)
		if not bool(choice_button.get_meta("available", true)):
			continue
		choice_button.pressed.connect(_on_event_choice.bind(event, choice))


func _add_event_npc_card(box: VBoxContainer, event: Dictionary) -> void:
	var npc: Dictionary = EventData.get_npc_profile(event)
	if npc.is_empty():
		return
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.91, 0.87, 0.77, 0.72), Color(0.65, 0.52, 0.34, 0.42), 5, 1))
	box.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	margin.add_child(content)
	content.add_child(_label("本次相逢 · 人物档案", 10, GOLD))
	content.add_child(_label("%s  ·  %s" % [String(npc.get("name", "无名")), String(npc.get("identity", "来历不明"))], 17, INK, font_title))
	content.add_child(_label("%s  ·  %s" % [String(npc.get("realm", "境界不详")), String(npc.get("faction", "来历不明"))], 11, MUTED))
	var saved_npc: Dictionary = {}
	for known_npc: Dictionary in state.met_npcs:
		if String(known_npc.get("event_id", "")) == String(npc.get("event_id", "")):
			saved_npc = known_npc
			break
	if not saved_npc.is_empty():
		var affinity := int(saved_npc.get("affinity", 0))
		var bond_text := "好感 %s%d · %s" % ["+" if affinity > 0 else "", affinity, String(saved_npc.get("relationship", "陌路"))]
		if bool(saved_npc.get("companion", false)):
			bond_text += " · 已结为伙伴"
		content.add_child(_label(bond_text, 11, JADE if affinity >= 0 else CINNABAR))
		if not String(saved_npc.get("last_choice", "")).is_empty():
			content.add_child(_label("仍记得你上次的选择：「%s」" % String(saved_npc.get("last_choice", "")), 10, MUTED))
	var appearance := _label(String(npc.get("appearance", "")), 11, INK_SOFT)
	appearance.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(appearance)

func _make_choice_button(choice: Dictionary, index: int) -> Button:
	var tone: String = String(choice.get("tone", "neutral"))
	var tone_color: Color = _tone_color(tone)
	var cost: int = int(choice.get("cost", 0))
	var req: Dictionary = choice.get("req", {})
	var available: bool = state.meets_requirement(req) and (cost <= 0 or state.can_afford(cost))
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true
	button.disabled = not available
	button.set_meta("available", available)
	button.add_theme_stylebox_override("normal", _card_style(Color(0.978, 0.948, 0.891, 0.88), Color(0.68, 0.59, 0.43, 0.26)))
	button.add_theme_stylebox_override("hover", _card_style(Color(1.0, 0.975, 0.925, 0.98), Color(tone_color.r, tone_color.g, tone_color.b, 0.62)))
	button.add_theme_stylebox_override("pressed", _card_style(Color(0.94, 0.90, 0.82, 0.98), Color(tone_color.r, tone_color.g, tone_color.b, 0.72)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", _card_style(Color(0.91, 0.88, 0.81, 0.42), Color(0.68, 0.59, 0.43, 0.14)))

	var margin := MarginContainer.new()
	button.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 5)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)
	var index_panel := PanelContainer.new()
	index_panel.custom_minimum_size = Vector2(28, 28)
	index_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	index_panel.add_theme_stylebox_override("panel", _panel_style(Color(tone_color.r, tone_color.g, tone_color.b, 0.10), Color(tone_color.r, tone_color.g, tone_color.b, 0.28), 3, 1))
	row.add_child(index_panel)
	var index_label := _label(_formal_number(index), 13, tone_color, font_title)
	index_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	index_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	index_panel.add_child(index_label)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_theme_constant_override("separation", 0)
	row.add_child(texts)
	texts.add_child(_label(String(choice.get("text", "")), 16, INK if available else MUTED))
	var hint_text: String = String(choice.get("hint", ""))
	if cost > 0:
		hint_text += " · 需 %d 灵石" % cost
	if not req.is_empty():
		hint_text += " · " + _requirement_text(req)
	if not available:
		if cost > 0 and not state.can_afford(cost):
			hint_text = "灵石不足 · " + hint_text
		else:
			hint_text = "条件不足 · " + hint_text
	var hint := _label(hint_text, 10, tone_color if available else Color(MUTED.r, MUTED.g, MUTED.b, 0.8))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texts.add_child(hint)
	var arrow := _label("›", 19, tone_color if available else MUTED, font_title)
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(arrow)
	return button

func _tone_color(tone: String) -> Color:
	match tone:
		"good": return JADE
		"evil": return CINNABAR
		"danger": return Color(0.56, 0.19, 0.14, 1.0)
		_:
			return GOLD

func _requirement_text(req: Dictionary) -> String:
	var parts := PackedStringArray()
	for key: Variant in req.keys():
		var labels: Dictionary = {"body": "根骨", "insight": "悟性", "luck": "气运", "daoheart": "道心", "realm": "境界", "karma_min": "因果", "karma_max": "因果", "stones": "灵石"}
		parts.append("%s≥%d" % [String(labels.get(String(key), String(key))), int(req[key])])
	return " · ".join(parts)

func _on_event_choice(event: Dictionary, choice: Dictionary) -> void:
	if not modal_open or state == null or not state.alive:
		return
	var cost: int = int(choice.get("cost", 0))
	if cost > 0 and not state.pay_stones(cost):
		return
	var outcome: Dictionary = choice
	if choice.has("outcomes"):
		var outcomes: Array = choice.get("outcomes", [])
		if not outcomes.is_empty():
			outcome = GameData.weighted_pick(outcomes, rng)
	var result_text: String = String(outcome.get("result", outcome.get("text", choice.get("result", ""))))
	var effects: Dictionary = outcome.get("effects", choice.get("effects", {}))
	var notes: Array = state.apply_effects(effects)
	if cost > 0:
		notes.push_front("灵石 -%d" % cost)
	var npc_profile: Dictionary = EventData.get_npc_profile(event)
	if not npc_profile.is_empty():
		var known_npc := false
		for old_npc: Dictionary in state.met_npcs:
			if String(old_npc.get("event_id", "")) == String(npc_profile.get("event_id", "")):
				known_npc = true
				break
		if not known_npc:
			state.met_npcs.append(npc_profile.duplicate(true))
			state.add_log("初识人物：%s（%s）" % [String(npc_profile.get("name", "无名")), String(npc_profile.get("identity", "来历不明"))], "event")
		var bond_notes: Array = state.record_npc_choice(npc_profile, event, choice, outcome)
		notes.append_array(bond_notes)
	# 先记录本次选择，再生成续篇，让续篇读取真实关系。
	if EventData.has_followup(event) and not String(event.get("id", "")).begins_with("linked_"):
		var followup_queue: Array = Array(state.flags.get("pending_adventure_events", [])).duplicate(true)
		followup_queue.append(EventData.build_followup(event, result_text, effects, state))
		state.flags["pending_adventure_events"] = followup_queue
		state.flags.erase("pending_adventure_event")
	var event_id: String = String(event.get("id", ""))
	if not event_id.is_empty() and not state.seen_events.has(event_id):
		state.seen_events.append(event_id)
	var log_text: String = "【%s】%s" % [String(event.get("title", "奇遇")), result_text]
	state.add_log(log_text, "event")
	if not notes.is_empty():
		state.add_log("　" + " · ".join(PackedStringArray(notes)), "gain")
	state.check_death()
	if state.alive:
		_save_run()
	else:
		_delete_run()
	_refresh_game_ui()
	_show_event_result(event, result_text, notes)

func _show_event_result(event: Dictionary, result_text: String, notes: Array) -> void:
	var box := _open_modal(Vector2(700, 0), false, Callable())
	var kicker := _label("因 果 已 定", 11, JADE)
	box.add_child(kicker)
	var title := _label(String(event.get("title", "奇遇")), 30, INK, font_title)
	box.add_child(title)
	box.add_child(_hairline())
	var story := _rich_label(result_text, 15, INK, 2)
	story.custom_minimum_size = Vector2(0, 112)
	box.add_child(story)
	if not notes.is_empty():
		var note_panel := PanelContainer.new()
		note_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.90, 0.87, 0.78, 0.58), Color(0.64, 0.55, 0.40, 0.20), 4, 1))
		box.add_child(note_panel)
		var note_margin := MarginContainer.new()
		note_margin.add_theme_constant_override("margin_left", 12)
		note_margin.add_theme_constant_override("margin_right", 12)
		note_margin.add_theme_constant_override("margin_top", 7)
		note_margin.add_theme_constant_override("margin_bottom", 7)
		note_panel.add_child(note_margin)
		var note_label := _label(" · ".join(PackedStringArray(notes)), 11, GOLD)
		note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note_margin.add_child(note_label)
	else:
		var empty := _label("水面无波，因果未改。", 11, MUTED)
		box.add_child(empty)
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(button_row)
	var cont := _make_button("继续前行", true, 150, 42)
	cont.pressed.connect(_after_event_continue)
	button_row.add_child(cont)

func _after_event_continue() -> void:
	_clear_modal(false)
	if state == null:
		return
	if state.check_death():
		_handle_death()
	else:
		if music != null:
			music.play_track("cultivation", 1.2)
		_finish_turn()

# ---------------------------------------------------------------------------
# 死亡与轮回
# ---------------------------------------------------------------------------

func _point_breakdown() -> Dictionary:
	var realm_points: int = 8 + state.realm * 4
	var year_points: int = mini(30, int(maxi(0, state.age - 16) / 10))
	var karma_points: int = 0
	if state.karma > 0:
		karma_points = int(state.karma / 12)
	elif state.karma < 0:
		karma_points = int(-state.karma / 25)
	var relic_points: int = state.treasures.size() * 2
	var ascend_points: int = 150 if state.ascended else 0
	var total: int = maxi(10, realm_points + year_points + karma_points + relic_points + ascend_points)
	return {
		"total": total,
		"realm": realm_points,
		"years": year_points,
		"karma": karma_points,
		"relics": relic_points,
		"ascend": ascend_points,
	}

func _handle_death() -> void:
	if state == null or state.death_handled:
		return
	state.death_handled = true
	if music != null:
		music.play_track("ending", 1.6)
	if state.death_reason.is_empty():
		state.die("寿元耗尽")
	var breakdown: Dictionary = _point_breakdown()
	pending_death_breakdown = breakdown
	var earned: int = int(breakdown["total"])

	soul["points"] = int(soul.get("points", 0)) + earned
	soul["lives"] = int(soul.get("lives", 0)) + 1
	soul["best_realm"] = maxi(int(soul.get("best_realm", 0)), state.realm)
	if state.ascended:
		soul["ascensions"] = int(soul.get("ascensions", 0)) + 1
	var chronicle: Array = soul.get("chronicle", [])
	chronicle.append({
		"life": int(soul["lives"]),
		"name": state.player_name,
		"age": state.age,
		"realm": state.realm,
		"realm_name": state.realm_name(),
		"origin": String(state.origin.get("name", "")),
		"root": String(state.root.get("name", "")),
		"karma": state.karma,
		"karma_title": state.alignment_text(),
		"cause": state.death_reason,
		"ascended": state.ascended,
		"points": earned,
	})
	while chronicle.size() > 40:
		chronicle.pop_front()
	soul["chronicle"] = chronicle
	_save_soul()
	_delete_run()
	ui_mode = "dead"
	_refresh_menu()
	_refresh_game_ui()
	_show_death_modal(earned, breakdown)

func _show_death_modal(earned: int, breakdown: Dictionary) -> void:
	var box := _open_modal(Vector2(860, 0), false, Callable())
	var ascension: bool = state.ascended
	var kicker_text: String = "白 日 飞 升" if ascension else "此 生 终 章"
	var title_text: String = "羽化登仙" if ascension else "此身已殁"
	var title_color: Color = GOLD if ascension else CINNABAR
	var kicker := _label(kicker_text, 11, title_color)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(kicker)
	var title := _label(title_text, 40, title_color, font_title)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var name_line := _label("%s · 享年 %d 岁 · %s" % [state.player_name, state.age, state.realm_name()], 15, INK_SOFT)
	name_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_line)

	var epitaph := _label(_pick_epitaph(), 19, INK, font_title)
	epitaph.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	epitaph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	epitaph.custom_minimum_size = Vector2(0, 62)
	epitaph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(epitaph)
	box.add_child(_hairline())

	var summary_row := HBoxContainer.new()
	summary_row.add_theme_constant_override("separation", 10)
	box.add_child(summary_row)
	summary_row.add_child(_death_fact("境界", state.realm_name()))
	summary_row.add_child(_death_fact("因果", "%s %+d" % [state.alignment_text(), state.karma]))
	summary_row.add_child(_death_fact("死因", state.death_reason))
	summary_row.add_child(_death_fact("遗物", "%d 件" % state.treasures.size()))

	var highlights_title := _label("此 生 掠 影", 10, MUTED)
	box.add_child(highlights_title)
	var highlights := _get_highlights()
	var highlight_text := "\n".join(highlights)
	if highlight_text.is_empty():
		highlight_text = "这一生平淡如水，像许多没有名字的人一样来去。"
	var h_label := _label(highlight_text, 12, INK_SOFT)
	h_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h_label.custom_minimum_size = Vector2(0, 54)
	box.add_child(h_label)

	var reward_panel := PanelContainer.new()
	reward_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.93, 0.88, 0.78, 0.72), Color(0.67, 0.54, 0.31, 0.36), 5, 1))
	box.add_child(reward_panel)
	var reward_margin := MarginContainer.new()
	reward_margin.add_theme_constant_override("margin_left", 16)
	reward_margin.add_theme_constant_override("margin_right", 16)
	reward_margin.add_theme_constant_override("margin_top", 10)
	reward_margin.add_theme_constant_override("margin_bottom", 10)
	reward_panel.add_child(reward_margin)
	var reward_box := VBoxContainer.new()
	reward_box.add_theme_constant_override("separation", 1)
	reward_margin.add_child(reward_box)
	var reward_head := HBoxContainer.new()
	reward_box.add_child(reward_head)
	reward_head.add_child(_label("所得轮回点", 12, INK_SOFT))
	var reward_spacer := Control.new()
	reward_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reward_head.add_child(reward_spacer)
	var reward_value := _label("+%d" % earned, 28, CINNABAR, font_title)
	reward_head.add_child(reward_value)
	var breakdown_text := "境界 +%d　年岁 +%d　因果 +%d　遗物 +%d" % [int(breakdown["realm"]), int(breakdown["years"]), int(breakdown["karma"]), int(breakdown["relics"])]
	if int(breakdown["ascend"]) > 0:
		breakdown_text += "　飞升 +%d" % int(breakdown["ascend"])
	var breakdown_label := _label(breakdown_text, 10, MUTED)
	reward_box.add_child(breakdown_label)
	reward_box.add_child(_label("现有轮回点 %d · 可在轮回殿中换取先天之资。" % int(soul.get("points", 0)), 10, INK_SOFT))

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	var meta_button := _make_button("前往轮回殿", false, 150, 44)
	meta_button.pressed.connect(_on_death_upgrades)
	buttons.add_child(meta_button)
	var again := _make_button("再入轮回", true, 160, 44)
	again.pressed.connect(_start_new_life)
	buttons.add_child(again)
	var back_menu := _make_text_button("回到主菜单", 12)
	back_menu.pressed.connect(_on_death_to_menu)
	buttons.add_child(back_menu)
	_flash(Color(0.99, 0.90, 0.69, 0.36), 0.7)

func _death_fact(label_text: String, value_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.955, 0.92, 0.85, 0.52), Color(0.67, 0.58, 0.43, 0.18), 4, 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	margin.add_child(box)
	box.add_child(_label(label_text, 9, MUTED))
	var value := _label(value_text, 13, INK)
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(value)
	return panel

func _get_highlights() -> PackedStringArray:
	var found: Array = []
	var allowed: Array = ["breakthrough", "danger", "epiphany", "event", "ascension"]
	for entry: Dictionary in state.logs:
		if not allowed.has(String(entry.get("kind", ""))):
			continue
		var clean := _strip_bbcode(String(entry.get("text", ""))).replace("\n", " ").strip_edges()
		if clean.length() > 58:
			clean = clean.substr(0, 58) + "……"
		found.append("· " + clean)
	var results := PackedStringArray()
	var start_index: int = maxi(0, found.size() - 4)
	for i: int in range(start_index, found.size()):
		results.append(String(found[i]))
	return results

func _pick_epitaph() -> String:
	var key: String
	if state.ascended:
		key = "ascend"
	elif state.realm <= 3:
		key = "low"
	elif state.realm <= 9:
		key = "mid"
	else:
		key = "high"
	var pool: Array = GameData.DEATH_EPITAPHS[key]
	return String(pool[rng.randi_range(0, pool.size() - 1)])

func _on_death_upgrades() -> void:
	_open_upgrade_screen(true)

func _on_death_to_menu() -> void:
	_clear_modal(false)
	_show_menu()

# ---------------------------------------------------------------------------
# 轮回殿与尘世录
# ---------------------------------------------------------------------------

func _open_upgrade_screen(from_death: bool = false) -> void:
	var box := _open_modal(Vector2(1030, 0), true, func() -> void:
		if from_death: _show_death_modal(int(pending_death_breakdown.get("total", 0)), pending_death_breakdown)
	)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	box.add_child(header)
	var head_box := VBoxContainer.new()
	head_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(head_box)
	head_box.add_child(_label("轮 回 殿", 34, INK, font_title))
	head_box.add_child(_label("以前世道果，换今生一点先天之资。", 12, INK_SOFT))
	var points_box := VBoxContainer.new()
	points_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(points_box)
	var points_label := _label("轮回点 %d" % int(soul.get("points", 0)), 22, CINNABAR, font_title)
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	points_box.add_child(points_label)
	var spent_label := _label("已历 %d 世" % int(soul.get("lives", 0)), 10, MUTED)
	spent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	points_box.add_child(spent_label)
	box.add_child(_hairline())

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 9)
	box.add_child(grid)
	for upgrade: Dictionary in GameData.UPGRADES:
		grid.add_child(_make_upgrade_card(upgrade, from_death))

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var footer_hint := _label("道果随身，轮回不灭。每一级传承都会在下一世生效。", 10, MUTED)
	footer_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(footer_hint)
	var back := _make_button("返回", false, 110, 40)
	back.pressed.connect(func() -> void: _close_modal())
	footer.add_child(back)
	if from_death:
		var again := _make_button("再入轮回", true, 140, 40)
		again.pressed.connect(_start_new_life)
		footer.add_child(again)

func _make_upgrade_card(upgrade: Dictionary, from_death: bool) -> PanelContainer:
	var id: String = String(upgrade["id"])
	var level: int = int((soul.get("upgrades", {}) as Dictionary).get(id, 0))
	var max_level: int = int(upgrade["max"])
	var cost: int = GameData.upgrade_cost(upgrade, level)
	var can_buy: bool = level < max_level and int(soul.get("points", 0)) >= cost
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 98)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.962, 0.932, 0.867, 0.80), Color(0.66, 0.57, 0.41, 0.26), 5, 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)
	var seal := _make_seal(String(upgrade["glyph"]), 40, 18)
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(seal)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 1)
	row.add_child(text_box)
	var title_row := HBoxContainer.new()
	text_box.add_child(title_row)
	title_row.add_child(_label(String(upgrade["name"]), 18, INK, font_title))
	var title_spacer := Control.new()
	title_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_spacer)
	title_row.add_child(_label("等级 %d / %d" % [level, max_level], 9, MUTED))
	text_box.add_child(_label(String(upgrade["effect"]), 10, GOLD))
	var desc := _label(String(upgrade["desc"]), 10, INK_SOFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 26)
	text_box.add_child(desc)
	var current := _label("当前：%s" % _upgrade_effect_text(id, level), 9, MUTED)
	text_box.add_child(current)
	var buy := _make_button("", true, 92, 42)
	buy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if level >= max_level:
		buy.text = "已圆满"
		buy.disabled = true
	elif int(soul.get("points", 0)) < cost:
		buy.text = "%d 点" % cost
		buy.disabled = true
	else:
		buy.text = "点化\n%d 点" % cost
		buy.pressed.connect(_on_buy_upgrade.bind(id, from_death))
	row.add_child(buy)
	return card

func _upgrade_effect_text(id: String, level: int) -> String:
	match id:
		"insight": return "初始悟性 +%d" % (level * 7)
		"body": return "初始根骨 +%d" % (level * 7)
		"luck": return "初始气运 +%d" % (level * 6)
		"daoheart": return "初始道心 +%d" % (level * 7)
		"root": return "修炼速度 +%d%%" % (level * 8)
		"stones": return "初始灵石 +%d" % (level * 35)
		"lifespan": return "初始寿元 +%d" % (level * 8)
		"breakthrough": return "突破成算 +%d%%" % (level * 3)
		_: return "未知传承"

func _on_buy_upgrade(id: String, from_death: bool) -> void:
	var upgrade: Dictionary = {}
	for candidate: Dictionary in GameData.UPGRADES:
		if String(candidate["id"]) == id:
			upgrade = candidate
			break
	if upgrade.is_empty():
		return
	var upgrades: Dictionary = soul.get("upgrades", {})
	var level: int = int(upgrades.get(id, 0))
	if level >= int(upgrade["max"]):
		return
	var cost: int = GameData.upgrade_cost(upgrade, level)
	if int(soul.get("points", 0)) < cost:
		return
	soul["points"] = int(soul.get("points", 0)) - cost
	upgrades[id] = level + 1
	soul["upgrades"] = upgrades
	_save_soul()
	_refresh_menu()
	_open_upgrade_screen(from_death)

func _open_help() -> void:
	var box := _open_modal(Vector2(780, 0), true, Callable())
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	box.add_child(head)
	var head_box := VBoxContainer.new()
	head_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_box)
	head_box.add_child(_label("问 心", 34, INK, font_title))
	head_box.add_child(_label("天地不仁，而你仍要选择。", 12, INK_SOFT))
	head.add_child(_make_seal("道", 42, 20))
	box.add_child(_hairline())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(scroll)
	var content_box := VBoxContainer.new()
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	content_box.add_theme_constant_override("separation", 2)
	scroll.add_child(content_box)

	var sections: Array = [
		["行 止", "每一念皆过一年。打坐炼气积累修为；参悟道法提升悟性与道心；红尘历练有机会触发带选项的正式奇遇；寻敌斗法可主动开启战斗；吐纳疗伤可恢复伤势、磨炼根骨。点击「灵境」可调整全屏和窗口分辨率，F11 可快速切换。"],
		["破 境", "修为圆满后可冲击下一境，成算取决于悟性、道心、气运、伤势、境界与前世传承。冲关失败会折损修为、受伤，甚至缩短寿元。"],
		["因 果", "事件中的选择会改变因果、道心与遗物。善恶并无绝对的对错，但会写进此生的终章，也影响轮回结算。"],
		["法 器", "右侧三个法器位分别对应兵器、护符与心印。点击法器位或收藏中的物品即可佩带；每个位置限佩一件。法器提供的属性、突破成算、修炼速度与减伤加成都会计入实时数值。"],
		["轮 回", "身死或白日飞升后，按境界、年岁、因果与遗物结算轮回点。可在轮回殿中兑换宿慧、道骨、灵根等传承，下一世自动生效。白日飞升，是此游的尽头。"],
		["灵 材", "来源：%s用途：%s" % [MaterialSourceGuide.category_source_text("灵材", 1), MaterialSourceGuide.category_usage_text("灵材")]],
		["兽 元", "来源：%s用途：%s" % [MaterialSourceGuide.category_source_text("兽元", 1), MaterialSourceGuide.category_usage_text("兽元")]],
		["器 纹", "来源：%s用途：%s" % [MaterialSourceGuide.category_source_text("器纹", 1), MaterialSourceGuide.category_usage_text("器纹")]],
		["魂 煞", "来源：%s用途：%s" % [MaterialSourceGuide.category_source_text("魂煞", 1), MaterialSourceGuide.category_usage_text("魂煞")]],
		["沧 海", "来源：%s用途：%s持有的材料在「储物袋」中查看，炼丹炼器进入「丹器百工坊」。" % [MaterialSourceGuide.category_source_text("沧海", 1), MaterialSourceGuide.category_usage_text("沧海")]],
		["存 档", "每一次行动与抉择后都会自动保存。主菜单选择「前尘续梦」继续今生；游戏中的「轮回殿」可返回主菜单。"],
	]
	for section: Array in sections:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		content_box.add_child(row)
		var section_line := ColorRect.new()
		section_line.color = Color(CINNABAR.r, CINNABAR.g, CINNABAR.b, 0.52)
		section_line.custom_minimum_size = Vector2(2, 0)
		section_line.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row.add_child(section_line)
		var text_box := VBoxContainer.new()
		text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_box.add_theme_constant_override("separation", 2)
		row.add_child(text_box)
		text_box.add_child(_label(String(section[0]), 13, CINNABAR, font_title))
		var body := _label(String(section[1]), 12, INK_SOFT)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_box.add_child(body)
		content_box.add_child(_hairline())

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var footer_hint := _label("顺心意而行，不必求全。", 10, MUTED)
	footer_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(footer_hint)
	var back := _make_button("返回", false, 100, 40)
	back.pressed.connect(_close_modal)
	footer.add_child(back)
	var close := _make_button("知道了", true, 110, 40)
	close.pressed.connect(_close_modal)
	footer.add_child(close)

func _open_chronicle() -> void:
	var box := _open_modal(Vector2(880, 0), true, Callable())
	var head := HBoxContainer.new()
	box.add_child(head)
	var head_box := VBoxContainer.new()
	head_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_box)
	head_box.add_child(_label("尘 世 录", 34, INK, font_title))
	head_box.add_child(_label("前世如烟，唯余数行。", 12, INK_SOFT))
	var stats_box := VBoxContainer.new()
	stats_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(stats_box)
	var stat_label := _label("已历 %d 世 · 飞升 %d 次" % [int(soul.get("lives", 0)), int(soul.get("ascensions", 0))], 12, GOLD)
	stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_box.add_child(stat_label)
	var best_label := _label("最高境界 %s" % GameData.realm_name(int(soul.get("best_realm", 0))), 10, MUTED)
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_box.add_child(best_label)
	box.add_child(_hairline())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	var chronicle: Array = soul.get("chronicle", [])
	if chronicle.is_empty():
		var empty := _label("你尚未走完一世。\n去人间看看，回来时这里便会有你的名字。", 14, MUTED)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.custom_minimum_size = Vector2(0, 160)
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		list.add_child(empty)
	else:
		var ordered: Array = chronicle.duplicate()
		ordered.reverse()
		for entry: Dictionary in ordered:
			var row_panel := PanelContainer.new()
			row_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.958, 0.927, 0.862, 0.66), Color(0.66, 0.57, 0.42, 0.18), 4, 1))
			list.add_child(row_panel)
			var row_margin := MarginContainer.new()
			row_margin.add_theme_constant_override("margin_left", 13)
			row_margin.add_theme_constant_override("margin_right", 13)
			row_margin.add_theme_constant_override("margin_top", 8)
			row_margin.add_theme_constant_override("margin_bottom", 7)
			row_panel.add_child(row_margin)
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 12)
			row_margin.add_child(row)
			var life_no := _label("第 %d 世" % int(entry.get("life", 0)), 10, CINNABAR, font_title)
			life_no.custom_minimum_size = Vector2(48, 0)
			row.add_child(life_no)
			var info_box := VBoxContainer.new()
			info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			info_box.add_theme_constant_override("separation", 0)
			row.add_child(info_box)
			var name_line := HBoxContainer.new()
			info_box.add_child(name_line)
			name_line.add_child(_label(String(entry.get("name", "无名")), 16, INK, font_title))
			var name_spacer := Control.new()
			name_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_line.add_child(name_spacer)
			var realm_label := _label(String(entry.get("realm_name", GameData.realm_name(int(entry.get("realm", 0))))), 11, INK_SOFT)
			name_line.add_child(realm_label)
			var cause: String = String(entry.get("cause", ""))
			var asc: bool = bool(entry.get("ascended", false))
			var sub_text := "享年 %d 岁 · %s · %s" % [int(entry.get("age", 0)), String(entry.get("karma_title", "")), cause]
			if asc:
				sub_text = "飞升 · %s · 大道圆满" % String(entry.get("realm_name", ""))
			info_box.add_child(_label(sub_text, 10, MUTED))
			var points_label := _label("+%d 道果" % int(entry.get("points", 0)), 10, GOLD)
			points_label.custom_minimum_size = Vector2(58, 0)
			points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			row.add_child(points_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(footer)
	var back := _make_button("返回", false, 110, 40)
	back.pressed.connect(_close_modal)
	footer.add_child(back)

# ---------------------------------------------------------------------------
# 模态框
# ---------------------------------------------------------------------------

func _open_modal(min_size: Vector2, dismissible: bool, on_close: Callable) -> VBoxContainer:
	_clear_modal(false)
	modal_root.visible = true
	modal_open = true
	modal_dismissible = dismissible
	modal_on_close = on_close

	var shade := ColorRect.new()
	shade.color = Color(0.075, 0.060, 0.043, 0.62)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var outer := MarginContainer.new()
	modal_root.add_child(outer)
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 36)
	outer.add_theme_constant_override("margin_right", 36)
	outer.add_theme_constant_override("margin_top", 30)
	outer.add_theme_constant_override("margin_bottom", 30)
	var center := CenterContainer.new()
	outer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.976, 0.949, 0.891, 0.985), Color(0.58, 0.46, 0.28, 0.54), 8, 2, true))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	margin.add_child(box)

	# 所有弹窗统一保持不透明：分类切换、机缘弹窗与机缘结果弹窗
	# 会在同一帧内重建内容；对整个 modal_root 做 0->1 淡入会造成明显闪屏。
	# 取消整层透明度动画，避免每次切换页面时短暂闪烁。
	modal_root.modulate = Color(1, 1, 1, 1)
	modal_instant_open = false
	return box

func _clear_modal(notify: bool) -> void :
	if modal_root == null:
		return
	modal_root.visible = false
	for child: Node in modal_root.get_children():
		modal_root.remove_child(child)
		child.queue_free()
	modal_open = false
	modal_dismissible = false
	var callback: Callable = modal_on_close
	modal_on_close = Callable()
	
	if notify and callback.is_valid():
		callback.call()
		
	# 【新增的修复代码】
	if notify and ui_mode == "game" and state != null and state.alive:
		_refresh_action_cards()
		_refresh_breakthrough_button()

func _close_modal() -> void:
	_clear_modal(true)

func _add_modal_heading(box: VBoxContainer, kicker_text: String, title_text: String, subtitle: String) -> void:
	box.add_child(_label(kicker_text, 11, CINNABAR))
	box.add_child(_label(title_text, 34, INK, font_title))
	var sub := _label(subtitle, 13, INK_SOFT)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(sub)
	box.add_child(_hairline())

# ---------------------------------------------------------------------------
# 通用控件
# ---------------------------------------------------------------------------

func _label(text: String, font_size: int = 16, color: Color = INK, font: Font = null) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if font != null:
		label.add_theme_font_override("font", font)
	return label

func _rich_label(text: String, font_size: int = 15, color: Color = INK, line_spacing: int = 4) -> RichTextLabel:
	var rich := RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.scroll_active = false
	rich.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rich.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rich.add_theme_font_override("normal_font", font_body)
	rich.add_theme_font_size_override("normal_font_size", font_size)
	rich.add_theme_constant_override("line_separation", line_spacing)
	rich.add_theme_color_override("default_color", color)
	rich.text = text
	return rich

func _make_seal(text: String, size: int = 38, font_size: int = 18) -> PanelContainer:
	var seal := PanelContainer.new()
	seal.custom_minimum_size = Vector2(size, size)
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	seal.add_theme_stylebox_override("panel", _panel_style(CINNABAR, Color(0.42, 0.13, 0.09, 0.72), 3, 1))
	var label := _label(text, font_size, WARM_WHITE, font_title)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	seal.add_child(label)
	return seal

func _make_tag(text: String, color: Color, font_size: int = 10) -> PanelContainer:
	var tag := PanelContainer.new()
	var style := _panel_style(Color(color.r, color.g, color.b, 0.09), Color(color.r, color.g, color.b, 0.22), 3, 1)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	tag.add_theme_stylebox_override("panel", style)
	var label := _label(text, font_size, color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tag.add_child(label)
	return tag

func _hairline() -> ColorRect:
	var line := ColorRect.new()
	line.color = Color(0.48, 0.41, 0.31, 0.17)
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line

func _panel_style(bg: Color, border: Color, radius: int, border_width: int = 1, shadow: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	if shadow:
		style.shadow_color = Color(0.12, 0.09, 0.06, 0.16)
		style.shadow_size = 14
		style.shadow_offset = Vector2(0, 5)
	return style

func _card_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := _panel_style(bg, border, 5, 1)
	return style

func _make_button(text: String, primary: bool = false, width: int = 0, height: int = 42) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, height)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", font_body)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if primary:
		button.add_theme_stylebox_override("normal", _panel_style(CINNABAR, Color(0.43, 0.14, 0.10, 0.8), 4, 1))
		button.add_theme_stylebox_override("hover", _panel_style(CINNABAR_DARK, Color(0.35, 0.10, 0.07, 0.9), 4, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color(0.40, 0.13, 0.09, 1.0), Color(0.33, 0.10, 0.07, 0.9), 4, 1))
		button.add_theme_color_override("font_color", WARM_WHITE)
		button.add_theme_color_override("font_hover_color", WARM_WHITE)
		button.add_theme_color_override("font_pressed_color", WARM_WHITE)
	else:
		button.add_theme_stylebox_override("normal", _panel_style(Color(0.92, 0.88, 0.79, 0.60), Color(0.64, 0.55, 0.39, 0.32), 4, 1))
		button.add_theme_stylebox_override("hover", _panel_style(Color(0.98, 0.95, 0.88, 0.95), Color(0.61, 0.50, 0.32, 0.48), 4, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color(0.88, 0.84, 0.75, 0.9), Color(0.61, 0.50, 0.32, 0.48), 4, 1))
		button.add_theme_color_override("font_color", INK_SOFT)
		button.add_theme_color_override("font_hover_color", INK)
		button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_disabled_color", Color(MUTED.r, MUTED.g, MUTED.b, 0.8))
	return button

func _make_text_button(text: String, font_size: int = 13) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", font_body)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK_SOFT)
	button.add_theme_color_override("font_hover_color", CINNABAR)
	button.add_theme_color_override("font_pressed_color", CINNABAR)
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("focus", empty)
	return button

# ---------------------------------------------------------------------------
# 存档
# ---------------------------------------------------------------------------

func _default_soul() -> Dictionary:
	var upgrades: Dictionary = {}
	for upgrade: Dictionary in GameData.UPGRADES:
		upgrades[String(upgrade["id"])] = 0
	return {
		"points": 0,
		"lives": 0,
		"best_realm": 0,
		"ascensions": 0,
		"upgrades": upgrades,
		"chronicle": [],
	}

func _load_soul() -> void:
	soul = _default_soul()
	if not FileAccess.file_exists(SAVE_SOUL):
		return
	var file := FileAccess.open(SAVE_SOUL, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	soul["points"] = maxi(0, int(data.get("points", 0)))
	soul["lives"] = maxi(0, int(data.get("lives", 0)))
	soul["best_realm"] = clampi(int(data.get("best_realm", 0)), 0, GameData.REALMS.size() - 1)
	soul["ascensions"] = maxi(0, int(data.get("ascensions", 0)))
	var upgrades: Dictionary = soul["upgrades"]
	if data.get("upgrades") is Dictionary:
		var loaded_upgrades: Dictionary = data["upgrades"]
		for upgrade: Dictionary in GameData.UPGRADES:
			var id: String = String(upgrade["id"])
			upgrades[id] = clampi(int(loaded_upgrades.get(id, 0)), 0, int(upgrade["max"]))
	soul["upgrades"] = upgrades
	if data.get("chronicle") is Array:
		soul["chronicle"] = Array(data["chronicle"]).duplicate(true)
	else:
		soul["chronicle"] = []

func _save_soul() -> void:
	var file := FileAccess.open(SAVE_SOUL, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(soul, "\t"))

func _save_run() -> void:
	if state == null or not state.alive:
		return
	var file := FileAccess.open(SAVE_RUN, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(state.to_dict(), "\t"))

func _load_run() -> bool:
	if not FileAccess.file_exists(SAVE_RUN):
		return false
	var file := FileAccess.open(SAVE_RUN, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_delete_run()
		return false
	var data: Dictionary = parsed
	var loaded := GameState.from_dict(data)
	if not loaded.alive:
		_delete_run()
		return false
	state = loaded
	state.death_handled = false
	current_life_number = int(soul.get("lives", 0)) + 1
	return true

func _delete_run() -> void:
	if FileAccess.file_exists(SAVE_RUN):
		var dir := DirAccess.open("user://")
		if dir != null:
			dir.remove("run_save.json")

func _has_run_save() -> bool:
	return FileAccess.file_exists(SAVE_RUN)

func _on_menu_upgrades() -> void:
	_open_upgrade_screen(false)

func _on_menu_chronicle() -> void:
	_open_chronicle()

func _on_quit() -> void:
	if state != null and state.alive:
		_save_run()
	_save_soul()
	get_tree().quit()

# ---------------------------------------------------------------------------
# 小工具
# ---------------------------------------------------------------------------

func _strip_bbcode(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\[[^\\]]*\\]")
	var plain := regex.sub(text, "", true)
	return plain

func _formal_number(value: int) -> String:
	var numerals: Array = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"]
	if value >= 0 and value < numerals.size():
		return String(numerals[value])
	return str(value)

func _cn_number(value: int) -> String:
	var number: int = maxi(0, value)
	if number < 10:
		return ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"][number]
	if number < 20:
		return "十" + ("" if number == 10 else ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"][number - 10])
	if number < 100:
		var tens: int = int(number / 10.0)
		var ones: int = number % 10
		return ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"][tens] + "十" + ("" if ones == 0 else ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"][ones])
	if number < 1000:
		var hundreds: int = int(number / 100.0)
		var remainder: int = number % 100
		var result: String = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"][hundreds] + "百"
		if remainder == 0:
			return result
		if remainder < 10:
			return result + "零" + _cn_number(remainder)
		return result + _cn_number(remainder)
	var thousands: int = int(number / 1000.0)
	var rest: int = number % 1000
	var result2: String = _cn_number(thousands) + "千"
	if rest == 0:
		return result2
	if rest < 100:
		return result2 + "零" + _cn_number(rest)
	return result2 + _cn_number(rest)
func _show_clear_save_confirm() -> void :
	var box: = _open_modal(Vector2(560, 300), true, Callable())
	_add_modal_heading(box, "天机不可泄露", "斩断因果？", "此举将彻底抹去你所有的轮回点、前世记忆与今生修为。一旦斩断，再无回头之路。是否确定？")
	var spacer: = Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	box.add_child(spacer)
	var buttons: = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(buttons)
	var cancel: = _make_button("三思而行", false, 120)
	cancel.pressed.connect(_close_modal)
	buttons.add_child(cancel)
	var confirm: = _make_button("斩断因果", true, 140)
	confirm.pressed.connect(_on_confirm_clear_save)
	buttons.add_child(confirm)

func _on_confirm_clear_save() -> void :
	_clear_modal(false)
	# 1. 删除今生存档
	_delete_run()
	# 2. 删除前世存档
	if FileAccess.file_exists(SAVE_SOUL):
		var dir: = DirAccess.open("user://")
		if dir != null:
			dir.remove("soul_save.json")
	# 3. 重置内存数据
	soul = _default_soul()
	state = null
	# 4. 刷新主菜单
	_refresh_menu()
	
	# 5. 给个反馈提示
	var box: = _open_modal(Vector2(400, 0), true, Callable())
	_add_modal_heading(box, "万事皆空", "因果已断", "你已忘却所有前世今生，天地间重归寂静。")
	var btn_row: = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(btn_row)
	var ok_btn: = _make_button("踏入虚无", true, 120)
	ok_btn.pressed.connect(_close_modal)
	btn_row.add_child(ok_btn)
