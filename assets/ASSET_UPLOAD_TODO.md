# Asset Upload TODO

Upload the extracted `assets/` folder from `yinqi_visual_asset_pack_v0_3_FIXED.zip` into this directory.

Expected structure:

```text
assets/backgrounds/*.png   17 files
assets/characters/*.png    20 files
assets/icons/*.png         18 files
```

V0.1 already binds six viewpoint background paths in `data/viewpoints/viewpoints.example.json`.

The current connector has committed the folders, manifest, mapping, and CI validation. Binary PNG upload should be done through GitHub web upload or a git push so the files remain valid PNG binaries.
