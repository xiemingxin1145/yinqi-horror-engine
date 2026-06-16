extends Node

func inspect_item(item_id: String) -> Dictionary:
    DataRegistry.load_all_data()
    var item := _get_item(item_id)
    if item.is_empty():
        return {"ok": false, "reason": "unknown_item", "item_id": item_id}

    var result := {
        "ok": true,
        "item_id": item_id,
        "item_name": item.get("name", item_id),
        "clue": {},
        "rule_result": {},
        "director_state": {}
    }

    var clue: Dictionary = item.get("clue", {})
    if not clue.is_empty() and clue.has("id"):
        ClueStore.add_item(str(clue.get("id")), clue)
        result["clue"] = clue

    var rule_action: Dictionary = item.get("rule_action", {})
    if not rule_action.is_empty():
        var case_data := GameState.get_value("case", {})
        var rule_result := FolkloreRules.check_rule_violation(rule_action, case_data)
        result["rule_result"] = rule_result
        if bool(rule_result.get("violated", false)):
            _apply_risk_delta(int(rule_result.get("risk_delta", 0)))
            result["director_state"] = HorrorDirector.evaluate_from_game_state()

    EventBus.emit_game_event("item_inspected", result)
    return result

func _apply_risk_delta(delta: int) -> void:
    var danger := int(GameState.get_value("player.danger", 0))
    GameState.set_value("player.danger", danger + delta)

func _get_item(item_id: String) -> Dictionary:
    if DataRegistry.has_method("get_interactable_template"):
        return DataRegistry.get_interactable_template(item_id)
    return {}
