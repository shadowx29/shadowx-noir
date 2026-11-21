#!/usr/bin/env bash
set -euo pipefail
OPTS="Lock\nLogout\nSuspend\nReboot\nShutdown"
C=$(printf '%b' "$OPTS" | rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" -p '[SHADOWX] POWER') || exit 0
case "$C" in
  Lock) "$HOME/.config/scripts/lock.sh" ;;
  Logout) hyprctl dispatch exit ;;
  Suspend) systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
