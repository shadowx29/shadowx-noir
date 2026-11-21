#!/usr/bin/env bash
SIG=$(ls /run/user/$(id -u)/hypr 2>/dev/null | head -1)
[[ -n "$SIG" ]] || { echo "Hyprland is not running"; exit 1; }
export HYPRLAND_INSTANCE_SIGNATURE="$SIG"
echo "=== Devices ==="; hyprctl devices
echo "=== Cursor ==="; hyprctl cursorpos
