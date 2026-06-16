extends Node2D

const InteractionLoopScript := preload("res://src/interactions/InteractionLoop.gd")

@onready var status_label: Label = $Status

var event_log: Array[String] = []

func _ready() -> void:
    EventBus.game_event.connect(_on_game_event)
    EventBus.horror_event_requested.connect(_on_horror_event_requested)
    EventBus.clue_added.connect(_on_clue_added)

    GameState.reset()
    ClueStore.reset()

    var world := WorldSim.create_world("foundation_world")
    var case_data := FolkloreRules.generate_case_seed(world)
    var npc_plans := NPCBehaviorPlanner.plan_for_all_npcs(world, case_data)

    GameState.set_value("player.fear", 15)
    GameState.set_value("player.progress", 20)
    GameState.set_value("player.danger", case_data.get("risk", 0))
    GameState.set_value("player.clue_pressure", 10)

    var interaction_loop = InteractionLoopScript.new()
    add_child(interaction_loop)
    var loop_result: Dictionary = interaction_loop.run_demo()
    var director_state := HorrorDirector.evaluate_from_game_state()

    status_label.text = _build_text(world, case_data, loop_result, director_state, npc_plans)

func _build_text(world: Dictionary, case_data: Dictionary, loop_result: Dictionary, director_state: Dictionary, npc_plans: Array) -> String:
    var summary := DataRegistry.summary()
    var plans := []
    for plan in npc_plans:
        plans.append("%s:%s" % [plan.get("npc_name", "npc"), plan.get("action", "idle")])

    return "Yinqi foundation loop V0.1\n\nData %s\nWorld %s\nCase %s\nLoop %s\nDirector %s intensity=%s\nNPC %s\nFlags %s\nClues %s\n\nEvents\n%s" % [
        summary,
        world.get("name", "world"),
        case_data.get("title", "case"),
        loop_result,
        director_state.get("phase", "phase"),
        director_state.get("intensity", 0),
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
