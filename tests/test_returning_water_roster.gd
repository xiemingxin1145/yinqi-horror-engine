extends Node

var failures: Array[String] = []
var checks: Array[Dictionary] = []
var checkpoints: Array[Dictionary] = []
var report_directory := ""
var run_started_at := ""


func _ready() -> void:
    report_directory = OS.get_environment("RWR_TEST_OUTPUT_DIR")
    if report_directory.is_empty():
        report_directory = ProjectSettings.globalize_path("user://returning_water_regression")
    elif not report_directory.is_absolute_path():
        report_directory = ProjectSettings.globalize_path(report_directory)
    DirAccess.make_dir_recursive_absolute(report_directory.path_join("screenshots"))
    run_started_at = Time.get_datetime_string_from_system(true)
    call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
    checks.append({"name": message, "passed": condition})
    if not condition:
        failures.append(message)


func _capture_checkpoint(scene: Variant, checkpoint_name: String) -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    var relative_path := "screenshots/%s.png" % checkpoint_name
    var absolute_path := report_directory.path_join(relative_path)
    var image: Image = scene.get_viewport().get_texture().get_image()
    var saved := image != null and not image.is_empty() and image.save_png(absolute_path) == OK
    _expect(saved, "viewport screenshot saved: %s" % checkpoint_name)
    checkpoints.append({
        "name": checkpoint_name,
        "screen": str(scene.current_screen),
        "viewpoint": str(scene.current_viewpoint_id),
        "core_clues": int(scene.get_core_clue_count()),
        "wrong_attempts": int(scene.wrong_attempts),
        "case_resolved": bool(scene.case_resolved),
        "screenshot": relative_path,
        "screenshot_saved": saved
    })


func _collect_buttons(root: Node, wanted_text: String, found: Array[Button]) -> void:
    if not is_instance_valid(root):
        return
    if root is Button:
        var button := root as Button
        if button.text == wanted_text and button.is_visible_in_tree() and not button.is_queued_for_deletion():
            found.append(button)
    for child in root.get_children():
        _collect_buttons(child, wanted_text, found)


func _buttons_with_text(root: Node, wanted_text: String) -> Array[Button]:
    var found: Array[Button] = []
    _collect_buttons(root, wanted_text, found)
    return found


func _find_check_button(root: Node) -> CheckButton:
    if not is_instance_valid(root):
        return null
    if root is CheckButton:
        return root as CheckButton
    for child in root.get_children():
        var found := _find_check_button(child)
        if found != null:
            return found
    return null


func _find_slider(root: Node) -> HSlider:
    if not is_instance_valid(root):
        return null
    if root is HSlider:
        return root as HSlider
    for child in root.get_children():
        var found := _find_slider(child)
        if found != null:
            return found
    return null


func _touch_control(scene: Variant, control: Control, point_fraction: Vector2 = Vector2(0.5, 0.5)) -> bool:
    await get_tree().process_frame
    if not is_instance_valid(control) or not control.is_visible_in_tree() or control.is_queued_for_deletion():
        _expect(false, "touch target exists and is visible in the active screen")
        return false
    if control is BaseButton and (control as BaseButton).disabled:
        _expect(false, "touch target is enabled: %s" % control.get_path())
        return false

    var viewport: Viewport = scene.get_viewport()
    var visible_rect: Rect2 = viewport.get_visible_rect()
    var rect: Rect2 = control.get_global_rect()
    var rect_end: Vector2 = rect.position + rect.size
    _expect(rect.size.x >= 24.0 and rect.size.y >= 24.0, "touch target has a usable hit area: %s" % control.get_path())
    _expect(
        rect.position.x >= visible_rect.position.x - 1.0
        and rect.position.y >= visible_rect.position.y - 1.0
        and rect_end.x <= visible_rect.end.x + 1.0
        and rect_end.y <= visible_rect.end.y + 1.0,
        "touch target stays inside the 1280x720 game viewport: %s %s / %s" % [control.get_path(), rect, visible_rect]
    )

    var touch_position := rect.position + rect.size * point_fraction
    var press := InputEventScreenTouch.new()
    press.index = 0
    press.position = touch_position
    press.pressed = true
    viewport.push_input(press, true)
    var release := InputEventScreenTouch.new()
    release.index = 0
    release.position = touch_position
    release.pressed = false
    viewport.push_input(release, true)
    await get_tree().process_frame
    return true


