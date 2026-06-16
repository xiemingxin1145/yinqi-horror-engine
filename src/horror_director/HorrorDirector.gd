extends Node

const PHASE_RELAX := "relax"
const PHASE_BUILD := "build"
const PHASE_PEAK := "peak"
const PHASE_COOLDOWN := "cooldown"

var current_phase: String = PHASE_RELAX
var last_intensity: int = 0

func evaluate_pressure(player_state: Dictionary) -> Dictionary:
    var fear = int(player_state.get("fear", 0))
    var progress = int(player_state.get("progress", 0))
    var danger = int(player_state.get("danger", 0))
    var clue_pressure = int(player_state.get("clue_pressure", 0))
    var intensity = clampi(fear + progress + danger + clue_pressure, 0, 100)
    last_intensity = intensity
    current_phase = _phase_for_intensity(intensity)
    var state := {
        "phase": current_phase,
        "mood": _mood_for_phase(current_phase),
        "intensity": intensity,
        "events": _events_for_phase(current_phase, intensity)
    }
    GameState.set_value("player.last_director_state", state)
    EventBus.emit_game_event("horror_director_evaluated", state)
    for event_packet in state.get("events", []):
        EventBus.emit_horror_event(event_packet)
    return state

func evaluate_from_game_state() -> Dictionary:
    return evaluate_pressure(GameState.get_value("player", {}))

func _phase_for_intensity(intensity: int) -> String:
    if intensity >= 85:
        return PHASE_PEAK
    if intensity >= 55:
        return PHASE_BUILD
    if intensity >= 30:
        return PHASE_COOLDOWN
    return PHASE_RELAX

func _mood_for_phase(phase: String) -> String:
    match phase:
        PHASE_PEAK:
            return "high_pressure"
        PHASE_BUILD:
            return "uneasy"
        PHASE_COOLDOWN:
            return "aftershock"
        _:
            return "quiet"

func _events_for_phase(phase: String, intensity: int) -> Array:
    var registry_events := _events_from_registry(intensity)
    if not registry_events.is_empty():
        return registry_events

    match phase:
        PHASE_PEAK:
            return [
                _event("near_footsteps", "audio", "behind_player", 0.95, intensity),
                _event("light_flicker", "light", "main_lamp", 0.80, intensity),
                _event("paper_bride_shadow", "visual", "corridor", 0.65, intensity)
            ]
        PHASE_BUILD:
            return [
                _event("door_knock", "audio", "door", 0.80, intensity),
                _event("paper_ash", "particle", "room_center", 0.55, intensity),
                _event("distant_opera", "audio", "far_stage", 0.45, intensity)
            ]
        PHASE_COOLDOWN:
            return [
                _event("candle_noise", "audio", "altar", 0.45, intensity),
                _event("small_object_shift", "animation", "desk_item", 0.35, intensity)
            ]
        _:
            return [
                _event("wind", "audio", "window", 0.25, intensity),
                _event("rain_loop", "audio", "ambient", 0.25, intensity)
            ]

func _events_from_registry(intensity: int) -> Array:
    var result := []
    for event_id in DataRegistry.event_templates.keys():
        var template := DataRegistry.get_event_template(event_id)
        if intensity >= int(template.get("min_intensity", 0)):
            result.append(_event(
                event_id,
                str(template.get("type", "generic")),
                str(template.get("target", "world")),
                0.5,
                intensity
            ))
    return result

func _event(id: String, event_type: String, target: String, weight: float, intensity: int) -> Dictionary:
    return {
        "id": id,
        "type": event_type,
        "target": target,
        "weight": weight,
        "intensity": intensity
    }
