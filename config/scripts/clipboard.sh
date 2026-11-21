#!/usr/bin/env bash
# SHADOWX // Clipboard history (SUPER+C) — cliphist + rofi
set -euo pipefail
if ! command -v cliphist >/dev/null 2>&1; then
  dunstify -u critical "SHADOWX" "cliphist not installed" 2>/dev/null || true; exit 1
fi
CHOICE=$(cliphist list | rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" \
  -p '[SHADOWX] CLIPBOARD' -l 12) || exit 0
[[ -n "$CHOICE" ]] || exit 0
printf '%s\n' "$CHOICE" | cliphist decode | wl-copy
dunstify "SHADOWX // CLIPBOARD" "Restored" 2>/dev/null || true
