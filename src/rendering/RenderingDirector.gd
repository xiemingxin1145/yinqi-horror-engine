extends Node

var render_commands: Array = []

func _ready() -> void:
    if not EventBus.horror_event_requested.is_connected(_on_horror_event_requested):
        EventBus.horror_event_requested.connect(_on_horror_event_requested)

func _on_horror_event_requested(event_packet: Dictionary) -> void:
    var command := build_command_from_event(event_packet)
    render_commands.append(command)
    GameState.set_value("render.last_command", command)
    GameState.set_value("render.commands", render_commands.duplicate(true))
    EventBus.emit_game_event("render_command_created", command)

func build_command_from_event(event_packet: Dictionary) -> Dictionary:
    var event_type := str(event_packet.get("type", "generic"))
    match event_type:
        "light":
            return _light_command(event_packet)
        "particle":
            return _particle_command(event_packet)
        "visual":
            return _visual_command(event_packet)
        "animation":
            return _animation_command(event_packet)
        "audio":
            return _audio_command(event_packet)
        _:
            return _generic_command(event_packet)

func _light_command(event_packet: Dictionary) -> Dictionary:
    return {
        "kind": "light",
        "event_id": event_packet.get("id", "unknown"),
        "target": event_packet.get("target", "main_lamp"),
        "node_type": "PointLight2D",
        "operation": "flicker_or_pulse",
        "energy": _energy_from_intensity(int(event_packet.get("intensity", 0))),
        "duration": 1.2
    }

func _particle_command(event_packet: Dictionary) -> Dictionary:
    return {
        "kind": "particle",
        "event_id": event_packet.get("id", "unknown"),
        "target": event_packet.get("target", "room_center"),
        "node_type": "GPUParticles2D",
        "operation": "one_shot_emit",
        "amount": 24 + int(event_packet.get("intensity", 0)),
        "duration": 2.0
    }

func _visual_command(event_packet: Dictionary) -> Dictionary:
    return {
        "kind": "visual",
        "event_id": event_packet.get("id", "unknown"),
        "target": event_packet.get("target", "screen"),
        "node_type": "CanvasItem/Shader/AnimationPlayer",
        "operation": "flash_shadow_or_overlay",
        "duration": 0.8
    }

func _animation_command(event_packet: Dictionary) -> Dictionary:
    return {
        "kind": "animation",
        "event_id": event_packet.get("id", "unknown"),
        "target": event_packet.get("target", "prop"),
        "node_type": "AnimationPlayer",
        "operation": "play_event_animation",
        "duration": 1.0
    }

func _audio_command(event_packet: Dictionary) -> Dictionary:
    return {
        "kind": "audio",
        "event_id": event_packet.get("id", "unknown"),
        "target": event_packet.get("target", "ambient"),
        "node_type": "AudioStreamPlayer2D/AudioStreamPlayer",
        "operation": "play_cue",
        "volume_scale": clampf(float(event_packet.get("intensity", 0)) / 100.0, 0.2, 1.0)
    }

func _generic_command(event_packet: Dictionary) -> Dictionary:
    return {
        "kind": "generic",
        "event_id": event_packet.get("id", "unknown"),
        "target": event_packet.get("target", "world"),
        "operation": "log_only"
    }

func _energy_from_intensity(intensity: int) -> float:
    return clampf(0.4 + float(intensity) / 100.0, 0.4, 1.4)

func get_commands() -> Array:
    return render_commands.duplicate(true)

func clear_commands() -> void:
    render_commands.clear()
