# Wukong Generated Sequence Frames

Reference source: `../悟空超赛神.png`

The reference image is low resolution, so these outputs are reference-based regenerated sprite frames rather than pixel-perfect edits of the original.

## Outputs

| Action | Frames | Sheet | Frame size | Suggested FPS |
| --- | ---: | --- | --- | ---: |
| idle | 4 | `idle/sheet-transparent.png` | 256x256 | 5-6 |
| run | 4 | `run/sheet-transparent.png` | 256x256 | 8-10 |
| attack | 6 | `attack/sheet-transparent.png` | 256x256 | 9-12 |

Each action folder also contains:

- `animation.gif` preview
- individual transparent frame PNGs
- `raw-sheet.png`
- `raw-sheet-clean.png`
- `prompt-used.txt`
- `pipeline-meta.json`

## Godot Notes

For `AnimatedSprite2D`, use the individual `wukong-*.png` frames.

For `Sprite2D` / `AnimationPlayer` with a sprite sheet:

- idle: hframes `2`, vframes `2`
- run: hframes `2`, vframes `2`
- attack: hframes `3`, vframes `2`

All final frames use transparent PNG alpha. The black background in previews is only the viewer background.
