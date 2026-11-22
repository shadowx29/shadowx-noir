#!/usr/bin/env bash
# SHADOWX // NOIR — your custom i3lock screen
set -uo pipefail
DIR="$HOME/lockscreen"
export LD_LIBRARY_PATH="$DIR/pkg/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

COLOR="$(tr -d '[:space:]#' < "$DIR/color" 2>/dev/null || true)"
COLOR="${COLOR:-000000}"

IMAGE=""
if [[ -f "$DIR/background.png" ]]; then IMAGE="$DIR/background.png"; fi

if [[ ! -f /etc/pam.d/i3lock ]]; then
  echo "i3lock: PAM service missing — run the rice installer once" >&2
  exit 1
fi

for p in $(pgrep -x i3lock 2>/dev/null); do
  [[ "$(awk '{print $3}' "/proc/$p/stat" 2>/dev/null)" == Z ]] || exit 0
done

exec "$DIR/pkg/usr/bin/i3lock" --color="$COLOR" --show-failed-attempts \
  ${IMAGE:+--image="$IMAGE"} "$@"
