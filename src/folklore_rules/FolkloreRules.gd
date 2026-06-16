extends Node

func generate_case_seed(world: Dictionary) -> Dictionary:
    var time = world.get("time", "子时")
    var location = "祠堂"
    return {
        "id": "ancestral_contract",
        "title": "阴契未断",
        "time": time,
        "location": location,
        "rules": ["忌夜入祠堂", "忌直呼亡者姓名", "纸人不可点睛"],
        "clues": ["族谱缺页", "红线断在供桌下", "纸人袖口有泥"],
        "risk": 65
    }

func check_rule_violation(action: Dictionary, case_data: Dictionary) -> Dictionary:
    return {
        "violated": false,
        "reason": "no rule matched",
        "risk_delta": 0
    }
