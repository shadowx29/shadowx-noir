#!/usr/bin/env python3
"""Draw the SHADOWX login page (X mark, live clock, date, username)."""
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os

W, H = 1920, 1080
RED, FG, MUTED = (204, 21, 21), (232, 232, 236), (122, 122, 133)
USER = "shadowx"
FD = "/usr/share/fonts/truetype/dejavu"
MONO = os.path.join(FD, "DejaVuSansMono.ttf")
BOLD = os.path.join(FD, "DejaVuSansMono-Bold.ttf")
STATE = os.path.expanduser("~/.config/shadowx/wallpaper.current")
OUT = os.path.expanduser("~/.config/shadowx/lock-bg.png")
WALLDIR = os.path.expanduser("~/Pictures/shadowx-wallpapers")

def fnt(path, size):
    return ImageFont.truetype(path, size) if os.path.exists(path) else ImageFont.load_default()

def w(d, txt, f):
    b = d.textbbox((0, 0), txt, font=f); return b[2] - b[0]

def main():
    wall = os.path.join(WALLDIR, "shadowx-custom.jpg")
    if os.path.isfile(STATE):
        saved = open(STATE).read().strip()
        if os.path.isfile(saved): wall = saved
    if not os.path.isfile(wall): return
    img = Image.open(wall).convert("RGBA").resize((W, H), Image.LANCZOS)
    img = Image.alpha_composite(img, Image.new("RGBA", (W, H), (0, 0, 0, 165)))
    d = ImageDraw.Draw(img, "RGBA")
    cx = W // 2
    d.line([(cx-60,150),(cx+60,270)], fill=(*RED,235), width=8)
    d.line([(cx+60,150),(cx-60,270)], fill=(*RED,235), width=8)
    d.ellipse([cx-20,195,cx+20,235], outline=(*RED,255), width=4)
    now = datetime.now()
    clock, date = now.strftime("%H:%M"), now.strftime("%a %d %b %Y").upper()
    big, small = fnt(BOLD,78), fnt(MONO,20)
    d.text((cx-w(d,clock,big)//2,320), clock, font=big, fill=(*FG,255))
    d.text((cx-w(d,date,small)//2,420), date, font=small, fill=(*MUTED,255))
    d.text((cx-w(d,USER,small)//2,706), USER, font=small, fill=(*MUTED,255))
    foot = "SHADOWX // NOIR  —  ENTER PASSWORD"
    d.text((cx-w(d,foot,fnt(MONO,16))//2,H-90), foot, font=fnt(MONO,16), fill=(*RED,255))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    img.convert("RGB").save(OUT, "PNG")

if __name__ == "__main__": main()
