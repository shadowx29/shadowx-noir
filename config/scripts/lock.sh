#!/usr/bin/env bash
# SHADOWX // lock screen — clock, date, username + red password ring
set -euo pipefail
WALLDIR="$HOME/Pictures/shadowx-wallpapers"
STATE="$HOME/.config/shadowx/wallpaper.current"
LOCKBG="$HOME/.config/shadowx/lock-bg.png"
WALL="$WALLDIR/shadowx-custom.jpg"
[[ -f "$STATE" ]] && C=$(cat "$STATE") && [[ -f "$C" ]] && WALL="$C"
if python3 -c 'import PIL' >/dev/null 2>&1; then
  python3 "$HOME/.config/scripts/lock-bg.py" && WALL="$LOCKBG"
fi
exec swaylock -f -i "$WALL"
