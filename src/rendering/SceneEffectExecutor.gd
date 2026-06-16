extends Node

@onready var ambient_shade: CanvasModulate = get_parent().get_node_or_null("AmbientShade")
@onready var background: ColorRect = get_parent().get_node_or_null("Background")
@onready var visual_overlay: ColorRect = get_parent().get_node_or_null("VisualOverlay")
@onready var main_lamp: PointLight2D = get_parent().get_node_or_null("MainLamp")
@onready var paper_ash: GPUParticles2D = get_parent().get_node_or_null("PaperAsh")
@onready var animation_player: AnimationPlayer = get_parent().get_node_or_null("HorrorAnimation")
@onready var audio_player: AudioStreamPlayer = get_parent().get_node_or_null("HorrorAudio")

var executed_commands: Array = []
var audio_phase := 0.0
var map_layer_nodes: Array[Node] = []

func _ready() -> void:
    _ensure_placeholder_audio()
    if not EventBus.game_event.is_connected(_on_game_event):
        EventBus.game_event.connect(_on_game_event)

func _on_game_event(event_name: String, payload: Dictionary) -> void:
    if event_name == "render_command_created":
        execute_command(payload)
    elif event_name == "map_skin_applied":
        apply_map_skin(payload)

func execute_command(command: Dictionary) -> void:
    executed_commands.append(command)
    GameState.set_value("render.executed_commands", executed_commands.duplicate(true))

    match str(command.get("kind", "generic")):
        "light":
            _execute_light(command)
        "particle":
            _execute_particle(command)
        "visual":
            _execute_visual(command)
        "animation":
            _execute_animation(command)
        "audio":
            _execute_audio(command)
        _:
            _execute_generic(command)

    EventBus.emit_game_event("scene_effect_executed", command)

func apply_map_skin(command: Dictionary) -> void:
    _clear_map_layers()
    var palette: Dictionary = command.get("palette", {})

    if background != null:
        background.color = _color_from_hex(str(palette.get("background", "#120B08")))
    if ambient_shade != null:
        ambient_shade.color = _color_from_hex(str(palette.get("ambient", "#15100C")))

    for layer in command.get("layers", []):
        _create_rect_layer(layer)

    var lights: Array = command.get("lights", [])
    if not lights.is_empty() and main_lamp != null:
        var light_data: Dictionary = lights[0]
        var pos: Array = light_data.get("position", [640, 300])
        main_lamp.position = Vector2(float(pos[0]), float(pos[1]))
        main_lamp.energy = float(light_data.get("energy", 0.7))
        main_lamp.texture_scale = float(light_data.get("scale", 3.0))

    GameState.set_value("map.last_skin_applied", command)
    EventBus.emit_game_event("map_skin_scene_applied", {"skin_id": command.get("skin_id", "unknown"), "layer_count": map_layer_nodes.size()})

func _create_rect_layer(layer: Dictionary) -> void:
    var rect_values: Array = layer.get("rect", [0, 0, 1280, 720])
    var node := ColorRect.new()
    node.name = "MapLayer_%s" % str(layer.get("name", "layer"))
    node.offset_left = float(rect_values[0])
    node.offset_top = float(rect_values[1])
    node.offset_right = float(rect_values[0]) + float(rect_values[2])
    node.offset_bottom = float(rect_values[1]) + float(rect_values[3])
    node.color = _color_from_hex(str(layer.get("color", "#111111")))
    node.mouse_filter = Control.MOUSE_FILTER_IGNORE
    get_parent().add_child(node)
    get_parent().move_child(node, 2)
    map_layer_nodes.append(node)

func _clear_map_layers() -> void:
    for node in map_layer_nodes:
        if is_instance_valid(node):
            node.queue_free()
    map_layer_nodes.clear()

func _color_from_hex(value: String) -> Color:
    var text := value.strip_edges()
    if text.begins_with("#"):
        text = text.substr(1)
    if text.length() == 6:
        text += "FF"
    if text.length() != 8:
        return Color(0.05, 0.04, 0.035, 1.0)
    var r := text.substr(0, 2).hex_to_int() / 255.0
    var g := text.substr(2, 2).hex_to_int() / 255.0
    var b := text.substr(4, 2).hex_to_int() / 255.0
    var a := text.substr(6, 2).hex_to_int() / 255.0
    return Color(r, g, b, a)

func _ensure_placeholder_audio() -> void:
    if audio_player == null or audio_player.stream != null:
        return
    var generator := AudioStreamGenerator.new()
    generator.mix_rate = 22050.0
    generator.buffer_length = 0.35
    audio_player.stream = generator

func _execute_light(command: Dictionary) -> void:
    if main_lamp != null:
        main_lamp.energy = float(command.get("energy", 1.0))
        var tween := create_tween()
        tween.tween_property(main_lamp, "energy", 0.15, 0.08)
        tween.tween_property(main_lamp, "energy", float(command.get("energy", 1.0)), 0.12)
    if ambient_shade != null:
        ambient_shade.color = Color(0.06, 0.045, 0.035, 1.0)

func _execute_particle(command: Dictionary) -> void:
    if paper_ash != null:
        paper_ash.amount = int(command.get("amount", 48))
        paper_ash.restart()
        paper_ash.emitting = true

func _execute_visual(_command: Dictionary) -> void:
    if visual_overlay == null:
        return
    visual_overlay.color = Color(0.0, 0.0, 0.0, 0.45)
    var tween := create_tween()
    tween.tween_property(visual_overlay, "color", Color(0.0, 0.0, 0.0, 0.0), 0.8)

func _execute_animation(command: Dictionary) -> void:
    if animation_player != null and animation_player.has_animation(str(command.get("event_id", ""))):
        animation_player.play(str(command.get("event_id", "")))

func _execute_audio(command: Dictionary) -> void:
    if audio_player == null:
        return
    _ensure_placeholder_audio()
    audio_player.volume_db = linear_to_db(float(command.get("volume_scale", 0.8)))
    audio_player.play()
    _fill_placeholder_audio(float(command.get("volume_scale", 0.8)))

func _fill_placeholder_audio(volume_scale: float) -> void:
    var playback := audio_player.get_stream_playback()
    if playback == null or not playback.has_method("push_frame"):
        return
    var frames := 4096
    var mix_rate := 22050.0
    for i in range(frames):
        var t := audio_phase / mix_rate
        var decay := 1.0 - float(i) / float(frames)
        var low := sin(TAU * 72.0 * t) * 0.42 * decay
        var click := sin(TAU * 260.0 * t) * 0.12 * decay
        var sample := (low + click) * clampf(volume_scale, 0.1, 1.0)
        playback.push_frame(Vector2(sample, sample))
        audio_phase += 1.0

func _execute_generic(_command: Dictionary) -> void:
    pass

func get_executed_commands() -> Array:
    return executed_commands.duplicate(true)
