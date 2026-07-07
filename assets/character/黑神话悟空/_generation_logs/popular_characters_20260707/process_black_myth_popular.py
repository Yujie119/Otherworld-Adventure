from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BASE = Path(r"D:\游戏\earth-online\main\assets\character\黑神话悟空")
LOG_DIR = BASE / "_generation_logs" / "popular_characters_20260707"
GEN_DIR = Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712")

FORMS = [
    {
        "slug": "destined_one",
        "label": "Destined One",
        "folder": BASE / "destined_one" / "形态01_常态",
        "source": GEN_DIR / "ig_0670f81e72c81f90016a4c907cb1f88198aeaf5630a746d5df.png",
        "target_height": 222,
    },
    {
        "slug": "great_sage_broken_shell",
        "label": "Great Sage",
        "folder": BASE / "great_sage_broken_shell" / "形态01_常态",
        "source": GEN_DIR / "ig_0670f81e72c81f90016a4c90d01e80819892013cb80df8b093.png",
        "target_height": 226,
    },
    {
        "slug": "zhu_bajie",
        "label": "Zhu Bajie",
        "folder": BASE / "zhu_bajie" / "形态01_常态",
        "source": GEN_DIR / "ig_0670f81e72c81f90016a4c911d1558819889dfbcd8036db85e.png",
        "target_height": 208,
    },
    {
        "slug": "erlang_shen",
        "label": "Erlang Shen",
        "folder": BASE / "erlang_shen" / "形态01_常态",
        "source": GEN_DIR / "ig_0670f81e72c81f90016a4c91715c1c8198bcfa3f6af953493b.png",
        "target_height": 226,
    },
    {
        "slug": "bull_king",
        "label": "Bull King",
        "folder": BASE / "bull_king" / "形态01_常态",
        "source": GEN_DIR / "ig_0670f81e72c81f90016a4c91c6252c81989ec9d3134a374658.png",
        "target_height": 214,
    },
    {
        "slug": "red_boy",
        "label": "Red Boy",
        "folder": BASE / "red_boy" / "形态01_常态",
        "source": GEN_DIR / "ig_0670f81e72c81f90016a4c922410a4819898208b6f6f63a61c.png",
        "target_height": 216,
    },
]


def is_green_key_like(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    return g >= 145 and g - r >= 55 and g - b >= 55


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

    # Remove bright key-color islands inside gaps between staff, horns, robes,
    # and hair. This selected batch has no legitimate bright green costume areas.
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
            if g > max(r, b) + 12 and g > 45:
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
    cols = 6
    tile_w, tile_h = 156, 214
    margin = 16
    label_h = 30
    canvas = Image.new("RGB", (margin * 2 + tile_w * cols, margin * 2 + tile_h + label_h), (22, 24, 29))
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 12)
    except OSError:
        font = ImageFont.load_default()
    for idx, item in enumerate(items):
        sprite = Image.open(item["folder"] / f"{item['slug']}.png").convert("RGBA")
        preview = Image.new("RGBA", (tile_w, tile_h), (0, 0, 0, 0))
        scale = min((tile_w - 10) / 256, (tile_h - 10) / 256)
        small = sprite.resize((round(256 * scale), round(256 * scale)), Image.Resampling.NEAREST)
        preview.alpha_composite(small, ((tile_w - small.width) // 2, tile_h - small.height - 4))
        x = margin + idx * tile_w
        y = margin
        canvas.paste(preview.convert("RGB"), (x, y), preview)
        draw.text((x + 6, y + tile_h + 4), item["label"], fill=(235, 238, 245), font=font)
    canvas.save(BASE / "black_myth_wukong_popular_characters_preview.png")


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
