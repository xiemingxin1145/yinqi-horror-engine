extends Node

func apply_location_skin(location_id: String) -> Dictionary:
    DataRegistry.load_all_data()
    var skin := DataRegistry.get_map_skin(location_id).duplicate(true)
    if skin.is_empty():
        return {"ok": false, "reason": "skin_not_found", "location_id": location_id}

    skin["id"] = location_id
    var command := build_skin_command(skin)
    GameState.set_value("map.current_skin", skin)
    GameState.set_value("map.skin_command", command)
    EventBus.emit_game_event("map_skin_applied", command)
    return {"ok": true, "skin": skin, "command": command}

func build_skin_command(skin: Dictionary) -> Dictionary:
    return {
        "skin_id": skin.get("id", "unknown_skin"),
        "location": skin.get("location", "unknown_location"),
        "name": skin.get("name", "未命名地图皮肤"),
        "palette": skin.get("palette", {}),
        "layers": skin.get("layers", []),
        "lights": skin.get("lights", []),
        "particles": skin.get("particles", []),
        "ambient_tags": skin.get("ambient_tags", [])
    }

func get_current_skin() -> Dictionary:
    return GameState.get_value("map.current_skin", {})
