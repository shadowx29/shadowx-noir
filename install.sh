#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  SHADOWX // NOIR — universal Linux installer
#  Supports: Debian/Ubuntu/Kali, Arch/Manjaro, Fedora, openSUSE, Alpine
#  Usage: bash install.sh [--check | --help]
# ═══════════════════════════════════════════════════════════════
set -uo pipefail
B=$'\033[1m'; R=$'\033[0m'; G=$'\033[0;32m'; Y=$'\033[0;33m'; BL=$'\033[0;34m'; RD=$'\033[0;31m'
say(){ printf '%s[*]%s %s\n' "$BL" "$R" "$*"; }
good(){ printf '%s[✓]%s %s\n' "$G" "$R" "$*"; }
note(){ printf '%s[!]%s %s\n' "$Y" "$R" "$*"; }
err(){ printf '%s[✗]%s %s\n' "$RD" "$R" "$*" >&2; }
ask(){ local q="$1" d="${2:-n}" a h="[y/N]"; [[ "$d" == y ]] && h="[Y/n]"
  while true; do read -rp "$(printf '%s[?]%s %s %s ' "$Y" "$R" "$q" "$h")" a; a=${a:-$d}
    case "${a,,}" in y|yes) return 0;; n|no) return 1;; *) note "Answer y or n.";; esac; done; }

MODE=install
case "${1:-}" in
  --check) MODE=check ;;
  --help|-h)
    printf 'SHADOWX // NOIR installer\n  bash install.sh           install\n  bash install.sh --check   show detected system + packages\n  bash install.sh --help    this help\n'; exit 0 ;;
  '') ;;
  *) err "Unknown option: $1"; exit 2 ;;
esac

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BAK="$HOME/.config-backup-shadowx-$(date +%Y%m%d-%H%M%S)"

# ── Detect distro / package manager ──────────────────────────────
DISTRO="unknown"; . /etc/os-release 2>/dev/null || true
DISTRO="${ID:-unknown}"; DISTRO_LIKE="${ID_LIKE:-}"
if [[ -n "$DISTRO_LIKE" ]]; then FAMILY="$DISTRO_LIKE"; else FAMILY="$DISTRO"; fi

PM=""
if   command -v apt-get     >/dev/null; then PM=apt
elif command -v pacman      >/dev/null; then PM=pacman
elif command -v dnf         >/dev/null; then PM=dnf
elif command -v zypper      >/dev/null; then PM=zypper
elif command -v apk         >/dev/null; then PM=apk
elif command -v xbps-install >/dev/null; then PM=xbps
fi
[[ -n "$PM" ]] || { err "No supported package manager found (apt/pacman/dnf/zypper/apk/xbps)."; exit 1; }

# Package names per package manager.
DEB_PKGS=(hyprland waybar rofi dunst swaybg grim slurp wl-clipboard cliphist
  brightnessctl playerctl xdotool pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus network-manager blueman
  polkit-kde-authentication-agent-1 fonts-jetbrains-mono fonts-noto-color-emoji
  python3-pil python3-qrcode xdg-utils)
PAC_PKGS=(hyprland waybar rofi dunst swaybg grim slurp wl-clipboard cliphist
  brightnessctl playerctl xdotool pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus networkmanager blueman
  polkit-kde-agent ttf-jetbrains-mono noto-fonts-emoji
  python-pillow python-qrcode xdg-utils)
DNF_PKGS=(hyprland waybar rofi dunst swaybg grim slurp wl-clipboard cliphist
  brightnessctl playerctl xdotool pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus NetworkManager blueman
  polkit-kde-agent jetbrains-mono-fonts google-noto-emoji-fonts
  python3-pillow python3-qrcode xdg-utils)
ZYPP_PKGS=(hyprland waybar rofi dunst swaybg grim slurp wl-clipboard cliphist
  brightnessctl playerctl xdotool pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus NetworkManager blueman
  polkit-kde-agent jetbrains-mono-fonts noto-fonts-emoji
  python3-Pillow python3-qrcode xdg-utils)
APK_PKGS=(hyprland waybar rofi dunst swaybg grim slurp wl-clipboard cliphist
  brightnessctl playerctl xdotool pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus networkmanager blueman
  polkit-kde-agent jetbrains-mono-fonts noto-fonts-emoji
  py3-pillow py3-qrcode xdg-utils)
