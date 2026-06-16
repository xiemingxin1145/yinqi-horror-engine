extends Node

func run_demo() -> Dictionary:
    var item := {
        "id": "paper_figure",
        "name": "未点睛纸人",
        "clue": {"id": "paper_sleeve_mark", "name": "纸人袖口泥痕", "tags": ["paper_figure"], "text": "纸人袖口有泥痕。"},
        "rule_action": {"time": "子时", "item_tag": "paper_figure", "action": "paint_eye"}
    }

    ClueStore.add_item(str(item["clue"].get("id")), item["clue"])
    var rule_result := FolkloreRules.check_rule_violation(item["rule_action"], GameState.get_value("case", {}))
    if bool(rule_result.get("violated", false)):
        var danger := int(GameState.get_value("player.danger", 0))
        GameState.set_value("player.danger", danger + int(rule_result.get("risk_delta", 0)))

    var director_state := HorrorDirector.evaluate_from_game_state()
    var result := {
        "item": item.get("name"),
        "clue": item.get("clue"),
        "rule_result": rule_result,
        "director_state": director_state
    }
    EventBus.emit_game_event("minimal_interaction_loop_completed", result)
    return result
