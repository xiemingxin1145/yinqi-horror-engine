extends Node

func inspect_item(item_id: String, action_override: String = "") -> Dictionary:
    DataRegistry.load_all_data()
    var item := DataRegistry.get_interactable(item_id).duplicate(true)
    if item.is_empty():
        return {"ok": false, "reason": "unknown_item", "item_id": item_id}

    item["id"] = item_id
    var action_name := action_override
    if action_name == "":
        action_name = str(item.get("default_action", "inspect"))

    var result := {
        "ok": true,
        "action": action_name,
        "item_id": item_id,
        "item_name": item.get("name", item_id),
        "clue": {},
        "rule_result": {},
        "storyline_result": {},
        "director_state": {}
    }

    var clue: Dictionary = item.get("clue", {})
    if not clue.is_empty() and clue.has("id"):
        ClueStore.add_item(str(clue.get("id")), clue)
        result["clue"] = clue

    var rule_action: Dictionary = item.get("rule_action", {}).duplicate(true)
    if not rule_action.is_empty():
        if action_override != "":
            rule_action["action"] = action_override
        var case_data := GameState.get_value("case", {})
        var rule_result := FolkloreRules.check_rule_violation(rule_action, case_data)
        result["rule_result"] = rule_result
        if bool(rule_result.get("violated", false)):
            _apply_risk_delta(int(rule_result.get("risk_delta", 0)))
            result["director_state"] = HorrorDirector.evaluate_from_game_state()

    if Engine.has_singleton("StorylineEngine"):
        pass
    if has_node("/root/StorylineEngine"):
        result["storyline_result"] = get_node("/root/StorylineEngine").evaluate_open_threads()

    EventBus.emit_game_event("item_inspected", result)
    return result

func inspect_current_location_first_item() -> Dictionary:
    var items := LocationController.get_current_interactables()
    if items.is_empty():
        return {"ok": false, "reason": "no_interactables"}
    return inspect_item(str(items[0].get("id", "")))

func perform_item_action(item_id: String, action_name: String) -> Dictionary:
    return inspect_item(item_id, action_name)

func _apply_risk_delta(delta: int) -> void:
    var danger := int(GameState.get_value("player.danger", 0))
    GameState.set_value("player.danger", danger + delta)
    EventBus.emit_game_event("risk_changed", {"delta": delta, "danger": danger + delta})
