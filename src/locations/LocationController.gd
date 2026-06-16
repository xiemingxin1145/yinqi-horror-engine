extends Node

var current_location_id: String = ""

func enter_location(location_id: String) -> Dictionary:
    DataRegistry.load_all_data()
    var location := DataRegistry.get_location(location_id).duplicate(true)
    if location.is_empty():
        return {"ok": false, "reason": "location_not_found", "location_id": location_id}

    current_location_id = location_id
    location["id"] = location_id
    var result := {
        "ok": true,
        "location_id": location_id,
        "location": location,
        "interactables": get_current_interactables(),
        "connected_locations": get_connected_locations()
    }

    GameState.set_value("world.current_location", location)
    GameState.set_value("world.current_location_id", location_id)
    GameState.set_value("player.current_location", location_id)
    EventBus.emit_game_event("location_entered", result)
    return result

func get_current_location() -> Dictionary:
    if current_location_id == "":
        return {}
    var location := DataRegistry.get_location(current_location_id).duplicate(true)
    location["id"] = current_location_id
    return location

func get_current_interactables() -> Array:
    if current_location_id == "":
        return []
    return DataRegistry.get_interactables_for_location(current_location_id)

func get_connected_locations() -> Array:
    var location := get_current_location()
    return location.get("connected_to", [])
