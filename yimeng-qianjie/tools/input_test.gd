extends SceneTree

## 用真实鼠标事件验证按钮命中（防止子控件遮挡按钮）。

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if ok:
		printerr("  ok  ", message)
	else:
		failures += 1
		printerr("  FAIL  ", message)

func _run() -> void:
	if OS.get_environment("DSH_GAME_TEST") != "1":
		printerr("请设置 DSH_GAME_TEST=1 并使用独立用户目录。")
		quit(1)
		return
	printerr("INPUT_TEST_START")
	create_timer(12.0).timeout.connect(func() -> void:
		printerr("INPUT_TEST_TIMEOUT")
		quit(2)
	)
	var packed: PackedScene = load("res://scenes/main.tscn")
	var scene: Control = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.soul = scene._default_soul()
	scene._save_soul()
	scene._delete_run()
	scene._refresh_menu()
	await process_frame
	await process_frame

	printerr("CLICK_MENU")
	await _click_control(scene.new_life_button)
	await process_frame
	await process_frame
	_check(scene.ui_mode == "game", "鼠标点击主菜单按钮可进入游戏")
	_check(scene.modal_open, "进入游戏后弹出转生介绍")
	if scene.modal_open:
		scene._close_modal()
	await process_frame
	if scene.state == null:
		printerr("游戏状态为空，无法继续输入测试。")
		quit(1)
		return

	var age_before: int = scene.state.age
	printerr("CLICK_ACTION viewport=", root.size, " card=", scene.action_cards[GameState.ACTION_CULTIVATE].get_global_rect())
	await _click_control(scene.action_cards[GameState.ACTION_CULTIVATE])
	await process_frame
	await process_frame
	_check(scene.state.age == age_before + 1, "鼠标点击行动卡可推进一年")
	if scene.modal_open:
		scene._clear_modal(false)
	await process_frame
	if not scene.state.treasures.has("无名玉简"):
		scene.state.treasures.append("无名玉简")
		scene.state.treasure_ages["无名玉简"] = scene.state.age
	scene._refresh_game_ui()
	await process_frame
	await process_frame
	var item_buttons: Array = []
	_collect_buttons(scene.treasure_flow, item_buttons)
	_check(not item_buttons.is_empty(), "遗物标签可点击")
	if not item_buttons.is_empty():
		var age_before_item: int = scene.state.age
		await _click_control(item_buttons[0])
		await process_frame
		await process_frame
		_check(scene.modal_open, "鼠标点击遗物可打开详情")
		_check(scene.state.age == age_before_item, "查看遗物不消耗时间")
		var detail_buttons: Array = []
		_collect_buttons(scene.modal_root, detail_buttons)
		var equip_button: Button = null
		for candidate: Button in detail_buttons:
			if candidate.text.begins_with("佩带于"):
				equip_button = candidate
				break
		_check(equip_button != null, "遗物详情有佩带按钮")
		if equip_button != null:
			var base_insight: int = scene.state.insight
			await _click_control(equip_button)
			await process_frame
			await process_frame
			_check(scene.state.is_equipped("无名玉简"), "鼠标点击可佩带法器")
			_check(scene.state.effective_stat("insight") > base_insight, "佩带后悟性加成生效")
			_check(scene.modal_open, "佩带后详情自动刷新")
			scene._close_modal()
			await process_frame
		await _click_control(scene.equipment_slot_widgets["heart"]["button"])
		await process_frame
		await process_frame
		_check(scene.modal_open, "鼠标点击法器位可打开佩带窗")
		scene._close_modal()
		await process_frame

	scene._open_event(EventData.EVENTS[0])
	await process_frame
	await process_frame
	printerr("CLICK_CHOICE")
	var choice_buttons: Array = []
	_collect_buttons(scene.modal_root, choice_buttons)
	_check(not choice_buttons.is_empty(), "事件选项按钮存在")
	if not choice_buttons.is_empty():
		await _click_control(choice_buttons[0])
		await process_frame
		await process_frame
		_check(scene.state.seen_events.has("old_beggar"), "鼠标点击事件选项可结算事件")
		_check(scene.modal_open, "事件结算后显示结果")
	scene._clear_modal(false)
	scene.queue_free()
	await process_frame
	if failures == 0:
		print("INPUT TESTS PASSED")
	quit(0 if failures == 0 else 1)

func _collect_buttons(node: Node, into: Array) -> void:
	for child: Node in node.get_children():
		if child is Button and child.visible and not child.disabled:
			into.append(child)
		_collect_buttons(child, into)

func _click_control(control: Control) -> void:
	var pos: Vector2 = control.get_global_rect().get_center()
	printerr("  click at ", pos, " rect=", control.get_global_rect())
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	root.push_input(motion, true)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	press.pressed = true
	press.position = pos
	press.global_position = pos
	root.push_input(press, true)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.button_mask = 0
	release.pressed = false
	release.position = pos
	release.global_position = pos
	root.push_input(release, true)
	await process_frame
