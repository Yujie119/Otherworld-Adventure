from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BASE = Path(r"D:\游戏\earth-online\main\assets\character\艾尔登法环\怪物")
LOG_DIR = BASE / "_generation_logs" / "popular_monsters_20260707"
GEN_DIR = Path(r"D:\codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712")

FORMS = [
    {
        "slug": "runebear",
        "label": "Runebear",
        "folder": BASE / "runebear" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c6fe61c40819ab28ab146d6f892be.png",
        "target_height": 220,
    },
    {
        "slug": "grafted_scion",
        "label": "Grafted Scion",
        "folder": BASE / "grafted_scion" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c7035df50819a979a5ede035e5b43.png",
        "target_height": 222,
    },
    {
        "slug": "royal_revenant",
        "label": "Royal Revenant",
        "folder": BASE / "royal_revenant" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c70841a8c819ab9c23edb0c777222.png",
        "target_height": 210,
    },
    {
        "slug": "abductor_virgin",
        "label": "Abductor Virgin",
        "folder": BASE / "abductor_virgin" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c70c62654819a9adeed1f1e11b8f2.png",
        "target_height": 224,
    },
    {
        "slug": "fingercreeper",
        "label": "Fingercreeper",
        "folder": BASE / "fingercreeper" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c70fa60ec819a85db59a9ec4fc4db.png",
        "target_height": 210,
    },
    {
        "slug": "basilisk",
        "label": "Basilisk",
        "folder": BASE / "basilisk" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c7145f8f4819abca3c85d64a62453.png",
        "target_height": 174,
    },
    {
        "slug": "giant_land_octopus",
        "label": "Giant Land Octopus",
        "folder": BASE / "giant_land_octopus" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c7194ee84819ab3474bb3a0befeeb.png",
        "target_height": 190,
    },
    {
        "slug": "giant_crayfish",
        "label": "Giant Crayfish",
        "folder": BASE / "giant_crayfish" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c71bf0f20819abe80e2096128efdf.png",
        "target_height": 188,
    },
    {
        "slug": "monstrous_crow",
        "label": "Giant Crow",
        "folder": BASE / "monstrous_crow" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c72180664819a92431b3fba61b7ef.png",
        "target_height": 218,
    },
    {
        "slug": "ulcerated_tree_spirit",
        "label": "Ulcerated Tree Spirit",
        "folder": BASE / "ulcerated_tree_spirit" / "形态01_常态",
        "source": GEN_DIR / "ig_013d9cdcdf849340016a4c7265bd24819a9c733aac8b528da3.png",
        "target_height": 210,
    },
]


def is_magenta_key_like(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    return r >= 150 and b >= 150 and g <= 135 and r - g >= 55 and b - g >= 55


def remove_connected_magenta(image: Image.Image) -> Image.Image:
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
        if not is_magenta_key_like(px[x, y]):
            continue
        visited.add((x, y))
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    for x, y in visited:
        px[x, y] = (0, 0, 0, 0)

    # Some monster silhouettes enclose background islands between limbs, claws,
    # roots, and tentacles. This batch has no legitimate magenta features, so
    # remove strong key-colored islands globally after the border flood pass.
    for y in range(height):
        for x in range(width):
            if is_magenta_key_like(px[x, y]):
                px[x, y] = (0, 0, 0, 0)

    for _ in range(2):
        to_clear: list[tuple[int, int]] = []
        for y in range(height):
            for x in range(width):
                r, g, b, a = px[x, y]
                if a == 0 or not is_magenta_key_like((r, g, b, a)):
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

    # Neutralize bright magenta fringe only on pixels adjacent to transparency.
    for y in range(height):
        for x in range(width):
            r, g, b, a = px[x, y]
            if a == 0:
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
            touches_alpha = any(0 <= nx < width and 0 <= ny < height and px[nx, ny][3] == 0 for nx, ny in neighbors)
            if touches_alpha and r > g + 25 and b > g + 25 and r > 80 and b > 80:
                neutral = max(g, min(r, b) // 3)
                px[x, y] = (neutral, g, neutral, a)
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
        label = item["label"]
        draw.text((x + 6, y + tile_h + 4), label, fill=(235, 238, 245), font=font)
    canvas.save(BASE / "elden_ring_popular_monsters_preview.png")


def main() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    summary = []
    for form in FORMS:
        form["folder"].mkdir(parents=True, exist_ok=True)
        raw = Image.open(form["source"]).convert("RGBA")
        raw.save(form["folder"] / "raw-source.png")
        cleaned = remove_connected_magenta(raw)
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
