from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "manifest" / "assets_manifest.json"


def main() -> None:
    if not MANIFEST.exists():
        raise SystemExit("missing manifest/assets_manifest.json")
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assets = data.get("assets", [])
    missing = []
    for asset in assets:
        rel = asset.get("path", "")
        if not rel:
            continue
        if not (ROOT / rel).exists():
            missing.append(rel)
    print(f"manifest assets listed: {len(assets)}")
    print(f"missing binary files: {len(missing)}")
    for rel in missing[:20]:
        print("MISSING", rel)
    if missing:
        print("NOTE: Missing PNG binaries are allowed during placeholder integration, but must be uploaded before final export.")


if __name__ == "__main__":
    main()
