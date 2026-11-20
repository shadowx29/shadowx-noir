#!/usr/bin/env bash
# SHADOWX // login screen — clock, date, username + red password ring
set -euo pipefail

WALLDIR="$HOME/Pictures/shadowx-wallpapers"
STATE="$HOME/.config/shadowx/wallpaper.current"
LOCKBG="$HOME/.config/shadowx/lock-bg.png"
FALLBACK="$WALLDIR/shadowx-void.png"

WALL="$FALLBACK"
[[ -f "$STATE" ]] && CURRENT=$(cat "$STATE") && [[ -f "$CURRENT" ]] && WALL="$CURRENT"

# Rebuild the login page with the current time and username.
if python3 -c 'import PIL' >/dev/null 2>&1; then
    python3 "$HOME/.config/scripts/lock-bg.py" && WALL="$LOCKBG"
fi

exec swaylock -f -i "$WALL"