func _tap_button(scene: Variant, wanted_text: String, occurrence: int = 0) -> bool:
    await get_tree().process_frame
    var buttons := _buttons_with_text(scene._ui, wanted_text)
    if occurrence < 0 or occurrence >= buttons.size():
        _expect(false, "visible button found: %s (occurrence %d)" % [wanted_text, occurrence])
        return false
    return await _touch_control(scene, buttons[occurrence])


func _drag_slider(scene: Variant, slider: HSlider, target_fraction: float) -> bool:
    await get_tree().process_frame
    if not is_instance_valid(slider) or not slider.is_visible_in_tree():
        _expect(false, "audio slider is visible before touch drag")
        return false
    var viewport: Viewport = scene.get_viewport()
    var rect: Rect2 = slider.get_global_rect()
    var current_fraction := inverse_lerp(slider.min_value, slider.max_value, slider.value)
    var start := rect.position + Vector2(rect.size.x * current_fraction, rect.size.y * 0.5)
    var target := rect.position + Vector2(rect.size.x * target_fraction, rect.size.y * 0.5)
    var press := InputEventScreenTouch.new()
    press.index = 0
    press.position = start
    press.pressed = true
    viewport.push_input(press, true)
    await get_tree().process_frame
    var drag := InputEventScreenDrag.new()
    drag.index = 0
    drag.position = target
    drag.relative = target - start
    viewport.push_input(drag, true)
    await get_tree().process_frame
    var release := InputEventScreenTouch.new()
    release.index = 0
    release.position = target
    release.pressed = false
    viewport.push_input(release, true)
    await get_tree().process_frame
    return true


func _inspect_by_ui(scene: Variant, button_text: String) -> void:
    _expect(await _tap_button(scene, button_text), "hotspot button accepts a screen touch: %s" % button_text)
    _expect(scene.current_screen == "clue", "hotspot touch opens its clue card: %s" % button_text)
    _expect(await _tap_button(scene, "回到现场"), "clue card return button accepts a screen touch")
    _expect(scene.current_screen == "game", "clue card returns to the same game view")


