from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BASE = Path(r"D:\游戏\earth-online\main\assets\character\尼尔机械纪元")
LOG_DIR = BASE / "_generation_logs" / "popular_20260707"

FORMS = [
    {
        "slug": "2b",
        "folder": BASE / "2b" / "形态01_常态",
        "source": Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712\ig_085aac35c103a07c016a4c689cfa1081999ba0681723971570.png"),
        "target_height": 222,
    },
    {
        "slug": "9s",
        "folder": BASE / "9s" / "形态01_常态",
        "source": Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712\ig_085aac35c103a07c016a4c68dd2d5481998eea8773a6ea930e.png"),
        "target_height": 220,
    },
    {
        "slug": "a2",
        "folder": BASE / "a2" / "形态01_常态",
        "source": Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712\ig_085aac35c103a07c016a4c6927b5e48199a1a57ffc965936c4.png"),
        "target_height": 224,
    },
    {
        "slug": "pascal",
        "folder": BASE / "pascal" / "形态01_常态",
        "source": Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712\ig_085aac35c103a07c016a4c6978fbf081999683db15c8e947ac.png"),
        "target_height": 188,
    },
]


def is_key_like(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    # Generated chroma edges are not always exactly #00ff00, so accept only
    # border-connected pixels that are strongly green.
    return g >= 150 and g - r >= 70 and g - b >= 70


def remove_connected_green(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    px = rgba.load()
    visited = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= width or y >= height or (x, y) in visited:
            continue
        if not is_key_like(px[x, y]):
            continue
        visited.add((x, y))
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    for x, y in visited:
        px[x, y] = (0, 0, 0, 0)

    # Clear one-pixel green halo only when it touches transparent background.
    for _ in range(2):
        to_clear: list[tuple[int, int]] = []
        for y in range(height):
            for x in range(width):
                r, g, b, a = px[x, y]
                if a == 0 or not is_key_like((r, g, b, a)):
                    continue
                neighbors = (
                    (x + 1, y),
                    (x - 1, y),
                    (x, y + 1),
                    (x, y - 1),
                    (x + 1, y + 1),
                    (x - 1, y - 1),
                    (x + 1, y - 1),
                    (x - 1, y + 1),
                )
                if any(0 <= nx < width and 0 <= ny < height and px[nx, ny][3] == 0 for nx, ny in neighbors):
                    to_clear.append((x, y))
        for x, y in to_clear:
            px[x, y] = (0, 0, 0, 0)

    # Despill remaining visible green edge pixels without deleting them.
    # The NieR batch intentionally has no green character details, so a stronger
    # neutralization is safer than leaving chroma-key halos on black outfits.
    for y in range(height):
        for x in range(width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if g > max(r, b) + 12 and g > 35:
                px[x, y] = (r, max(r, b), b, a)
    return rgba


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def normalize(image: Image.Image, target_height: int, bottom_y: int = 240) -> Image.Image:
    bbox = alpha_bbox(image)
    if bbox is None:
        raise ValueError("image has no visible pixels")
    cropped = image.crop(bbox)
    w, h = cropped.size
    scale = min(target_height / h, 238 / w)
    new_size = (max(1, round(w * scale)), max(1, round(h * scale)))
    resized = cropped.resize(new_size, Image.Resampling.NEAREST)
    out = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    x = (256 - new_size[0]) // 2
    y = bottom_y - new_size[1]
    if y < 4:
        y = 4
    out.alpha_composite(resized, (x, y))
    return out


def key_residual_count(image: Image.Image) -> dict[str, int]:
    rgba = image.convert("RGBA")
    counts = {"green_key": 0, "greenish_residual": 0, "magenta_key": 0}
    for r, g, b, a in rgba.getdata():
        if a == 0:
            continue
        if g >= 245 and r <= 12 and b <= 12:
            counts["green_key"] += 1
        if g > max(r, b) + 18 and g > 45:
            counts["greenish_residual"] += 1
        if r >= 245 and b >= 245 and g <= 12:
            counts["magenta_key"] += 1
    return counts


def qc_meta(image: Image.Image) -> dict:
    bbox = alpha_bbox(image)
    width, height = image.size
    alpha = image.getchannel("A")
    edge_alpha = 0
    for x in range(width):
        edge_alpha = max(edge_alpha, alpha.getpixel((x, 0)), alpha.getpixel((x, height - 1)))
    for y in range(height):
        edge_alpha = max(edge_alpha, alpha.getpixel((0, y)), alpha.getpixel((width - 1, y)))
    residuals = key_residual_count(image)
    return {
        "size": [width, height],
        "mode": image.mode,
        "bbox": list(bbox) if bbox else None,
        "bbox_bottom": bbox[3] if bbox else None,
        "max_edge_alpha": int(edge_alpha),
        **residuals,
    }


def make_preview(items: list[dict]) -> None:
    tile_w, tile_h = 176, 212
    margin = 18
    label_h = 22
    canvas = Image.new("RGB", (margin * 2 + tile_w * len(items), margin * 2 + tile_h + label_h), (22, 24, 29))
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 14)
    except OSError:
        font = ImageFont.load_default()
    for idx, item in enumerate(items):
        sprite = Image.open(item["folder"] / f"{item['slug']}.png").convert("RGBA")
        preview = Image.new("RGBA", (tile_w, tile_h), (0, 0, 0, 0))
        scale = min((tile_w - 16) / 256, (tile_h - 20) / 256)
        small = sprite.resize((round(256 * scale), round(256 * scale)), Image.Resampling.NEAREST)
        preview.alpha_composite(small, ((tile_w - small.width) // 2, tile_h - small.height - 6))
        x = margin + idx * tile_w
        y = margin
        canvas.paste(preview.convert("RGB"), (x, y), preview)
        draw.text((x + 8, y + tile_h + 2), item["slug"], fill=(235, 238, 245), font=font)
    canvas.save(BASE / "nier_automata_popular_forms_preview.png")


def main() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    summary = []
    for form in FORMS:
        form["folder"].mkdir(parents=True, exist_ok=True)
        raw_copy = form["folder"] / "raw-source.png"
        raw = Image.open(form["source"]).convert("RGBA")
        raw.save(raw_copy)
        cleaned = remove_connected_green(raw)
        cleaned.save(form["folder"] / "raw-source-clean.png")
        final = normalize(cleaned, form["target_height"])
        final_path = form["folder"] / f"{form['slug']}.png"
        final.save(final_path)
        meta = qc_meta(final)
        meta["slug"] = form["slug"]
        meta["source"] = str(form["source"])
        meta["final"] = str(final_path)
        (form["folder"] / "qc-meta.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
        summary.append(meta)
    (LOG_DIR / "qc_summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    make_preview(FORMS)
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
