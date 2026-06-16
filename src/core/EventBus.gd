extends Node

signal game_event(event_name: String, payload: Dictionary)
signal state_changed(path: String, value)
signal clue_added(clue_id: String, clue_data: Dictionary)
signal horror_event_requested(event_packet: Dictionary)

var history: Array[Dictionary] = []

func emit_game_event(event_name: String, payload: Dictionary = {}) -> void:
    _record("game", event_name, payload)
    game_event.emit(event_name, payload)

func emit_state_changed(path: String, value) -> void:
    _record("state", path, {"value": value})
    state_changed.emit(path, value)

func emit_clue_added(clue_id: String, clue_data: Dictionary) -> void:
    _record("clue", clue_id, clue_data)
    clue_added.emit(clue_id, clue_data)

func emit_horror_event(event_packet: Dictionary) -> void:
    _record("horror", str(event_packet.get("id", "unknown")), event_packet)
    horror_event_requested.emit(event_packet)

func clear_history() -> void:
    history.clear()

func last_events(limit: int = 20) -> Array:
    if limit <= 0 or history.size() <= limit:
        return history.duplicate(true)
    return history.slice(history.size() - limit, history.size())

func _record(kind: String, name: String, payload: Dictionary) -> void:
    history.append({
        "kind": kind,
        "name": name,
        "payload": payload,
        "index": history.size()
    })
