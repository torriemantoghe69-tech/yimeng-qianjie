class_name InkBackground
extends Control

## 用代码绘制的宣纸、远山、云、雾与飞尘，不依赖任何外部美术素材。
## 山体完全静止；云与水面缓慢漂移，保持文字游戏界面流畅。

var _time: float = 0.0
var _motes: Array = []
var _clouds: Array = []
var _rng := RandomNumberGenerator.new()
var _paper_texture: GradientTexture2D
var _grain_texture: ImageTexture
var _triangle_checks: Dictionary = {}

const PAPER_TOP := Color("#ede5d4")
const PAPER_BOTTOM := Color("#ccd4c7")
const INK_FAR := Color(0.19, 0.25, 0.23, 0.10)
const INK_MID := Color(0.17, 0.23, 0.21, 0.16)
const INK_NEAR := Color(0.12, 0.17, 0.15, 0.30)
const CINNABAR := Color("#a84432")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	_rng.seed = 20261031
	_build_paper_textures()
	_build_clouds()
	for i: int in range(20):
		_motes.append({
			"x": _rng.randf(),
			"y": _rng.randf(),
			"size": _rng.randf_range(0.8, 2.6),
			"speed": _rng.randf_range(0.004, 0.018),
			"phase": _rng.randf_range(0.0, TAU),
			"red": _rng.randf() < 0.2,
			"alpha": _rng.randf_range(0.16, 0.44),
		})

func _build_clouds() -> void:
	# 预生成几层云，位置与速度固定，只随时间平移。
	_clouds.clear()
	var presets: Array = [
		{"y": 0.12, "w": 0.42, "h": 0.055, "speed": 0.008, "alpha": 0.11, "phase": 0.0},
		{"y": 0.18, "w": 0.55, "h": 0.045, "speed": 0.012, "alpha": 0.09, "phase": 1.7},
		{"y": 0.26, "w": 0.38, "h": 0.040, "speed": 0.006, "alpha": 0.08, "phase": 3.2},
		{"y": 0.33, "w": 0.48, "h": 0.038, "speed": 0.010, "alpha": 0.07, "phase": 4.8},
		{"y": 0.41, "w": 0.35, "h": 0.032, "speed": 0.014, "alpha": 0.06, "phase": 2.1},
		{"y": 0.48, "w": 0.50, "h": 0.028, "speed": 0.007, "alpha": 0.05, "phase": 5.5},
	]
	for p: Dictionary in presets:
		_clouds.append({
			"y": float(p["y"]),
			"w": float(p["w"]),
			"h": float(p["h"]),
			"speed": float(p["speed"]),
			"alpha": float(p["alpha"]),
			"phase": float(p["phase"]),
			"x0": _rng.randf(),
		})

