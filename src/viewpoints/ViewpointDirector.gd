extends Node

var current_viewpoint_id := ""

func start(location_id: String = "village_gate") -> Dictionary:
    DataRegistry.load_all_data()
    var first := DataRegistry.get_first_viewpoint_for_location(location_id)
    if first.is_empty():
        return {"ok": false, "reason": "no_viewpoint_for_location", "location_id": location_id}
    return enter_viewpoint(str(first.get("id", "")))

func enter_viewpoint(viewpoint_id: String) -> Dictionary:
    DataRegistry.load_all_data()
    var viewpoint := DataRegistry.get_viewpoint(viewpoint_id).duplicate(true)
    if viewpoint.is_empty():
        return {"ok": false, "reason": "viewpoint_not_found", "viewpoint_id": viewpoint_id}
    viewpoint["id"] = viewpoint_id
    current_viewpoint_id = viewpoint_id
    var location_id := str(viewpoint.get("location", ""))
    LocationController.enter_location(location_id)
    MapSkinDirector.apply_location_skin(str(viewpoint.get("skin", location_id)))
    GameState.set_value("viewpoint.current", viewpoint)
    GameState.set_value("viewpoint.current_id", viewpoint_id)
    EventBus.emit_game_event("viewpoint_entered", viewpoint)
    return {"ok": true, "viewpoint": viewpoint, "hotspots": get_current_hotspots()}

func turn_left() -> Dictionary:
    return _turn_to("left")

func turn_right() -> Dictionary:
    return _turn_to("right")

func _turn_to(direction: String) -> Dictionary:
    var current := get_current_viewpoint()
    if current.is_empty():
        return start("village_gate")
    var target := str(current.get(direction, current_viewpoint_id))
    return enter_viewpoint(target)

func get_current_viewpoint() -> Dictionary:
    if current_viewpoint_id == "":
        return {}
    var viewpoint := DataRegistry.get_viewpoint(current_viewpoint_id).duplicate(true)
    if not viewpoint.is_empty():
        viewpoint["id"] = current_viewpoint_id
    return viewpoint

func get_current_hotspots() -> Array:
    var result := []
    var viewpoint := get_current_viewpoint()
    for hotspot_id in viewpoint.get("hotspots", []):
        var item := DataRegistry.get_interactable(str(hotspot_id)).duplicate(true)
        if item.is_empty():
            continue
        item["id"] = str(hotspot_id)
        result.append(item)
    return result

func get_exit_target() -> String:
    return str(get_current_viewpoint().get("exit_to", ""))

func get_exit_label() -> String:
    return str(get_current_viewpoint().get("exit_label", ""))

func can_exit() -> Dictionary:
    var viewpoint := get_current_viewpoint()
    var missing := []
    for clue_id in viewpoint.get("locked_until", []):
        if not ClueStore.has_item(str(clue_id)):
            missing.append(str(clue_id))
    return {"ok": missing.is_empty(), "missing": missing, "target": viewpoint.get("exit_to", "")}

func go_exit() -> Dictionary:
    var check := can_exit()
    if not bool(check.get("ok", false)):
        EventBus.emit_game_event("viewpoint_exit_locked", check)
        return check
    var target_location := str(check.get("target", ""))
    if target_location == "":
        return {"ok": false, "reason": "no_exit_target"}
    return start(target_location)