func _run() -> void:
    var packed_scene: PackedScene = load("res://scenes/ReturningWaterRoster.tscn")
    _expect(packed_scene != null, "chapter scene loads")
    if packed_scene == null:
        _finish()
        return

    var game_viewport := SubViewport.new()
    game_viewport.name = "ReturningWaterRosterTestViewport"
    game_viewport.size = Vector2i(1280, 720)
    game_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    get_tree().root.add_child(game_viewport)

    var scene: Variant = packed_scene.instantiate()
    _expect(scene != null, "chapter root instantiates")
    if scene == null:
        _finish()
        return
    game_viewport.add_child(scene)
    await get_tree().process_frame
    var viewport_size: Vector2 = scene.get_viewport().get_visible_rect().size
    _expect(viewport_size.x > 0.0 and viewport_size.y > 0.0, "headless touch test has a real viewport")
    _expect(absf(viewport_size.x / viewport_size.y - 16.0 / 9.0) < 0.03, "test viewport matches the 16:9 mobile game layout")
    _expect(scene.current_screen == "title", "title page is the opening state")
    await _capture_checkpoint(scene, "title-launch")
    var registry: Node = get_node("/root/DataRegistry")
    var registered_locations: Dictionary = registry.get("locations")
    var registered_interactables: Dictionary = registry.get("interactable_templates")
    var registered_skins: Dictionary = registry.get("map_skin_templates")
    var registered_viewpoints: Dictionary = registry.get("viewpoint_templates")
    _expect(registered_locations.size() == 2 and not registered_locations.has("old_house") and not registered_locations.has("opera_stage") and not registered_locations.has("ancestral_hall"), "chapter data contains only village gate and river bridge locations")
    _expect(not registered_interactables.has("blood_red_wedding_dress") and not registered_interactables.has("paper_bride_body"), "chapter data excludes later chapter interaction items")
    _expect(registered_skins.size() == 2 and not registered_skins.has("old_house") and not registered_skins.has("opera_stage") and not registered_skins.has("ancestral_hall"), "chapter data contains only its two location skins")
    _expect(registered_viewpoints.size() == 6, "chapter data contains only its six fixed viewpoints")

    _expect(await _tap_button(scene, "设置"), "settings open from the title with a screen touch")
    _expect(scene.current_screen == "settings", "settings page opens")
    var toggle := _find_check_button(scene._ui)
    _expect(toggle != null, "flash accessibility setting is visible")
    if toggle != null:
        if scene.flash_enabled:
            _expect(await _touch_control(scene, toggle), "flash setting toggles off by touch")
        else:
            _expect(await _touch_control(scene, toggle), "flash setting toggles on by touch")
            _expect(await _touch_control(scene, toggle), "flash setting toggles back off by touch")
    _expect(not scene.flash_enabled, "flash can be disabled using the actual CheckButton")

    var slider := _find_slider(scene._ui)
    _expect(slider != null, "audio volume slider is visible")
    var desired_volume := 75 if scene.volume_percent == 25 else 25
    if slider != null:
        _expect(await _drag_slider(scene, slider, float(desired_volume) / 100.0), "audio volume slider accepts a real screen-touch drag")
    _expect(absi(scene.volume_percent - desired_volume) <= 5, "touch-dragging the slider updates the stored volume")
    await _capture_checkpoint(scene, "settings-volume-touch")
    var persisted_flash: bool = scene.flash_enabled
    var persisted_volume: int = scene.volume_percent
    _expect(await _tap_button(scene, "返回"), "settings return button accepts a screen touch")
    _expect(scene.current_screen == "title", "settings return to the title")

    var settings_probe: Variant = packed_scene.instantiate()
    game_viewport.add_child(settings_probe)
    await get_tree().process_frame
    _expect(settings_probe.flash_enabled == persisted_flash and settings_probe.volume_percent == persisted_volume, "settings persist across a fresh scene load")
    checkpoints.append({
        "name": "settings-save-reload",
        "screen": str(settings_probe.current_screen),
        "flash_enabled": bool(settings_probe.flash_enabled),
        "volume_percent": int(settings_probe.volume_percent),
        "persisted_values_match": settings_probe.flash_enabled == persisted_flash and settings_probe.volume_percent == persisted_volume,
        "screenshot": "screenshots/settings-volume-touch.png",
        "screenshot_saved": true
    })
    settings_probe.queue_free()
    await get_tree().process_frame

    _expect(await _tap_button(scene, "开始 / 重玩"), "title start button accepts a screen touch")
    _expect(scene.current_screen == "intro", "start enters the chapter intro")
    _expect(await _tap_button(scene, "走近村口"), "intro continue button accepts a screen touch")
    _expect(scene.current_screen == "game", "intro enters the playable chapter")
    _expect(scene.current_viewpoint_id == "village_gate_front", "chapter begins at the real village gate viewpoint")
    await _capture_checkpoint(scene, "location-village-gate")

    var locked_exits := _buttons_with_text(scene._ui, "沿雾路前往河桥")
    _expect(locked_exits.size() == 1 and locked_exits[0].disabled, "gate route button is visibly locked before the two required clues")
    await _inspect_by_ui(scene, "调查 · 归魂村村民公约")
    var rule_text: String = str(scene.found_clues.get("red_painted_rule_three", {}).get("text", ""))
    _expect(rule_text.contains("虚构村规") and rule_text.contains("子时") and rule_text.contains("不可应声"), "rule is clearly fictional and states the midnight no-response rule")
    _expect(await _tap_button(scene, "右看 ▶"), "right-look control accepts touch")
    _expect(scene.current_viewpoint_id == "village_gate_right", "right-look reaches the microphone viewpoint")
    await _inspect_by_ui(scene, "调查 · 苏青青的备用麦克风")
    var recording_text: String = str(scene.found_clues.get("microphone_drowning_audio", {}).get("text", ""))
    _expect(recording_text.contains("晚秋") and recording_text.contains("船要顺着水"), "recording transcript connects the given name and downstream direction")

    _expect(await _tap_button(scene, "◀ 左看"), "left-look returns to the central gate viewpoint")
    _expect(scene.current_viewpoint_id == "village_gate_front", "gate front remains a real viewpoint")
    _expect(await _tap_button(scene, "◀ 左看"), "left-look reaches the other legal gate viewpoint")
    _expect(scene.current_viewpoint_id == "village_gate_left", "left gate viewpoint is reachable by UI")
    _expect(await _tap_button(scene, "沿雾路前往河桥"), "unlocked gate exit accepts touch from the left viewpoint")
    _expect(scene.current_viewpoint_id == "river_bridge_front", "left gate route reaches the real bridge viewpoint")
    _expect(await _tap_button(scene, "回到村口"), "bridge return route accepts touch")
    _expect(scene.current_viewpoint_id == "village_gate_front", "return route lands at the gate front")
    _expect(await _tap_button(scene, "右看 ▶"), "right-look reaches the other legal gate viewpoint")
    _expect(scene.current_viewpoint_id == "village_gate_right", "right gate viewpoint is reachable by UI")
    _expect(await _tap_button(scene, "沿雾路前往河桥"), "unlocked gate exit accepts touch from the right viewpoint")
    _expect(scene.current_viewpoint_id == "river_bridge_front", "right gate route reaches the real bridge viewpoint")
    await _capture_checkpoint(scene, "location-river-bridge")

    var premature_boat_buttons := _buttons_with_text(scene._ui, "查看三只纸船")
    _expect(premature_boat_buttons.size() == 1 and premature_boat_buttons[0].disabled, "paper-boat decision remains locked until all five clues")
    _expect(await _tap_button(scene, "◀ 左看"), "bridge rail viewpoint is reachable by touch")
    _expect(scene.current_viewpoint_id == "river_bridge_rail", "bridge rail view is selected")
    await _inspect_by_ui(scene, "调查 · 浸水白布条")
    _expect(await _tap_button(scene, "◀ 左看"), "bridge ground viewpoint is reachable by touch")
    _expect(scene.current_viewpoint_id == "river_bridge_ground", "bridge ground view is selected")
    await _inspect_by_ui(scene, "调查 · 凌乱草鞋与脚印")
    await _inspect_by_ui(scene, "调查 · 学生证项链")

    _expect(scene.has_all_core_clues(), "all five core clues are collected through touch buttons")
    _expect(scene.get_core_clue_count() == 5, "clue counter reaches five")
    var student_text: String = str(scene.found_clues.get("lin_wanqiu_student_id", {}).get("text", ""))
    var cloth_text: String = str(scene.found_clues.get("oil_soaked_gag_cloth", {}).get("text", ""))
    var footprint_text: String = str(scene.found_clues.get("footprints_to_river", {}).get("text", ""))
    _expect(student_text.contains("林晚秋"), "student ID establishes Lin Wanqiu's full name")
    _expect(cloth_text.contains("L.W.") and footprint_text.contains("河边"), "cloth initials and footprints support the identity/location inference")
    _expect(await _tap_button(scene, "线索簿 5/5"), "clue-journal control accepts touch")
    _expect(scene.current_screen == "journal", "clue journal opens from the actual button")
    await _capture_checkpoint(scene, "five-clues-journal")
    _expect(await _tap_button(scene, "回到现场"), "clue journal returns to the bridge")
    _expect(await _tap_button(scene, "查看三只纸船"), "boat decision unlocks after all five clues")
    _expect(scene.current_screen == "boat", "three boat cards are visible")

    var boat_buttons := _buttons_with_text(scene._ui, "放下这只")
    _expect(boat_buttons.size() == 3, "all three different-name boat choices have visible action buttons")
    var inspect_buttons := _buttons_with_text(scene._ui, "检查名牌")
    _expect(inspect_buttons.size() == 3, "each paper-boat card offers a non-consuming inspection action")
    _expect(await _tap_button(scene, "检查名牌", 1), "paper-boat nameplate can be inspected by touch")
    _expect(scene.current_screen == "boat" and scene.status_notice.contains("林晚秋"), "inspection shows the selected name and direction without submitting a choice")
    _expect(scene.wrong_attempts == 0, "inspection does not consume a decision attempt")
    _expect(await _tap_button(scene, "放下这只", 0), "first boat card accepts touch")
    _expect(scene.current_screen == "failure", "wrong boat shows recoverable feedback")
    _expect(scene.scare_played and scene.chase_sequence_count == 1, "first wrong choice triggers exactly one pursuit sequence")
    _expect(is_instance_valid(scene._chase_overlay) and scene._chase_overlay.is_visible_in_tree(), "a visible moving-shadow pursuit appears instead of audio-only scare")
    _expect(not scene._flash.visible, "pursuit remains visible with optional flash disabled")
    _expect(scene.get_core_clue_count() == 5, "failure keeps all five clues")
    await _capture_checkpoint(scene, "wrong-choice-recovery")
    await get_tree().create_timer(1.1).timeout
    await get_tree().process_frame
    _expect(scene.current_screen == "failure" and not is_instance_valid(scene._chase_overlay), "one-second pursuit finishes without blocking retry")
    _expect(await _tap_button(scene, "回桥头重试"), "retry button accepts touch")
    _expect(await _tap_button(scene, "查看三只纸船"), "boat choice reopens on retry")
    await _capture_checkpoint(scene, "recovery-retry-choice")
    _expect(await _tap_button(scene, "放下这只", 1), "second boat card accepts touch")
    _expect(scene.current_screen == "release", "correct boat starts the three-beat river release")
    await get_tree().create_timer(1.1).timeout
    await get_tree().process_frame
    _expect(scene.current_screen == "call" and not scene._ambient_player.playing, "three clear water beats stop the river before the name-call choice")
    _expect(await _tap_button(scene, "回应：“谁在那儿？”"), "river-call wrong-answer button accepts touch")
    _expect(scene.wrong_attempts == 2, "wrong choices are counted")
    _expect(scene.chase_sequence_count == 1, "later wrong answers do not repeat the pursuit")
    _expect(await _tap_button(scene, "查看更清楚的提示"), "optional hint button accepts touch after two mistakes")
    _expect(scene.hint_viewed, "optional clearer hint can be opened")
    _expect(await _tap_button(scene, "关闭提示，回到河桥"), "hint close button returns to play")
    _expect(await _tap_button(scene, "查看三只纸船"), "retry remains available after the hint")
    _expect(await _tap_button(scene, "放下这只", 1), "correct boat remains selectable on retry")
    await get_tree().create_timer(1.1).timeout
    await get_tree().process_frame
    _expect(scene.current_screen == "call", "correct boat returns to the final silence decision after the river beat")
    _expect(await _tap_button(scene, "不应声，退到灯下"), "remaining silent accepts touch and resolves the case")
    _expect(scene.case_resolved and scene.current_screen == "exit", "success enters the clear-fog village-exit vignette")
    var exit_texture: Texture2D = scene._background.texture
    _expect(exit_texture != null and exit_texture.resource_path.ends_with("gate_exit_clear.webp"), "ending uses the dedicated clear-fog village-exit background")
    _expect(not scene._ambient_player.playing and not scene._effect_player.playing, "successful resolution stops ambient and one-shot audio")
    _expect(not is_instance_valid(scene._chase_overlay), "pursuit overlay is cleared when the case resolves")
    _expect(await _tap_button(scene, "查看结案记录"), "exit vignette continue button accepts touch")
    _expect(scene.current_screen == "ending", "success shows the formal case-closed page")
    await _capture_checkpoint(scene, "correct-ending")
    var game_state: Node = get_node("/root/GameState")
    _expect(bool(game_state.call("has_flag", "returning_water_roster_resolved")), "shared game state receives the chapter completion flag")

    _expect(await _tap_button(scene, "再玩一次"), "replay entry accepts touch")
    await get_tree().process_frame
    _expect(scene.current_screen == "intro", "replay starts a fresh run")
    await _capture_checkpoint(scene, "replay-start")
    _expect(scene.get_core_clue_count() == 0, "replay clears clues")
    _expect(scene.wrong_attempts == 0 and not scene.scare_played and scene.chase_sequence_count == 0, "replay clears errors and pursuit state")
    _expect(not scene.case_resolved and not scene.hint_viewed, "replay clears ending and hint state")
    _expect(scene.flash_enabled == persisted_flash and scene.volume_percent == persisted_volume, "replay preserves user settings")

    scene._ambient_player.stop()
    scene._effect_player.stop()
    scene._ambient_player.stream = null
    scene._effect_player.stream = null
    await get_tree().create_timer(0.25).timeout
    scene.free()
    game_viewport.free()
    await get_tree().process_frame
    _finish()


