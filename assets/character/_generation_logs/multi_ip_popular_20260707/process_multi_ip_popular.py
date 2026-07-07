from __future__ import annotations

import csv
import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(r"D:\游戏\earth-online\main\assets\character")
LOG_DIR = ROOT / "_generation_logs" / "multi_ip_popular_20260707"
GEN_DIR = Path(r"C:\Users\宇杰\.codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712")


FORMS = [
    {
        "ip": "海贼王",
        "slug": "luffy",
        "label": "Luffy",
        "key": "green",
        "target_height": 222,
        "source": "ig_026fa4f1c18d1df6016a4c9bcf9e1881989d7736570a1eb298.png",
        "prompt": "Monkey D. Luffy, black messy hair, red vest, blue shorts, straw hat, sandals.",
    },
    {
        "ip": "海贼王",
        "slug": "zoro",
        "label": "Zoro",
        "key": "magenta",
        "target_height": 222,
        "source": "ig_026fa4f1c18d1df6016a4c9c0cfc488198b088a020eec90a17.png",
        "prompt": "Roronoa Zoro, green hair, green sash, three swords close to body.",
    },
    {
        "ip": "海贼王",
        "slug": "nami",
        "label": "Nami",
        "key": "green",
        "target_height": 222,
        "source": "ig_026fa4f1c18d1df6016a4c9c533694819884525ce5dcdaafc2.png",
        "prompt": "Nami, orange hair, blue-white outfit, clima-tact staff close to body.",
    },
    {
        "ip": "海贼王",
        "slug": "sanji",
        "label": "Sanji",
        "key": "green",
        "target_height": 222,
        "source": "ig_026fa4f1c18d1df6016a4c9c92b3688198b4d7e55137675cf0.png",
        "prompt": "Sanji, blond hair over one eye, dark suit, calm kickfighter posture.",
    },
    {
        "ip": "死神",
        "slug": "ichigo_kurosaki",
        "label": "Ichigo",
        "key": "green",
        "target_height": 224,
        "source": "ig_026fa4f1c18d1df6016a4c9ce27b5c8198b70ccbe4b2ef6e9b.png",
        "prompt": "Ichigo Kurosaki, orange hair, black shihakusho, large sword close to body.",
    },
    {
        "ip": "死神",
        "slug": "rukia_kuchiki",
        "label": "Rukia",
        "key": "green",
        "target_height": 216,
        "source": "ig_026fa4f1c18d1df6016a4c9d2738d88198a84378a3333ab742.png",
        "prompt": "Rukia Kuchiki, short black hair, black shihakusho, short sword close to body.",
    },
    {
        "ip": "死神",
        "slug": "byakuya_kuchiki",
        "label": "Byakuya",
        "key": "green",
        "target_height": 224,
        "source": "ig_026fa4f1c18d1df6016a4c9d6b5e0c81988e37629e80731f93.png",
        "prompt": "Byakuya Kuchiki, long black hair, black robe, white captain haori.",
    },
    {
        "ip": "死神",
        "slug": "sosuke_aizen",
        "label": "Aizen",
        "key": "green",
        "target_height": 224,
        "source": "ig_026fa4f1c18d1df6016a4c9db2b9748198a52f96ad8a296448.png",
        "prompt": "Sosuke Aizen, swept brown hair, white robe coat, calm villain stance.",
    },
    {
        "ip": "咒术回战",
        "slug": "yuji_itadori",
        "label": "Yuji",
        "key": "green",
        "target_height": 222,
        "source": "ig_026fa4f1c18d1df6016a4c9e0213a881988ab0f3bf3c2edd64.png",
        "prompt": "Yuji Itadori, pink hair, dark uniform with red hood accent, fists ready.",
    },
    {
        "ip": "咒术回战",
        "slug": "megumi_fushiguro",
        "label": "Megumi",
        "key": "green",
        "target_height": 222,
        "source": "ig_026fa4f1c18d1df6016a4c9e4293b08198bff66c6348abab21.png",
        "prompt": "Megumi Fushiguro, spiky black hair, dark high-collar school uniform.",
    },
    {
        "ip": "咒术回战",
        "slug": "satoru_gojo",
        "label": "Gojo",
        "key": "green",
        "target_height": 224,
        "source": "ig_026fa4f1c18d1df6016a4c9e836d90819888313e5a97d95aa3.png",
        "prompt": "Satoru Gojo, white hair, blindfold or dark glasses, dark high-collar outfit.",
    },
    {
        "ip": "咒术回战",
        "slug": "ryomen_sukuna",
        "label": "Sukuna",
        "key": "green",
        "target_height": 224,
        "source": "ig_026fa4f1c18d1df6016a4c9ec26984819887bd54f28ed54c12.png",
        "prompt": "Ryomen Sukuna, pink hair, abstract dark markings, menacing stance.",
    },
    {
        "ip": "鬼灭之刃",
        "slug": "tanjiro_kamado",
        "label": "Tanjiro",
        "key": "magenta",
        "target_height": 222,
        "source": "ig_025cb096dbab5378016a4ca29f2b74819ba419dfa7297032b4.png",
        "prompt": "Tanjiro Kamado, maroon hair, green-black checkered haori, katana close.",
    },
    {
        "ip": "鬼灭之刃",
        "slug": "nezuko_kamado",
        "label": "Nezuko",
        "key": "magenta",
        "target_height": 216,
        "source": "ig_025cb096dbab5378016a4ca2ef95b0819b813a5886b1ecc2c8.png",
        "prompt": "Nezuko Kamado, long dark hair with orange tips, pink kimono, bamboo muzzle.",
    },
    {
        "ip": "鬼灭之刃",
        "slug": "zenitsu_agatsuma",
        "label": "Zenitsu",
        "key": "green",
        "target_height": 222,
        "source": "ig_025cb096dbab5378016a4ca3381650819ba76956c4fd0c703e.png",
        "prompt": "Zenitsu Agatsuma, yellow-orange hair, orange haori, sheathed katana.",
    },
    {
        "ip": "鬼灭之刃",
        "slug": "inosuke_hashibira",
        "label": "Inosuke",
        "key": "green",
        "target_height": 218,
        "source": "ig_023bcaca6db967c1016a4ca5413f14819b8cbbc8aeacc018e4.png",
        "prompt": "Inosuke Hashibira, boar mask, bare torso, fur pelt waist, two swords.",
    },
    {
        "ip": "进击的巨人",
        "slug": "eren_yeager",
        "label": "Eren",
        "key": "magenta",
        "target_height": 222,
        "source": "ig_0f9156ba45ea1581016a4ca72aa8a481988a1c51ab6299be0d.png",
        "prompt": "Eren Yeager, brown hair, green cloak, harness, blades close to body.",
    },
    {
        "ip": "进击的巨人",
        "slug": "mikasa_ackerman",
        "label": "Mikasa",
        "key": "magenta",
        "target_height": 220,
        "source": "ig_0f9156ba45ea1581016a4ca79eb7c481989f6b044c7be863f0.png",
        "prompt": "Mikasa Ackerman, short dark hair, red scarf, green cloak, blades close.",
    },
    {
        "ip": "进击的巨人",
        "slug": "levi_ackerman",
        "label": "Levi",
        "key": "magenta",
        "target_height": 216,
        "source": "ig_0f9156ba45ea1581016a4ca7f4f0b48198855204a7a9ba1142.png",
        "prompt": "Levi Ackerman, short undercut hair, green cloak, harness, blades close.",
    },
    {
        "ip": "进击的巨人",
        "slug": "armored_titan",
        "label": "Armored Titan",
        "key": "green",
        "target_height": 226,
        "source": "ig_0db2aea1bc37106f016a4ca91a25e081988faa2e1c22eae038.png",
        "prompt": "Armored Titan, pale hardened armor plates, broad humanoid monster stance.",
    },
    {
        "ip": "原神",
        "slug": "aether_traveler",
        "label": "Aether",
        "key": "green",
        "target_height": 222,
        "source": "ig_0db2aea1bc37106f016a4ca9870f64819889e40d1d2017b2b4.png",
        "prompt": "Traveler Aether, blond hair, white-brown adventurer outfit, short cape.",
    },
    {
        "ip": "原神",
        "slug": "paimon",
        "label": "Paimon",
        "key": "green",
        "target_height": 194,
        "source": "ig_0db2aea1bc37106f016a4ca9f31b148198990facca73ba1962.png",
        "prompt": "Paimon, white hair, halo-like crown, white outfit, tiny hovering companion.",
    },
    {
        "ip": "原神",
        "slug": "zhongli",
        "label": "Zhongli",
        "key": "green",
        "target_height": 224,
        "source": "ig_0db2aea1bc37106f016a4caa4115bc8198999a1456a2902e5d.png",
        "prompt": "Zhongli, dark brown hair with amber tips, brown-black long coat.",
    },
    {
        "ip": "原神",
        "slug": "raiden_shogun",
        "label": "Raiden",
        "key": "green",
        "target_height": 224,
        "source": "ig_0db2aea1bc37106f016a4caa92d80c81988fab69def76718e5.png",
        "prompt": "Raiden Shogun, violet hair braid, purple kimono-style outfit.",
    },
    {
        "ip": "英雄联盟",
        "slug": "jinx",
        "label": "Jinx",
        "key": "green",
        "target_height": 222,
        "source": "ig_0db2aea1bc37106f016a4caaf952188198b1bbacd14f09079c.png",
        "prompt": "Jinx, long blue twin braids, punk outfit, compact oversized weapon.",
    },
    {
        "ip": "英雄联盟",
        "slug": "ahri",
        "label": "Ahri",
        "key": "green",
        "target_height": 222,
        "source": "ig_0db2aea1bc37106f016a4cab4c725c8198b3c0a3de375e1a57.png",
        "prompt": "Ahri, fox ears, white-red outfit, multiple tails close behind body.",
    },
    {
        "ip": "英雄联盟",
        "slug": "yasuo",
        "label": "Yasuo",
        "key": "green",
        "target_height": 222,
        "source": "ig_0db2aea1bc37106f016a4caba1f5548198998b6438649d2d30.png",
        "prompt": "Yasuo, tied dark hair, blue-gray ronin outfit, katana close.",
    },
    {
        "ip": "英雄联盟",
        "slug": "teemo",
        "label": "Teemo",
        "key": "magenta",
        "target_height": 194,
        "source": "ig_0db2aea1bc37106f016a4cac103e908198bcd443ab976b2d93.png",
        "prompt": "Teemo, small yordle scout, green cap, red scarf, blowgun close.",
    },
    {
        "ip": "我的世界",
        "slug": "creeper",
        "label": "Creeper",
        "key": "magenta",
        "target_height": 210,
        "source": "ig_0808acc7b9230de7016a4cb4d6f5d8819bb06d1b3a8a52fa51.png",
        "prompt": "Creeper, tall blocky green hostile creature, four short blocky legs.",
    },
    {
        "ip": "我的世界",
        "slug": "zombie",
        "label": "Zombie",
        "key": "magenta",
        "target_height": 210,
        "source": "ig_0808acc7b9230de7016a4cb52723a4819b9e2b5e070a990f3a.png",
        "prompt": "Zombie, blocky undead humanoid, green skin, teal shirt, blue pants.",
    },
    {
        "ip": "我的世界",
        "slug": "skeleton",
        "label": "Skeleton",
        "key": "green",
        "target_height": 210,
        "source": "ig_0808acc7b9230de7016a4cb581d658819b81de1414755da80d.png",
        "prompt": "Skeleton, blocky pale skeleton archer, bow kept close to body.",
    },
    {
        "ip": "我的世界",
        "slug": "enderman",
        "label": "Enderman",
        "key": "green",
        "target_height": 226,
        "source": "ig_0808acc7b9230de7016a4cb5d58984819bb8be018af8daad55.png",
        "prompt": "Enderman, tall thin black blocky creature, long limbs, purple eyes.",
    },
    {
        "ip": "最终幻想VII",
        "slug": "cloud_strife",
        "label": "Cloud",
        "key": "green",
        "target_height": 224,
        "source": "ig_0dda1ef1a2760ad3016a4cb83f00308198b4427d6453e067e6.png",
        "prompt": "Cloud Strife, spiky blond hair, dark outfit, huge buster sword close.",
    },
    {
        "ip": "最终幻想VII",
        "slug": "tifa_lockhart",
        "label": "Tifa",
        "key": "green",
        "target_height": 222,
        "source": "ig_0dda1ef1a2760ad3016a4cb8a0b72c8198873ffd539d510f3d.png",
        "prompt": "Tifa Lockhart, long dark hair, white top, black skirt or shorts, red gloves.",
    },
    {
        "ip": "最终幻想VII",
        "slug": "aerith_gainsborough",
        "label": "Aerith",
        "key": "green",
        "target_height": 222,
        "source": "ig_0dda1ef1a2760ad3016a4cb9165b30819887d153b4aad6279f.png",
        "prompt": "Aerith Gainsborough, brown braid with ribbon, pink dress, red jacket, staff.",
    },
    {
        "ip": "最终幻想VII",
        "slug": "sephiroth",
        "label": "Sephiroth",
        "key": "green",
        "target_height": 226,
        "source": "ig_0dda1ef1a2760ad3016a4cb99612fc8198a49e20c48aebf747.png",
        "prompt": "Sephiroth, very long silver hair, black coat, long katana close.",
    },
    {
        "ip": "怪物猎人",
        "slug": "rathalos",
        "label": "Rathalos",
        "key": "green",
        "target_height": 222,
        "max_width": 238,
        "source": "ig_0dda1ef1a2760ad3016a4cba0dae7881988df59f4a4a59ba41.png",
        "prompt": "Rathalos, red wyvern, folded wings, tail curled close.",
    },
    {
        "ip": "怪物猎人",
        "slug": "rathian",
        "label": "Rathian",
        "key": "magenta",
        "target_height": 222,
        "max_width": 238,
        "source": "ig_0dda1ef1a2760ad3016a4cba6c941881989cacf1097e3a100c.png",
        "prompt": "Rathian, green wyvern, folded wings, spiked tail curled close.",
    },
    {
        "ip": "怪物猎人",
        "slug": "zinogre",
        "label": "Zinogre",
        "key": "green",
        "target_height": 220,
        "max_width": 238,
        "source": "ig_0dda1ef1a2760ad3016a4cbad16cbc8198be8d58836e8900c5.png",
        "prompt": "Zinogre, thunder wolf wyvern, bulky forelimbs, yellow accents.",
    },
    {
        "ip": "怪物猎人",
        "slug": "nargacuga",
        "label": "Nargacuga",
        "key": "green",
        "target_height": 214,
        "max_width": 238,
        "source": "ig_0dda1ef1a2760ad3016a4cbb3003688198a978d163062d27af.png",
        "prompt": "Nargacuga, black panther wyvern, red eyes, wing arms folded close.",
    },
]


