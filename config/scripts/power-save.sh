#!/usr/bin/env bash
# SHADOWX // NOIR — battery saver (no root needed)
set -uo pipefail

# System power profile: power-saver
busctl set-property org.freedesktop.UPower.PowerProfiles \
  /org/freedesktop/UPower/PowerProfiles \
  org.freedesktop.UPower.PowerProfiles ActiveProfile s power-saver >/dev/null 2>&1 || true

# Lower screen brightness a little (only if backlight is available)
brightnessctl set 35% >/dev/null 2>&1 || true

# Screen blank after 5 minutes (Hyprland DPMS)
pkill -x swayidle 2>/dev/null || true
nohup swayidle -w timeout 300 'hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' >/dev/null 2>&1 &

echo "Power saver active: profile=$(busctl get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles ActiveProfile 2>/dev/null)"
