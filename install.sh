#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  SHADOWX // NOIR — complete Kali port installer
#  from the Tsugumori rice, with your shortcuts, wallpaper & Ghostty
# ═══════════════════════════════════════════════════════════════
set -euo pipefail
B=$'\033[1m'; R=$'\033[0m'; RED=$'\033[0;31m'; GRN=$'\033[0;32m'; YEL=$'\033[0;33m'; BLU=$'\033[0;34m'
log(){ printf '%s[*]%s %s\n' "$BLU" "$R" "$*"; }
ok(){ printf '%s[✓]%s %s\n' "$GRN" "$R" "$*"; }
warn(){ printf '%s[!]%s %s\n' "$YEL" "$R" "$*"; }
die(){ printf '%s[✗]%s %s\n' "$RED" "$R" "$*" >&2; exit 1; }
ask(){ local q="$1" d="${2:-n}" a h="[y/N]"; [[ "$d" == y ]] && h="[Y/n]"
  while true; do read -rp "$(printf '%s[?]%s %s %s ' "$YEL" "$R" "$q" "$h")" a; a=${a:-$d}
    case "${a,,}" in y|yes) return 0;; n|no) return 1;; *) warn "Answer y or n.";; esac; done; }

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BAK="$HOME/.config-backup-shadowx-$(date +%Y%m%d-%H%M%S)"
MANAGED=(hypr waybar rofi dunst swaylock scripts fastfetch btop session)

PACKAGES=(
  hyprland waybar rofi dunst swaybg swaylock swayidle
  grim slurp wl-clipboard cliphist brightnessctl playerctl xdotool
  pipewire pipewire-pulse wireplumber pavucontrol
  fastfetch btop mpv nautilus
  network-manager blueman polkit-kde-authentication-agent-1
  fonts-jetbrains-mono fonts-ibm-plex fonts-noto-color-emoji
  python3-pil python3-qrcode imagemagick xdg-utils
)

preflight(){
  log "Pre-flight..."
  (( EUID != 0 )) || die "Run as a normal user, not root."
  command -v apt-get >/dev/null || die "This installer is for Kali/Debian (apt)."
  command -v sudo >/dev/null || die "sudo is required."
  [[ -d "$HERE/config" ]] || die "config/ folder missing."
  command -v ghostty >/dev/null || warn "ghostty not in PATH — install it: snap install ghostty"
  sudo -v || die "sudo authentication failed."
  ( while true; do sudo -n true; sleep 60; kill -0 $$ 2>/dev/null || exit; done ) 2>/dev/null &
  ok "Ready."
}

install_packages(){
  log "Installing packages..."
  local p
  for p in "${PACKAGES[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then ok "$p"
    elif ! sudo apt-get install -y "$p" >/dev/null 2>&1; then warn "skipped $p (not available)"; fi
  done
  dpkg -s polkit-kde-authentication-agent-1 >/dev/null 2>&1 \
    || sudo apt-get install -y polkit-kde-agent-1 >/dev/null 2>&1 || warn "polkit agent missing"
  ok "Packages done."
}

deploy_configs(){
  log "Deploying configs..."
  mkdir -p "$CFG"
  local d
  for d in "${MANAGED[@]}"; do
    if [[ -e "$CFG/$d" || -L "$CFG/$d" ]]; then
      if $BACKUP; then mkdir -p "$BAK"; mv "$CFG/$d" "$BAK/$d"; log "backed up $d"
      else rm -rf "$CFG/$d"; fi
    fi
  done
  for d in "${MANAGED[@]}"; do cp -r "$HERE/config/$d" "$CFG/"; done
  chmod +x "$CFG/scripts/"* 2>/dev/null || true
  mkdir -p "$CFG/shadowx"
  [[ -f "$CFG/hypr/user.conf" ]] || printf '%s\n' 'monitor = eDP-1, 1920x1080@60, 0x0, 1' > "$CFG/hypr/user.conf"
  ok "Configs deployed."
}

