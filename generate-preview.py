#!/usr/bin/env python3
"""
SHADOWX // NOIR — animated preview generator.
Renders a short MP4 of the rice: wallpaper, bottom bar, terminal and menu.
Usage: python3 generate-preview.py   -> assets/preview.mp4
"""
from PIL import Image, ImageDraw, ImageFont
import os
import subprocess
import tempfile

W, H = 1920, 1080
FPS = 20
SCONDS = 4
TOTAL = FPS * SCONDS

BG = (10, 10, 12)
RED = (204, 21, 21)
FG = (232, 232, 236)
MUTED = (122, 122, 133)
PANEL = (13, 13, 16)
LINE = (38, 38, 46)

FDIR = "/usr/share/fonts/truetype/dejavu"
MONO = os.path.join(FDIR, "DejaVuSansMono.ttf")
BOLD = os.path.join(FDIR, "DejaVuSansMono-Bold.ttf")
HERE = os.path.dirname(os.path.abspath(__file__))
WALLDIR = os.path.join(HERE, "assets", "wallpapers")


def f(path, size):
    return ImageFont.truetype(path, size) if os.path.exists(path) else ImageFont.load_default()


F12 = f(MONO, 16)
F14 = f(MONO, 19)
F16 = f(BOLD, 21)
F20 = f(BOLD, 26)
F40 = f(BOLD, 52)


def text_width(d, txt, font):
    b = d.textbbox((0, 0), txt, font=font)
    return b[2] - b[0]


def zoomed_wallpaper(path, scale=1.08):
    im = Image.open(path).convert("RGBA")
    return im.resize((int(W * scale), int(H * scale)), Image.LANCZOS)


def zoom_crop(big, pan, scale=1.08):
    zw, zh = int(W * scale), int(H * scale)
    x = (zw - W) // 2 + pan
    y = (zh - H) // 2
    return big.crop((x, y, x + W, y + H))


