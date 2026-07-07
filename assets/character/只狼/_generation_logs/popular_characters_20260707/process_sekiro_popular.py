from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BASE = Path(r"D:\游戏\earth-online\main\assets\character\只狼")
LOG_DIR = BASE / "_generation_logs" / "popular_characters_20260707"
GEN_DIR = Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712")

FORMS = [
    {
        "slug": "wolf_sekiro",
        "label": "Wolf",
        "folder": BASE / "wolf_sekiro" / "形态01_常态",
        "source": GEN_DIR / "ig_0e1e6408d7c36202016a4c795728b8819ba1680e648a9a2cca.png",
        "target_height": 222,
    },
    {
        "slug": "kuro",
        "label": "Kuro",
        "folder": BASE / "kuro" / "形态01_常态",
        "source": GEN_DIR / "ig_0e1e6408d7c36202016a4c79c3be38819bb463384cacd3b85d.png",
        "target_height": 192,
    },
    {
        "slug": "emma",
        "label": "Emma",
        "folder": BASE / "emma" / "形态01_常态",
        "source": GEN_DIR / "ig_0e1e6408d7c36202016a4c7a0f89b0819ba5c123e85d554de3.png",
        "target_height": 218,
    },
    {
        "slug": "isshin_ashina",
        "label": "Isshin",
        "folder": BASE / "isshin_ashina" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7b064d44819a8e958647aa0d191b.png",
        "target_height": 222,
    },
    {
        "slug": "genichiro_ashina",
        "label": "Genichiro",
        "folder": BASE / "genichiro_ashina" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7b6a5d8c819ab755ec7e00f38b89.png",
        "target_height": 224,
    },
    {
        "slug": "great_shinobi_owl",
        "label": "Owl",
        "folder": BASE / "great_shinobi_owl" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7bd14c40819a9bc1516f234f44c5.png",
        "target_height": 226,
    },
    {
        "slug": "lady_butterfly",
        "label": "Lady Butterfly",
        "folder": BASE / "lady_butterfly" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7c1e3e24819aa778ca8efe6ebf6b.png",
        "target_height": 218,
    },
    {
        "slug": "sculptor",
        "label": "Sculptor",
        "folder": BASE / "sculptor" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7c660958819ab77ea95c8ccd1278.png",
        "target_height": 210,
    },
    {
        "slug": "divine_child",
        "label": "Divine Child",
        "folder": BASE / "divine_child" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7cb5e434819a8d573acc6431c6c9.png",
        "target_height": 190,
    },
    {
        "slug": "corrupted_monk",
        "label": "Corrupted Monk",
        "folder": BASE / "corrupted_monk" / "形态01_常态",
        "source": GEN_DIR / "ig_042152bcb92515c9016a4c7d0595c4819aab0f1182b42ee572.png",
        "target_height": 226,
    },
]


def is_green_key_like(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    return g >= 145 and g - r >= 60 and g - b >= 60


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
        if not is_green_key_like(px[x, y]):
            continue
        visited.add((x, y))
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    for x, y in visited:
        px[x, y] = (0, 0, 0, 0)

    # Remove strong green islands caught inside sleeves, swords, and hair gaps.
    # This batch has no official bright-green costume features.
    for y in range(height):
        for x in range(width):
            if is_green_key_like(px[x, y]):
                px[x, y] = (0, 0, 0, 0)

    for _ in range(2):
        to_clear: list[tuple[int, int]] = []
        for y in range(height):
            for x in range(width):
                if not is_green_key_like(px[x, y]) or px[x, y][3] == 0:
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

    for y in range(height):
        for x in range(width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if g > max(r, b) + 18 and g > 60:
                px[x, y] = (r, max(r, b), b, a)
    return rgba


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def normalize(image: Image.Image, target_height: int, bottom_y: int = 240, max_width: int = 236) -> Image.Image:
    bbox = alpha_bbox(image)
    if bbox is None:
        raise ValueError("image has no visible pixels")
    cropped = image.crop(bbox)
    w, h = cropped.size
    scale = min(target_height / h, max_width / w)
    new_size = (max(1, round(w * scale)), max(1, round(h * scale)))
    resized = cropped.resize(new_size, Image.Resampling.NEAREST)
    out = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    x = (256 - new_size[0]) // 2
    y = bottom_y - new_size[1]
    if y < 4:
        y = 4
    out.alpha_composite(resized, (x, y))
    return out


def residual_counts(image: Image.Image) -> dict[str, int]:
    counts = {"green_key": 0, "greenish_residual": 0, "magenta_key": 0, "magenta_residual": 0}
    for r, g, b, a in image.convert("RGBA").getdata():
        if a == 0:
            continue
        if g >= 245 and r <= 12 and b <= 12:
            counts["green_key"] += 1
        if g > max(r, b) + 45 and g > 150:
            counts["greenish_residual"] += 1
        if r >= 245 and b >= 245 and g <= 12:
            counts["magenta_key"] += 1
        if r > g + 60 and b > g + 60 and r > 170 and b > 170:
            counts["magenta_residual"] += 1
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
    return {
        "size": [width, height],
        "mode": image.mode,
        "bbox": list(bbox) if bbox else None,
        "bbox_bottom": bbox[3] if bbox else None,
        "max_edge_alpha": int(edge_alpha),
        **residual_counts(image),
    }


def write_preview(items: list[dict]) -> None:
    cols = 5
    rows = 2
    tile_w, tile_h = 170, 214
    margin = 16
    label_h = 30
    canvas = Image.new(
        "RGB",
        (margin * 2 + tile_w * cols, margin * 2 + (tile_h + label_h) * rows),
        (22, 24, 29),
    )
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 12)
    except OSError:
        font = ImageFont.load_default()
    for idx, item in enumerate(items):
        sprite = Image.open(item["folder"] / f"{item['slug']}.png").convert("RGBA")
        preview = Image.new("RGBA", (tile_w, tile_h), (0, 0, 0, 0))
        scale = min((tile_w - 12) / 256, (tile_h - 10) / 256)
        small = sprite.resize((round(256 * scale), round(256 * scale)), Image.Resampling.NEAREST)
        preview.alpha_composite(small, ((tile_w - small.width) // 2, tile_h - small.height - 4))
        col = idx % cols
        row = idx // cols
        x = margin + col * tile_w
        y = margin + row * (tile_h + label_h)
        canvas.paste(preview.convert("RGB"), (x, y), preview)
        draw.text((x + 6, y + tile_h + 4), item["label"], fill=(235, 238, 245), font=font)
    canvas.save(BASE / "sekiro_popular_characters_preview.png")


def main() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    summary = []
    for form in FORMS:
        form["folder"].mkdir(parents=True, exist_ok=True)
        raw = Image.open(form["source"]).convert("RGBA")
        raw.save(form["folder"] / "raw-source.png")
        cleaned = remove_connected_green(raw)
        cleaned.save(form["folder"] / "raw-source-clean.png")
        final = normalize(cleaned, form["target_height"])
        final_path = form["folder"] / f"{form['slug']}.png"
        final.save(final_path)
        meta = qc_meta(final)
        meta["slug"] = form["slug"]
        meta["label"] = form["label"]
        meta["source"] = str(form["source"])
        meta["final"] = str(final_path)
        (form["folder"] / "qc-meta.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
        summary.append(meta)
    (LOG_DIR / "qc_summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    write_preview(FORMS)
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
