#!/usr/bin/env bash
# SHADOWX // area screenshot to file + clipboard
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/shadowx-$(date +%Y%m%d-%H%M%S).png"

GEOM=$(slurp) || exit 0
[[ -n "$GEOM" ]] || exit 0

grim -g "$GEOM" "$FILE"
wl-copy < "$FILE"
dunstify "SHADOWX // SHOT" "$FILE" 2>/dev/null || true
