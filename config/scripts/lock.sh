#!/usr/bin/env bash
# SHADOWX // lock screen
set -euo pipefail

STATE="$HOME/.config/shadowx/wallpaper.current"
WALL="$HOME/Pictures/shadowx-wallpapers/shadowx-void.png"
[[ -f "$STATE" ]] && CURRENT=$(cat "$STATE") && [[ -f "$CURRENT" ]] && WALL="$CURRENT"

exec swaylock -f -i "$WALL"
