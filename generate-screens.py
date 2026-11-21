#!/usr/bin/env python3
"""
SHADOWX // NOIR — UI mockup screenshots.
Generates: app-menu.png, power-menu.png, wallpaper-picker.png, lock-screen.png, terminal.png
Usage: python3 generate-screens.py
"""
from PIL import Image, ImageDraw, ImageFont
import os

W, H = 1920, 1080
RED = (204, 21, 21)
FG = (232, 232, 236)
MUTED = (122, 122, 133)
BG = (10, 10, 12)
PANEL = (14, 14, 18)
LINE = (38, 38, 46)

FDIR = "/usr/share/fonts/truetype/dejavu"
MONO = os.path.join(FDIR, "DejaVuSansMono.ttf")
BOLD = os.path.join(FDIR, "DejaVuSansMono-Bold.ttf")
HERE = os.path.dirname(os.path.abspath(__file__))
WALLDIR = os.path.join(HERE, "assets", "wallpapers")
OUTDIR = os.path.join(HERE, "assets", "screenshots")


def f(path, size):
    return ImageFont.truetype(path, size) if os.path.exists(path) else ImageFont.load_default()


F12 = f(MONO, 16)
F14 = f(MONO, 20)
F16 = f(BOLD, 22)
F18 = f(BOLD, 26)
F30 = f(BOLD, 42)
F56 = f(BOLD, 78)


def tw(d, txt, font):
    b = d.textbbox((0, 0), txt, font=font)
    return b[2] - b[0]


def background(dim=125):
    im = Image.open(os.path.join(WALLDIR, "shadowx-custom-2190504.jpg")).convert("RGBA").resize((W, H), Image.LANCZOS)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, dim))
    return Image.alpha_composite(im, layer)


def save(img, name):
    os.makedirs(OUTDIR, exist_ok=True)
    path = os.path.join(OUTDIR, name)
    img.convert("RGB").save(path, "PNG")
    print(f"Wrote {path}")


def window(d, x0, y0, w, h):
    d.rectangle([x0, y0, x0 + w, y0 + h], fill=(*BG, 255), outline=(*RED, 255), width=2)


def prompt_bar(d, x0, y0, w, label, typed):
    d.rectangle([x0 + 1, y0 + 1, x0 + w - 1, y0 + 64], fill=(18, 18, 23, 255))
    d.line([(x0, y0 + 64), (x0 + w, y0 + 64)], fill=(*LINE, 255), width=1)
    d.text((x0 + 20, y0 + 18), "[SHADOWX]", font=F16, fill=(*RED, 255))
    tx = x0 + 190
    d.text((tx, y0 + 20), typed, font=F14, fill=(*FG, 255))
    cx = tx + tw(d, typed, F14) + 3
    d.rectangle([cx, y0 + 21, cx + 3, y0 + 45], fill=(*RED, 255))
    if not typed:
        d.text((tx, y0 + 20), label, font=F14, fill=(*MUTED, 255))


def app_menu():
    base = background(120)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x0, y0, w, h = 650, 130, 620, 560
    window(d, x0, y0, w, h)
    prompt_bar(d, x0, y0, w, "search / run...", "fire")

    apps = [
        ("Firefox", "web browser"),
        ("Ghostty", "terminal emulator"),
        ("Nautilus", "file manager"),
        ("mpv", "media player"),
        ("btop", "system monitor"),
        ("GIMP", "image editor"),
        ("Code", "text editor"),
    ]
    for i, (name, desc) in enumerate(apps):
        iy = y0 + 88 + i * 62
        if i == 0:
            d.rectangle([x0 + 12, iy - 8, x0 + w - 12, iy + 46], fill=(*RED, 48))
            d.rectangle([x0 + 12, iy - 8, x0 + 16, iy + 46], fill=(*RED, 255))
        color = (*FG, 255) if i == 0 else (*MUTED, 255)
        d.text((x0 + 36, iy), name, font=F16, fill=color)
        d.text((x0 + 36 + tw(d, name, F16) + 18, iy + 4), desc, font=F12,
               fill=(*RED, 200) if i == 0 else (*MUTED, 150))
    d.text((x0 + 20, y0 + h - 34), "[SHADOWX] DRUN", font=F12, fill=(*RED, 255))
    save(Image.alpha_composite(base, layer), "app-menu.png")


def power_menu():
    base = background(130)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x0, y0, w, h = 650, 150, 620, 420
    window(d, x0, y0, w, h)
    prompt_bar(d, x0, y0, w, "search / run...", "")
    items = ["Logout", "Suspend", "Reboot", "Shutdown"]
    for i, item in enumerate(items):
        iy = y0 + 88 + i * 56
        if i == 0:
            d.rectangle([x0 + 12, iy - 6, x0 + w - 12, iy + 40], fill=(*RED, 48))
            d.rectangle([x0 + 12, iy - 6, x0 + 16, iy + 40], fill=(*RED, 255))
        d.text((x0 + 36, iy), item, font=F16,
               fill=(*FG, 255) if i == 0 else (*MUTED, 255))
    d.text((x0 + 20, y0 + h - 34), "[SHADOWX] POWER", font=F12, fill=(*RED, 255))
    save(Image.alpha_composite(base, layer), "power-menu.png")


