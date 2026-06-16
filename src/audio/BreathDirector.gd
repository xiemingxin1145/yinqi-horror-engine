extends Node

var breath_level := 0.0
var last_intensity := 0.0
var enabled := true

func _ready() -> void:
    if not EventBus.game_event.is_connected(_on_game_event):
        EventBus.game_event.connect(_on_game_event)
    if not EventBus.horror_event_requested.is_connected(_on_horror_event_requested):
        EventBus.horror_event_requested.connect(_on_horror_event_requested)

func _on_game_event(event_name: String, payload: Dictionary) -> void:
    if event_name == "viewpoint_entered":
        _evaluate_from_viewpoint(payload)
    elif event_name == "hotspot_inspected":
        _raise_breath(0.08)

func _on_horror_event_requested(event_packet: Dictionary) -> void:
    var intensity := float(event_packet.get("intensity", 0.0))
    set_intensity(intensity)

func _evaluate_from_viewpoint(viewpoint: Dictionary) -> void:
    var location_id := str(viewpoint.get("location", ""))
    var base := 0.15
    if location_id == "river_bridge":
        base = 0.32
    elif location_id == "old_house":
        base = 0.48
    elif location_id == "ancestral_hall":
        base = 0.72
    breath_level = max(breath_level, base)
    _publish_state()

func set_intensity(intensity: float) -> void:
    last_intensity = intensity
    breath_level = clampf(intensity / 100.0, 0.0, 1.0)
    _publish_state()

func _raise_breath(amount: float) -> void:
    breath_level = clampf(breath_level + amount, 0.0, 1.0)
    _publish_state()

func calm_down(amount: float = 0.05) -> void:
    breath_level = clampf(breath_level - amount, 0.0, 1.0)
    _publish_state()

func get_state() -> Dictionary:
    return {
        "enabled": enabled,
        "breath_level": breath_level,
        "last_intensity": last_intensity,
        "breath_rate": lerpf(0.65, 1.8, breath_level),
        "volume_scale": lerpf(0.15, 0.9, breath_level)
    }

func _publish_state() -> void:
    var state := get_state()
    GameState.set_value("audio.breath", state)
    EventBus.emit_game_event("breath_state_changed", state)
