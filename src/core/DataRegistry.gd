extends Node

var locations: Dictionary = {}
var npc_templates: Dictionary = {}
var rule_templates: Dictionary = {}
var event_templates: Dictionary = {}
var loaded_sources: Array[String] = []

const LOCATION_FILES := [
    "res://data/locations/locations.example.json"
]
const NPC_FILES := [
    "res://data/npcs/npcs.example.json"
]
const RULE_FILES := [
    "res://data/rules/folklore_rules.example.json"
]
const EVENT_FILES := [
    "res://data/events/event_templates.example.json"
]

func clear() -> void:
    locations.clear()
    npc_templates.clear()
    rule_templates.clear()
    event_templates.clear()
    loaded_sources.clear()

func load_all_data(force_reload: bool = false) -> void:
    if not force_reload and _has_any_data():
        return

    clear()
    for path in LOCATION_FILES:
        load_locations_from_file(path)
    for path in NPC_FILES:
        load_npcs_from_file(path)
    for path in RULE_FILES:
        load_rules_from_file(path)
    for path in EVENT_FILES:
        load_events_from_file(path)

    if not _has_any_data():
        seed_minimal_demo_data()
        loaded_sources.append("seed_minimal_demo_data")

    EventBus.emit_game_event("data_registry_loaded", summary())

func _has_any_data() -> bool:
    return not locations.is_empty() or not npc_templates.is_empty() or not rule_templates.is_empty() or not event_templates.is_empty()

func load_locations_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("locations", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_location(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func load_npcs_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("npcs", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_npc_template(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func load_rules_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("rules", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_rule(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func load_events_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("events", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_event_template(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func _read_json_dictionary(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("DataRegistry missing file: %s" % path)
        return {}

    var raw := FileAccess.get_file_as_string(path)
    var parsed = JSON.parse_string(raw)
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("DataRegistry invalid json dictionary: %s" % path)
        return {}
    return parsed

func register_location(location_id: String, data: Dictionary) -> void:
    locations[location_id] = data

func register_npc_template(npc_id: String, data: Dictionary) -> void:
    npc_templates[npc_id] = data

func register_rule(rule_id: String, data: Dictionary) -> void:
    rule_templates[rule_id] = data

func register_event_template(event_id: String, data: Dictionary) -> void:
    event_templates[event_id] = data

func get_location(location_id: String) -> Dictionary:
    return locations.get(location_id, {})

func get_npc_template(npc_id: String) -> Dictionary:
    return npc_templates.get(npc_id, {})

func get_rule(rule_id: String) -> Dictionary:
    return rule_templates.get(rule_id, {})

func get_event_template(event_id: String) -> Dictionary:
    return event_templates.get(event_id, {})

func summary() -> Dictionary:
    return {
        "locations": locations.size(),
        "npcs": npc_templates.size(),
        "rules": rule_templates.size(),
        "events": event_templates.size(),
        "sources": loaded_sources.duplicate()
    }

func seed_minimal_demo_data() -> void:
    register_location("ancestral_hall", {
        "name": "祠堂",
        "tags": ["family", "ritual", "night_sensitive"],
        "risk": 40
    })
    register_location("old_house", {
        "name": "老宅",
        "tags": ["marriage", "memory", "locked_room"],
        "risk": 35
    })
    register_npc_template("paper_master", {
        "name": "纸扎匠",
        "tags": ["craft", "secret_keeper"],
        "base_fear": 45,
        "base_trust": 20
    })
    register_rule("no_eye_painting_at_midnight", {
        "name": "子时不可点睛",
        "trigger": "item_action",
        "conditions": {"time": "子时", "item_tag": "paper_figure", "action": "paint_eye"},
        "effects": {"risk_delta": 30, "event": "paper_figure_moves", "flag": "paper_eye_taboo_broken"}
    })
    register_event_template("door_knock", {
        "type": "audio",
        "target": "door",
        "min_intensity": 40
    })