XBP_PKGS=(hyprland waybar rofi dunst swaybg grim slurp wl-clipboard cliphist
  brightnessctl playerctl xdotool pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus NetworkManager blueman
  polkit-kde-agent jetbrains-mono-fonts noto-fonts-emoji
  python3-pillow python3-qrcode xdg-utils)

case "$PM" in
  apt)    PKGS=("${DEB_PKGS[@]}") ;;
  pacman) PKGS=("${PAC_PKGS[@]}") ;;
  dnf)    PKGS=("${DNF_PKGS[@]}") ;;
  zypper) PKGS=("${ZYPP_PKGS[@]}") ;;
  apk)    PKGS=("${APK_PKGS[@]}") ;;
  xbps)   PKGS=("${XBP_PKGS[@]}") ;;
esac

# ── Privilege helper ────────────────────────────────────────────
PRIV=()
if (( EUID != 0 )); then
  if command -v sudo >/dev/null; then PRIV=(sudo)
  elif command -v doas >/dev/null; then PRIV=(doas)
  else err "sudo or doas required."; exit 1; fi
fi

pkg_installed(){
  case "$PM" in
    apt)    dpkg -s "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Qi "$1" >/dev/null 2>&1 ;;
    dnf)    rpm -q "$1" >/dev/null 2>&1 ;;
    zypper) rpm -q "$1" >/dev/null 2>&1 ;;
    apk)    apk info -e "$1" >/dev/null 2>&1 ;;
    xbps)   xbps-query "$1" >/dev/null 2>&1 ;;
  esac
}

install_pkgs(){
  case "$PM" in
    apt)    "${PRIV[@]}" apt-get install -y "$@" ;;
    pacman) "${PRIV[@]}" pacman -S --needed --noconfirm "$@" ;;
    dnf)    "${PRIV[@]}" dnf install -y "$@" ;;
    zypper) "${PRIV[@]}" zypper --non-interactive install "$@" ;;
    apk)    "${PRIV[@]}" apk add --no-cache "$@" ;;
    xbps)   "${PRIV[@]}" xbps-install -S -y "$@" ;;
  esac
}

# ── Check mode ──────────────────────────────────────────────────
if [[ "$MODE" == check ]]; then
  printf 'Distro: %s (%s)\nPackage manager: %s\nPrivilege: %s\n\n' \
    "$DISTRO" "$FAMILY" "$PM" "${PRIV:-root}"
  printf 'Packages to install (%s):\n' "${#PKGS[@]}"
  printf '  %s\n' "${PKGS[@]}"
  printf '\nMissing binaries:\n'
  for b in Hyprland waybar rofi dunst swaybg ghostty; do
    command -v "$b" >/dev/null 2>&1 && printf '  ok   %s\n' "$b" || printf '  MISS %s\n' "$b"
  done
  exit 0
fi

# ── Install mode ────────────────────────────────────────────────
preflight(){
  say "Pre-flight — distro: $DISTRO, package manager: $PM"
  [[ -f "$HERE/config/hypr/hyprland.lua" ]] || { err "config/hypr/hyprland.lua missing"; exit 1; }
  if (( EUID != 0 )); then
    "${PRIV[@]}" -v 2>/dev/null || "${PRIV[@]}" true || { err "privilege escalation failed"; exit 1; }
    ( while true; do "${PRIV[@]}" -n true 2>/dev/null || "${PRIV[@]}" true; sleep 60; kill -0 $$ 2>/dev/null || exit; done ) 2>/dev/null & 
  fi
  command -v ghostty >/dev/null || note "ghostty not in PATH — install it separately (snap/cargo)"
  good "Ready."
}

