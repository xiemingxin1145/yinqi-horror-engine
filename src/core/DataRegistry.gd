extends Node

var locations: Dictionary = {}
var npc_templates: Dictionary = {}
var rule_templates: Dictionary = {}
var event_templates: Dictionary = {}

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
        "tags": ["paper_figure", "midnight"],
        "risk_delta": 30
    })
    register_event_template("door_knock", {
        "type": "audio",
        "target": "door",
        "min_intensity": 40
    })
