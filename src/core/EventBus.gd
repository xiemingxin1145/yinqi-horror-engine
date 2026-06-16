extends Node

signal game_event(event_name: String, payload: Dictionary)
signal state_changed(path: String, value)
signal clue_added(clue_id: String, clue_data: Dictionary)
signal horror_event_requested(event_packet: Dictionary)

func emit_game_event(event_name: String, payload: Dictionary = {}) -> void:
    game_event.emit(event_name, payload)

func emit_state_changed(path: String, value) -> void:
    state_changed.emit(path, value)

func emit_clue_added(clue_id: String, clue_data: Dictionary) -> void:
    clue_added.emit(clue_id, clue_data)

func emit_horror_event(event_packet: Dictionary) -> void:
    horror_event_requested.emit(event_packet)
