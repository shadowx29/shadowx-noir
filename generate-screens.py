#!/usr/bin/env python3
"""
SHADOWX // NOIR — mockup screenshots of the rice.
Writes assets/screenshots/*.png (1920x1080). No external images used.
Usage: python3 generate-screens.py
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

W, H = 1920, 1080
RED, FG, MUTE = (204, 21, 21), (232, 232, 236), (122, 122, 133)
BG, PANEL, LINE = (10, 10, 12), (16, 16, 20), (38, 38, 46)
GRUV_BG, GRUV_FG, YELLOW = (29, 32, 33), (251, 241, 199), (250, 189, 47)

ROOT = Path(__file__).resolve().parent
WALL = ROOT / "assets/wallpapers/shadowx.jpg"
OUT = ROOT / "assets/screenshots"
FD = "/usr/share/fonts/truetype/dejavu"
MONO = f"{FD}/DejaVuSansMono.ttf"
BOLD = f"{FD}/DejaVuSansMono-Bold.ttf"


def font(path, size):
    return ImageFont.truetype(path, size) if Path(path).exists() else ImageFont.load_default()


F12, F14, F16, F18, F20, F26, F56 = (font(MONO, 16), font(MONO, 20), font(BOLD, 22),
                                      font(BOLD, 26), font(BOLD, 26), font(BOLD, 34), font(BOLD, 78))


def width(d, txt, f):
    b = d.textbbox((0, 0), txt, font=f)
    return b[2] - b[0]


def bg(dim=120):
    img = Image.open(WALL).convert("RGBA").resize((W, H), Image.LANCZOS)
    return Image.alpha_composite(img, Image.new("RGBA", (W, H), (0, 0, 0, dim)))


def save(img, name):
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    img.convert("RGB").save(path, "PNG")
    print("Wrote", path)


def frame(d, x, y, w, h, title):
    d.rectangle([x, y, x + w, y + h], fill=(*BG, 252), outline=(*RED, 255), width=2)
    d.rectangle([x + 1, y + 1, x + w - 1, y + 56], fill=(*PANEL, 255))
    d.line([(x, y + 56), (x + w, y + 56)], fill=(*LINE, 255), width=1)
    d.text((x + 20, y + 17), title, font=F16, fill=(*RED, 255))


def rows(d, x, y, items, selected=0, step=54):
    for i, item in enumerate(items):
        iy = y + i * step
        if i == selected:
            d.rectangle([x + 12, iy - 6, x + 600, iy + 40], fill=(*RED, 45))
            d.rectangle([x + 12, iy - 6, x + 16, iy + 40], fill=(*RED, 255))
        d.text((x + 34, iy), item, font=F16,
               fill=(*FG, 255) if i == selected else (*MUTE, 255))


def terminal():
    base = bg(40)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x, y, w, h = 150, 90, 1620, 900
    d.rectangle([x + 12, y + 12, x + w + 12, y + h + 12], fill=(0, 0, 0, 120))
    d.rectangle([x, y, x + w, y + h], fill=(*GRUV_BG, 235))
    d.line([(x, y), (x + w, y)], fill=(*RED, 200), width=2)
    d.text((x + 26, y + 18), "ghostty", font=F14, fill=(168, 153, 132, 220))
    lines = [
        (RED, "  ┌────────────────────────────────────┐"),
        (FG,  "  │ SHADOWX // NOIR                    │"),
        (RED, "  └────────────────────────────────────┘"),
        (None, ""),
        (GRUV_FG, "  OS        Kali GNU/Linux 2026.3"),
        (GRUV_FG, "  KERNEL    7.2.15+kali-amd64"),
        (GRUV_FG, "  SHELL     bash 5.2"),
        (GRUV_FG, "  WM        Hyprland"),
        (GRUV_FG, "  TERM      ghostty"),
        (None, ""),
        (GRUV_FG, "  CPU       Intel(R) Core(TM) i5-1335U"),
        (GRUV_FG, "  MEMORY    6.1 GiB / 15.3 GiB (40%)"),
        (GRUV_FG, "  DISK      83 GiB / 256 GiB (32%)"),
        (GRUV_FG, "  UPTIME    4h 14m"),
        (None, ""),
        (RED, "  // OWN YOUR DESKTOP"),
    ]
    yy = y + 84
    for color, txt in lines:
        if txt:
            d.text((x + 70, yy), txt, font=F16, fill=(*color, 255))
        yy += 38
    d.text((x + 70, yy + 16), "$ ", font=F16, fill=(*RED, 255))
    d.rectangle([x + 102, yy + 20, x + 122, yy + 44], fill=(*YELLOW, 255))
    save(Image.alpha_composite(base, layer), "terminal.png")


def menu():
    base = bg(125)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x, y, w, h = 640, 130, 640, 560
    frame(d, x, y, w, h, "[SHADOWX]")
    d.text((x + 210, y + 18), "type to search...", font=F14, fill=(*MUTE, 255))
    d.rectangle([x + 200, y + 20, x + 204, y + 46], fill=(*RED, 255))
    items = ["Firefox", "Ghostty", "Nautilus", "mpv", "btop", "Code", "GIMP"]
    for i, item in enumerate(items):
        iy = y + 88 + i * 60
        if i == 1:
            d.rectangle([x + 12, iy - 8, x + w - 12, iy + 44], fill=(*RED, 45))
            d.rectangle([x + 12, iy - 8, x + 16, iy + 44], fill=(*RED, 255))
        d.text((x + 36, iy), item, font=F16,
               fill=(*FG, 255) if i == 1 else (*MUTE, 255))
    d.text((x + 20, y + h - 32), "[SHADOWX] DRUN", font=F12, fill=(*RED, 255))
    save(Image.alpha_composite(base, layer), "app-menu.png")


def control_center():
    base = bg(135)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x, y, w, h = 640, 120, 640, 470
    frame(d, x, y, w, h, "[SHADOWX] CONTROL")
    d.text((x + 24, y + 18), "", font=F14, fill=(*MUTE, 255))
    rows(d, x, y + 86, ["Wi-Fi  [connected]", "Bluetooth  [on]", "Volume  [80%]",
                        "Brightness  [70%]", "Notifications", "Quickshare", "Power", "Close"])
    save(Image.alpha_composite(base, layer), "control-center.png")


def wallpaper_picker():
    base = bg(140)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    d.text((730, 80), "[SHADOWX] WALLPAPER", font=F18, fill=(*RED, 255))
    x, y, cw, ch = 700, 170, 520, 293
    im = Image.open(WALL).convert("RGBA").resize((cw, ch), Image.LANCZOS)
    layer.alpha_composite(im, (x, y))
    d = ImageDraw.Draw(layer, "RGBA")
    d.rectangle([x, y, x + cw - 1, y + ch - 1], outline=(*RED, 255), width=3)
    d.rectangle([x, y + ch, x + cw, y + ch + 40], fill=(*BG, 245))
    d.text((x + 12, y + ch + 8), "01  shadowx.jpg", font=F14, fill=(*FG, 255))
    d.rectangle([x, 870, x + cw, 956], fill=(*BG, 250), outline=(*RED, 255), width=2)
    d.text((x + 22, 890), "APPLY WALLPAPER", font=F16, fill=(*FG, 255))
    d.rectangle([x + cw - 170, 888, x + cw - 20, 934], fill=(*RED, 255))
    d.text((x + cw - 148, 896), "[ APPLY ]", font=F14, fill=(*BG, 255))
    save(Image.alpha_composite(base, layer), "wallpaper-picker.png")


def notes():
    base = bg(140)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x, y, w, h = 1150, 120, 620, 520
    frame(d, x, y, w, h, "[SHADOWX] NOTES")
    rows(d, x, y + 86, ["+ NEW NOTE", "01// ideas", "02// todo", "03// codes"], selected=1)
    save(Image.alpha_composite(base, layer), "notes.png")


def player():
    base = bg(140)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x, y, w, h = 660, 250, 600, 380
    frame(d, x, y, w, h, "[SHADOWX] PLAYER")
    d.text((x + 30, y + 90), "Now playing", font=F14, fill=(*MUTE, 255))
    d.text((x + 30, y + 130), "MIDNIGHT CITY // OST", font=F20, fill=(*FG, 255))
    d.rectangle([x + 30, y + 190, x + w - 30, y + 194], fill=(*RED, 255))
    d.ellipse([x + 30, y + 184, x + 46, y + 200], fill=(*RED, 255))
    rows(d, x, y + 230, ["Play/Pause", "Next", "Previous", "Open mpv", "Close"])
    save(Image.alpha_composite(base, layer), "player.png")



def logout():
    base = bg(150)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    x, y, w, h = 660, 230, 600, 470
    d.rectangle([x, y, x + w, y + h], fill=(*BG, 252), outline=(*RED, 255), width=2)
    d.rectangle([x + 1, y + 1, x + w - 1, y + 58], fill=(*PANEL, 255))
    d.text((x + 22, y + 17), "[SHADOWX] POWER", font=F16, fill=(*RED, 255))
    d.text((x + 22, y + 80), "SESSION ACTIONS", font=F12, fill=(*MUTE, 255))
    items = ["Logout", "Suspend", "Reboot", "Shutdown", "Cancel"]
    for i, item in enumerate(items):
        iy = y + 120 + i * 56
        if i == 0:
            d.rectangle([x + 14, iy - 6, x + w - 14, iy + 40], fill=(*RED, 48))
            d.rectangle([x + 14, iy - 6, x + 18, iy + 40], fill=(*RED, 255))
        d.text((x + 38, iy), item, font=F16,
               fill=(*FG, 255) if i == 0 else (*MUTE, 255))
    d.line([(x + 20, y + h - 46), (x + w - 20, y + h - 46)], fill=(*LINE, 255), width=1)
    d.text((x + 22, y + h - 34), "Ctrl+Alt+Delete  —  POWER MENU", font=F12, fill=(*RED, 255))
    save(Image.alpha_composite(base, layer), "logout-screen.png")


if __name__ == "__main__":
    terminal()
    menu()
    control_center()
    wallpaper_picker()
    notes()
    player()
    logout()