func _build_paper_textures() -> void:
	# 纵向宣纸渐变：一张 8×256 的渐变纹理拉伸覆盖全屏。
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.58, 1.0])
	gradient.colors = PackedColorArray([
		PAPER_TOP,
		Color(0.890, 0.883, 0.820, 1.0),
		PAPER_BOTTOM,
	])
	_paper_texture = GradientTexture2D.new()
	_paper_texture.gradient = gradient
	_paper_texture.width = 8
	_paper_texture.height = 256
	_paper_texture.fill_from = Vector2(0.0, 0.0)
	_paper_texture.fill_to = Vector2(0.0, 1.0)

	# 纸纹预先烘成一张纹理，避免每帧绘制上百个小圆点。
	var grain_image := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	grain_image.fill(Color(0, 0, 0, 0))
	for i: int in range(2600):
		var x: int = _rng.randi_range(0, 511)
		var y: int = _rng.randi_range(0, 511)
		var alpha: float = _rng.randf_range(0.012, 0.040)
		grain_image.set_pixel(x, y, Color(0.25, 0.20, 0.14, alpha))
	for i: int in range(110):
		var y: int = _rng.randi_range(0, 511)
		var x: int = _rng.randi_range(0, 511)
		var length: int = _rng.randi_range(8, 34)
		var alpha: float = _rng.randf_range(0.008, 0.020)
		for j: int in range(length):
			grain_image.set_pixel((x + j) % 512, y, Color(0.30, 0.24, 0.17, alpha))
	_grain_texture = ImageTexture.create_from_image(grain_image)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var view: Vector2 = size
	if view.x <= 1.0 or view.y <= 1.0:
		return

	# 宣纸底色与纸纹：各一次纹理绘制。
	if _paper_texture != null:
		draw_texture_rect(_paper_texture, Rect2(Vector2.ZERO, view), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, view), PAPER_TOP)
	if _grain_texture != null:
		draw_texture_rect(_grain_texture, Rect2(Vector2.ZERO, view), false, Color(1.0, 1.0, 1.0, 0.82))

	# 月上东山：保留光晕与月面，减少叠加圆的数量。
	var sun_pos := Vector2(view.x * 0.80, view.y * 0.20)
	draw_circle(sun_pos, 82.0, Color(0.64, 0.35, 0.24, 0.045))
	draw_circle(sun_pos, 43.0, Color(0.68, 0.35, 0.23, 0.16))
	draw_circle(sun_pos, 39.0, Color(0.84, 0.62, 0.43, 0.09))

	# 云带：多层缓慢横向飘动（山保持静止）。
	_draw_clouds(view)

	# 雾带：两团缓慢漂移的淡雾。
	var mist_shift: float = sin(_time * 0.09) * 30.0
	draw_circle(Vector2(view.x * 0.27 + mist_shift, view.y * 0.53), view.x * 0.30, Color(0.94, 0.94, 0.88, 0.065))
	draw_circle(Vector2(view.x * 0.68 - mist_shift * 0.7, view.y * 0.64), view.x * 0.35, Color(0.94, 0.94, 0.88, 0.055))

	# 三重远山（完全静止，不随时间变化）。
	_draw_mountain(view, 0.735, 0.075, 1.2, INK_FAR)
	_draw_mountain(view, 0.800, 0.105, 4.4, INK_MID)
	_draw_mountain(view, 0.885, 0.135, 2.1, INK_NEAR)

	# 山脚淡墨与动态水面。
	_draw_water(view)

	# 飞尘 / 落英。
	for mote: Dictionary in _motes:
		var mx: float = fposmod(float(mote["x"]) * view.x + _time * 9.0 * float(mote["speed"]) * 100.0 + sin(_time * 0.35 + float(mote["phase"])) * 22.0, view.x + 80.0) - 40.0
		var my: float = fposmod(float(mote["y"]) * view.y + _time * float(mote["speed"]) * 38.0, view.y + 40.0) - 20.0
		var col: Color = CINNABAR if bool(mote["red"]) else Color(0.20, 0.24, 0.21)
		col.a = float(mote["alpha"]) * (0.65 + 0.35 * sin(_time * 0.8 + float(mote["phase"])))
		if bool(mote["red"]):
			var p := Vector2(mx, my)
			var d := Vector2(cos(float(mote["phase"]) + _time * 0.15), sin(float(mote["phase"]) + _time * 0.15)) * 3.2
			draw_line(p - d, p + d, col, 1.4)
		else:
			draw_circle(Vector2(mx, my), float(mote["size"]), col)

	# 内框，像旧书页的边。
	draw_rect(Rect2(18.0, 18.0, view.x - 36.0, view.y - 36.0), Color(0.30, 0.25, 0.18, 0.10), false, 1.0)
	draw_rect(Rect2(23.0, 23.0, view.x - 46.0, view.y - 46.0), Color(0.30, 0.25, 0.18, 0.05), false, 1.0)

