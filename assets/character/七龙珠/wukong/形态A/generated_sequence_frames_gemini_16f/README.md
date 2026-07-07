# Wukong Gemini 16-frame sequence sprites

Reference image:

- `D:\游戏\earth-online\main\assets\character\七龙珠\wukong\形态A\wukong.png`

Generation config:

- Source config: `D:\游戏\earth-online\key.txt`
- Model: `gemini-3.1-flash-image`
- Endpoint mode: OpenAI-compatible `/chat/completions`
- API key is intentionally not copied into this folder.

Output root:

- `D:\游戏\earth-online\main\assets\character\七龙珠\wukong\形态A\generated_sequence_frames_gemini_16f`

## Actions

| Action | Frames | Sheet | Cell | Suggested playback |
| --- | ---: | --- | --- | --- |
| `idle` | 16 | `idle\sheet-transparent.png` | 256x256, 4x4 | 6-7 FPS |
| `run` | 16 | `run\sheet-transparent.png` | 256x256, 4x4 | 11-12 FPS |
| `attack` | 16 | `attack\sheet-transparent.png` | 256x256, 4x4 | 12-13 FPS |

Each action folder contains:

- `raw-sheet-provider.jpg`: direct model response image.
- `raw-sheet.png`: normalized PNG copy of the provider image.
- `raw-sheet-preclean.png`: deterministic cleanup of JPEG magenta noise and generated grid separators.
- `raw-sheet-repadded.png`: deterministic 4x4 magenta sheet used for the final processor pass.
- `raw-sheet-clean.png`: chroma-key-cleaned intermediate sheet.
- `sheet-transparent.png`: transparent 4x4 animation sheet.
- `wukong-<action>-1.png` through `wukong-<action>-16.png`: individual transparent frames.
- `animation.gif`: quick preview GIF.
- `prompt-used-full.txt`: full Gemini prompt.
- `key-model-config.redacted.json`: redacted request configuration.
- `pipeline-meta.json`: final processing and QC metadata.

## Godot notes

For sheet-based import:

- `hframes = 4`
- `vframes = 4`
- frame order is left-to-right across each row, then next row.

For `AnimatedSprite2D` / `SpriteFrames`, import the individual PNG frames from each action folder in numeric order.

QC summary:

- `idle`: 16 frames, 1024x1024 transparent sheet, edge touch count 0.
- `run`: 16 frames, 1024x1024 transparent sheet, edge touch count 0.
- `attack`: 16 frames, 1024x1024 transparent sheet, edge touch count 0.

Note: the source reference is low resolution, so this is a reference-based redraw from the configured image model, followed by deterministic cleanup and frame extraction.
