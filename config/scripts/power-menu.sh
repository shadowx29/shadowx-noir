#!/usr/bin/env bash
set -euo pipefail
OPTS="Logout\nSuspend\nReboot\nShutdown\nCancel"
C=$(printf '%b' "$OPTS" | env -u WAYLAND_DISPLAY rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" -p '[SHADOWX] POWER') || exit 0
case "$C" in
  Logout) hyprctl dispatch exit ;;
  Suspend) systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
  Cancel) exit 0 ;;
esac
