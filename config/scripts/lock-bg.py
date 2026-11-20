#!/usr/bin/env python3
"""Draw the SHADOWX login page background (clock, date, user) behind swaylock."""
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os

W, H = 1920, 1080
RED = (204, 21, 21)
FG = (232, 232, 236)
MUTED = (122, 122, 133)
USER = "shadowx"

FDIR = "/usr/share/fonts/truetype/dejavu"
MONO = os.path.join(FDIR, "DejaVuSansMono.ttf")
BOLD = os.path.join(FDIR, "DejaVuSansMono-Bold.ttf")
STATE = os.path.expanduser("~/.config/shadowx/wallpaper.current")
OUT = os.path.expanduser("~/.config/shadowx/lock-bg.png")
WALLDIR = os.path.expanduser("~/Pictures/shadowx-wallpapers")


def font(path, size):
    return ImageFont.truetype(path, size) if os.path.exists(path) else ImageFont.load_default()


def width(d, txt, fnt):
    b = d.textbbox((0, 0), txt, font=fnt)
    return b[2] - b[0]


def main():
    wall = os.path.join(WALLDIR, "shadowx-void.png")
    if os.path.isfile(STATE):
        with open(STATE) as fh:
            saved = fh.read().strip()
        if os.path.isfile(saved):
            wall = saved
    if not os.path.isfile(wall):
        return

    img = Image.open(wall).convert("RGBA").resize((W, H), Image.LANCZOS)
    img = Image.alpha_composite(img, Image.new("RGBA", (W, H), (0, 0, 0, 165)))
    d = ImageDraw.Draw(img, "RGBA")
    cx = W // 2

    # X mark
    d.line([(cx - 60, 150), (cx + 60, 270)], fill=(*RED, 235), width=8)
    d.line([(cx + 60, 150), (cx - 60, 270)], fill=(*RED, 235), width=8)
    d.ellipse([cx - 20, 195, cx + 20, 235], outline=(*RED, 255), width=4)

    # Live clock + date
    now = datetime.now()
    clock = now.strftime("%H:%M")
    date = now.strftime("%a %d %b %Y").upper()
    big = font(BOLD, 78)
    small = font(MONO, 20)
    d.text((cx - width(d, clock, big) // 2, 320), clock, font=big, fill=(*FG, 255))
    d.text((cx - width(d, date, small) // 2, 420), date, font=small, fill=(*MUTED, 255))

    # Username under the password ring (ring sits at 960x610 via swaylock config)
    d.text((cx - width(d, USER, small) // 2, 706), USER, font=small, fill=(*MUTED, 255))

    foot = "SHADOWX // NOIR  —  ENTER PASSWORD"
    tiny = font(MONO, 16)
    d.text((cx - width(d, foot, tiny) // 2, H - 90), foot, font=tiny, fill=(*RED, 255))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    img.convert("RGB").save(OUT, "PNG")


if __name__ == "__main__":
    main()
