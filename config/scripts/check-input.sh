#!/usr/bin/env bash
# SHADOWX // input diagnostics — run from a TTY if mouse/keyboard stops working.
SIG=$(ls /run/user/$(id -u)/hypr 2>/dev/null | head -1)
if [[ -z "$SIG" ]]; then
    echo "Hyprland is not running."
    exit 1
fi
export HYPRLAND_INSTANCE_SIGNATURE="$SIG"
echo "=== Input devices ==="
hyprctl devices
echo
echo "=== Cursor position ==="
hyprctl cursorpos
echo
echo "If 'mice' and 'Keyboards' are empty, log out and log back in"
echo "through the SHADOWX // NOIR session so the seat is active at start."