deploy_assets(){
  local dest="$HOME/Pictures/shadowx-wallpapers"; local fdir="$HOME/.local/share/fonts/SHADOWX"
  mkdir -p "$dest" "$HOME/Pictures/Screenshots" "$fdir"
  cp -n "$HERE"/assets/wallpapers/* "$dest/" 2>/dev/null || true
  printf '%s\n' "$dest/shadowx-custom.jpg" > "$CFG/shadowx/wallpaper.current"
  mkdir -p "$fdir/share-tech-mono" "$fdir/ibm-plex-mono"
  cp "$HERE"/assets/fonts/share-tech-mono/* "$fdir/share-tech-mono/" 2>/dev/null || true
  cp "$HERE"/assets/fonts/ibm-plex-mono/* "$fdir/ibm-plex-mono/" 2>/dev/null || true
  command -v fc-cache >/dev/null && fc-cache -f "$fdir" >/dev/null 2>&1 || true
  # XFCE wallpaper too, so it shows before switching sessions.
  if command -v xfconf-query >/dev/null 2>&1; then
    local p
    for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -iE 'image-path|last-image'); do
      xfconf-query -c xfce4-desktop -p "$p" -s "$dest/shadowx-custom.jpg" >/dev/null 2>&1 || true
    done
  fi
  ok "Wallpapers and fonts installed."
}

deploy_shell(){
  $SHELLRC || { warn "skipping .bashrc"; return; }
  local src="$HERE/config/.bashrc" dst="$HOME/.bashrc"
  [[ -f "$src" ]] || return 0
  if [[ -e "$dst" || -L "$dst" ]]; then $BACKUP && { mkdir -p "$BAK"; cp -a "$dst" "$BAK/.bashrc"; }; fi
  install -m 644 "$src" "$dst"
  [[ -f "$HOME/.bashrc.local" ]] || printf '%s\n' '# SHADOWX personal overrides' > "$HOME/.bashrc.local"
  ok ".bashrc installed."
}

setup_system(){
  # Lock-screen PAM
  if [[ ! -f /etc/pam.d/swaylock ]]; then
    printf '%%PAM-1.0\n@include common-auth\n@include common-account\n@include common-session\n' \
      | sudo tee /etc/pam.d/swaylock >/dev/null 2>&1 && ok "PAM service created."
  fi
  # Session wrapper waits for logind ACTIVE — fixes dead mouse/keyboard.
  sudo install -m 755 "$HERE/config/session/shadowx-session" /usr/local/bin/shadowx-session 2>/dev/null || warn "session wrapper failed"
  sudo install -m 644 "$HERE/config/session/shadowx.desktop" /usr/share/wayland-sessions/shadowx.desktop 2>/dev/null || warn "session entry failed"
  printf '[Seat:*]\nuser-session=shadowx\n' > "$HERE/.lightdm-shadowx.conf"
  sudo install -m 644 "$HERE/.lightdm-shadowx.conf" /etc/lightdm/lightdm.conf.d/50-shadowx.conf 2>/dev/null \
    && ok "default session = SHADOWX" || warn "set default session manually at login"
  rm -f "$HERE/.lightdm-shadowx.conf"
}

verify(){
  command -v Hyprland >/dev/null || return 0
  log "Verifying Hyprland config..."
  Hyprland --verify-config --config "$CFG/hypr/hyprland.conf" >/dev/null 2>&1 \
    && ok "Config valid" || warn "Config errors — check with Hyprland --verify-config"
}

main(){
  printf '\n%sSHADOWX // NOIR%s — complete Kali rice\n\n' "$B" "$R"
  BACKUP=true; ask "Back up old configs?" y || BACKUP=false
  SHELLRC=true; ask "Install themed .bashrc?" y || SHELLRC=false
  preflight; install_packages; deploy_configs; deploy_assets; deploy_shell; setup_system; verify
  printf '\n%sDone.%s Log out and log back in — SHADOWX // NOIR is the default session.\n' "$GRN" "$R"
  printf '  SUPER+Space menu · SUPER+T Ghostty · SUPER+Tab control center · SUPER+P wallpaper\n'
  printf '  SUPER+L lock · SUPER+N notes · SUPER+C clipboard · SUPER+SHIFT+Return player\n\n'
}
main "$@"