packages(){
  say "Installing packages via $PM..."
  local missing=() p
  for p in "${PKGS[@]}"; do
    if pkg_installed "$p"; then good "$p"; else missing+=("$p"); fi
  done
  if (( ${#missing[@]} )); then
    if ! install_pkgs "${missing[@]}" >/dev/null 2>&1; then
      note "batch install failed — retrying individually"
      for p in "${missing[@]}"; do install_pkgs "$p" >/dev/null 2>&1 || note "skipped $p"; done
    fi
  fi
  good "Packages done."
}

configs(){
  say "Deploying configs..."
  mkdir -p "$CFG" "$HOME/Pictures/shadowx-wallpapers" "$CFG/shadowx" "$HOME/.local/bin"
  local d
  for d in hypr waybar rofi dunst scripts session fastfetch btop; do
    if [[ -e "$CFG/$d" || -L "$CFG/$d" ]]; then
      if $BACKUP; then mkdir -p "$BAK"; mv "$CFG/$d" "$BAK/$d"; else rm -rf "$CFG/$d"; fi
    fi
    cp -r "$HERE/config/$d" "$CFG/"
  done
  chmod +x "$CFG/scripts/"* "$CFG/session/shadowx-session" 2>/dev/null || true
  [[ -f "$CFG/hypr/user.lua" ]] || cp "$HERE/config/hypr/user.lua" "$CFG/hypr/user.lua"
  if $BACKUP; then
    mkdir -p "$BAK/hypr"
    [[ -f "$CFG/hypr/hyprland.conf" ]] && cp -a "$CFG/hypr/hyprland.conf" "$BAK/hypr/" 2>/dev/null || true
  fi
  rm -f "$CFG/hypr/hyprland.conf" "$CFG/hypr/user.conf"

  # Generic polkit launcher (binary path differs per distro).
  local POLKIT
  POLKIT=$(command -v polkit-kde-authentication-agent-1 2>/dev/null || \
    find /usr/lib /usr/libexec -name polkit-kde-authentication-agent-1 -type f 2>/dev/null | head -1)
  if [[ -n "$POLKIT" ]]; then
    printf '#!/bin/sh\nexec "%s" "$@"\n' "$POLKIT" > "$HOME/.local/bin/shadowx-polkit"
    chmod +x "$HOME/.local/bin/shadowx-polkit"
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
  "${PRIV[@]}" install -m 755 "$HERE/config/session/shadowx-session" /usr/local/bin/shadowx-session 2>/dev/null || note "session wrapper failed"
  "${PRIV[@]}" install -m 644 "$HERE/config/session/shadowx.desktop" /usr/share/wayland-sessions/shadowx.desktop 2>/dev/null || note "session entry failed"

  local DM=""
  for d in lightdm sddm gdm gdm3 lxdm; do command -v "$d" >/dev/null 2>&1 && DM="$d" && break; done
  case "$DM" in
    lightdm)
      "${PRIV[@]}" install -d -m 755 /etc/lightdm/lightdm.conf.d 2>/dev/null || true
      printf '[Seat:*]\nuser-session=shadowx\n' > "$HERE/.sess"
      "${PRIV[@]}" install -m 644 "$HERE/.sess" /etc/lightdm/lightdm.conf.d/50-shadowx.conf 2>/dev/null \
        && good "LightDM default session set" || note "set session manually"
      rm -f "$HERE/.sess"
      GREETER=/etc/lightdm/lightdm-gtk-greeter.conf
      [[ -f "$GREETER" ]] && grep -q '^default-session=' "$GREETER" && \
        "${PRIV[@]}" sed -i 's|^default-session=.*|default-session=shadowx|' "$GREETER" 2>/dev/null || true
      ;;
    sddm)
      "${PRIV[@]}" install -d -m 755 /etc/sddm.conf.d 2>/dev/null || true
      printf '[General]\nSession=shadowx.desktop\n' > "$HERE/.sess"
      "${PRIV[@]}" install -m 644 "$HERE/.sess" /etc/sddm.conf.d/50-shadowx.conf 2>/dev/null \
        && good "SDDM default session set" || note "set session manually"
      rm -f "$HERE/.sess"
      ;;
    *)
      printf '[Desktop]\nSession=shadowx\n' > "$HOME/.dmrc"
      note "Default session written to ~/.dmrc — pick SHADOWX at login if needed"
      ;;
  esac
}

verify(){
  command -v Hyprland >/dev/null 2>&1 || return 0
  Hyprland --verify-config --config "$CFG/hypr/hyprland.lua" >/dev/null 2>&1 \
    && good "Config verified" || note "Config has errors"
}

main(){
  printf '\n%sSHADOWX // NOIR%s — universal installer (%s / %s)\n\n' "$B" "$R" "$DISTRO" "$PM"
  BACKUP=true; ask "Back up old configs?" y || BACKUP=false
  preflight; packages; configs; assets; system; verify
  printf '\n%sDone.%s Log out and select SHADOWX // NOIR (or plain Hyprland).\n' "$G" "$R"
}
main "$@"