REJECTED_SOURCES = [
    {
        "reason": "Duplicate League of Legends regeneration, excluded from final batch",
        "source": "ig_0808acc7b9230de7016a4cb352942c819baceda5fe2fb72de2.png",
    },
    {
        "reason": "Duplicate League of Legends regeneration, excluded from final batch",
        "source": "ig_0808acc7b9230de7016a4cb3a97754819bba370b7360664cd9.png",
    },
    {
        "reason": "Duplicate League of Legends regeneration, excluded from final batch",
        "source": "ig_0808acc7b9230de7016a4cb41527ec819bbea058cf4b609393.png",
    },
    {
        "reason": "Duplicate League of Legends regeneration, excluded from final batch",
        "source": "ig_0808acc7b9230de7016a4cb47c9bcc819bbb48a22661fdf268.png",
    },
]


def key_like(pixel: tuple[int, int, int, int], key: str) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    if key == "green":
        return g >= 145 and g - r >= 55 and g - b >= 55
    if key == "magenta":
        return r >= 145 and b >= 145 and g <= 145 and r - g >= 45 and b - g >= 45
    raise ValueError(f"unknown key: {key}")


def remove_connected_key(image: Image.Image, key: str) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    px = rgba.load()
    visited: set[tuple[int, int]] = set()
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
        if not key_like(px[x, y], key):
            continue
        visited.add((x, y))
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    for x, y in visited:
        px[x, y] = (0, 0, 0, 0)

    # Remove isolated key-color islands left in holes between limbs, hair, weapons, and tails.
    for y in range(height):
        for x in range(width):
            if key_like(px[x, y], key):
                px[x, y] = (0, 0, 0, 0)

    for _ in range(2):
        to_clear: list[tuple[int, int]] = []
        for y in range(height):
            for x in range(width):
                if px[x, y][3] == 0 or not key_like(px[x, y], key):
                    continue
                if any_neighbor_alpha(px, width, height, x, y):
                    to_clear.append((x, y))
        for x, y in to_clear:
            px[x, y] = (0, 0, 0, 0)

    for y in range(height):
        for x in range(width):
            r, g, b, a = px[x, y]
            if a == 0 or not any_neighbor_alpha(px, width, height, x, y):
                continue
            if key == "green" and g > max(r, b) + 16 and g > 70:
                px[x, y] = (r, max(r, b), b, a)
            elif key == "magenta" and r > g + 25 and b > g + 25 and r > 80 and b > 80:
                neutral = max(g, min(r, b) // 3)
                px[x, y] = (neutral, g, neutral, a)
    return rgba


def any_neighbor_alpha(px, width: int, height: int, x: int, y: int) -> bool:
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
    return any(0 <= nx < width and 0 <= ny < height and px[nx, ny][3] == 0 for nx, ny in neighbors)


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def normalize(
    image: Image.Image,
    target_height: int,
    bottom_y: int = 240,
    max_width: int = 236,
) -> Image.Image:
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
    y = max(4, bottom_y - new_size[1])
    out.alpha_composite(resized, (x, y))
    return out


def sanitize_exact_key_colors(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    px = rgba.load()
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if g >= 245 and r <= 12 and b <= 12:
                px[x, y] = (12, 238, 12, a)
            elif r >= 245 and b >= 245 and g <= 12:
                px[x, y] = (238, 12, 238, a)
    return rgba


def residual_counts(image: Image.Image) -> dict[str, int]:
    counts = {
        "green_key": 0,
        "strong_greenish": 0,
        "magenta_key": 0,
        "strong_magenta": 0,
    }
    for r, g, b, a in image.convert("RGBA").getdata():
        if a == 0:
            continue
        if g >= 245 and r <= 12 and b <= 12:
            counts["green_key"] += 1
        if g > max(r, b) + 60 and g > 170:
            counts["strong_greenish"] += 1
        if r >= 245 and b >= 245 and g <= 12:
            counts["magenta_key"] += 1
        if r > g + 80 and b > g + 80 and r > 185 and b > 185:
            counts["strong_magenta"] += 1
    return counts


def qc_meta(image: Image.Image, form: dict, final_path: Path) -> dict:
    bbox = alpha_bbox(image)
    width, height = image.size
    alpha = image.getchannel("A")
    edge_alpha = 0
    for x in range(width):
        edge_alpha = max(edge_alpha, alpha.getpixel((x, 0)), alpha.getpixel((x, height - 1)))
    for y in range(height):
        edge_alpha = max(edge_alpha, alpha.getpixel((0, y)), alpha.getpixel((width - 1, y)))
    counts = residual_counts(image)
    passed = (
        image.mode == "RGBA"
        and image.size == (256, 256)
        and int(edge_alpha) == 0
        and counts["green_key"] == 0
        and counts["magenta_key"] == 0
        and bbox is not None
        and bbox[3] <= 241
    )
    return {
        "ip": form["ip"],
        "slug": form["slug"],
        "label": form["label"],
        "key": form["key"],
        "source": str(GEN_DIR / form["source"]),
        "final": str(final_path),
        "size": [width, height],
        "mode": image.mode,
        "bbox": list(bbox) if bbox else None,
        "bbox_bottom": bbox[3] if bbox else None,
        "max_edge_alpha": int(edge_alpha),
        "passed_machine_qc": passed,
        **counts,
    }


def write_preview(items: list[dict], out_path: Path, cols: int = 8) -> None:
    tile_w, tile_h = 142, 172
    label_h = 26
    margin = 14
    rows = (len(items) + cols - 1) // cols
    canvas = Image.new(
        "RGB",
        (margin * 2 + tile_w * cols, margin * 2 + (tile_h + label_h) * rows),
        (22, 24, 29),
    )
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 11)
    except OSError:
        font = ImageFont.load_default()
    for idx, item in enumerate(items):
        sprite = Image.open(item["folder"] / f"{item['slug']}.png").convert("RGBA")
        preview = Image.new("RGBA", (tile_w, tile_h), (0, 0, 0, 0))
        scale = min((tile_w - 12) / 256, (tile_h - 8) / 256)
        small = sprite.resize((round(256 * scale), round(256 * scale)), Image.Resampling.NEAREST)
        preview.alpha_composite(small, ((tile_w - small.width) // 2, tile_h - small.height - 3))
        col = idx % cols
        row = idx // cols
        x = margin + col * tile_w
        y = margin + row * (tile_h + label_h)
        canvas.paste(preview.convert("RGB"), (x, y), preview)
        label = item["label"][:20]
        draw.text((x + 4, y + tile_h + 4), label, fill=(235, 238, 245), font=font)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path)


def main() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    summary = []
    source_rows = []
    for form in FORMS:
        folder = ROOT / form["ip"] / form["slug"] / "形态01_常态"
        folder.mkdir(parents=True, exist_ok=True)
        form["folder"] = folder
        source_path = GEN_DIR / form["source"]
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        raw = Image.open(source_path).convert("RGBA")
        raw.save(folder / "raw-source.png")
        cleaned = remove_connected_key(raw, form["key"])
        cleaned.save(folder / "raw-source-clean.png")
        final = normalize(
            cleaned,
            form["target_height"],
            max_width=form.get("max_width", 236),
        )
        final = sanitize_exact_key_colors(final)
        final_path = folder / f"{form['slug']}.png"
        final.save(final_path)
        (folder / "prompt-used.txt").write_text(form["prompt"], encoding="utf-8")
        meta = qc_meta(final, form, final_path)
        (folder / "qc-meta.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
        summary.append(meta)
        source_rows.append(
            {
                "ip": form["ip"],
                "slug": form["slug"],
                "label": form["label"],
                "key": form["key"],
                "source": str(source_path),
                "final": str(final_path),
            }
        )

    with (LOG_DIR / "source_map.csv").open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=["ip", "slug", "label", "key", "source", "final"])
        writer.writeheader()
        writer.writerows(source_rows)

    (LOG_DIR / "qc_summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (LOG_DIR / "rejected_sources.json").write_text(
        json.dumps(REJECTED_SOURCES, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    write_preview(FORMS, LOG_DIR / "multi_ip_popular_preview.png", cols=8)
    write_preview(FORMS, ROOT / "multi_ip_popular_20260707_preview.png", cols=8)

    by_ip: dict[str, list[dict]] = {}
    for form in FORMS:
        by_ip.setdefault(form["ip"], []).append(form)
    for ip, forms in by_ip.items():
        write_preview(forms, ROOT / ip / f"{ip}_popular_preview.png", cols=4)

    print(json.dumps({"count": len(summary), "failed": [m for m in summary if not m["passed_machine_qc"]]}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
