extends Node

var memories: Dictionary = {}

func remember(npc_id: String, memory: Dictionary) -> void:
    if not memories.has(npc_id):
        memories[npc_id] = []
    memories[npc_id].append(memory)

func recall(npc_id: String, tag: String = "") -> Array:
    var result: Array = []
    for item in memories.get(npc_id, []):
        if tag == "" or tag in item.get("tags", []):
            result.append(item)
    return result

func seed_demo_memories() -> void:
    remember("village_head", {"text": "三年前祠堂封过一次门。", "tags": ["祠堂", "旧事"]})
    remember("paper_master", {"text": "那只未点睛的纸人不该被搬走。", "tags": ["纸人", "禁忌"]})