func _finish() -> void:
    var passed_count := 0
    for check in checks:
        if bool(check.get("passed", false)):
            passed_count += 1
    var success := failures.is_empty()
    var report := {
        "schema_version": 1,
        "suite": "returning_water_roster_regression",
        "engine_version": Engine.get_version_info().string,
        "started_at_utc": run_started_at,
        "finished_at_utc": Time.get_datetime_string_from_system(true),
        "result": "passed" if success else "failed",
        "simulated_touch": true,
        "real_device_validation": false,
        "check_count": checks.size(),
        "passed_count": passed_count,
        "failure_count": failures.size(),
        "failures": failures,
        "checks": checks,
        "checkpoints": checkpoints
    }
    var report_path := report_directory.path_join("report.json")
    var report_file := FileAccess.open(report_path, FileAccess.WRITE)
    if report_file == null:
        push_error("RWR_SELF_TEST_FAIL: cannot write JSON report at %s" % report_path)
        get_tree().quit(2)
        return
    report_file.store_string(JSON.stringify(report, "    ") + "\n")
    report_file.close()
    if success:
        print("RWR_SELF_TEST_PASS: %d/%d checks; JSON report: %s" % [passed_count, checks.size(), report_path])
        get_tree().quit(0)
        return
    for failure in failures:
        push_error("RWR_SELF_TEST_FAIL: " + failure)
    print("RWR_SELF_TEST_FAIL: JSON report: %s" % report_path)
    get_tree().quit(1)
