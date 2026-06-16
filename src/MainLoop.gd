extends Node2D

@onready var status_label: Label = $Status
@onready var scene_effect_executor: Node = $SceneEffectExecutor

var event_log: Array[String] = []
var demo_actions: Array[String] = []

func _ready() -> void:
    EventBus.game_event.connect(_on_game_event)
    EventBus.horror_event_requested.connect(_on_horror_event_requested)
    EventBus.clue_added.connect(_on_clue_added)

    GameState.reset()
    ClueStore.reset()
    RenderingDirector.clear_commands()
    DataRegistry.load_all_data(true)

    GameState.set_value("player.fear", 10)
    GameState.set_value("player.progress", 0)
    GameState.set_value("player.danger", 15)
    GameState.set_value("player.clue_pressure", 0)

    var start_result := ViewpointDirector.start("village_gate")
    demo_actions.append("进入试玩版：村口")

    var inspect_boundary := HotspotController.inspect_hotspot("broken_boundary_stone")
    demo_actions.append("调查界碑")

    var turn_right_result := ViewpointDirector.turn_right()
    demo_actions.append("右转：土路与麦克风")

    var inspect_microphone := HotspotController.inspect_hotspot("qingqing_microphone")
    demo_actions.append("调查麦克风，获得落水声录音")

    var go_bridge_result := ViewpointDirector.go_exit()
    demo_actions.append("前往河桥")

    var inspect_white_cloth := HotspotController.inspect_hotspot("oil_soaked_white_cloth")
    demo_actions.append("调查香油白布")

    var turn_bridge_result := ViewpointDirector.turn_right()
    demo_actions.append("右转：桥面脚印")

    var inspect_student_id := HotspotController.inspect_hotspot("student_id_necklace")
    demo_actions.append("调查学生证项链，确认林晚秋身份")

    GameState.set_value("player.progress", 20)
    GameState.set_value("player.clue_pressure", ClueStore.list_item_ids().size() * 5)
    var director_state := HorrorDirector.evaluate_from_game_state()
    var storyline_result := StorylineEngine.evaluate_open_threads()
    var current_viewpoint := ViewpointDirector.get_current_viewpoint()
    var visible_hotspots := ViewpointDirector.get_current_hotspots()
    var render_commands := RenderingDirector.get_commands()
    var executed_commands := []
    if scene_effect_executor != null and scene_effect_executor.has_method("get_executed_commands"):
        executed_commands = scene_effect_executor.get_executed_commands()

    status_label.text = _build_text(
        start_result,
        inspect_boundary,
        turn_right_result,
        inspect_microphone,
        go_bridge_result,
        inspect_white_cloth,
        turn_bridge_result,
        inspect_student_id,
        current_viewpoint,
        visible_hotspots,
        storyline_result,
        director_state,
        render_commands,
        executed_commands
    )

func _build_text(start_result: Dictionary, inspect_boundary: Dictionary, turn_right_result: Dictionary, inspect_microphone: Dictionary, go_bridge_result: Dictionary, inspect_white_cloth: Dictionary, turn_bridge_result: Dictionary, inspect_student_id: Dictionary, current_viewpoint: Dictionary, visible_hotspots: Array, storyline_result: Dictionary, director_state: Dictionary, render_commands: Array, executed_commands: Array) -> String:
    var summary := DataRegistry.summary()
    var hotspot_names := []
    for item in visible_hotspots:
        hotspot_names.append(item.get("name", item.get("id", "unknown")))

    return "《阴契》试玩版 V0.1：村口 → 河桥\n\nData %s\nCurrentViewpoint: %s / %s\nVisibleHotspots: %s\n\nDemoActions:\n%s\n\nStart %s\nBoundary %s\nTurnGate %s\nMicrophone %s\nGoBridge %s\nWhiteCloth %s\nTurnBridge %s\nStudentId %s\n\nClues %s\nStorylines %s\nDirector %s intensity=%s events=%s\nRenderCommands %s\nExecutedEffects %s\nFlags %s\n\nEvents\n%s\n\n试玩版结束：前往老宅的路被雾封住，后续版本开放。" % [
        summary,
        current_viewpoint.get("location", "unknown"),
        current_viewpoint.get("name", "unknown"),
        ", ".join(hotspot_names),
        "\n".join(demo_actions),
        start_result.get("ok", false),
        inspect_boundary.get("clue", {}),
        turn_right_result.get("viewpoint", {}).get("name", "unknown"),
        inspect_microphone.get("clue", {}),
        go_bridge_result.get("viewpoint", {}).get("name", "unknown"),
        inspect_white_cloth.get("clue", {}),
        turn_bridge_result.get("viewpoint", {}).get("name", "unknown"),
        inspect_student_id.get("clue", {}),
        ClueStore.list_item_ids(),
        storyline_result,
        director_state.get("phase", "phase"),
        director_state.get("intensity", 0),
        director_state.get("events", []).size(),
        render_commands.size(),
        executed_commands.size(),
        GameState.get_value("flags", {}),
        "\n".join(event_log)
    ]

func _on_game_event(event_name: String, _payload: Dictionary) -> void:
    event_log.append("GAME " + event_name)

func _on_horror_event_requested(event_packet: Dictionary) -> void:
    event_log.append("HORROR %s %s" % [event_packet.get("type", "generic"), event_packet.get("id", "event")])

func _on_clue_added(clue_id: String, _clue_data: Dictionary) -> void:
    event_log.append("CLUE " + clue_id)
