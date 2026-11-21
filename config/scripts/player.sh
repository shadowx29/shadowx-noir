#!/usr/bin/env bash
# SHADOWX // Player (SUPER+SHIFT+Return) — playerctl + rofi
set -euo pipefail
command -v playerctl >/dev/null 2>&1 || { dunstify -u critical "SHADOWX" "playerctl missing"; exit 1; }
TITLE=$(playerctl metadata title 2>/dev/null || echo "no media")
ARTIST=$(playerctl metadata artist 2>/dev/null || echo "")
C=$(printf 'Play/Pause\nNext\nPrevious\nStop\nOpen mpv\nClose' | env -u WAYLAND_DISPLAY rofi -dmenu \
  -theme "$HOME/.config/rofi/shadowx.rasi" -p "[SHADOWX] $TITLE") || exit 0
case "$C" in
  Play/Pause) playerctl play-pause ;;
  Next) playerctl next ;;
  Previous) playerctl previous ;;
  Stop) playerctl stop ;;
  Open\ mpv) ghostty --gtk-single-instance=true -e mpv &
  ;;
esac
