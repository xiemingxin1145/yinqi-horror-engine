extends Node

var active_threads: Dictionary = {}

func evaluate_open_threads() -> Dictionary:
    DataRegistry.load_all_data()
    var activated := []
    var blocked := []

    for thread_id in DataRegistry.storyline_templates.keys():
        var thread := DataRegistry.get_storyline(thread_id).duplicate(true)
        var missing := _missing_required_clues(thread)
        if missing.is_empty():
            _activate_thread(thread_id, thread)
            activated.append(thread_id)
        else:
            blocked.append({"id": thread_id, "missing": missing})

    var result := {"activated": activated, "blocked": blocked, "active_threads": active_threads.keys()}
    EventBus.emit_game_event("storylines_evaluated", result)
    return result

func _missing_required_clues(thread: Dictionary) -> Array:
    var missing := []
    for clue_id in thread.get("required_clues", []):
        if not ClueStore.has_item(str(clue_id)):
            missing.append(str(clue_id))
    return missing

func _activate_thread(thread_id: String, thread: Dictionary) -> void:
    if active_threads.has(thread_id):
        return
    active_threads[thread_id] = thread
    var effects: Dictionary = thread.get("effects", {})
    var flag_id := str(effects.get("activate_flag", ""))
    if flag_id != "":
        GameState.set_flag(flag_id, true)
    var risk_delta := int(effects.get("risk_delta", 0))
    if risk_delta != 0:
        var danger := int(GameState.get_value("player.danger", 0))
        GameState.set_value("player.danger", danger + risk_delta)
    GameState.set_value("storylines.%s" % thread_id, thread)
    EventBus.emit_game_event("storyline_activated", {"id": thread_id, "thread": thread})

func get_active_threads() -> Dictionary:
    return active_threads.duplicate(true)
