extends Node2D

@onready var status_label: Label = $Status
@onready var scene_effect_executor: Node = $SceneEffectExecutor

var event_log: Array[String] = []

func _ready() -> void:
    EventBus.game_event.connect(_on_game_event)
    EventBus.horror_event_requested.connect(_on_horror_event_requested)
    EventBus.clue_added.connect(_on_clue_added)

    GameState.reset()
    ClueStore.reset()
    RenderingDirector.clear_commands()
    DataRegistry.load_all_data(true)

    var world := WorldSim.create_world("engine_matrix_world")
    var case_data := FolkloreRules.generate_case_seed(world)

    GameState.set_value("player.fear", 18)
    GameState.set_value("player.progress", 25)
    GameState.set_value("player.danger", case_data.get("risk", 0))
    GameState.set_value("player.clue_pressure", 12)

    var location_result := LocationController.enter_location("ancestral_hall")
    var map_skin_result := MapSkinDirector.apply_location_skin("ancestral_hall")
    var inspect_result := InteractionController.inspect_item("paper_figure")
    var taboo_result := InteractionController.perform_item_action("paper_figure", "paint_eye")
    var storyline_result := StorylineEngine.evaluate_open_threads()
    var npc_plans := NPCBehaviorPlanner.plan_for_all_npcs(world, case_data)
    var director_state := HorrorDirector.evaluate_from_game_state()
    var engine_summary := EngineHub.summary()
    var render_commands := RenderingDirector.get_commands()
    var executed_commands := []
    if scene_effect_executor != null and scene_effect_executor.has_method("get_executed_commands"):
        executed_commands = scene_effect_executor.get_executed_commands()

    status_label.text = _build_text(
        world,
        case_data,
        location_result,
        map_skin_result,
        inspect_result,
        taboo_result,
        storyline_result,
        director_state,
        npc_plans,
        engine_summary,
        render_commands,
        executed_commands
    )

func _build_text(world: Dictionary, case_data: Dictionary, location_result: Dictionary, map_skin_result: Dictionary, inspect_result: Dictionary, taboo_result: Dictionary, storyline_result: Dictionary, director_state: Dictionary, npc_plans: Array, engine_summary: Dictionary, render_commands: Array, executed_commands: Array) -> String:
    var summary := DataRegistry.summary()
    var plans := []
    for plan in npc_plans:
        plans.append("%s:%s" % [plan.get("npc_name", "npc"), plan.get("action", "idle")])

    var interactable_names := []
    for item in location_result.get("interactables", []):
        interactable_names.append(item.get("name", item.get("id", "unknown")))

    return "《阴契》Engine Matrix Loop V0.3\n\nEngineHub %s\nData %s\nWorld %s\nCase %s\n\nLocation %s\nMapSkin %s\nInteractables %s\nInspect %s\nTaboo %s\nStorylines %s\n\nDirector %s intensity=%s events=%s\nRenderCommands %s\nExecutedEffects %s\nNPC %s\nFlags %s\nClues %s\n\nEvents\n%s" % [
        engine_summary,
        summary,
        world.get("name", "world"),
        case_data.get("title", "case"),
        location_result.get("location", {}).get("name", "unknown"),
        map_skin_result.get("skin", {}).get("name", "no_skin"),
        ", ".join(interactable_names),
        inspect_result,
        taboo_result,
        storyline_result,
        director_state.get("phase", "phase"),
        director_state.get("intensity", 0),
        director_state.get("events", []).size(),
        render_commands.size(),
        executed_commands.size(),
        ", ".join(plans),
        GameState.get_value("flags", {}),
        ClueStore.list_item_ids(),
        "\n".join(event_log)
    ]

func _on_game_event(event_name: String, _payload: Dictionary) -> void:
    event_log.append("GAME " + event_name)

func _on_horror_event_requested(event_packet: Dictionary) -> void:
    event_log.append("HORROR %s %s" % [event_packet.get("type", "generic"), event_packet.get("id", "event")])

func _on_clue_added(clue_id: String, _clue_data: Dictionary) -> void:
    event_log.append("CLUE " + clue_id)
