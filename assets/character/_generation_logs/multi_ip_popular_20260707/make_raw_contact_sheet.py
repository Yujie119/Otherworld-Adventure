from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


GEN_DIR = Path(r"C:\Users\宇杰\.codex\generated_images\019f387e-cf1e-71a2-9560-b5b79b4d5712")
LOG_DIR = Path(r"D:\游戏\earth-online\main\assets\character\_generation_logs\multi_ip_popular_20260707")

FILES = [
    "ig_026fa4f1c18d1df6016a4c9bcf9e1881989d7736570a1eb298.png",
    "ig_026fa4f1c18d1df6016a4c9c0cfc488198b088a020eec90a17.png",
    "ig_026fa4f1c18d1df6016a4c9c533694819884525ce5dcdaafc2.png",
    "ig_026fa4f1c18d1df6016a4c9c92b3688198b4d7e55137675cf0.png",
    "ig_026fa4f1c18d1df6016a4c9ce27b5c8198b70ccbe4b2ef6e9b.png",
    "ig_026fa4f1c18d1df6016a4c9d2738d88198a84378a3333ab742.png",
    "ig_026fa4f1c18d1df6016a4c9d6b5e0c81988e37629e80731f93.png",
    "ig_026fa4f1c18d1df6016a4c9db2b9748198a52f96ad8a296448.png",
    "ig_026fa4f1c18d1df6016a4c9e0213a881988ab0f3bf3c2edd64.png",
    "ig_026fa4f1c18d1df6016a4c9e4293b08198bff66c6348abab21.png",
    "ig_026fa4f1c18d1df6016a4c9e836d90819888313e5a97d95aa3.png",
    "ig_026fa4f1c18d1df6016a4c9ec26984819887bd54f28ed54c12.png",
    "ig_025cb096dbab5378016a4ca29f2b74819ba419dfa7297032b4.png",
    "ig_025cb096dbab5378016a4ca2ef95b0819b813a5886b1ecc2c8.png",
    "ig_025cb096dbab5378016a4ca3381650819ba76956c4fd0c703e.png",
    "ig_023bcaca6db967c1016a4ca5413f14819b8cbbc8aeacc018e4.png",
    "ig_0f9156ba45ea1581016a4ca72aa8a481988a1c51ab6299be0d.png",
    "ig_0f9156ba45ea1581016a4ca79eb7c481989f6b044c7be863f0.png",
    "ig_0f9156ba45ea1581016a4ca7f4f0b48198855204a7a9ba1142.png",
    "ig_0db2aea1bc37106f016a4ca91a25e081988faa2e1c22eae038.png",
    "ig_0db2aea1bc37106f016a4ca9870f64819889e40d1d2017b2b4.png",
    "ig_0db2aea1bc37106f016a4ca9f31b148198990facca73ba1962.png",
    "ig_0db2aea1bc37106f016a4caa4115bc8198999a1456a2902e5d.png",
    "ig_0db2aea1bc37106f016a4caa92d80c81988fab69def76718e5.png",
    "ig_0db2aea1bc37106f016a4caaf952188198b1bbacd14f09079c.png",
    "ig_0db2aea1bc37106f016a4cab4c725c8198b3c0a3de375e1a57.png",
    "ig_0db2aea1bc37106f016a4caba1f5548198998b6438649d2d30.png",
    "ig_0db2aea1bc37106f016a4cac103e908198bcd443ab976b2d93.png",
    "ig_0808acc7b9230de7016a4cb352942c819baceda5fe2fb72de2.png",
    "ig_0808acc7b9230de7016a4cb3a97754819bba370b7360664cd9.png",
    "ig_0808acc7b9230de7016a4cb41527ec819bbea058cf4b609393.png",
    "ig_0808acc7b9230de7016a4cb47c9bcc819bbb48a22661fdf268.png",
    "ig_0808acc7b9230de7016a4cb4d6f5d8819bb06d1b3a8a52fa51.png",
    "ig_0808acc7b9230de7016a4cb52723a4819b9e2b5e070a990f3a.png",
    "ig_0808acc7b9230de7016a4cb581d658819b81de1414755da80d.png",
    "ig_0808acc7b9230de7016a4cb5d58984819bb8be018af8daad55.png",
    "ig_0dda1ef1a2760ad3016a4cb83f00308198b4427d6453e067e6.png",
    "ig_0dda1ef1a2760ad3016a4cb8a0b72c8198873ffd539d510f3d.png",
    "ig_0dda1ef1a2760ad3016a4cb9165b30819887d153b4aad6279f.png",
    "ig_0dda1ef1a2760ad3016a4cb99612fc8198a49e20c48aebf747.png",
    "ig_0dda1ef1a2760ad3016a4cba0dae7881988df59f4a4a59ba41.png",
    "ig_0dda1ef1a2760ad3016a4cba6c941881989cacf1097e3a100c.png",
    "ig_0dda1ef1a2760ad3016a4cbad16cbc8198be8d58836e8900c5.png",
    "ig_0dda1ef1a2760ad3016a4cbb3003688198a978d163062d27af.png",
]


def main() -> None:
    cols = 8
    tile = 150
    label = 24
    rows = (len(FILES) + cols - 1) // cols
    canvas = Image.new("RGB", (cols * tile, rows * (tile + label)), (24, 26, 32))
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 14)
    except OSError:
        font = ImageFont.load_default()
    for i, name in enumerate(FILES, start=1):
        img = Image.open(GEN_DIR / name).convert("RGB")
        img.thumbnail((tile - 8, tile - 8), Image.Resampling.NEAREST)
        x = ((i - 1) % cols) * tile
        y = ((i - 1) // cols) * (tile + label)
        canvas.paste(img, (x + (tile - img.width) // 2, y + 4))
        draw.text((x + 6, y + tile + 2), str(i), fill=(255, 255, 255), font=font)
    out = LOG_DIR / "raw_contact_sheet_44.png"
    canvas.save(out)
    print(out)


if __name__ == "__main__":
    main()
