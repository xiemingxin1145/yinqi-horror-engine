extends Control

const CORE_CLUE_IDS: Array[String] = [
	"microphone_drowning_audio",
	"red_painted_rule_three",
	"oil_soaked_gag_cloth",
	"footprints_to_river",
	"lin_wanqiu_student_id"
]
const BACKGROUND_FALLBACK := "res://assets/returning_water/backgrounds/gate_front.webp"
const EXIT_BACKGROUND := "res://assets/returning_water/backgrounds/gate_exit_clear.webp"
const HERO_PORTRAIT := "res://assets/returning_water/characters/chen_mo_portrait.webp"
const PAPER_BOAT_CARD := "res://assets/returning_water/props/paper_boat_scene.webp"
const RIVER_LOOP := "res://assets/returning_water/audio/river_night_loop.mp3"
const RECORDING_TEXTURE := "res://assets/returning_water/audio/microphone_recording_texture.mp3"
const CHASE_CUE := "res://assets/returning_water/audio/one_time_river_chase.mp3"
const UI_FONT_PATH := "res://assets/returning_water/fonts/NotoSansCJKsc-subset.otf"
const SETTINGS_PATH := "user://returning_water_roster.cfg"

var _background: TextureRect
var _dim: ColorRect
var _ui: Control
var _flash: ColorRect
var _ambient_player: AudioStreamPlayer
var _effect_player: AudioStreamPlayer
var _chase_overlay: Control

var flash_enabled := true
var volume_percent := 40
var current_screen := "title"
var return_screen := "game"
var current_viewpoint_id := ""
var found_clues: Dictionary = {}
var wrong_attempts := 0
var scare_played := false
var chase_sequence_count := 0
var case_resolved := false
var chapter_active := false
var hint_viewed := false
var status_notice := ""
var failure_reason := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_full_rect(self)
	DataRegistry.load_all_data(true, true)
	var ui_font := load(UI_FONT_PATH) as Font
	if ui_font != null:
		add_theme_font_override("font", ui_font)
	_build_layers()
	_load_settings()
	_apply_audio_volume()
	_show_title()


