#!/usr/bin/env bash
# SHADOWX // screenshots: --region | --window | --full
set -euo pipefail
MODE="${1:---region}"
DIR="$HOME/Pictures/Screenshots"; mkdir -p "$DIR"
FILE="$DIR/shadowx-$(date +%Y%m%d-%H%M%S).png"

case "$MODE" in
  --full)   grim "$FILE" ;;
  --window) GEOM=$(slurp) || exit 0; grim -g "$GEOM" "$FILE" ;;
  *)        GEOM=$(slurp) || exit 0; grim -g "$GEOM" "$FILE" ;;
esac
wl-copy < "$FILE" 2>/dev/null || true
dunstify "SHADOWX // SHOT" "$FILE" 2>/dev/null || true
