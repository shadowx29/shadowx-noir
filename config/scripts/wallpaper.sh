#!/usr/bin/env bash
# SHADOWX // wallpaper picker
set -euo pipefail

WALLDIR="$HOME/Pictures/shadowx-wallpapers"
STATE="$HOME/.config/shadowx/wallpaper.current"
mkdir -p "$WALLDIR" "$(dirname "$STATE")"

mapfile -t WALLS < <(find "$WALLDIR" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    -printf '%f\n' | sort)

if (( ${#WALLS[@]} == 0 )); then
    dunstify -u critical "SHADOWX" "No wallpapers in $WALLDIR" 2>/dev/null || true
    exit 1
fi

CHOICE=$(printf '%s\n' "${WALLS[@]}" | rofi -dmenu \
    -p '[SHADOWX] WALLPAPER' \
    -theme "$HOME/.config/rofi/shadowx.rasi") || exit 0
[[ -n "$CHOICE" ]] || exit 0

IMG="$WALLDIR/$CHOICE"
pkill -x swaybg 2>/dev/null || true
swaybg -i "$IMG" -m fill &
printf '%s\n' "$IMG" > "$STATE"
dunstify "SHADOWX // WALLPAPER" "$CHOICE" 2>/dev/null || true
