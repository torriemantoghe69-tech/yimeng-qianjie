class_name MusicManager
extends Node

## 场景音乐管理：双播放器交叉淡入淡出，四套无缝循环。
## 音频由 tools/make_music.py 纯代码合成，不含外部采样。

signal track_changed(key: String, title: String)

const TRACKS := {
	"menu": preload("res://assets/audio/menu_theme.wav"),
	"cultivation": preload("res://assets/audio/cultivation_theme.wav"),
	"event": preload("res://assets/audio/event_theme.wav"),
	"ending": preload("res://assets/audio/ending_theme.wav"),
}

const TRACK_NAMES := {
	"menu": "轮回之门",
	"cultivation": "云山静修",
	"event": "红尘机缘",
	"ending": "此身终章",
}

const TRACK_CONTEXTS := {
	"menu": "主菜单 · 轮回殿 · 尘世录",
	"cultivation": "修行 · 游历 · 日常",
	"event": "机缘与劫数",
	"ending": "身死 · 飞升",
}

var _players: Array[AudioStreamPlayer] = []
var _active: AudioStreamPlayer
var _streams: Dictionary = {}
var _current_key: String = ""
var _enabled: bool = true
var _volume: float = 0.35
var _fade_tween: Tween
var _stop_tween: Tween

func _ready() -> void:
	for i: int in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "MusicVoice%d" % (i + 1)
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_players.append(player)
	_prepare_streams()

func _prepare_streams() -> void:
	for key: Variant in TRACKS.keys():
		var source: AudioStream = TRACKS[key]
		if source is AudioStreamWAV:
			var wav := (source as AudioStreamWAV).duplicate() as AudioStreamWAV
			wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav.loop_begin = 0
			var frames: int = int(round(wav.get_length() * float(wav.mix_rate)))
			if frames > 0:
				wav.loop_end = frames
			_streams[String(key)] = wav
		else:
			_streams[String(key)] = source

func play_track(key: String, fade: float = 1.2) -> void:
	if not TRACKS.has(key):
		return
	_current_key = key
	if not _enabled:
		return
	if _active != null and _active.playing and _current_key == key and not _needs_restart(key):
		return
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	if _stop_tween != null and _stop_tween.is_valid():
		_stop_tween.kill()

	var old: AudioStreamPlayer = _active
	var next: AudioStreamPlayer = _players[0]
	if _players.size() > 1 and _active == _players[0]:
		next = _players[1]
	if next.playing:
		next.stop()
	next.stream = _streams.get(key)
	if next.stream == null:
		return
	next.volume_db = -60.0
	next.play()
	_active = next

	var target: float = _target_db()
	if old != null and old != next and old.playing:
		_fade_tween = create_tween().set_parallel(true)
		_fade_tween.tween_property(old, "volume_db", -60.0, maxf(0.01, fade)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_fade_tween.tween_property(next, "volume_db", target, maxf(0.01, fade)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_fade_tween.chain().tween_callback(old.stop)
	else:
		_fade_tween = create_tween()
		_fade_tween.tween_property(next, "volume_db", target, maxf(0.05, minf(fade, 1.5))).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	emit_signal("track_changed", key, String(TRACK_NAMES.get(key, "无名曲")))

func _needs_restart(key: String) -> bool:
	return _active == null or _active.stream != _streams.get(key)

func set_enabled(value: bool) -> void:
	if _enabled == value:
		if value and _active == null and not _current_key.is_empty():
			play_track(_current_key, 0.8)
		return
	_enabled = value
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	if _stop_tween != null and _stop_tween.is_valid():
		_stop_tween.kill()
	if not _enabled:
		_stop_all(0.7)
	else:
		_stop_all(0.01)
		if not _current_key.is_empty():
			play_track(_current_key, 0.9)

func set_volume(value: float) -> void:
	_volume = clampf(value, 0.0, 1.0)
	if _active != null and _enabled:
		_active.volume_db = _target_db()

func _target_db() -> float:
	return linear_to_db(maxf(_volume, 0.001)) - 6.0

func _stop_all(fade: float) -> void:
	var target := -60.0
	var has_playing: bool = false
	for player: AudioStreamPlayer in _players:
		if player.playing:
			has_playing = true
			break
	if has_playing and fade > 0.02:
		_stop_tween = create_tween().set_parallel(true)
		for player: AudioStreamPlayer in _players:
			if player.playing:
				_stop_tween.tween_property(player, "volume_db", target, fade).set_trans(Tween.TRANS_SINE)
		_stop_tween.chain().tween_callback(_finish_stop_all)
	else:
		_finish_stop_all()

func _finish_stop_all() -> void:
	for player: AudioStreamPlayer in _players:
		player.stop()
		player.volume_db = -60.0
	_active = null

func current_key() -> String:
	return _current_key

func current_title() -> String:
	return String(TRACK_NAMES.get(_current_key, "静默"))

func current_context() -> String:
	return String(TRACK_CONTEXTS.get(_current_key, ""))

func is_enabled() -> bool:
	return _enabled

func volume() -> float:
	return _volume

func track_titles() -> Array:
	var result: Array = []
	for key: Variant in TRACKS.keys():
		result.append({"key": String(key), "title": String(TRACK_NAMES.get(String(key), "")), "context": String(TRACK_CONTEXTS.get(String(key), ""))})
	return result