func _draw_clouds(view: Vector2) -> void:
	for cloud: Dictionary in _clouds:
		var cy: float = view.y * float(cloud["y"])
		var cw: float = view.x * float(cloud["w"])
		var ch: float = view.y * float(cloud["h"])
		var speed: float = float(cloud["speed"])
		var alpha: float = float(cloud["alpha"])
		var phase: float = float(cloud["phase"])
		var x0: float = float(cloud["x0"])

		# 水平循环漂移
		var cx: float = fposmod(x0 * view.x + _time * speed * view.x * 0.35 + sin(_time * 0.12 + phase) * 12.0, view.x + cw) - cw * 0.5

		var col := Color(0.96, 0.95, 0.90, alpha)
		var soft := Color(0.96, 0.95, 0.90, alpha * 0.55)

		# 用几个椭圆叠成一朵云
		draw_circle(Vector2(cx, cy), ch * 1.1, soft)
		draw_circle(Vector2(cx + cw * 0.22, cy - ch * 0.15), ch * 1.35, col)
		draw_circle(Vector2(cx + cw * 0.45, cy + ch * 0.08), ch * 1.15, soft)
		draw_circle(Vector2(cx + cw * 0.68, cy - ch * 0.10), ch * 1.25, col)
		draw_circle(Vector2(cx + cw * 0.88, cy + ch * 0.05), ch * 0.95, soft)

func _draw_water(view: Vector2) -> void:
	# 山脚淡墨水域
	draw_rect(Rect2(0.0, view.y * 0.92, view.x, view.y * 0.08), Color(0.12, 0.17, 0.15, 0.20))

	# 动态波纹线（左右缓慢错位）
	for i: int in range(6):
		var y: float = view.y * (0.925 + i * 0.011)
		var shift: float = sin(_time * 0.28 + i * 0.9) * (14.0 + i * 2.0)
		var alpha: float = 0.14 - i * 0.015
		var col := Color(0.90, 0.91, 0.85, alpha)
		draw_line(Vector2(view.x * 0.05 + shift, y), Vector2(view.x * 0.48 + shift, y), col, 1.0)
		draw_line(Vector2(view.x * 0.52 - shift * 0.8, y + 2.5), Vector2(view.x * 0.96 - shift * 0.8, y + 2.5), col, 1.0)

	# 几道更柔和的反光带
	for i: int in range(3):
		var y: float = view.y * (0.935 + i * 0.018)
		var shift: float = cos(_time * 0.18 + i * 1.3) * 22.0
		var col := Color(0.93, 0.94, 0.88, 0.07 - i * 0.015)
		draw_line(Vector2(view.x * 0.15 + shift, y), Vector2(view.x * 0.55 + shift, y), col, 2.0)

func _draw_mountain(view: Vector2, base_ratio: float, height_ratio: float, phase: float, color: Color) -> void:
	var steps: int = 72
	var ridge_line := PackedVector2Array()
	var points := PackedVector2Array()
	points.append(Vector2(0.0, view.y))
	for i: int in range(steps + 1):
		var t: float = float(i) / float(steps)
		var x: float = t * view.x
		var ridge: float = 0.0
		ridge += sin(t * TAU * 1.15 + phase) * 0.52
		ridge += sin(t * TAU * 2.7 + phase * 1.9) * 0.25
		ridge += sin(t * TAU * 5.4 + phase * 2.4) * 0.10
		ridge += sin(t * TAU * 11.0 + phase) * 0.035
		var y: float = view.y * base_ratio - ridge * view.y * height_ratio
		points.append(Vector2(x, y))
		ridge_line.append(Vector2(x, y))
	points.append(Vector2(view.x, view.y))

	# 正常渲染时用单个多边形，一次绘制整层山；headless 或无三角化能力的
	# 情况退回分条填充，避免渲染器报错。
	var key: String = "%.3f" % phase
	if not _triangle_checks.has(key):
		_triangle_checks[key] = not Geometry2D.triangulate_polygon(points).is_empty()
	if DisplayServer.get_name() != "headless" and bool(_triangle_checks[key]):
		draw_colored_polygon(points, color)
	else:
		for i: int in range(steps):
			var left: Vector2 = points[i + 1]
			var right: Vector2 = points[i + 2]
			if absf(right.x - left.x) < 0.001:
				continue
			draw_colored_polygon(PackedVector2Array([
				left,
				right,
				Vector2(right.x, view.y + 1.0),
				Vector2(left.x, view.y + 1.0),
			]), color)

	# 在山脊上补一层极淡的轮廓，像干墨。
	if color.a > 0.12:
		draw_polyline(ridge_line, Color(0.10, 0.14, 0.12, color.a * 0.30), 1.2, true)
