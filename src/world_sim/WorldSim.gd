extends Node

func create_world(world_name: String) -> Dictionary:
    DataRegistry.load_all_data()

    var locations := []
    for location_id in DataRegistry.locations.keys():
        var location := DataRegistry.get_location(location_id).duplicate(true)
        location["id"] = location_id
        locations.append(location)

    var npcs := []
    for npc_id in DataRegistry.npc_templates.keys():
        var template := DataRegistry.get_npc_template(npc_id)
        npcs.append({
            "id": npc_id,
            "name": template.get("name", npc_id),
            "role": template.get("role", "unknown"),
            "fear": template.get("base_fear", 0),
            "trust": template.get("base_trust", 0),
            "tags": template.get("tags", []),
            "home_location": template.get("home_location", "")
        })

    var world := {
        "name": world_name,
        "time": "子时",
        "weather": "细雨",
        "locations": locations,
        "npcs": npcs,
        "flags": []
    }

    GameState.set_value("world", world)
    for npc in npcs:
        GameState.set_value("npcs.%s" % npc.get("id"), npc)
    EventBus.emit_game_event("world_created", world)
    return world

func tick(world: Dictionary) -> Dictionary:
    var next_world = world.duplicate(true)
    next_world["time"] = "丑时" if world.get("time") == "子时" else "子时"
    GameState.set_value("world", next_world)
    EventBus.emit_game_event("world_tick", next_world)
    return next_world

func get_location_ids(world: Dictionary) -> Array:
    var ids := []
    for location in world.get("locations", []):
        ids.append(location.get("id", location.get("name", "unknown")))
    return ids

func get_npc_ids(world: Dictionary) -> Array:
    var ids := []
    for npc in world.get("npcs", []):
        ids.append(npc.get("id", npc.get("name", "unknown")))
    return ids
