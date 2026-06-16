extends Node

func build_opening(world: Dictionary, case_data: Dictionary, ghost: Dictionary) -> String:
    return "你在%s的%s醒来，细雨敲着窗。桌上压着一页残缺族谱，旁边放着半截红线。%s似乎还没有真正离开。" % [
        world.get("name", "村庄"),
        case_data.get("location", "老宅"),
        ghost.get("name", "某个东西")
    ]

func chain_clues(case_data: Dictionary) -> Array:
    return case_data.get("clues", [])
