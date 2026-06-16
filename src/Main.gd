extends Node2D

@onready var status_label: Label = $Status

var event_log: Array[String] = []

func _ready() -> void:
    EventBus.game_event.connect(_on_game_event)
    EventBus.horror_event_requested.connect(_on_horror_event_requested)
    EventBus.clue_added.connect(_on_clue_added)

    GameState.reset()
    var world = WorldSim.create_world("地基演示世界")
    var case_data = FolkloreRules.generate_case_seed(world)

    GameState.set_value("player.fear", 15)
    GameState.set_value("player.progress", 20)
    GameState.set_value("player.danger", case_data.get("risk", 0))
    GameState.set_value("player.clue_pressure", 10)

    var rule_result = FolkloreRules.check_rule_violation({
        "time": "子时",
        "item_tag": "paper_figure",
        "action": "paint_eye"
    }, case_data)

    var director_state = HorrorDirector.evaluate_from_game_state()
    var snapshot = GameState.snapshot()

    status_label.text = _build_status_text(world, case_data, rule_result, director_state, snapshot)

func _build_status_text(world: Dictionary, case_data: Dictionary, rule_result: Dictionary, director_state: Dictionary, snapshot: Dictionary) -> String:
    var location_names := []
    for location in world.get("locations", []):
        location_names.append(location.get("name", location.get("id", "unknown")))

    var npc_names := []
    for npc in world.get("npcs", []):
        npc_names.append(npc.get("name", npc.get("id", "unknown")))

    return "《阴契》地基演示\n\nWorld: %s\nLocations: %s\nNPCs: %s\nCase: %s / %s\nRule: %s\nDirector: %s / intensity %s\nFlags: %s\n\nEventLog:\n%s" % [
        world.get("name", "unknown"),
        ", ".join(location_names),
        ", ".join(npc_names),
        case_data.get("title", "unknown"),
        case_data.get("location_name", case_data.get("location", "unknown")),
        rule_result,
        director_state.get("phase", "unknown"),
        director_state.get("intensity", 0),
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
