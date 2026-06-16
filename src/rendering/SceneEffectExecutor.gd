extends Node

@onready var ambient_shade: CanvasModulate = get_parent().get_node_or_null("AmbientShade")
@onready var visual_overlay: ColorRect = get_parent().get_node_or_null("VisualOverlay")
@onready var main_lamp: PointLight2D = get_parent().get_node_or_null("MainLamp")
@onready var paper_ash: GPUParticles2D = get_parent().get_node_or_null("PaperAsh")
@onready var animation_player: AnimationPlayer = get_parent().get_node_or_null("HorrorAnimation")
@onready var audio_player: AudioStreamPlayer = get_parent().get_node_or_null("HorrorAudio")

var executed_commands: Array = []

func _ready() -> void:
    if not EventBus.game_event.is_connected(_on_game_event):
        EventBus.game_event.connect(_on_game_event)

func _on_game_event(event_name: String, payload: Dictionary) -> void:
    if event_name != "render_command_created":
        return
    execute_command(payload)

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
    if audio_player != null and audio_player.stream != null:
        audio_player.volume_db = linear_to_db(float(command.get("volume_scale", 0.8)))
        audio_player.play()

func _execute_generic(_command: Dictionary) -> void:
    pass

func get_executed_commands() -> Array:
    return executed_commands.duplicate(true)
