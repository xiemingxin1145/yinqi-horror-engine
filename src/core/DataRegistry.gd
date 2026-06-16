extends Node

var locations: Dictionary = {}
var npc_templates: Dictionary = {}
var rule_templates: Dictionary = {}
var event_templates: Dictionary = {}
var interactable_templates: Dictionary = {}
var storyline_templates: Dictionary = {}
var map_skin_templates: Dictionary = {}
var viewpoint_templates: Dictionary = {}
var loaded_sources: Array[String] = []

const LOCATION_FILES := ["res://data/locations/locations.example.json"]
const NPC_FILES := ["res://data/npcs/npcs.example.json"]
const RULE_FILES := ["res://data/rules/folklore_rules.example.json"]
const EVENT_FILES := ["res://data/events/event_templates.example.json"]
const INTERACTABLE_FILES := ["res://data/interactables/interactables.example.json"]
const STORYLINE_FILES := ["res://data/storylines/open_storylines.example.json"]
const MAP_SKIN_FILES := ["res://data/maps/map_skins.example.json"]
const VIEWPOINT_FILES := ["res://data/viewpoints/viewpoints.example.json"]

func clear() -> void:
    locations.clear()
    npc_templates.clear()
    rule_templates.clear()
    event_templates.clear()
    interactable_templates.clear()
    storyline_templates.clear()
    map_skin_templates.clear()
    viewpoint_templates.clear()
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
    for path in INTERACTABLE_FILES:
        load_interactables_from_file(path)
    for path in STORYLINE_FILES:
        load_storylines_from_file(path)
    for path in MAP_SKIN_FILES:
        load_map_skins_from_file(path)
    for path in VIEWPOINT_FILES:
        load_viewpoints_from_file(path)
    if not _has_any_data():
        seed_minimal_demo_data()
        loaded_sources.append("seed_minimal_demo_data")
    EventBus.emit_game_event("data_registry_loaded", summary())

func _has_any_data() -> bool:
    return not locations.is_empty() or not npc_templates.is_empty() or not rule_templates.is_empty() or not event_templates.is_empty() or not interactable_templates.is_empty() or not storyline_templates.is_empty() or not map_skin_templates.is_empty() or not viewpoint_templates.is_empty()

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

func load_interactables_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("interactables", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_interactable(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func load_storylines_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("storylines", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_storyline(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func load_map_skins_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("map_skins", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_map_skin(id, item_copy)
    if not data.is_empty():
        loaded_sources.append(path)

func load_viewpoints_from_file(path: String) -> void:
    var data := _read_json_dictionary(path)
    for item in data.get("viewpoints", []):
        if typeof(item) == TYPE_DICTIONARY and item.has("id"):
            var item_copy: Dictionary = item.duplicate(true)
            var id := str(item_copy.get("id"))
            item_copy.erase("id")
            register_viewpoint(id, item_copy)
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
func register_interactable(interactable_id: String, data: Dictionary) -> void:
    interactable_templates[interactable_id] = data
func register_storyline(storyline_id: String, data: Dictionary) -> void:
    storyline_templates[storyline_id] = data
func register_map_skin(map_skin_id: String, data: Dictionary) -> void:
    map_skin_templates[map_skin_id] = data
func register_viewpoint(viewpoint_id: String, data: Dictionary) -> void:
    viewpoint_templates[viewpoint_id] = data

func get_location(location_id: String) -> Dictionary:
    return locations.get(location_id, {})
func get_npc_template(npc_id: String) -> Dictionary:
    return npc_templates.get(npc_id, {})
func get_rule(rule_id: String) -> Dictionary:
    return rule_templates.get(rule_id, {})
func get_event_template(event_id: String) -> Dictionary:
    return event_templates.get(event_id, {})
func get_interactable(interactable_id: String) -> Dictionary:
    return interactable_templates.get(interactable_id, {})
func get_storyline(storyline_id: String) -> Dictionary:
    return storyline_templates.get(storyline_id, {})
func get_map_skin(map_skin_id: String) -> Dictionary:
    return map_skin_templates.get(map_skin_id, {})
func get_viewpoint(viewpoint_id: String) -> Dictionary:
    return viewpoint_templates.get(viewpoint_id, {})

func get_viewpoints_for_location(location_id: String) -> Array:
    var result := []
    for viewpoint_id in viewpoint_templates.keys():
        var viewpoint := get_viewpoint(viewpoint_id).duplicate(true)
        if str(viewpoint.get("location", "")) == location_id:
            viewpoint["id"] = viewpoint_id
            result.append(viewpoint)
    result.sort_custom(func(a, b): return int(a.get("order", 0)) < int(b.get("order", 0)))
    return result

func get_first_viewpoint_for_location(location_id: String) -> Dictionary:
    var list := get_viewpoints_for_location(location_id)
    if list.is_empty():
        return {}
    return list[0]

func get_interactables_for_location(location_id: String) -> Array:
    var result := []
    for item_id in interactable_templates.keys():
        var item := get_interactable(item_id).duplicate(true)
        if str(item.get("location", "")) == location_id:
            item["id"] = item_id
            result.append(item)
    return result

func summary() -> Dictionary:
    return {
        "locations": locations.size(),
        "npcs": npc_templates.size(),
        "rules": rule_templates.size(),
        "events": event_templates.size(),
        "interactables": interactable_templates.size(),
        "storylines": storyline_templates.size(),
        "map_skins": map_skin_templates.size(),
        "viewpoints": viewpoint_templates.size(),
        "sources": loaded_sources.duplicate()
    }

func seed_minimal_demo_data() -> void:
    register_location("village_gate", {"name": "归魂村村口", "tags": ["fog", "boundary"], "risk": 25})
    register_location("river_bridge", {"name": "河桥", "tags": ["cold", "river"], "risk": 45})
    register_interactable("qingqing_microphone", {"name": "苏青青的备用麦克风", "location": "village_gate", "clue": {"id": "microphone_drowning_audio", "name": "落水声录音", "text": "麦克风里残留着重物落水声。"}})
    register_map_skin("village_gate", {"name": "归魂村村口皮肤", "location": "village_gate", "palette": {"background": "#061014", "ambient": "#08161A"}, "layers": [], "lights": []})
    register_viewpoint("village_gate_front", {"location": "village_gate", "name": "村口正面", "hotspots": ["qingqing_microphone"], "left": "village_gate_front", "right": "village_gate_front"})
