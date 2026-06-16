extends Node

func inspect_hotspot(hotspot_id: String) -> Dictionary:
    var result := InteractionController.inspect_item(hotspot_id)
    result["hotspot_id"] = hotspot_id
    EventBus.emit_game_event("hotspot_inspected", result)
    return result

func inspect_first_visible_hotspot() -> Dictionary:
    var hotspots := ViewpointDirector.get_current_hotspots()
    if hotspots.is_empty():
        return {"ok": false, "reason": "no_visible_hotspot"}
    return inspect_hotspot(str(hotspots[0].get("id", "")))

func list_visible_hotspots() -> Array:
    return ViewpointDirector.get_current_hotspots()