def bar_overlay():
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    y0 = H - 34
    d.rectangle([0, y0, W, H], fill=(*PANEL, 245))
    d.line([(0, y0), (W, y0)], fill=(*RED, 150), width=1)

    # Workspaces
    for i in range(5):
        x = 10 + i * 36
        active = i == 1
        if active:
            d.rectangle([x, y0 + 4, x + 32, H - 4], fill=(*RED, 255))
        d.text((x + 10, y0 + 6), str(i + 1), font=F12,
               fill=(*BG, 255) if active else (*MUTED, 255))

    d.text((200, y0 + 7), "// kitty — ~", font=F14, fill=(*FG, 255))

    mark = "[ SHADOWX ]  // NOIR"
    mw = text_width(d, mark, F14)
    d.text(((W - mw) // 2, y0 + 7), mark, font=F14, fill=(*FG, 255))

    # Right-side readings, right-aligned from x = W-560
    right = W - 700
    readings = ["CPU 12%", "MEM 38%", "NET wifi", "VOL 80%", "BAT 76%"]
    x = right
    for r in readings:
        d.text((x, y0 + 8), r, font=F12, fill=(*FG, 255))
        x += text_width(d, r, F12) + 20

    # Clock block
    clock_w = 96
    d.rectangle([W - 160 - clock_w, y0 + 4, W - 160, H - 4], fill=(*RED, 255))
    d.text((W - 160 - clock_w + 22, y0 + 6), "21:47", font=F14, fill=(*BG, 255))
    d.text((W - 120, y0 + 4), "⏻", font=F20, fill=(*RED, 255))
    return layer


def terminal_overlay():
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x0, y0, w, h = 250, 130, 1420, 790
    d.rectangle([x0 + 14, y0 + 14, x0 + w + 14, y0 + h + 14], fill=(0, 0, 0, 150))
    d.rectangle([x0, y0, x0 + w, y0 + h], fill=(*BG, 252), outline=(*LINE, 255), width=2)
    d.rectangle([x0, y0, x0 + w, y0 + 40], fill=(16, 16, 20, 255))
    d.ellipse([x0 + 18, y0 + 15, x0 + 28, y0 + 25], fill=(*RED, 255))
    d.ellipse([x0 + 36, y0 + 15, x0 + 46, y0 + 25], fill=(90, 90, 100, 255))
    d.ellipse([x0 + 54, y0 + 15, x0 + 64, y0 + 25], fill=(90, 90, 100, 255))
    d.text((x0 + 90, y0 + 10), "kitty — SHADOWX // NOIR", font=F12, fill=(*MUTED, 255))

    lines = [
        (RED, " ┌──────────────────────────────────────────┐"),
        (FG,  " │ SHADOWX // NOIR                         │"),
        (RED, " └──────────────────────────────────────────┘"),
        (MUTED, ""),
        (FG,  "  OS        Kali GNU/Linux 2026.x"),
        (FG,  "  KERNEL    6.12-x-amd64"),
        (FG,  "  SHELL     bash 5.2"),
        (FG,  "  WM        Hyprland"),
        (FG,  "  TERM      kitty"),
        (MUTED, ""),
        (FG,  "  CPU       Intel(R) Core(TM) i5 — Iris Xe"),
        (FG,  "  MEMORY    4.2 GiB / 15.6 GiB (27%)"),
        (FG,  "  DISK      38 GiB / 256 GiB (15%)"),
        (FG,  "  UPTIME    2h 14m"),
        (MUTED, ""),
        (RED, " // SHADOWX — OWN YOUR DESKTOP"),
        (MUTED, ""),
    ]
    y = y0 + 76
    for color, txt in lines:
        d.text((x0 + 60, y), txt, font=F16, fill=(*color, 255) if txt else (0, 0, 0, 0))
        y += 34
    d.text((x0 + 60, y + 10), "$ ", font=F16, fill=(*RED, 255))
    d.rectangle([x0 + 90, y + 12, x0 + 108, y + 32], fill=(*RED, 255))
    return layer


def menu_overlay():
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    d.rectangle([0, 0, W, H], fill=(0, 0, 0, 125))
    x0, y0, w, h = (W - 620) // 2, 140, 620, 430
    d.rectangle([x0, y0, x0 + w, y0 + h], fill=(*BG, 255), outline=(*RED, 255), width=2)
    d.rectangle([x0 + 1, y0 + 1, x0 + w - 1, y0 + 64], fill=(16, 16, 20, 255))
    d.text((x0 + 20, y0 + 19), "[SHADOWX]", font=F16, fill=(*RED, 255))
    d.text((x0 + 180, y0 + 21), "search / run...", font=F14, fill=(*MUTED, 255))
    d.rectangle([x0 + 180, y0 + 22, x0 + 184, y0 + 44], fill=(*RED, 255))
    items = ["Lock", "Logout", "Suspend", "Reboot", "Shutdown"]
    for i, item in enumerate(items):
        iy = y0 + 86 + i * 56
        if i == 0:
            d.rectangle([x0 + 12, iy - 6, x0 + w - 12, iy + 40], fill=(*RED, 45))
            d.rectangle([x0 + 12, iy - 6, x0 + 15, iy + 40], fill=(*RED, 255))
        d.text((x0 + 34, iy), item, font=F16,
               fill=(*FG, 255) if i == 0 else (*MUTED, 255))
    d.text((x0 + 20, y0 + h - 34), "[SHADOWX] POWER", font=F12, fill=(*RED, 255))
    return layer


def fade(base, overlay, t, fade_in=0.5, fade_out=0.4):
    """Composite overlay with fade ramp, then fade whole frame to/from black."""
    img = Image.alpha_composite(base, overlay)
    a = 255
    if t < fade_in:
        a = int(255 * t / fade_in)
    elif t > SCONDS - fade_out:
        a = int(255 * (SCONDS - t) / fade_out)
    if a < 255:
        black = Image.new("RGBA", (W, H), (0, 0, 0, 255 - a))
        img = Image.alpha_composite(img, black)
    return img.convert("RGB")


def main():
    scenes = [
        ("void", bar_overlay()),
        ("void", terminal_overlay()),
        ("void", menu_overlay()),
        ("grid", bar_overlay()),
    ]
    with tempfile.TemporaryDirectory(prefix="shadowx-frames-") as tmp:
        n = 0
        for idx, (wall, overlay) in enumerate(scenes):
            path = os.path.join(WALLDIR, f"shadowx-{wall}.png")
            big = zoomed_wallpaper(path)
            for frame in range(TOTAL):
                t = frame / FPS
                pan = int(18 * (frame / TOTAL) - 9)
                base = zoom_crop(big, pan)
                out = fade(base, overlay, t)
                out.save(os.path.join(tmp, f"frame_{n:05d}.png"))
                n += 1
        outpath = os.path.join(HERE, "assets", "preview.mp4")
        subprocess.run([
            "ffmpeg", "-y", "-loglevel", "error",
            "-framerate", str(FPS),
            "-i", os.path.join(tmp, "frame_%05d.png"),
            "-c:v", "libx264", "-preset", "veryfast", "-crf", "23",
            "-pix_fmt", "yuv420p", "-movflags", "+faststart", outpath,
        ], check=True)
        print(f"Wrote {outpath} ({os.path.getsize(outpath) // 1024} KB)")


if __name__ == "__main__":
    main()
