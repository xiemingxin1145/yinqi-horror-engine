extends Node2D

@onready var status_label: Label = $Status

func _ready() -> void:
    var world = WorldSim.create_world("归魂村")
    var case_data = FolkloreRules.generate_case_seed(world)
    var ghost = GhostGenerator.create_from_case(case_data)
    var opening = NarrativeEngine.build_opening(world, case_data, ghost)
    var director_state = HorrorDirector.evaluate_pressure({"fear": 10, "progress": 0})

    status_label.text = "World: %s\nCase: %s\nGhost: %s\nDirector: %s\n\n%s" % [
        world.get("name"),
        case_data.get("title"),
        ghost.get("name"),
        director_state.get("mood"),
        opening
    ]
