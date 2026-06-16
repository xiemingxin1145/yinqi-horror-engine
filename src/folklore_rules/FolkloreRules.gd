extends Node

func generate_case_seed(world: Dictionary) -> Dictionary:
    DataRegistry.seed_minimal_demo_data()
    var primary_location := "ancestral_hall"
    if not DataRegistry.locations.has(primary_location) and not DataRegistry.locations.is_empty():
        primary_location = DataRegistry.locations.keys()[0]

    var location_data := DataRegistry.get_location(primary_location)
    var active_rules := []
    for rule_id in DataRegistry.rule_templates.keys():
        var rule := DataRegistry.get_rule(rule_id).duplicate(true)
        rule["id"] = rule_id
        active_rules.append(rule)

    var case_data := {
        "id": "foundation_demo_case",
        "title": "地基演示案",
        "time": world.get("time", "子时"),
        "location": primary_location,
        "location_name": location_data.get("name", primary_location),
        "rules": active_rules,
        "clues": [],
        "risk": int(location_data.get("risk", 10))
    }

    GameState.set_value("case", case_data)
    EventBus.emit_game_event("case_seed_created", case_data)
    return case_data

func check_rule_violation(action: Dictionary, case_data: Dictionary) -> Dictionary:
    for rule in case_data.get("rules", []):
        var conditions: Dictionary = rule.get("conditions", {})
        if _matches_conditions(action, conditions):
            var effects: Dictionary = rule.get("effects", {})
            var result := {
                "violated": true,
                "rule_id": rule.get("id", "unknown_rule"),
                "rule_name": rule.get("name", "未命名规则"),
                "risk_delta": int(effects.get("risk_delta", 0)),
                "event": effects.get("event", ""),
                "flag": effects.get("flag", "")
            }
            if result.get("flag", "") != "":
                GameState.set_flag(result.get("flag"), true)
            EventBus.emit_game_event("folklore_rule_violated", result)
            return result

    return {
        "violated": false,
        "reason": "no rule matched",
        "risk_delta": 0
    }

func _matches_conditions(action: Dictionary, conditions: Dictionary) -> bool:
    for key in conditions.keys():
        if not action.has(key):
            return false
        if str(action.get(key)) != str(conditions.get(key)):
            return false
    return true
