#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  SHADOWX // NOIR — XFCE edition setup
#  Applies the rice look to XFCE (where input hardware works).
# ═══════════════════════════════════════════════════════════════
set -uo pipefail
say(){ printf '[*] %s\n' "$*"; }

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WALL="$HOME/Pictures/shadowx-wallpapers/shadowx.jpg"
mkdir -p "$HOME/Pictures/shadowx-wallpapers" "$HOME/.local/bin"
cp -f "$ROOT/assets/wallpapers/shadowx.jpg" "$WALL" 2>/dev/null || true

say "Wallpaper"
for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -iE 'image-path|last-image'); do
    xfconf-query -c xfce4-desktop -p "$p" -s "$WALL" 2>/dev/null || true
done
for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -i 'image-style'); do
    xfconf-query -c xfce4-desktop -p "$p" -s 4 2>/dev/null || true   # fill
done

say "Theme and fonts"
xfconf-query -c xsettings -p /Net/ThemeName -s "Kali-Red-Dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "JetBrainsMono Nerd Font 11" 2>/dev/null || xfconf-query -c xsettings -p /Gtk/FontName -s "JetBrainsMono Nerd Font 11" 2>/dev/null || true
xfconf-query -c xsettings -p /Gtk/MonospaceFontName -n -t string -s "JetBrainsMono Nerd Font 11" 2>/dev/null || xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "JetBrainsMono Nerd Font 11" 2>/dev/null || true

say "Panel (bottom, 30px, charcoal)"
xfconf-query -c xfce4-panel -p /panels/panel-0/position -n -t string -s bottom 2>/dev/null || xfconf-query -c xfce4-panel -p /panels/panel-0/position -s bottom 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-0/size -n -t int -s 30 2>/dev/null || xfconf-query -c xfce4-panel -p /panels/panel-0/size -s 30 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-0/length -n -t int -s 100 2>/dev/null || xfconf-query -c xfce4-panel -p /panels/panel-0/length -s 100 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-0/background-style -n -t uint -s 1 2>/dev/null || xfconf-query -c xfce4-panel -p /panels/panel-0/background-style -s 1 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-0/background-color -t uint16 -s 10 -s 10 -s 12 -s 255 2>/dev/null || true

say "Shortcuts"
addkey(){
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$1" -n -t string -s "$2" 2>/dev/null \
      || xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$1" -s "$2" 2>/dev/null || true
}
addkey '<Super>t' 'ghostty --gtk-single-instance=true'
addkey '<Super>Return' 'ghostty --gtk-single-instance=true'
addkey '<Super>e' 'nautilus'
addkey '<Super>f' 'nautilus'
addkey '<Super>p' "$HOME/.local/bin/shadowx-wallpaper.sh"
addkey '<Super>space' 'env -u WAYLAND_DISPLAY rofi -show drun -theme $HOME/.config/rofi/shadowx.rasi'
addkey '<Super><Shift>space' "$HOME/.config/scripts/menu.sh"
addkey '<Super>n' "$HOME/.config/scripts/notes.sh"
addkey '<Super>c' "$HOME/.config/scripts/clipboard.sh"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>Tab" -r 2>/dev/null || true
addkey '<Super><Shift>Tab' "$HOME/.config/scripts/control-center.sh"

say "Wallpaper picker script"
cat > "$HOME/.local/bin/shadowx-wallpaper.sh" <<'EOF'
#!/usr/bin/env bash
WALLDIR="$HOME/Pictures/shadowx-wallpapers"
CHOICE=$(find "$WALLDIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) -printf '%f\n' | sort \
  | env -u WAYLAND_DISPLAY rofi -dmenu -p '[SHADOWX] WALLPAPER' -theme "$HOME/.config/rofi/shadowx.rasi") || exit 0
[[ -n "$CHOICE" ]] || exit 0
IMG="$WALLDIR/$CHOICE"
for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -iE 'image-path|last-image'); do
    xfconf-query -c xfce4-desktop -p "$p" -s "$IMG" 2>/dev/null || true
done
notify-send "SHADOWX // WALLPAPER" "$CHOICE" 2>/dev/null || true
EOF
chmod +x "$HOME/.local/bin/shadowx-wallpaper.sh"

say "Done — XFCE styled as SHADOWX // NOIR."
