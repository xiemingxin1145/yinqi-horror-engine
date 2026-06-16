extends Node

func create_world(world_name: String) -> Dictionary:
    return {
        "name": world_name,
        "time": "子时",
        "weather": "细雨",
        "locations": ["村口", "祠堂", "老宅", "戏台", "河桥"],
        "npcs": [
            {"id": "village_head", "name": "村长", "fear": 20, "trust": 35},
            {"id": "paper_master", "name": "纸扎匠", "fear": 45, "trust": 20},
            {"id": "opera_leader", "name": "戏班班主", "fear": 30, "trust": 25},
            {"id": "widow", "name": "王寡妇", "fear": 60, "trust": 10}
        ],
        "flags": []
    }

func tick(world: Dictionary) -> Dictionary:
    var next_world = world.duplicate(true)
    next_world["time"] = "丑时" if world.get("time") == "子时" else "子时"
    return next_world