func _build_layers() -> void:
	_background = TextureRect.new()
	_full_rect(_background)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	_dim = ColorRect.new()
	_full_rect(_dim)
	_dim.color = Color(0.015, 0.025, 0.04, 0.24)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)

	_ui = Control.new()
	_full_rect(_ui)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ui)

	_flash = ColorRect.new()
	_full_rect(_flash)
	_flash.color = Color(0.78, 0.86, 0.92, 0.0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.visible = false
	add_child(_flash)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.name = "RiverAmbience"
	add_child(_ambient_player)
	_effect_player = AudioStreamPlayer.new()
	_effect_player.name = "ChapterEffects"
	add_child(_effect_player)


func _full_rect(node: Control) -> void:
	node.anchor_left = 0.0
	node.anchor_top = 0.0
	node.anchor_right = 1.0
	node.anchor_bottom = 1.0
	node.offset_left = 0.0
	node.offset_top = 0.0
	node.offset_right = 0.0
	node.offset_bottom = 0.0


func _clear_ui() -> void:
	for child in _ui.get_children():
		child.queue_free()


func _set_background(path: String) -> bool:
	if not ResourceLoader.exists(path):
		push_error("ReturningWaterRoster: missing background %s" % path)
		path = BACKGROUND_FALLBACK
	if not ResourceLoader.exists(path):
		return false
	_background.texture = load(path) as Texture2D
	return _background.texture != null


func _set_viewpoint(viewpoint_id: String) -> bool:
	var result: Dictionary = ViewpointDirector.enter_viewpoint(viewpoint_id)
	if not bool(result.get("ok", false)):
		push_error("ReturningWaterRoster: failed to enter %s: %s" % [viewpoint_id, result])
		return false
	current_viewpoint_id = viewpoint_id
	var viewpoint: Dictionary = result.get("viewpoint", {})
	return _set_background(str(viewpoint.get("background_asset", BACKGROUND_FALLBACK)))


func start_new_game() -> void:
	_reset_case_state()
	chapter_active = true
	current_screen = "intro"
	_set_viewpoint("village_gate_front")
	_start_ambience()
	_show_intro()


func restart_to_title() -> void:
	_reset_case_state()
	chapter_active = false
	_show_title()


func _reset_case_state() -> void:
	GameState.reset()
	ClueStore.reset()
	found_clues.clear()
	wrong_attempts = 0
	scare_played = false
	chase_sequence_count = 0
	case_resolved = false
	hint_viewed = false
	status_notice = ""
	failure_reason = ""
	current_viewpoint_id = ""
	if is_instance_valid(_ambient_player) and _ambient_player.playing:
		_ambient_player.stop()
	if is_instance_valid(_effect_player) and _effect_player.playing:
		_effect_player.stop()
	_clear_chase_overlay()


func begin_chapter() -> bool:
	if not chapter_active:
		return false
	if not _set_viewpoint("village_gate_front"):
		return false
	status_notice = "先核对录音与归魂村村规；界碑是可选线索。"
	_show_game()
	return true


func _show_title() -> void:
	current_screen = "title"
	_set_background(BACKGROUND_FALLBACK)
	_dim.color = Color(0.015, 0.025, 0.04, 0.36)
	_clear_ui()
	var panel := _panel(Rect2(38, 38, 1204, 644))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	panel.add_child(row)

	var portrait_frame := _panel_child(row)
	portrait_frame.custom_minimum_size = Vector2(340, 560)
	var portrait := _make_image(HERO_PORTRAIT, Vector2(320, 530), TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	portrait_frame.add_child(portrait)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(content)
	content.add_child(_label("阴契：回水名册", 42, HORIZONTAL_ALIGNMENT_LEFT))
	content.add_child(_label("独立短章 · 固定机位 2.5D", 24))
	content.add_child(_label("午夜误入归魂村的跑腿员陈默，在河桥发现一段被截断的求救录音。他必须查清录音里的人，并平安离村。", 24))
	content.add_child(_label("本章村规与纸船习俗均为归魂村虚构设定，不代表现实民俗。", 20, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	content.add_child(_label("含一次低强度短追逐/闪暗效果；闪暗可关闭，音量可调，所有声音线索均有文字稿。", 18))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)
	content.add_child(_button("开始 / 重玩", Callable(self, "start_new_game"), 64))
	content.add_child(_button("设置", Callable(self, "_show_settings"), 58))
	content.add_child(_label("一段可通关、可重开的独立章节；不会进入老宅、戏台或祠堂。", 17))


func _show_intro() -> void:
	current_screen = "intro"
	_dim.color = Color(0.01, 0.02, 0.035, 0.40)
	_clear_ui()
	var panel := _panel(Rect2(86, 74, 1108, 572))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	panel.add_child(row)
	var portrait_frame := _panel_child(row)
	portrait_frame.custom_minimum_size = Vector2(330, 510)
	portrait_frame.add_child(_make_image(HERO_PORTRAIT, Vector2(310, 480), TextureRect.STRETCH_KEEP_ASPECT_COVERED))
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	row.add_child(content)
	content.add_child(_label("23:47 · 最后一单", 34))
	content.add_child(_label("陈默接下一单：把一盏白灯送到归魂村河桥。桥边留着一段被截断的求救录音。找到录音里的人，平安离村。", 25))
	content.add_child(_label("过了子时，水里若有人喊你的名字——先弄清楚留下了什么，再决定要不要回答。", 22))
	content.add_child(_label("声音可静音；调查与推理均不需要麦克风或手机传感器权限。", 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)
	content.add_child(_button("走近村口", Callable(self, "begin_chapter"), 64))
	content.add_child(_button("设置", Callable(self, "_show_settings"), 56))


func _show_game() -> void:
	current_screen = "game"
	_dim.color = Color(0.015, 0.025, 0.04, 0.20)
	_clear_ui()
	var viewpoint := ViewpointDirector.get_current_viewpoint()
	if viewpoint.is_empty():
		_set_viewpoint("village_gate_front")
		viewpoint = ViewpointDirector.get_current_viewpoint()
	var location_id := str(viewpoint.get("location", "village_gate"))
	var location_name := "村口" if location_id == "village_gate" else "河桥"
	var required_count := get_core_clue_count()
	var objective := "目标：核对录音与村规，再沿雾路前往河桥。" if location_id == "village_gate" else "目标：确认录音里的人，并判断纸船名牌与水流方向。"

	var header := _panel(Rect2(20, 18, 950, 142))
	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 5)
	header.add_child(header_box)
	header_box.add_child(_label("回水名册  ·  %s / %s" % [location_name, str(viewpoint.get("name", ""))], 25))
	header_box.add_child(_label(objective, 20))
	header_box.add_child(_label("核心线索 %d / 5%s" % [required_count, "    ·    " + status_notice if status_notice != "" else ""], 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.86, 0.84)))

	var portrait_frame := _panel(Rect2(990, 18, 270, 330))
	var portrait := _make_image(HERO_PORTRAIT, Vector2(250, 288), TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	portrait_frame.add_child(portrait)
	var caption := _label("陈默  ·  夜班跑腿员", 17, HORIZONTAL_ALIGNMENT_CENTER)
	portrait_frame.add_child(caption)

	var action_panel := _panel(Rect2(20, 462, 1240, 238))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	action_panel.add_child(stack)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	stack.add_child(navigation)
	navigation.add_child(_button("◀ 左看", Callable(self, "_turn_left"), 52))
	navigation.add_child(_button("右看 ▶", Callable(self, "_turn_right"), 52))
	navigation.add_child(_button("线索簿 %d/5" % required_count, Callable(self, "_show_journal").bind("game"), 52))
	navigation.add_child(_button("设置", Callable(self, "_show_settings"), 52))

	var hotspots_row := HBoxContainer.new()
	hotspots_row.add_theme_constant_override("separation", 8)
	stack.add_child(hotspots_row)
	var hotspots: Array = ViewpointDirector.get_current_hotspots()
	if hotspots.is_empty():
		hotspots_row.add_child(_label("灯位暂时没有可调查物；可查看左右桥栏与桥面。", 18))
	else:
		for item in hotspots:
			var hotspot_id := str(item.get("id", ""))
			var item_label := str(item.get("name", hotspot_id))
			hotspots_row.add_child(_button("调查 · " + item_label, Callable(self, "inspect_hotspot").bind(hotspot_id), 56))

	var route_row := HBoxContainer.new()
	route_row.add_theme_constant_override("separation", 8)
	stack.add_child(route_row)
	if location_id == "village_gate":
		var gate_ready := found_clues.has("microphone_drowning_audio") and found_clues.has("red_painted_rule_three")
		var route_button := _button("沿雾路前往河桥", Callable(self, "_move_to_bridge"), 56)
		route_button.disabled = not gate_ready
		route_row.add_child(route_button)
		if not gate_ready:
			route_row.add_child(_label("先调查录音与被涂掉的村规；断碑为可选线索。", 18))
	else:
		route_row.add_child(_button("回到村口", Callable(self, "_return_to_gate"), 56))
		var boat_button := _button("查看三只纸船", Callable(self, "open_boat_table"), 56)
		boat_button.disabled = not has_all_core_clues()
		route_row.add_child(boat_button)
		if not has_all_core_clues():
			route_row.add_child(_label("五类核心线索齐备后才开放判断（当前 %d/5）。" % required_count, 18))


func inspect_hotspot(hotspot_id: String) -> bool:
	var result: Dictionary = HotspotController.inspect_hotspot(hotspot_id)
	if not bool(result.get("ok", false)):
		status_notice = "现场没有可读线索；请换一个视角。"
		_show_game()
		return false
	var clue: Dictionary = result.get("clue", {})
	if not clue.is_empty():
		var clue_id := str(clue.get("id", ""))
		if clue_id != "":
			found_clues[clue_id] = clue.duplicate(true)
	status_notice = ""
	return_screen = "game"
	_show_clue_detail(clue, str(result.get("item_name", "现场记录")))
	return true


func _show_clue_detail(clue: Dictionary, item_name: String) -> void:
	current_screen = "clue"
	_clear_ui()
	var panel := _panel(Rect2(76, 64, 1128, 592))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var clue_name := str(clue.get("name", item_name))
	box.add_child(_label("现场记录  ·  " + item_name, 22, HORIZONTAL_ALIGNMENT_LEFT, Color(0.80, 0.85, 0.82)))
	box.add_child(_label(clue_name, 32))
	box.add_child(_label(str(clue.get("text", "没有更多可读信息。")), 24))
	if str(clue.get("id", "")) == "microphone_drowning_audio":
		box.add_child(_label("录音的完整可读稿已保留在上方；播放键只播放水声、静电与截断声，不请求麦克风权限。", 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	if str(clue.get("id", "")) == "microphone_drowning_audio":
		box.add_child(_button("播放录音底噪与落水声", Callable(self, "_play_recording"), 56))
	box.add_child(_button("回到现场", Callable(self, "_restore_screen").bind("game"), 56))


func _show_journal(back_to: String = "game") -> void:
	return_screen = back_to
	current_screen = "journal"
	_clear_ui()
	var panel := _panel(Rect2(70, 40, 1140, 640))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_label("线索簿  ·  %d / 5" % get_core_clue_count(), 32))
	var ordered := [
		"microphone_drowning_audio",
		"red_painted_rule_three",
		"oil_soaked_gag_cloth",
		"footprints_to_river",
		"lin_wanqiu_student_id"
	]
	for clue_id in ordered:
		var clue: Dictionary = found_clues.get(clue_id, {})
		if clue.is_empty():
			box.add_child(_label("○  尚未确认：" + _clue_short_name(clue_id), 19, HORIZONTAL_ALIGNMENT_LEFT, Color(0.68, 0.72, 0.72)))
		else:
			box.add_child(_label("●  %s：%s" % [str(clue.get("name", _clue_short_name(clue_id))), str(clue.get("text", ""))], 18))
	if wrong_attempts >= 2:
		box.add_child(_button("查看更清楚的提示", Callable(self, "_show_hint"), 48))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("回到现场", Callable(self, "_restore_screen").bind(back_to), 56))


func _clue_short_name(clue_id: String) -> String:
	var names := {
		"microphone_drowning_audio": "备用麦克风录音",
		"red_painted_rule_three": "被涂掉的归魂村村规",
		"oil_soaked_gag_cloth": "香油白布",
		"footprints_to_river": "沿桥延伸的脚印",
		"lin_wanqiu_student_id": "学生证姓名"
	}
	return str(names.get(clue_id, clue_id))


func _show_hint() -> void:
	current_screen = "hint"
	hint_viewed = true
	_clear_ui()
	var panel := _panel(Rect2(126, 155, 1028, 410))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	box.add_child(_label("再看一次线索关系", 32))
	box.add_child(_label("把学生证姓名与白布上的 L.W. 对起来，再沿泥印看到它停在哪里。村规说纸船要顺水送名；河里呼你的名字时，不要回答。", 25))
	box.add_child(_label("提示可关闭，线索不丢失。", 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("关闭提示，回到河桥", Callable(self, "_retry_at_bridge"), 58))


func _turn_left() -> void:
	var result: Dictionary = ViewpointDirector.turn_left()
	if bool(result.get("ok", false)):
		current_viewpoint_id = str(result.get("viewpoint", {}).get("id", ""))
		_set_background(str(result.get("viewpoint", {}).get("background_asset", BACKGROUND_FALLBACK)))
		status_notice = ""
	_show_game()


func _turn_right() -> void:
	var result: Dictionary = ViewpointDirector.turn_right()
	if bool(result.get("ok", false)):
		current_viewpoint_id = str(result.get("viewpoint", {}).get("id", ""))
		_set_background(str(result.get("viewpoint", {}).get("background_asset", BACKGROUND_FALLBACK)))
		status_notice = ""
	_show_game()


func _move_to_bridge() -> bool:
	if not found_clues.has("microphone_drowning_audio") or not found_clues.has("red_painted_rule_three"):
		status_notice = "先找到录音与被涂掉的村规。"
		_show_game()
		return false
	if not _set_viewpoint("river_bridge_front"):
		return false
	status_notice = "河水由左向右流；可继续调查桥栏与桥面。"
	_show_game()
	return true


func _return_to_gate() -> bool:
	if not _set_viewpoint("village_gate_front"):
		return false
	status_notice = "村口线索仍保留；本章不会离开这两处地点。"
	_show_game()
	return true


func has_all_core_clues() -> bool:
	for clue_id in CORE_CLUE_IDS:
		if not found_clues.has(clue_id):
			return false
	return true


func get_core_clue_count() -> int:
	var count := 0
	for clue_id in CORE_CLUE_IDS:
		if found_clues.has(clue_id):
			count += 1
	return count


func open_boat_table() -> bool:
	if not has_all_core_clues():
		status_notice = "五类核心线索齐备后，才能辨认纸船名牌。"
		_show_game()
		return false
	if current_viewpoint_id != "river_bridge_front":
		_set_viewpoint("river_bridge_front")
	status_notice = ""
	_show_boat_table()
	return true


func _show_boat_table() -> void:
	current_screen = "boat"
	_dim.color = Color(0.01, 0.02, 0.035, 0.34)
	_clear_ui()
	var panel := _panel(Rect2(48, 50, 1184, 620))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(_label("三只纸船 · 一次判断", 32))
	box.add_child(_label("河水由左向右流。选择一只名牌与船头方向相符的纸船；错误可以重试，线索不会丢失。", 20))
	if not status_notice.is_empty():
		box.add_child(_label(status_notice, 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.86, 0.78)))
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 14)
	box.add_child(choices)
	_add_boat_choice(choices, "陈默", "upstream", "船头朝左  ←  逆水")
	_add_boat_choice(choices, "林晚秋", "downstream", "船头朝右  →  顺水")
	_add_boat_choice(choices, "空白", "across", "船头横向  ↑")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("回到线索簿，不放船", Callable(self, "_show_journal").bind("game"), 52))


func _add_boat_choice(parent: HBoxContainer, name_tag: String, direction: String, direction_text: String) -> void:
	var card := _panel_child(parent)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 370)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)
	box.add_child(_make_image(PAPER_BOAT_CARD, Vector2(300, 190), TextureRect.STRETCH_KEEP_ASPECT_COVERED))
	box.add_child(_label("名牌：" + name_tag, 24, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_label(direction_text, 19, HORIZONTAL_ALIGNMENT_CENTER, Color(0.84, 0.86, 0.80)))
	box.add_child(_button("检查名牌", Callable(self, "inspect_paper_boat").bind(name_tag, direction_text), 48))
	box.add_child(_button("放下这只", Callable(self, "submit_paper_boat_choice").bind(name_tag, direction), 56))


func inspect_paper_boat(name_tag: String, direction_text: String) -> bool:
	if not has_all_core_clues() or case_resolved:
		return false
	status_notice = "检查记录：名牌写着“%s”，%s；这一步不消耗判断机会。" % [name_tag, direction_text]
	_show_boat_table()
	return true


func submit_paper_boat_choice(name_tag: String, direction: String) -> bool:
	if not has_all_core_clues() or case_resolved:
		return false
	if name_tag != "林晚秋" or direction != "downstream":
		_register_failure("纸船没有顺着正确的名字离开。河面开始重复陈默的呼吸声。")
		return false
	status_notice = "林晚秋的名字顺水离开；雾中传来陈默自己的声音。"
	_begin_release_sequence()
	return true


func _begin_release_sequence() -> void:
	current_screen = "release"
	_dim.color = Color(0.015, 0.025, 0.04, 0.26)
	_clear_ui()
	var panel := _panel(Rect2(128, 172, 1024, 376))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	panel.add_child(box)
	box.add_child(_label("纸船顺着河水离开", 34))
	box.add_child(_label("名牌逐渐没入雾里，只剩下三次拍岸声。", 23))
	var beat_label := _label("水声拍岸 · 第 1/3 声", 28, HORIZONTAL_ALIGNMENT_CENTER, Color(0.82, 0.90, 0.94))
	box.add_child(beat_label)
	var ripple := ColorRect.new()
	ripple.custom_minimum_size = Vector2(720, 6)
	ripple.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ripple.color = Color(0.72, 0.86, 0.92, 0.66)
	box.add_child(ripple)
	for beat in range(1, 4):
		beat_label.text = "水声拍岸 · 第 %d/3 声" % beat
		ripple.modulate.a = 0.28
		var pulse := create_tween()
		pulse.tween_property(ripple, "modulate:a", 1.0, 0.08)
		pulse.tween_property(ripple, "modulate:a", 0.28, 0.20)
		await get_tree().create_timer(0.34).timeout
	if is_instance_valid(_ambient_player):
		_ambient_player.stop()
	status_notice = "三次拍岸声停了。"
	_show_call_choice()


func _show_call_choice() -> void:
	current_screen = "call"
	_dim.color = Color(0.01, 0.02, 0.035, 0.44)
	_clear_ui()
	var panel := _panel(Rect2(112, 112, 1056, 496))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	box.add_child(_label("河面安静了一瞬", 32))
	box.add_child(_label("水里的声音变成了陈默自己的声音：“陈默——回来。”村规与录音都还在你的线索簿里。", 25))
	box.add_child(_label("回应是一次可恢复的错误；沉默并退到白灯下，才能结束这一夜。", 20, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("回应：“谁在那儿？”", Callable(self, "choose_to_remain_silent").bind(false), 58))
	box.add_child(_button("不应声，退到灯下", Callable(self, "choose_to_remain_silent").bind(true), 58))


func choose_to_remain_silent(remain_silent: bool) -> bool:
	if case_resolved:
		return false
	if not remain_silent:
		_register_failure("陈默回应了河中的呼名。脚步追到桥头后停下，线索仍在。")
		return false
	_complete_case()
	return true


func _register_failure(message: String) -> void:
	wrong_attempts += 1
	failure_reason = message
	status_notice = ""
	if not scare_played:
		scare_played = true
		_trigger_one_time_scare()
	current_screen = "failure"
	_show_failure()


func _show_failure() -> void:
	current_screen = "failure"
	_dim.color = Color(0.01, 0.015, 0.025, 0.55)
	_clear_ui()
	var panel := _panel(Rect2(120, 104, 1040, 512))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 15)
	panel.add_child(box)
	box.add_child(_label("河桥 · 暂时退回灯下", 32))
	box.add_child(_label(failure_reason, 23))
	box.add_child(_label("失败不扣资源，五类线索全部保留。可以马上重试，也可以先看线索簿。", 19, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("回桥头重试", Callable(self, "_retry_at_bridge"), 56))
	box.add_child(_button("检查线索", Callable(self, "_show_journal").bind("failure"), 52))
	if wrong_attempts >= 2:
		box.add_child(_button("查看更清楚的提示", Callable(self, "_show_hint"), 50))


func _retry_at_bridge() -> void:
	_set_viewpoint("river_bridge_front")
	status_notice = "线索保留；错误不会永久锁住本章。"
	if volume_percent > 0 and is_instance_valid(_ambient_player) and not _ambient_player.playing:
		_start_ambience()
	_show_game()


func _trigger_one_time_scare() -> void:
	chase_sequence_count += 1
	_play_effect(CHASE_CUE)
	_show_short_pursuit()
	if not flash_enabled:
		return
	_flash.visible = true
	_flash.color = Color(0.78, 0.86, 0.92, 0.18)
	var tween := create_tween()
	tween.tween_property(_flash, "color:a", 0.0, 0.28)
	tween.finished.connect(func() -> void:
		_flash.visible = false
	)


func _show_short_pursuit() -> void:
	_clear_chase_overlay()
	_chase_overlay = Control.new()
	_chase_overlay.name = "OneTimePursuitOverlay"
	_full_rect(_chase_overlay)
	_chase_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chase_overlay.z_index = 20
	add_child(_chase_overlay)

	var haze := ColorRect.new()
	_full_rect(haze)
	haze.color = Color(0.01, 0.015, 0.025, 0.0)
	haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chase_overlay.add_child(haze)

	var runner := Polygon2D.new()
	runner.name = "RushingShadow"
	runner.polygon = PackedVector2Array([
		Vector2(52, 0), Vector2(83, 0), Vector2(98, 15), Vector2(96, 42),
		Vector2(84, 57), Vector2(101, 73), Vector2(126, 96), Vector2(118, 108),
		Vector2(92, 94), Vector2(93, 135), Vector2(113, 169), Vector2(101, 181),
		Vector2(73, 151), Vector2(58, 186), Vector2(43, 178), Vector2(54, 135),
		Vector2(40, 105), Vector2(20, 132), Vector2(8, 124), Vector2(31, 82),
		Vector2(35, 64), Vector2(18, 54), Vector2(23, 42), Vector2(43, 54), Vector2(50, 39)
	])
	runner.position = Vector2(1310, 145)
	runner.scale = Vector2(1.05, 1.15)
	runner.rotation_degrees = 4.0
	runner.color = Color(0.72, 0.80, 0.82, 0.82)
	_chase_overlay.add_child(runner)

	var caption := _label("身后的湿脚步骤然逼近……", 27, HORIZONTAL_ALIGNMENT_CENTER, Color(0.94, 0.94, 0.89))
	caption.position = Vector2(180, 66)
	caption.size = Vector2(920, 62)
	caption.add_theme_color_override("font_outline_color", Color(0.005, 0.01, 0.015, 1.0))
	caption.add_theme_constant_override("outline_size", 4)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chase_overlay.add_child(caption)

	var tween := create_tween()
	tween.tween_property(haze, "color:a", 0.14, 0.12)
	tween.parallel().tween_property(runner, "position", Vector2(960, 168), 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(runner, "position", Vector2(610, 238), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(haze, "color:a", 0.08, 0.24)
	tween.tween_property(haze, "color:a", 0.0, 0.20)
	tween.parallel().tween_property(runner, "modulate:a", 0.0, 0.20)
	tween.tween_callback(_clear_chase_overlay)


func _clear_chase_overlay() -> void:
	if is_instance_valid(_chase_overlay):
		_chase_overlay.queue_free()
	_chase_overlay = null


func _complete_case() -> void:
	case_resolved = true
	chapter_active = false
	GameState.set_flag("returning_water_roster_resolved", true)
	if is_instance_valid(_ambient_player):
		_ambient_player.stop()
	if is_instance_valid(_effect_player):
		_effect_player.stop()
	_clear_chase_overlay()
	_set_viewpoint("village_gate_front")
	_set_background(EXIT_BACKGROUND)
	status_notice = "河桥呼名停止，雾散开了。"
	_show_exit_transition()


func _show_exit_transition() -> void:
	current_screen = "exit"
	_dim.color = Color(0.015, 0.025, 0.04, 0.18)
	_clear_ui()
	var panel := _panel(Rect2(116, 166, 1048, 388))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	box.add_child(_label("雾散了 · 走出归魂村", 34))
	box.add_child(_label("河桥的呼名停了。陈默没有回头，提灯越过界碑，走出了归魂村。", 25))
	box.add_child(_label("今晚的短案已经闭合；未解的老宅订单只留作后续线索。", 20, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("查看结案记录", Callable(self, "continue_to_ending"), 58))


func continue_to_ending() -> bool:
	if current_screen != "exit":
		return false
	_show_ending()
	return true


func _show_ending() -> void:
	current_screen = "ending"
	_dim.color = Color(0.015, 0.025, 0.04, 0.30)
	_clear_ui()
	var panel := _panel(Rect2(74, 56, 1132, 608))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	panel.add_child(row)
	var portrait_frame := _panel_child(row)
	portrait_frame.custom_minimum_size = Vector2(310, 520)
	portrait_frame.add_child(_make_image(HERO_PORTRAIT, Vector2(290, 490), TextureRect.STRETCH_KEEP_ASPECT_COVERED))
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 14)
	row.add_child(box)
	box.add_child(_label("本夜结案 · 回水名册", 34))
	box.add_child(_label("林晚秋的姓名已确认；河桥呼唤暂时停止。陈默走出村口，手机恢复一格信号。", 24))
	box.add_child(_label("本章异常已经闭合；林晚秋的全部遭遇仍未查明。归魂村老宅的订单只留作下一章钩子。", 20, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var hint_status := "看过提示" if hint_viewed else "未查看提示"
	box.add_child(_label("本次记录：核心线索 %d/5 · %s · 失败次数 %d" % [get_core_clue_count(), hint_status, wrong_attempts], 19))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("再玩一次", Callable(self, "start_new_game"), 58))
	box.add_child(_button("回到标题", Callable(self, "restart_to_title"), 54))


func _show_settings() -> void:
	return_screen = current_screen
	current_screen = "settings"
	_clear_ui()
	var panel := _panel(Rect2(178, 112, 924, 496))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	box.add_child(_label("设置与可访问性", 32))
	var flash_toggle := CheckButton.new()
	flash_toggle.text = "允许一次轻微闪暗（关闭后仍可完整通关）"
	flash_toggle.button_pressed = flash_enabled
	flash_toggle.add_theme_font_size_override("font_size", 21)
	flash_toggle.custom_minimum_size = Vector2(0, 54)
	flash_toggle.toggled.connect(func(enabled: bool) -> void:
		flash_enabled = enabled
		_save_settings()
	)
	box.add_child(flash_toggle)
	box.add_child(_label("音效音量：%d%%" % volume_percent, 20))
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.value = volume_percent
	slider.custom_minimum_size = Vector2(0, 42)
	slider.gui_input.connect(func(event: InputEvent) -> void:
		var fraction := -1.0
		if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
			fraction = (event as InputEventScreenTouch).position.x / maxf(slider.size.x, 1.0)
		elif event is InputEventScreenDrag:
			fraction = (event as InputEventScreenDrag).position.x / maxf(slider.size.x, 1.0)
		if fraction >= 0.0:
			slider.value = lerpf(slider.min_value, slider.max_value, clampf(fraction, 0.0, 1.0))
	)
	slider.value_changed.connect(func(value: float) -> void:
		volume_percent = int(value)
		_apply_audio_volume()
		_save_settings()
		if is_instance_valid(box) and box.get_child_count() > 2:
			box.get_child(2).text = "音效音量：%d%%" % volume_percent
	)
	box.add_child(slider)
	box.add_child(_label("所有声音线索有完整文字稿；不请求麦克风、陀螺仪或网络权限。", 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.78, 0.65)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(_button("返回", Callable(self, "_restore_screen").bind(return_screen), 56))


func _restore_screen(screen_name: String) -> void:
	match screen_name:
		"game":
			_show_game()
		"intro":
			_show_intro()
		"failure":
			_show_failure()
		"ending":
			_show_ending()
		"title":
			_show_title()
		_:
			_show_game()


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		flash_enabled = bool(config.get_value("accessibility", "flash_enabled", true))
		volume_percent = clampi(int(config.get_value("audio", "volume_percent", 40)), 0, 100)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("accessibility", "flash_enabled", flash_enabled)
	config.set_value("audio", "volume_percent", volume_percent)
	config.save(SETTINGS_PATH)


func _apply_audio_volume() -> void:
	var gain := float(volume_percent) / 100.0
	var db := linear_to_db(maxf(gain, 0.001))
	if is_instance_valid(_ambient_player):
		_ambient_player.volume_db = db
	if is_instance_valid(_effect_player):
		_effect_player.volume_db = db
	if volume_percent == 0 and is_instance_valid(_ambient_player):
		_ambient_player.stop()
	elif chapter_active and is_instance_valid(_ambient_player) and not _ambient_player.playing:
		_start_ambience()


func _start_ambience() -> void:
	if not ResourceLoader.exists(RIVER_LOOP):
		return
	var stream := load(RIVER_LOOP) as AudioStreamMP3
	if stream == null:
		return
	stream.loop = true
	_ambient_player.stream = stream
	_ambient_player.volume_db = linear_to_db(maxf(float(volume_percent) / 100.0, 0.001))
	if volume_percent > 0:
		_ambient_player.play()


func _play_recording() -> void:
	_play_effect(RECORDING_TEXTURE)


func _play_effect(path: String) -> void:
	if volume_percent <= 0 or not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	_effect_player.stream = stream
	_effect_player.volume_db = linear_to_db(maxf(float(volume_percent) / 100.0, 0.001))
	_effect_player.play()


func get_run_snapshot() -> Dictionary:
	return {
		"screen": current_screen,
		"viewpoint": current_viewpoint_id,
		"found_clues": found_clues.keys(),
		"core_clues": get_core_clue_count(),
		"wrong_attempts": wrong_attempts,
		"scare_played": scare_played,
		"chase_sequence_count": chase_sequence_count,
		"resolved": case_resolved,
		"active": chapter_active,
		"hint_viewed": hint_viewed,
		"flash_enabled": flash_enabled,
		"volume_percent": volume_percent
	}


func _make_image(path: String, min_size: Vector2, stretch: TextureRect.StretchMode) -> TextureRect:
	var image := TextureRect.new()
	image.custom_minimum_size = min_size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch
	image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path):
		image.texture = load(path) as Texture2D
	return image


func _panel(rect: Rect2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.045, 0.06, 0.92)
	style.border_color = Color(0.52, 0.62, 0.62, 0.65)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 18
	style.content_margin_top = 16
	style.content_margin_right = 18
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	_ui.add_child(panel)
	return panel


func _panel_child(parent: Control) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.07, 0.86)
	style.border_color = Color(0.43, 0.54, 0.56, 0.50)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


func _label(text: String, font_size: int = 21, alignment: int = HORIZONTAL_ALIGNMENT_LEFT, color: Color = Color(0.93, 0.94, 0.90)) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


func _button(text: String, action: Callable, height: int = 56) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(0.94, 0.95, 0.91))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.93, 0.72))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.17, 0.18, 0.96)
	normal.border_color = Color(0.55, 0.66, 0.63, 0.72)
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.20, 0.27, 0.26, 1.0)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.08, 0.11, 0.12, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	if action.is_valid():
		button.pressed.connect(action)
	return button
