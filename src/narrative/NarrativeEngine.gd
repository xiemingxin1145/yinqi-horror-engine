extends Node

const DIALOGUE_TOOL_NONE := "none"
const DIALOGUE_TOOL_DIALOGUE_MANAGER := "dialogue_manager"
const DIALOGUE_TOOL_DIALOGIC := "dialogic"

var preferred_dialogue_tool: String = DIALOGUE_TOOL_DIALOGUE_MANAGER

func build_opening(world: Dictionary, case_data: Dictionary, ghost: Dictionary) -> String:
    return "你在%s的%s醒来，细雨敲着窗。桌上压着一页残缺族谱，旁边放着半截红线。%s似乎还没有真正离开。" % [
        world.get("name", "村庄"),
        case_data.get("location", "老宅"),
        ghost.get("name", "某个东西")
    ]

func chain_clues(case_data: Dictionary) -> Array:
    return case_data.get("clues", [])

func build_dialogue_context(world: Dictionary, case_data: Dictionary, npc: Dictionary) -> Dictionary:
    return {
        "world_name": world.get("name", "村庄"),
        "time": world.get("time", "子时"),
        "weather": world.get("weather", "细雨"),
        "case_id": case_data.get("id", "unknown_case"),
        "case_title": case_data.get("title", "未命名怪事"),
        "location": case_data.get("location", "老宅"),
        "npc_id": npc.get("id", "unknown_npc"),
        "npc_name": npc.get("name", "无名人"),
        "npc_fear": npc.get("fear", 0),
        "npc_trust": npc.get("trust", 0),
        "unlocked_clues": case_data.get("clues", [])
    }

func request_dialogue_start(dialogue_id: String, context: Dictionary) -> Dictionary:
    # Bridge layer only. Real Dialogue Manager / Dialogic plugin calls should be added later.
    # Keep this method stable so game code does not depend on a specific plugin.
    if preferred_dialogue_tool == DIALOGUE_TOOL_DIALOGUE_MANAGER:
        return {
            "tool": DIALOGUE_TOOL_DIALOGUE_MANAGER,
            "dialogue_id": dialogue_id,
            "context": context,
            "status": "plugin_not_installed_yet"
        }
    if preferred_dialogue_tool == DIALOGUE_TOOL_DIALOGIC:
        return {
            "tool": DIALOGUE_TOOL_DIALOGIC,
            "dialogue_id": dialogue_id,
            "context": context,
            "status": "plugin_not_installed_yet"
        }
    return {
        "tool": DIALOGUE_TOOL_NONE,
        "dialogue_id": dialogue_id,
        "context": context,
        "status": "fallback_text_only"
    }

func apply_dialogue_mutation(mutation_id: String, payload: Dictionary) -> Dictionary:
    # Dialogue choices should call this instead of directly changing world state.
    # Later this will route to FolkloreRules, NPCMemory, WorldSim and GhostGenerator.
    match mutation_id:
        "unlock_clue":
            return {"ok": true, "effect": "clue_unlocked", "payload": payload}
        "npc_remember":
            NPCMemory.remember(str(payload.get("npc_id", "unknown_npc")), {
                "text": str(payload.get("text", "")),
                "tags": payload.get("tags", [])
            })
            return {"ok": true, "effect": "memory_written", "payload": payload}
        "raise_risk":
            return {"ok": true, "effect": "risk_delta", "delta": int(payload.get("delta", 0))}
        _:
            return {"ok": false, "effect": "unknown_mutation", "payload": payload}
