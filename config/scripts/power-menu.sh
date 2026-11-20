#!/usr/bin/env bash
# SHADOWX // power menu
set -euo pipefail

OPTS="Lock\nLogout\nSuspend\nReboot\nShutdown"
CHOICE=$(printf '%b' "$OPTS" | rofi -dmenu \
    -p '[SHADOWX] POWER' \
    -theme "$HOME/.config/rofi/shadowx.rasi") || exit 0

case "$CHOICE" in
    Lock)     "$HOME/.config/scripts/lock.sh" ;;
    Logout)   hyprctl dispatch exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
