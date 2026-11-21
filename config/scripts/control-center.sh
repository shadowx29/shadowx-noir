#!/usr/bin/env bash
# SHADOWX // Control Center (rofi) — Wi-Fi, Bluetooth, audio, brightness,
# notifications, quickshare and power.
set -euo pipefail
ROFI="rofi -dmenu -theme $HOME/.config/rofi/shadowx.rasi -p [SHADOWX]-CONTROL"

wifi_status() {
  if command -v nmcli >/dev/null 2>&1; then
    nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}'
  fi
}
bt_status() {
  if command -v bluetoothctl >/dev/null 2>&1; then
    bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}'
  fi
}

main_menu() {
  local W BT VOL BL
  W=$(wifi_status); W=${W:-offline}
  BT=$(bt_status); BT=${BT:-off}
  VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | head -1); VOL=${VOL:-?}
  BL=$(brightnessctl get 2>/dev/null || echo 0)
  local items="Wi-Fi  [$W]\nBluetooth  [$BT]\nVolume  [$VOL]\nBrightness  [$BL]\nNotifications\nQuickshare\nPower\nClose"
  printf '%b' "$items" | rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" -p '[SHADOWX] CONTROL'
}

case "$(main_menu)" in
  Wi-Fi*)
    if command -v nmcli >/dev/null 2>&1; then
      CHOICE=$(nmcli -t -f SSID dev wifi list 2>/dev/null | sort -u | grep -v '^$' | rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" -p '[SHADOWX] WIFI') || exit 0
      [[ -n "$CHOICE" ]] && nmcli dev wifi connect "$CHOICE" 2>/dev/null && dunstify "SHADOWX // WIFI" "Connected: $CHOICE"
    fi ;;
  Bluetooth*)
    if command -v bluetoothctl >/dev/null 2>&1; then
      S=$(bluetoothctl show | awk '/Powered:/{print $2}')
      [[ "$S" == "yes" ]] && bluetoothctl power off || bluetoothctl power on
      dunstify "SHADOWX // BLUETOOTH" "Toggled"
    fi ;;
  Volume*)
    V=$(printf '10%%\n25%%\n50%%\n75%%\n100%%\nMute\nUnmute' | rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" -p '[SHADOWX] VOLUME') || exit 0
    case "$V" in
      Mute) pactl set-sink-mute @DEFAULT_SINK@ 1 ;;
      Unmute) pactl set-sink-mute @DEFAULT_SINK@ 0 ;;
      *) pactl set-sink-volume @DEFAULT_SINK@ "$V" ;;
    esac ;;
  Brightness*)
    V=$(printf '10%%\n25%%\n50%%\n75%%\n100%%' | rofi -dmenu -theme "$HOME/.config/rofi/shadowx.rasi" -p '[SHADOWX] BRIGHTNESS') || exit 0
    brightnessctl set "$V" 2>/dev/null || true ;;
  Notifications) dunstify "SHADOWX // NOTIFICATIONS" "Use dunst history (Ctrl+Shift+period)" ;;
  Quickshare) python3 "$HOME/.config/scripts/quickshare.py" ;;
  Power) "$HOME/.config/scripts/power-menu.sh" ;;
esac
