extends Node

func create_from_case(case_data: Dictionary) -> Dictionary:
    return {
        "id": "paper_bride",
        "name": "纸新娘",
        "origin": case_data.get("title", "unknown"),
        "haunt_location": case_data.get("location", "老宅"),
        "obsession": "寻找未完成的婚契",
        "danger": case_data.get("risk", 50),
        "weakness": "完整族谱 + 断红线 + 未点睛纸人",
        "appear_conditions": ["子时", "雨夜", "玩家持有红线"]
    }
