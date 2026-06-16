extends Node

var current_location_id: String = ""

func enter_location(location_id: String) -> Dictionary:
    DataRegistry.load_all_data()
    current_location_id = location_id
    var location := DataRegistry.get_location(location_id)
    var interactables := []
    if DataRegistry.has_method("get_interactables_for_location"):
        interactables = DataRegistry.get_interactables_for_location(location_id)

    var result := {
        "location_id": location_id,
        "location": location,
        "interactables": interactables
    }

    GameState.set_value("player.current_location", location_id)
    EventBus.emit_game_event("location_entered", result)
    return result

func get_current_interactables() -> Array:
    if current_location_id == "":
        return []
    if DataRegistry.has_method("get_interactables_for_location"):
        return DataRegistry.get_interactables_for_location(current_location_id)
    return []
