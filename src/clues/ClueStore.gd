extends Node

var items: Dictionary = {}

func reset() -> void:
    items.clear()

func add_item(item_id: String, data: Dictionary) -> void:
    items[item_id] = data
    GameState.add_clue(item_id, data)

func has_item(item_id: String) -> bool:
    return items.has(item_id)

func get_item(item_id: String) -> Dictionary:
    return items.get(item_id, {})

func list_items() -> Array:
    return items.values()

func list_item_ids() -> Array:
    return items.keys()

func seed_demo_items() -> void:
    add_item("red_thread", {"name": "红线", "tags": ["ritual", "marriage"]})
    add_item("genealogy_page", {"name": "族谱残页", "tags": ["family", "record"]})

func combine_items(first_id: String, second_id: String) -> Dictionary:
    if not has_item(first_id) or not has_item(second_id):
        return {"ok": false, "reason": "missing_item"}

    var first := get_item(first_id)
    var second := get_item(second_id)
    var first_tags: Array = first.get("tags", [])
    var second_tags: Array = second.get("tags", [])

    if "marriage" in first_tags and "family" in second_tags:
        var result := {
            "ok": true,
            "result_id": "contract_family_link",
            "text": "红线与族谱残页指向同一个家族记录。"
        }
        EventBus.emit_game_event("clue_combined", result)
        return result

    return {"ok": false, "reason": "no_rule"}
