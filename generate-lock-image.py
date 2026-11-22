#!/usr/bin/env python3
"""Generate an i3lock-style preview image from the bundled background."""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

ROOT = Path(__file__).resolve().parent
BG = ROOT / "assets/i3lock/background.png"
OUT = ROOT / "assets/screenshots/i3-lock-screen.png"

W, H = 1920, 1080
FD = "/usr/share/fonts/truetype/dejavu"
BOLD = f"{FD}/DejaVuSansMono-Bold.ttf"


def font(size):
    return ImageFont.truetype(BOLD, size) if Path(BOLD).exists() else ImageFont.load_default()


def width(d, txt, f):
    b = d.textbbox((0, 0), txt, font=f)
    return b[2] - b[0]


def main():
    img = Image.open(BG).convert("RGBA").resize((W, H), Image.LANCZOS)
    # i3lock darkens the screen with the configured color (000000).
    img = Image.alpha_composite(img, Image.new("RGBA", (W, H), (0, 0, 0, 150)))
    d = ImageDraw.Draw(img, "RGBA")

    clock = "21:47"
    f_clock = font(200)
    d.text(((W - width(d, clock, f_clock)) // 2, 250), clock,
           font=f_clock, fill=(255, 255, 255, 255))

    date = "FRI 20 NOV 2026"
    f_date = font(46)
    d.text(((W - width(d, date, f_date)) // 2, 490), date,
           font=f_date, fill=(220, 220, 220, 220))

    status = "Operation:Locked"
    f_status = font(86)
    d.text(((W - width(d, status, f_status)) // 2, 620), status,
           font=f_status, fill=(255, 255, 255, 235))

    # Password indicator ring — bottom-right, matching the config.
    cx, cy, r = W - 150, H - 150, 40
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 230), width=5)
    d.arc([cx - r, cy - r, cx + r, cy + r], start=-60, end=120,
          fill=(0, 229, 255, 255), width=6)
    d.ellipse([cx - 10, cy - 10, cx + 10, cy + 10], fill=(255, 255, 255, 220))

    corner = "Kali Linux"
    f_corner = font(30)
    d.text((50, H - 70), corner, font=f_corner, fill=(230, 230, 230, 200))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(OUT, "PNG")
    print("Wrote", OUT)


if __name__ == "__main__":
    main()
