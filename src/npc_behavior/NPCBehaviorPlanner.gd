extends Node

# Lightweight behavior-tree-like planner.
# This keeps the project usable before we decide whether to import bitbrain/beehave.

func plan_for_npc(npc: Dictionary, world: Dictionary, case_data: Dictionary) -> Dictionary:
    var fear := int(npc.get("fear", 0))
    var trust := int(npc.get("trust", 0))
    var time := str(world.get("time", "子时"))

    if fear >= 70:
        return _action("hide", npc, "恐惧过高，先躲起来")
    if time == "子时" and npc.get("id") == "paper_master":
        return _action("guard_secret", npc, "纸扎匠在子时守住纸人秘密")
    if trust >= 50:
        return _action("share_clue", npc, "信任玩家，愿意说出一条线索")
    if case_data.get("location") == "祠堂":
        return _action("avoid_location", npc, "回避祠堂")
    return _action("idle", npc, "维持日常行为")

func _action(action_id: String, npc: Dictionary, reason: String) -> Dictionary:
    return {
        "action": action_id,
        "npc_id": npc.get("id", "unknown_npc"),
        "npc_name": npc.get("name", "无名人"),
        "reason": reason
    }
