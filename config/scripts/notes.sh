#!/usr/bin/env bash
# SHADOWX // Quick Notes (SUPER+N) — autosaving rofi drawer
set -euo pipefail
DIR="$HOME/.local/share/shadowx/notes"
mkdir -p "$DIR"
mapfile -t NOTES < <(find "$DIR" -maxdepth 1 -name '*.txt' -printf '%f\n' | sort)

CHOICE=$( { printf '+ NEW NOTE\n'; printf '%s\n' "${NOTES[@]}" 2>/dev/null; } \
  | rofi -dmenu -theme "$HOME/.config/rofi/sidonia.rasi" -p '[SHADOWX] NOTES') || exit 0
[[ -n "$CHOICE" ]] || exit 0

if [[ "$CHOICE" == "+ NEW NOTE" ]]; then
  TITLE=$(rofi -dmenu -theme "$HOME/.config/rofi/sidonia.rasi" -p 'TITLE') || exit 0
  [[ -n "$TITLE" ]] || exit 0
  FILE="$DIR/$(echo "$TITLE" | tr ' /' '__').txt"
  printf '# %s\n\n' "$TITLE" > "$FILE"
else
  FILE="$DIR/$CHOICE"
fi

# Edit body in Ghostty's editor via a temporary file + rofi line entry.
BODY=$(cat "$FILE")
NEW=$(printf '%s\n' "$BODY" | rofi -dmenu -theme "$HOME/.config/rofi/sidonia.rasi" \
  -p '[SHADOWX] EDIT' -l 12) || exit 0
[[ -n "$NEW" ]] && printf '%s\n' "$NEW" > "$FILE"
dunstify "SHADOWX // NOTES" "Saved: $(basename "$FILE")" 2>/dev/null || true
