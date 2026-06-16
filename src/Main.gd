extends Node2D

@onready var status_label: Label = $Status

var event_log: Array[String] = []

func _ready() -> void:
    EventBus.game_event.connect(_on_game_event)
    EventBus.horror_event_requested.connect(_on_horror_event_requested)
    EventBus.clue_added.connect(_on_clue_added)

    GameState.reset()
    ClueStore.reset()
    DataRegistry.load_all_data(true)

    var world = WorldSim.create_world("开放地图演示世界")
    var case_data = FolkloreRules.generate_case_seed(world)

    var location_result = LocationController.enter_location("ancestral_hall")
    var inspect_result = InteractionController.inspect_item("paper_figure")
    var taboo_result = InteractionController.perform_item_action("paper_figure", "paint_eye")
    var storyline_result = StorylineEngine.evaluate_open_threads()
    var npc_plans = NPCBehaviorPlanner.plan_for_all_npcs(world, case_data)
    var director_state = HorrorDirector.evaluate_from_game_state()
    var snapshot = GameState.snapshot()

    status_label.text = _build_status_text(
        world,
        case_data,
        location_result,
        inspect_result,
        taboo_result,
        storyline_result,
        director_state,
        snapshot,
        npc_plans
    )

func _build_status_text(world: Dictionary, case_data: Dictionary, location_result: Dictionary, inspect_result: Dictionary, taboo_result: Dictionary, storyline_result: Dictionary, director_state: Dictionary, snapshot: Dictionary, npc_plans: Array) -> String:
    var location_names := []
    for location in world.get("locations", []):
        location_names.append(location.get("name", location.get("id", "unknown")))

    var npc_names := []
    for npc in world.get("npcs", []):
        npc_names.append(npc.get("name", npc.get("id", "unknown")))

    var plan_lines := []
    for plan in npc_plans:
        plan_lines.append("%s:%s" % [plan.get("npc_name", "unknown"), plan.get("action", "idle")])

    var interactable_names := []
    for item in location_result.get("interactables", []):
        interactable_names.append(item.get("name", item.get("id", "unknown")))

    var data_summary := DataRegistry.summary()

    return "《阴契》开放地图 + 开放剧情线 调试面板\n\nData: locations=%s npcs=%s rules=%s events=%s interactables=%s storylines=%s\n\nWorld: %s\nLocations: %s\nNPCs: %s\nNPCPlans: %s\n\nCurrentLocation: %s\nInteractables: %s\n\nCase: %s / %s\nInspect: %s\nTabooAction: %s\nOpenStorylines: %s\nClues: %s\nDirector: %s / intensity %s / events=%s\nFlags: %s\n\nEventLog:\n%s" % [
        data_summary.get("locations", 0),
        data_summary.get("npcs", 0),
        data_summary.get("rules", 0),
        data_summary.get("events", 0),
        data_summary.get("interactables", 0),
        data_summary.get("storylines", 0),
        world.get("name", "unknown"),
        ", ".join(location_names),
        ", ".join(npc_names),
        ", ".join(plan_lines),
        location_result.get("location", {}).get("name", "unknown"),
        ", ".join(interactable_names),
        case_data.get("title", "unknown"),
        case_data.get("location_name", case_data.get("location", "unknown")),
        inspect_result,
        taboo_result,
        storyline_result,
        ClueStore.list_item_ids(),
        director_state.get("phase", "unknown"),
        director_state.get("intensity", 0),
        director_state.get("events", []).size(),
        snapshot.get("flags", {}),
        "\n".join(event_log)
    ]

func _on_game_event(event_name: String, payload: Dictionary) -> void:
    event_log.append("GAME: %s" % event_name)

func _on_horror_event_requested(event_packet: Dictionary) -> void:
    event_log.append("HORROR: %s/%s -> %s" % [
        event_packet.get("type", "generic"),
        event_packet.get("id", "unknown"),
        event_packet.get("target", "world")
    ])

func _on_clue_added(clue_id: String, _clue_data: Dictionary) -> void:
    event_log.append("CLUE: %s" % clue_id)
