#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  SHADOWX // NOIR — installer (all code written from scratch)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail
B=$'\033[1m'; R=$'\033[0m'; G=$'\033[0;32m'; Y=$'\033[0;33m'; BL=$'\033[0;34m'; RD=$'\033[0;31m'
say(){ printf '%s[*]%s %s\n' "$BL" "$R" "$*"; }
good(){ printf '%s[✓]%s %s\n' "$G" "$R" "$*"; }
note(){ printf '%s[!]%s %s\n' "$Y" "$R" "$*"; }
ask(){ local q="$1" d="${2:-n}" a; while true; do
  read -rp "$(printf '%s[?]%s %s [y/N] ' "$Y" "$R" "$q")" a; a=${a:-$d}
  case "${a,,}" in y|yes) return 0;; n|no) return 1;; *) note "Answer y or n.";; esac; done; }

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BAK="$HOME/.config-backup-shadowx-$(date +%Y%m%d-%H%M%S)"

PKGS=(
  hyprland waybar rofi dunst swaybg swaylock swayidle
  grim slurp wl-clipboard cliphist brightnessctl playerctl xdotool
  pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus network-manager blueman
  polkit-kde-authentication-agent-1
  fonts-jetbrains-mono fonts-noto-color-emoji
  python3-pil python3-qrcode xdg-utils
)

preflight(){
  say "Pre-flight..."
  (( EUID != 0 )) || { printf '%s[✗]%s Run as normal user\n' "$RD" "$R" >&2; exit 1; }
  command -v apt-get >/dev/null || { printf '%s[✗]%s Kali/Debian required\n' "$RD" "$R" >&2; exit 1; }
  command -v ghostty >/dev/null || note "ghostty not in PATH — install it separately"
  sudo -v || { printf '%s[✗]%s sudo failed\n' "$RD" "$R" >&2; exit 1; }
  ( while true; do sudo -n true; sleep 60; kill -0 $$ 2>/dev/null || exit; done ) 2>/dev/null &
  good "Ready."
}

packages(){
  say "Installing packages..."
  local p
  for p in "${PKGS[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then good "$p"
    elif ! sudo apt-get install -y "$p" >/dev/null 2>&1; then note "skipped $p"; fi
  done
  good "Packages done."
}

configs(){
  say "Deploying configs..."
  mkdir -p "$CFG" "$HOME/Pictures/shadowx-wallpapers" "$CFG/shadowx"
  local d
  for d in hypr waybar rofi dunst swaylock scripts session fastfetch btop; do
    if [[ -e "$CFG/$d" || -L "$CFG/$d" ]]; then
      if $BACKUP; then mkdir -p "$BAK"; mv "$CFG/$d" "$BAK/$d"; else rm -rf "$CFG/$d"; fi
    fi
    cp -r "$HERE/config/$d" "$CFG/"
  done
  chmod +x "$CFG/scripts/"* "$CFG/session/shadowx-session" 2>/dev/null || true
  [[ -f "$CFG/hypr/user.conf" ]] || printf '%s\n' 'monitor = eDP-1, 1920x1080@60, 0x0, 1' > "$CFG/hypr/user.conf"
  if [[ -f "$HERE/config/bash/.bashrc" ]]; then
    if [[ -f "$HOME/.bashrc" ]] && $BACKUP; then mkdir -p "$BAK"; cp -a "$HOME/.bashrc" "$BAK/.bashrc"; fi
    install -m 644 "$HERE/config/bash/.bashrc" "$HOME/.bashrc"
    [[ -f "$HOME/.bashrc.local" ]] || printf '%s\n' '# personal overrides' > "$HOME/.bashrc.local"
  fi
  good "Configs deployed."
}

assets(){
  local dest="$HOME/Pictures/shadowx-wallpapers"
  cp -n "$HERE"/assets/wallpapers/* "$dest/" 2>/dev/null || true
  printf '%s\n' "$dest/shadowx.jpg" > "$CFG/shadowx/wallpaper.current"
  if command -v xfconf-query >/dev/null 2>&1; then
    local p
    for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -iE 'image-path|last-image'); do
      xfconf-query -c xfce4-desktop -p "$p" -s "$dest/shadowx.jpg" >/dev/null 2>&1 || true
    done
  fi
  good "Wallpaper installed."
}

system(){
  if [[ ! -f /etc/pam.d/swaylock ]]; then
    printf '%%PAM-1.0\n@include common-auth\n@include common-account\n@include common-session\n' \
      | sudo tee /etc/pam.d/swaylock >/dev/null 2>&1 && good "PAM ready"
  fi
  sudo install -m 755 "$HERE/config/session/shadowx-session" /usr/local/bin/shadowx-session 2>/dev/null || note "session wrapper failed"
  sudo install -m 644 "$HERE/config/session/shadowx.desktop" /usr/share/wayland-sessions/shadowx.desktop 2>/dev/null || note "session entry failed"
  printf '[Seat:*]\nuser-session=shadowx\n' > "$HERE/.sess"
  sudo install -m 644 "$HERE/.sess" /etc/lightdm/lightdm.conf.d/50-shadowx.conf 2>/dev/null && good "default session set" || note "select session manually"
  rm -f "$HERE/.sess"
  # The GTK greeter has its own default-session setting — override it too.
  GREETER=/etc/lightdm/lightdm-gtk-greeter.conf
  if [[ -f "$GREETER" ]] && grep -q '^default-session=' "$GREETER"; then
    sudo sed -i 's|^default-session=.*|default-session=shadowx|' "$GREETER" 2>/dev/null \
      && good "greeter default session set" || note "greeter default not set"
  fi
}

verify(){
  command -v Hyprland >/dev/null || return 0
  Hyprland --verify-config --config "$CFG/hypr/hyprland.conf" >/dev/null 2>&1 \
    && good "Config verified" || note "Config has errors"
}

main(){
  printf '\n%sSHADOWX // NOIR%s — your rice, written from scratch\n\n' "$B" "$R"
  BACKUP=true; ask "Back up old configs?" y || BACKUP=false
  preflight; packages; configs; assets; system; verify
  printf '\n%sDone.%s Log out and log back in.\n' "$G" "$R"
  printf '  Super+Space menu · Super+T terminal · Super+Tab control center\n'
  printf '  Super+P wallpaper · Super+L lock · Super+N notes · Super+C clipboard\n\n'
}
main "$@"
