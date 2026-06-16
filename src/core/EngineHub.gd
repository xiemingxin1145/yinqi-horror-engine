extends Node

var modules: Dictionary = {}

func _ready() -> void:
    register_default_modules()

func register_default_modules() -> void:
    register_module("world_sim_engine", "世界模拟引擎", "foundation_ready", "WorldSim")
    register_module("folklore_rule_engine", "民俗规则引擎", "foundation_ready", "FolkloreRules")
    register_module("horror_director_engine", "恐怖导演引擎", "foundation_ready", "HorrorDirector")
    register_module("rendering_engine", "动态渲染引擎", "command_layer_ready", "RenderingDirector")
    register_module("open_map_engine", "开放地图引擎", "foundation_ready", "LocationController")
    register_module("interaction_engine", "交互探索引擎", "foundation_ready", "InteractionController")
    register_module("clue_engine", "线索引擎", "foundation_ready", "ClueStore")
    register_module("storyline_engine", "开放剧情线引擎", "foundation_ready", "StorylineEngine")
    register_module("npc_memory_engine", "NPC记忆引擎", "prototype", "NPCMemory")
    register_module("npc_behavior_engine", "NPC行为引擎", "foundation_ready", "NPCBehaviorPlanner")
    register_module("ghost_generator_engine", "鬼怪生成引擎", "prototype", "GhostGenerator")
    register_module("narrative_engine", "叙事桥接引擎", "bridge_ready", "NarrativeEngine")
    EventBus.emit_game_event("engine_hub_registered", summary())

func register_module(module_id: String, module_name: String, status: String, singleton_name: String) -> void:
    modules[module_id] = {
        "id": module_id,
        "name": module_name,
        "status": status,
        "singleton": singleton_name
    }

func set_module_status(module_id: String, status: String) -> void:
    if not modules.has(module_id):
        return
    modules[module_id]["status"] = status
    EventBus.emit_game_event("engine_module_status_changed", modules[module_id])

func get_module(module_id: String) -> Dictionary:
    return modules.get(module_id, {})

func list_modules() -> Array:
    return modules.values()

func summary() -> Dictionary:
    var counts := {}
    for module in modules.values():
        var status := str(module.get("status", "unknown"))
        counts[status] = int(counts.get(status, 0)) + 1
    return {
        "total": modules.size(),
        "status_counts": counts,
        "modules": modules.keys()
    }
