extends Node

var state: Dictionary = {
    "world": {},
    "case": {},
    "player": {
        "fear": 0,
        "progress": 0,
        "danger": 0,
        "clue_pressure": 0
    },
    "flags": {},
    "clues": {},
    "npcs": {},
    "ghosts": {}
}

func reset() -> void:
    state["world"] = {}
    state["case"] = {}
    state["player"] = {"fear": 0, "progress": 0, "danger": 0, "clue_pressure": 0}
    state["flags"] = {}
    state["clues"] = {}
    state["npcs"] = {}
    state["ghosts"] = {}
    EventBus.emit_game_event("game_state_reset")

func set_value(path: String, value) -> void:
    var parts := path.split(".")
    if parts.is_empty():
        return
    var cursor = state
    for i in range(parts.size() - 1):
        var key := parts[i]
        if not cursor.has(key) or typeof(cursor[key]) != TYPE_DICTIONARY:
            cursor[key] = {}
        cursor = cursor[key]
    cursor[parts[-1]] = value
    EventBus.emit_state_changed(path, value)

func get_value(path: String, fallback = null):
    var parts := path.split(".")
    var cursor = state
    for key in parts:
        if typeof(cursor) != TYPE_DICTIONARY or not cursor.has(key):
            return fallback
        cursor = cursor[key]
    return cursor

func add_clue(clue_id: String, clue_data: Dictionary) -> void:
    state["clues"][clue_id] = clue_data
    EventBus.emit_clue_added(clue_id, clue_data)

func set_flag(flag_id: String, value = true) -> void:
    state["flags"][flag_id] = value
    EventBus.emit_state_changed("flags.%s" % flag_id, value)

func has_flag(flag_id: String) -> bool:
    return bool(state["flags"].get(flag_id, false))

func snapshot() -> Dictionary:
    return state.duplicate(true)
