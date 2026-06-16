extends Node

var store: Dictionary = {}

func add_record(actor_id: String, record: Dictionary) -> void:
    if not store.has(actor_id):
        store[actor_id] = []
    var item := record.duplicate(true)
    item["index"] = store[actor_id].size()
    store[actor_id].append(item)
    EventBus.emit_game_event("npc_record_added", {"actor_id": actor_id, "record": item})

func query(actor_id: String, tag: String = "") -> Array:
    var result: Array = []
    for item in store.get(actor_id, []):
        if tag == "" or tag in item.get("tags", []):
            result.append(item)
    return result

func query_top(actor_id: String, limit: int = 3) -> Array:
    var result := query(actor_id)
    result.sort_custom(func(a, b): return int(a.get("importance", 1)) > int(b.get("importance", 1)))
    return result.slice(0, mini(limit, result.size()))
