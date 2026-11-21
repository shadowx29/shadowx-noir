#!/usr/bin/env bash
# SHADOWX // apply the single wallpaper
set -euo pipefail

WALLDIR="$HOME/Pictures/shadowx-wallpapers"
STATE="$HOME/.config/shadowx/wallpaper.current"
IMG="$WALLDIR/shadowx-custom-2190504.jpg"

mkdir -p "$WALLDIR" "$(dirname "$STATE")"
if [[ ! -f "$IMG" ]]; then
    dunstify -u critical "SHADOWX" "Wallpaper missing: $IMG" 2>/dev/null || true
    exit 1
fi

pkill -x swaybg 2>/dev/null || true
swaybg -i "$IMG" -m fill &
printf '%s\n' "$IMG" > "$STATE"
dunstify "SHADOWX // WALLPAPER" "Applied" 2>/dev/null || true
