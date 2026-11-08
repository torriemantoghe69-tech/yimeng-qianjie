extends SceneTree

## 性能测量：帧时间分布、UI 刷新耗时、绘制调用数。
## 仅用于开发验收，会重写测试档案。

var scene: Control
var recording: bool = false
var samples: Array[float] = []
var last_us: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if OS.get_environment("DSH_GAME_TEST") != "1":
		printerr("请设置 DSH_GAME_TEST=1 并使用独立用户目录。")
		quit(1)
		return
	process_frame.connect(_on_frame)
	var packed: PackedScene = load("res://scenes/main.tscn")
	scene = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.soul = scene._default_soul()
	scene._save_soul()
	scene._delete_run()
	scene._refresh_menu()
	await process_frame
	await process_frame

	await _measure_idle("主菜单静置", 3.0)
	scene._start_new_life()
	await process_frame
	await process_frame
	scene._close_modal()
	await process_frame
	await _measure_idle("游戏界面静置", 3.0)

	var t0: int = Time.get_ticks_usec()
	for i: int in range(40):
		scene._refresh_game_ui()
	var refresh_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0 / 40.0
	print("REFRESH_EMPTY_LOG_MS=", refresh_ms)

	var open_times: Array[float] = []
	for i: int in range(6):
		t0 = Time.get_ticks_usec()
		scene._open_treasure_detail("天外星石")
		open_times.append(float(Time.get_ticks_usec() - t0) / 1000.0)
		await process_frame
		await process_frame
		scene._clear_modal(false)
		await process_frame
	print("OPEN_DETAIL_EACH_MS=", open_times)
	print("OPEN_DETAIL_MS avg=", _avg(open_times), " min=", open_times.min(), " max=", open_times.max())
	scene._clear_modal(false)

	for i: int in range(96):
		scene.state.add_log("这是用于性能测量的模拟行迹。山风穿过洞府，灵气如潮，你听见远处有鹤唳。", "action")
	t0 = Time.get_ticks_usec()
	for i: int in range(30):
		scene._refresh_game_ui()
	var refresh_big_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0 / 30.0
	print("REFRESH_100_LOG_MS=", refresh_big_ms)

	for i: int in range(150):
		scene.state.add_log("第二段模拟日志，用来测试长日志下的渲染与重排开销。", "action")
	t0 = Time.get_ticks_usec()
	for i: int in range(20):
		scene._refresh_game_ui()
	var refresh_huge_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0 / 20.0
	print("REFRESH_250_LOG_MS=", refresh_huge_ms)

	await process_frame
	await _measure_idle("长时间后游戏静置", 2.0)
	print("CURRENT_FPS=", Performance.get_monitor(Performance.TIME_FPS))
	print("DRAW_CALLS=", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	print("OBJECTS=", Performance.get_monitor(Performance.OBJECT_COUNT))

	scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)

func _avg(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / maxf(1.0, float(values.size()))

func _on_frame() -> void:
	var now: int = Time.get_ticks_usec()
	if recording and last_us > 0:
		samples.append(float(now - last_us) / 1000.0)
	last_us = now

func _measure_idle(label: String, duration: float) -> void:
	await process_frame
	samples.clear()
	recording = true
	await create_timer(duration).timeout
	recording = false
	samples.sort()
	if samples.is_empty():
		return
	var total: float = 0.0
	for value: float in samples:
		total += value
	var p50: float = samples[int(samples.size() * 0.50)]
	var p95: float = samples[int(samples.size() * 0.95)]
	var p99: float = samples[int(samples.size() * 0.99)]
	var avg: float = total / samples.size()
	print("%s: avg=%.2fms p50=%.2f p95=%.2f p99=%.2f max=%.2f frames=%d" % [label, avg, p50, p95, p99, samples[-1], samples.size()])
