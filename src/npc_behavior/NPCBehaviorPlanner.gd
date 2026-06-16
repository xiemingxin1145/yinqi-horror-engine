extends Node

# Lightweight behavior-tree-like planner.
# This keeps the project usable before we decide whether to import bitbrain/beehave.

func plan_for_all_npcs(world: Dictionary, case_data: Dictionary) -> Array:
    var plans := []
    for npc in world.get("npcs", []):
        var plan := plan_for_npc(npc, world, case_data)
        plans.append(plan)
        GameState.set_value("npcs.%s.last_plan" % npc.get("id", "unknown_npc"), plan)
        EventBus.emit_game_event("npc_plan_created", plan)
    return plans

func plan_for_npc(npc: Dictionary, world: Dictionary, case_data: Dictionary) -> Dictionary:
    var fear := int(npc.get("fear", 0))
    var trust := int(npc.get("trust", 0))
    var time := str(world.get("time", "子时"))
    var case_location := str(case_data.get("location", ""))

    if fear >= 70:
        return _action("hide", npc, "fear_high")
    if time == "子时" and npc.get("id") == "paper_master":
        return _action("guard_secret", npc, "midnight_secret_keeper")
    if trust >= 50:
        return _action("share_clue", npc, "trust_high")
    if case_location == "ancestral_hall" and "secret_keeper" in npc.get("tags", []):
        return _action("avoid_location", npc, "avoid_case_location")
    return _action("idle", npc, "default")

func _action(action_id: String, npc: Dictionary, reason: String) -> Dictionary:
    return {
        "action": action_id,
        "npc_id": npc.get("id", "unknown_npc"),
        "npc_name": npc.get("name", "无名人"),
        "reason": reason
    }
