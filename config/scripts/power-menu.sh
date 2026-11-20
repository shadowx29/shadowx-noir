#!/usr/bin/env bash
# SHADOWX // power menu
set -euo pipefail

OPTS="Logout\nSuspend\nReboot\nShutdown"
CHOICE=$(printf '%b' "$OPTS" | rofi -dmenu \
    -p '[SHADOWX] POWER' \
    -theme "$HOME/.config/rofi/shadowx.rasi") || exit 0

case "$CHOICE" in
    Logout)   hyprctl dispatch exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
