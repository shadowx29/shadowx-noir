#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  SHADOWX // NOIR installer — Kali Linux / Debian
#  Usage: bash install.sh
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

B=$'\033[1m'; R=$'\033[0m'; RED=$'\033[0;31m'; GRN=$'\033[0;32m'
YEL=$'\033[0;33m'; BLU=$'\033[0;34m'

log()  { printf '%s[*]%s %s\n' "$BLU" "$R" "$*"; }
ok()   { printf '%s[✓]%s %s\n' "$GRN" "$R" "$*"; }
warn() { printf '%s[!]%s %s\n' "$YEL" "$R" "$*"; }
err()  { printf '%s[✗]%s %s\n' "$RED" "$R" "$*" >&2; }
die()  { err "$*"; exit 1; }

ask() {
    local q="$1" d="${2:-n}" a hint="[y/N]"
    [[ "$d" == "y" ]] && hint="[Y/n]"
    while true; do
        read -rp "$(printf '%s[?]%s %s %s ' "$YEL" "$R" "$q" "$hint")" a
        a="${a:-$d}"
        case "${a,,}" in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) warn "Answer y or n." ;;
        esac
    done
}

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BAK="$HOME/.config-backup-shadowx-$(date +%Y%m%d-%H%M%S)"
MANAGED=(hypr waybar btop rofi dunst mpv scripts)

PACKAGES=(
    hyprland waybar rofi dunst swaybg
    grim slurp wl-clipboard brightnessctl playerctl
    pipewire pipewire-pulse wireplumber pavucontrol
    fastfetch btop mpv nautilus
    network-manager blueman
    polkit-kde-authentication-agent-1
    fonts-jetbrains-mono fonts-ibm-plex fonts-noto-color-emoji
    python3-pil imagemagick xdg-utils
)

check() {
    log "Pre-flight..."
    (( EUID != 0 )) || die "Run as a normal user, not root."
    command -v apt-get >/dev/null || die "apt-get missing — this is for Kali/Debian."
    command -v sudo >/dev/null || die "sudo is required."
    [[ -d "$HERE/config" ]] || die "config/ folder not found next to install.sh."
    command -v ghostty >/dev/null || warn "ghostty not found in PATH — install it with: snap install ghostty"
    sudo -v || die "sudo authentication failed."
    ( while true; do sudo -n true; sleep 60; kill -0 $$ 2>/dev/null || exit; done ) 2>/dev/null &
    ok "Ready."
}

add_packages() {
    log "Installing packages..."
    local p
    for p in "${PACKAGES[@]}"; do
        if dpkg -s "$p" >/dev/null 2>&1; then
            ok "$p"
        elif ! sudo apt-get install -y "$p" >/dev/null 2>&1; then
            warn "skipped $p (not available on this Kali version)"
        fi
    done
    dpkg -s polkit-kde-authentication-agent-1 >/dev/null 2>&1 \
        || sudo apt-get install -y polkit-kde-agent-1 >/dev/null 2>&1 \
        || warn "polkit agent missing"
    ok "Packages done."
}

install_configs() {
    log "Deploying configs..."
    mkdir -p "$CFG"
    local d
    for d in "${MANAGED[@]}"; do
        if [[ -e "$CFG/$d" || -L "$CFG/$d" ]]; then
            if $BACKUP; then
                mkdir -p "$BAK"
                mv "$CFG/$d" "$BAK/$d"
                log "backed up $d"
            else
                rm -rf "$CFG/$d"
            fi
        fi
    done

    for d in hypr waybar btop rofi dunst mpv scripts; do
        cp -r "$HERE/config/$d" "$CFG/"
    done
    chmod +x "$CFG/scripts/"*.sh

    mkdir -p "$CFG/shadowx"
    cp "$HERE/config/fastfetch/config.jsonc" "$CFG/shadowx/fastfetch.jsonc"
    # Your Ghostty config is intentionally NOT overwritten.
    [[ -f "$CFG/hypr/user.conf" ]] || cat > "$CFG/hypr/user.conf" <<'EOF'
# SHADOWX personal overrides
monitor = eDP-1, 1920x1080@60, 0x0, 1
EOF
    ok "Configs deployed."
}

install_wallpapers() {
    local dest="$HOME/Pictures/shadowx-wallpapers"
    mkdir -p "$dest" "$HOME/Pictures/Screenshots"
    cp -n "$HERE"/assets/wallpapers/* "$dest/" 2>/dev/null || true
    printf '%s\n' "$dest/shadowx-void.png" > "$CFG/shadowx/wallpaper.current"
    ok "Wallpapers installed."
}

install_shell() {
    $SHELLRC || { warn "skipping .bashrc"; return; }
    local src="$HERE/config/bash/.bashrc" dst="$HOME/.bashrc"
    if [[ -e "$dst" || -L "$dst" ]]; then
        $BACKUP && { mkdir -p "$BAK"; cp -a "$dst" "$BAK/.bashrc"; }
    fi
    install -m 644 "$src" "$dst"
    [[ -f "$HOME/.bashrc.local" ]] || printf '%s\n' '# SHADOWX personal overrides' > "$HOME/.bashrc.local"
    ok ".bashrc installed."
}

main() {
    printf '\n%sSHADOWX // NOIR%s — original Kali rice, 1920x1080, Intel iGPU\n\n' "$B" "$R"
    BACKUP=true;  ask "Back up old configs?" y || BACKUP=false
    SHELLRC=true; ask "Install themed .bashrc?" y || SHELLRC=false

    check
    add_packages
    install_configs
    install_wallpapers
    install_shell

    printf '\n%sDone.%s Log out and choose Hyprland.\n' "$GRN" "$R"
    printf '  Menu: SUPER+Space   Terminal: SUPER+T   Wallpaper: SUPER+P\n'
    printf '  Backups: %s\n  Your overrides: %s/hypr/user.conf\n\n' "$BAK" "$CFG"
}

main "$@"