def wallpaper_picker():
    base = background(140)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    d.text((W // 2 - tw(d, "[SHADOWX] WALLPAPER", F18) // 2, 70),
           "[SHADOWX] WALLPAPER", font=F18, fill=(*RED, 255))

    names = ["shadowx-custom-2190504.jpg"] * 4
    cw, ch, gap = 420, 236, 26
    x_start = (W - (cw * 2 + gap)) // 2
    y_start = 160
    for i, name in enumerate(names):
        col, row = i % 2, i // 2
        x = x_start + col * (cw + gap)
        y = y_start + row * (ch + 64)
        thumb = Image.open(os.path.join(WALLDIR, name)).convert("RGBA").resize((cw, ch), Image.LANCZOS)
        layer.alpha_composite(thumb, (x, y))
        d = ImageDraw.Draw(layer, "RGBA")
        d.rectangle([x, y, x + cw - 1, y + ch - 1],
                    outline=(*RED, 255) if i == 0 else (*LINE, 200), width=3 if i == 0 else 1)
        d.rectangle([x, y + ch, x + cw, y + ch + 38], fill=(*BG, 245))
        d.text((x + 12, y + ch + 8), f"0{i+1}  {name}", font=F12,
               fill=(*FG, 255) if i == 0 else (*MUTED, 255))

    # Apply panel
    py = 870
    d.rectangle([x_start, py, x_start + cw * 2 + gap, py + 86], fill=(*BG, 250),
                outline=(*RED, 255), width=2)
    d.text((x_start + 22, py + 16), "APPLY SELECTED WALLPAPER", font=F16, fill=(*FG, 255))
    bx = x_start + cw * 2 + gap - 180
    d.rectangle([bx, py + 20, bx + 156, py + 64], fill=(*RED, 255))
    d.text((bx + 34, py + 26), "[ APPLY ]", font=F14, fill=(*BG, 255))
    save(Image.alpha_composite(base, layer), "wallpaper-picker.png")


def lock_screen():
    """Picture only — no lock-screen code is shipped with the rice."""
    base = background(165)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    cx = W // 2

    d.line([(cx - 60, 150), (cx + 60, 270)], fill=(*RED, 235), width=8)
    d.line([(cx + 60, 150), (cx - 60, 270)], fill=(*RED, 235), width=8)
    d.ellipse([cx - 20, 195, cx + 20, 235], outline=(*RED, 255), width=4)

    clock = "21:47"
    d.text((cx - tw(d, clock, F56) // 2, 320), clock, font=F56, fill=(*FG, 255))
    date = "FRI 20 NOV 2026"
    d.text((cx - tw(d, date, F14) // 2, 420), date, font=F14, fill=(*MUTED, 255))

    cy = 610
    d.ellipse([cx - 62, cy - 62, cx + 62, cy + 62], outline=(*LINE, 255), width=6)
    d.arc([cx - 62, cy - 62, cx + 62, cy + 62], start=0, end=280, fill=(*RED, 255), width=6)
    d.ellipse([cx - 48, cy - 48, cx + 48, cy + 48], fill=(12, 12, 16, 245))
    dots = "••••"
    d.text((cx - tw(d, dots, F18) // 2, cy - 18), dots, font=F18, fill=(*FG, 255))
    user = "shadowx"
    d.text((cx - tw(d, user, F14) // 2, cy + 96), user, font=F14, fill=(*MUTED, 255))

    foot = "SHADOWX // NOIR  —  ENTER PASSWORD"
    d.text((cx - tw(d, foot, F12) // 2, H - 90), foot, font=F12, fill=(*RED, 255))
    save(Image.alpha_composite(base, layer), "lock-screen.png")


def terminal_screen():
    """Ghostty-style terminal picture with the SHADOWX Fastfetch banner."""
    base = background(35)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")

    # Borderless, semi-transparent Ghostty-like surface (Gruvbox charcoal).
    x0, y0, w, h = 130, 80, 1660, 920
    d.rectangle([x0, y0, x0 + w, y0 + h], fill=(29, 32, 33, 225))
    d.line([(x0, y0), (x0 + w, y0)], fill=(*RED, 160), width=2)
    d.text((x0 + 28, y0 + 20), "ghostty", font=F12, fill=(168, 153, 132, 220))

    gruv_fg = (251, 241, 199)
    gruv_dim = (168, 153, 132)
    yellow = (250, 189, 47)

    lines = [
        (RED, " ┌──────────────────────────────────────────┐"),
        (gruv_fg, " │ SHADOWX // NOIR                         │"),
        (RED, " └──────────────────────────────────────────┘"),
        (None, ""),
        (gruv_fg, "  OS        Kali GNU/Linux 2026.3"),
        (gruv_fg, "  KERNEL    7.2.15+kali-amd64"),
        (gruv_fg, "  SHELL     bash 5.2"),
        (gruv_fg, "  WM        Hyprland"),
        (gruv_fg, "  TERM      ghostty"),
        (None, ""),
        (gruv_fg, "  CPU       Intel(R) Core(TM) i5-1335U"),
        (gruv_fg, "  MEMORY    6.1 GiB / 15.3 GiB (40%)"),
        (gruv_fg, "  DISK      83 GiB / 256 GiB (32%)"),
        (gruv_fg, "  UPTIME    4h 14m"),
        (None, ""),
        (RED, " // SHADOWX — OWN YOUR DESKTOP"),
    ]
    y = y0 + 90
    for color, txt in lines:
        if txt:
            d.text((x0 + 60, y), txt, font=F16, fill=(*color, 255))
        y += 38

    d.text((x0 + 60, y + 20), "$ ", font=F16, fill=(*RED, 255))
    d.rectangle([x0 + 92, y + 24, x0 + 112, y + 46], fill=(*yellow, 255))
    save(Image.alpha_composite(base, layer), "terminal.png")


if __name__ == "__main__":
    app_menu()
    power_menu()
    wallpaper_picker()
    lock_screen()
    terminal_screen()
