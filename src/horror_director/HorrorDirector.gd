extends Node

func evaluate_pressure(player_state: Dictionary) -> Dictionary:
    var fear = int(player_state.get("fear", 0))
    var progress = int(player_state.get("progress", 0))
    var score = fear + progress
    if score >= 80:
        return {"mood": "high_pressure", "events": ["near_footsteps", "light_flicker", "distant_laugh"]}
    if score >= 40:
        return {"mood": "uneasy", "events": ["door_knock", "paper_ash"]}
    return {"mood": "quiet", "events": ["wind", "candle_noise"]}
