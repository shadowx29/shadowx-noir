#!/usr/bin/env python3
"""
SHADOWX // NOIR — original wallpaper generator.
Writes two 1920x1080 variants. No external images are used.
Usage: python3 generate-wallpaper.py
"""
from PIL import Image, ImageDraw, ImageFont
import math
import os

W, H = 1920, 1080
BG = (10, 10, 12)
RED = (204, 21, 21)
DIM = (98, 12, 12)
FG = (232, 232, 232)
MUTED = (122, 122, 133)

FONT_DIR = "/usr/share/fonts/truetype/dejavu"
BOLD = os.path.join(FONT_DIR, "DejaVuSansMono-Bold.ttf")
REG = os.path.join(FONT_DIR, "DejaVuSansMono.ttf")


def font(path, size):
    return ImageFont.truetype(path, size) if os.path.exists(path) else ImageFont.load_default()


def draw_x(d, cx, cy, size, alpha):
    """Draw an X from four angled bars with layered shadow echoes."""
    a = size
    for shift in range(7, 0, -1):
        off = shift * 7
        fade = int(alpha * (1 - shift / 9))
        for sign in (-1, 1):
            d.line([(cx - a + off, cy - a + off), (cx + a + off, cy + a + off)],
                   fill=(*DIM, fade), width=10)
            d.line([(cx + a + off, cy - a + off), (cx - a + off, cy + a + off)],
                   fill=(*DIM, fade), width=10)
    for sign in (-1, 1):
        d.line([(cx - a, cy - a), (cx + a, cy + a)], fill=(*RED, alpha), width=12)
        d.line([(cx + a, cy - a), (cx - a, cy + a)], fill=(*RED, alpha), width=12)
    d.ellipse([cx - 26, cy - 26, cx + 26, cy + 26],
              outline=(*RED, alpha), width=5)


def frame(d, variant):
    """Angular border with tick ruler on the left."""
    pad = 70
    cut = 55
    pts = [(pad + cut, pad), (W - pad - cut, pad), (W - pad, pad + cut),
           (W - pad, H - pad - cut), (W - pad - cut, H - pad),
           (pad + cut, H - pad), (pad, H - pad - cut), (pad, pad + cut)]
    d.line(pts + [pts[0]], fill=(*RED, 90), width=2)

    ruler_x = pad + 40
    for y in range(pad + 120, H - pad - 120, 34):
        long = (y - pad - 120) % 136 == 0
        d.line([(ruler_x, y), (ruler_x + (22 if long else 10), y)],
               fill=(*RED, 150 if long else 70), width=2)
    d.line([(ruler_x, pad + 120), (ruler_x, H - pad - 120)],
           fill=(*RED, 60), width=1)


def make(variant):
    img = Image.new("RGBA", (W, H), BG + (255,))
    d = ImageDraw.Draw(img, "RGBA")

    # Background: faint diagonal scan bands + technical grid.
    if variant == "grid":
        for x in range(0, W, 60):
            d.line([(x, 0), (x, H)], fill=(*RED, 13), width=1)
        for y in range(0, H, 60):
            d.line([(0, y), (W, y)], fill=(*RED, 13), width=1)
    else:
        for i in range(-H, W + H, 150):
            d.line([(i, 0), (i + H, H)], fill=(*RED, 9), width=46)

    frame(d, variant)

    if variant == "grid":
        draw_x(d, 1360, 430, 190, 220)
        d.ellipse([1360 - 300, 430 - 300, 1360 + 300, 430 + 300],
                  outline=(*RED, 55), width=2)
    else:
        draw_x(d, 1120, 470, 275, 235)
        d.ellipse([1120 - 375, 470 - 375, 1120 + 375, 470 + 375],
                  outline=(*RED, 45), width=2)

    # Scanlines
    for y in range(0, H, 5):
        d.line([(0, y), (W, y)], fill=(0, 0, 0, 22), width=1)

    title = font(BOLD, 112)
    small = font(REG, 25)
    tiny = font(REG, 19)

    if variant == "grid":
        tx, ty = 150, 790
    else:
        tx, ty = 150, 820

    d.text((tx, ty - 58), "// NOIR — KALI RICE", font=small, fill=(*RED, 235))
    d.text((tx, ty), "SHADOWX", font=title, fill=(*FG, 255))
    d.line([(tx, ty + 130), (tx + 560, ty + 130)], fill=(*RED, 255), width=4)

    tag = "SYS // 1920x1080 // INTEL"
    tb = d.textbbox((0, 0), tag, font=tiny)
    d.text((W - 120 - (tb[2] - tb[0]), 105), tag, font=tiny, fill=(*MUTED, 255))

    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                           "assets", "wallpapers")
    os.makedirs(out_dir, exist_ok=True)
    # Composite translucent layers over a solid base before saving, otherwise
    # ImageDraw's alpha values would be dropped as solid colour by convert().
    base = Image.new("RGBA", (W, H), BG + (255,))
    out = os.path.join(out_dir, f"shadowx-{variant}.png")
    Image.alpha_composite(base, img).convert("RGB").save(out, "PNG")
    print(f"Wrote {out}")


if __name__ == "__main__":
    make("void")
    make("grid")
