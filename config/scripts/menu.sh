#!/usr/bin/env bash
# SHADOWX // NOIR — main menu (rofi)
set -euo pipefail
S="$HOME/.config/scripts"
CHOICE=$(printf '%b' 'All Applications\nFile Manager\nTerminal\nWeb Browser\nWallpaper\nNotes\nClipboard\nControl Center\nPower Menu\nClose' \
  | env -u WAYLAND_DISPLAY rofi -dmenu \
      -theme "$HOME/.config/rofi/shadowx.rasi" \
      -p '[SHADOWX] MENU') || exit 0

case "$CHOICE" in
  'All Applications') exec env -u WAYLAND_DISPLAY rofi -show drun -theme "$HOME/.config/rofi/shadowx.rasi" ;;
  'File Manager')    exec nautilus ;;
  'Terminal')        exec ghostty --gtk-single-instance=true ;;
  'Web Browser')     exec firefox ;;
  'Wallpaper')       exec "$S/wallpaper.sh" ;;
  'Notes')           exec "$S/notes.sh" ;;
  'Clipboard')       exec "$S/clipboard.sh" ;;
  'Control Center')  exec "$S/control-center.sh" ;;
  'Power Menu')      exec "$S/power-menu.sh" ;;
  'Close')           exit 0 ;;
esac
