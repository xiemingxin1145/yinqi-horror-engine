extends Node2D

@onready var status_label: Label = $Status
@onready var scene_effect_executor: Node = $SceneEffectExecutor

var event_log: Array[String] = []
var action_log: Array[String] = []
var last_result: Dictionary = {}
var button_left: Button
var button_right: Button
var button_inspect: Button
var button_exit: Button
var button_restart: Button

func _ready() -> void:
    _connect_events()
    _create_demo_buttons()
    _start_demo()

func _connect_events() -> void:
    if not EventBus.game_event.is_connected(_on_game_event):
        EventBus.game_event.connect(_on_game_event)
    if not EventBus.horror_event_requested.is_connected(_on_horror_event_requested):
        EventBus.horror_event_requested.connect(_on_horror_event_requested)
    if not EventBus.clue_added.is_connected(_on_clue_added):
        EventBus.clue_added.connect(_on_clue_added)

func _create_demo_buttons() -> void:
    button_left = _make_button("Left", Vector2(48, 560), Vector2(200, 76), _on_left_pressed)
    button_right = _make_button("Right", Vector2(280, 560), Vector2(200, 76), _on_right_pressed)
    button_inspect = _make_button("Inspect", Vector2(512, 560), Vector2(248, 76), _on_inspect_pressed)
    button_exit = _make_button("Go", Vector2(792, 560), Vector2(248, 76), _on_exit_pressed)
    button_restart = _make_button("Restart", Vector2(1072, 560), Vector2(158, 76), _on_restart_pressed)

func _make_button(label: String, pos: Vector2, size: Vector2, callback: Callable) -> Button:
    var button := Button.new()
    button.text = label
    button.position = pos
    button.size = size
    button.pressed.connect(callback)
    add_child(button)
    return button

func _start_demo() -> void:
    GameState.reset()
    ClueStore.reset()
    RenderingDirector.clear_commands()
    DataRegistry.load_all_data(true)
    event_log.clear()
    action_log.clear()
    last_result = ViewpointDirector.start("village_gate")
    action_log.append("Start at village gate")
    _refresh_screen()

func _on_left_pressed() -> void:
    last_result = ViewpointDirector.turn_left()
    action_log.append("Turn left")
    _refresh_screen()

func _on_right_pressed() -> void:
    last_result = ViewpointDirector.turn_right()
    action_log.append("Turn right")
    _refresh_screen()

func _on_inspect_pressed() -> void:
    var result := HotspotController.inspect_first_visible_hotspot()
    last_result = result
    action_log.append("Inspect: %s" % result.get("hotspot_id", "none"))
    _update_pressure_after_action()
    _refresh_screen()

func _on_exit_pressed() -> void:
    var target := ViewpointDirector.get_exit_target()
    if target == "old_house":
        last_result = {"ok": false, "reason": "demo_end", "message": "The path to the old house is sealed by fog. Demo V0.1 ends here."}
        action_log.append("Demo end: old house locked")
        _refresh_screen()
        return
    last_result = ViewpointDirector.go_exit()
    action_log.append("Go to: %s" % target)
    _refresh_screen()

func _on_restart_pressed() -> void:
    _start_demo()

func _update_pressure_after_action() -> void:
    GameState.set_value("player.progress", min(100, ClueStore.list_item_ids().size() * 10))
    GameState.set_value("player.clue_pressure", ClueStore.list_item_ids().size() * 5)
    HorrorDirector.evaluate_from_game_state()
    StorylineEngine.evaluate_open_threads()

func _refresh_screen() -> void:
    var current_viewpoint := ViewpointDirector.get_current_viewpoint()
    var visible_hotspots := ViewpointDirector.get_current_hotspots()
    var hotspot_names := []
    for item in visible_hotspots:
        hotspot_names.append("%s[%s]" % [item.get("name", "hotspot"), item.get("id", "id")])

    var director_state := HorrorDirector.evaluate_from_game_state()
    var current_skin := MapSkinDirector.get_current_skin()
    var render_commands := RenderingDirector.get_commands()
    var executed_commands := []
    if scene_effect_executor != null and scene_effect_executor.has_method("get_executed_commands"):
        executed_commands = scene_effect_executor.get_executed_commands()

    if button_exit != null:
        var exit_label := ViewpointDirector.get_exit_label()
        button_exit.text = "Go" if exit_label == "" else "Go: " + exit_label.substr(0, min(exit_label.length(), 10))

    status_label.text = "《阴契》试玩版 V0.1\n\nLocation: %s\nView: %s\nSkin: %s\n\nVisible hotspots:\n%s\n\nClues: %s\nLastResult: %s\n\nDirector: %s intensity=%s events=%s\nRenderCommands: %s  ExecutedEffects: %s\n\nActions:\n%s\n\nEvents:\n%s" % [
        current_viewpoint.get("location", "unknown"),
        current_viewpoint.get("name", "unknown"),
        current_skin.get("name", "no skin"),
        "\n".join(hotspot_names),
        ClueStore.list_item_ids(),
        last_result,
        director_state.get("phase", "phase"),
        director_state.get("intensity", 0),
        director_state.get("events", []).size(),
        render_commands.size(),
        executed_commands.size(),
        "\n".join(action_log.slice(max(0, action_log.size() - 8), action_log.size())),
        "\n".join(event_log.slice(max(0, event_log.size() - 10), event_log.size()))
    ]

func _on_game_event(event_name: String, _payload: Dictionary) -> void:
    event_log.append("GAME " + event_name)

func _on_horror_event_requested(event_packet: Dictionary) -> void:
    event_log.append("HORROR %s %s" % [event_packet.get("type", "generic"), event_packet.get("id", "event")])

func _on_clue_added(clue_id: String, _clue_data: Dictionary) -> void:
    event_log.append("CLUE " + clue_id)
