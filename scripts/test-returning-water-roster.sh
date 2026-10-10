#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-${RWR_TEST_OUTPUT_DIR:-${TMPDIR:-/tmp}/returning-water-roster-regression}}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
export RWR_TEST_OUTPUT_DIR="$OUTPUT_DIR"

GODOT_BIN="${GODOT_BIN:-godot}"
if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
    echo "ERROR: Godot 4.7.2 executable not found: $GODOT_BIN" >&2
    exit 2
fi
if ! command -v xvfb-run >/dev/null 2>&1; then
    echo "ERROR: xvfb-run is required for rendered screenshots (install Xvfb)." >&2
    exit 2
fi

CONFIG_BACKUP="$(mktemp "$OUTPUT_DIR/.project.godot.backup.XXXXXX")"
cp "$ROOT_DIR/project.godot" "$CONFIG_BACKUP"
restore_project_config() {
    if [[ -n "${CONFIG_BACKUP:-}" && -f "$CONFIG_BACKUP" ]]; then
        cp "$CONFIG_BACKUP" "$ROOT_DIR/project.godot"
        rm -f -- "$CONFIG_BACKUP"
        CONFIG_BACKUP=""
    fi
}
trap restore_project_config EXIT HUP INT TERM

run_godot() {
    xvfb-run -a env LIBGL_ALWAYS_SOFTWARE=1 "$GODOT_BIN" \
        --path "$ROOT_DIR" \
        --rendering-method gl_compatibility \
        --rendering-driver opengl3 \
        "$@"
}

run_logged() {
    local log_file="$1"
    shift
    local status=0
    set +e
    run_godot "$@" 2>&1 | tee "$log_file"
    status=${PIPESTATUS[0]}
    set -e
    return "$status"
}

failed=0
if run_logged "$OUTPUT_DIR/import.log" --editor --quit --import; then
    echo "Godot resource import: PASS"
else
    echo "Godot resource import: FAIL (see $OUTPUT_DIR/import.log)" >&2
    failed=1
fi

if run_logged "$OUTPUT_DIR/godot-test.log" res://tests/ReturningWaterRosterTestRunner.tscn --quit-after 1800; then
    echo "Returning Water Roster touch-flow regression: PASS"
else
    echo "Returning Water Roster touch-flow regression: FAIL (see $OUTPUT_DIR/godot-test.log)" >&2
    failed=1
fi

if run_logged "$OUTPUT_DIR/scene-smoke.log" res://scenes/ReturningWaterRoster.tscn --quit-after 30; then
    echo "Returning Water Roster scene smoke: PASS"
else
    echo "Returning Water Roster scene smoke: FAIL (see $OUTPUT_DIR/scene-smoke.log)" >&2
    failed=1
fi

if [[ -f "$OUTPUT_DIR/report.json" ]]; then
    if python3 - "$OUTPUT_DIR/report.json" "$OUTPUT_DIR" <<'PY'
import json
import struct
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
output_dir = Path(sys.argv[2])
report = json.loads(report_path.read_text(encoding="utf-8"))
assert report.get("result") == "passed", f"test result is {report.get('result')}"
assert report.get("simulated_touch") is True, "report must identify injected/simulated touch"
assert report.get("real_device_validation") is False, "headless/Xvfb run is not real-device validation"
required = {
    "title-launch",
    "settings-volume-touch",
    "settings-save-reload",
    "location-village-gate",
    "location-river-bridge",
    "five-clues-journal",
    "wrong-choice-recovery",
    "recovery-retry-choice",
    "correct-ending",
    "replay-start",
}
checkpoints = {item["name"]: item for item in report.get("checkpoints", [])}
missing = required - checkpoints.keys()
assert not missing, f"missing regression checkpoints: {sorted(missing)}"
for name in sorted(required):
    item = checkpoints[name]
    assert item.get("screenshot_saved") is True, f"checkpoint {name} has no saved screenshot"
    relative = item.get("screenshot")
    assert relative, f"checkpoint {name} has no screenshot path"
    image_path = output_dir / relative
    assert image_path.is_file(), f"missing screenshot file: {image_path}"
    data = image_path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", f"not a PNG: {image_path}"
    width, height = struct.unpack(">II", data[16:24])
    assert (width, height) == (1280, 720), f"unexpected screenshot size {width}x{height}: {image_path}"
print(f"JSON report and {len(required)} required regression checkpoints: PASS")
print(f"Checks: {report['passed_count']}/{report['check_count']}; screenshots are 1280x720 PNGs")
print("Touch mode: simulated; real-device validation: not performed")
PY
    then
        echo "Machine-readable results/screenshots validation: PASS"
    else
        echo "Machine-readable results/screenshots validation: FAIL" >&2
        failed=1
    fi
else
    echo "ERROR: test did not produce $OUTPUT_DIR/report.json" >&2
    failed=1
fi

restore_project_config
trap - EXIT HUP INT TERM

printf '\nArtifacts: %s\n' "$OUTPUT_DIR"
find "$OUTPUT_DIR" -maxdepth 2 -type f -printf '%P (%s bytes)\n' | sort
exit "$failed"
