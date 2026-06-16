# Workflow Status

## Added

```text
.github/workflows/validate.yml
scripts/validate_assets.py
```

The workflow validates:

```text
JSON syntax under data/, manifest/, godot/
required Godot project files
V0.1 viewpoint background_asset bindings
```

## Important

This CI does not export Android APK yet. It is the first safety net for the playable demo branch.

Next CI stage should add:

```text
Godot headless import check
Android export preset check
APK artifact build
```

## Asset binaries

Asset folders are committed with `.keep` files. The 55 PNG binaries from the V0.3 pack should be uploaded to:

```text
assets/backgrounds/
assets/characters/
assets/icons/
```

Once uploaded, `scripts/validate_assets.py` can be changed from warning-only to fail-on-missing mode.
