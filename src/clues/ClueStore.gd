extends Node

var items: Dictionary = {}

func add_item(item_id: String, data: Dictionary) -> void:
    items[item_id] = data

func has_item(item_id: String) -> bool:
    return items.has(item_id)

func get_item(item_id: String) -> Dictionary:
    return items.get(item_id, {})

func list_items() -> Array:
    return items.values()

func seed_demo_items() -> void:
    add_item("red_thread", {"name": "红线", "tags": ["ritual", "marriage"]})
    add_item("genealogy_page", {"name": "族谱残页", "tags": ["family", "record"]})
