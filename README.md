# SHADOWX // NOIR

<p align="center">
  <img src="assets/wallpapers/shadowx-void.png" alt="SHADOWX NOIR wallpaper" width="800">
</p>

<p align="center">
  <b>SHADOWX // NOIR</b> — an original desktop rice for Kali Linux.
  Charcoal black <code>#0a0a0c</code> · signal red <code>#cc1515</code> ·
  built for a 1920×1080 laptop with Intel integrated graphics.
</p>

---

## Gallery

| Main wallpaper | Alternate wallpaper |
|---|---|
| <img src="assets/wallpapers/shadowx-void.png" alt="shadowx-void" width="420"> | <img src="assets/wallpapers/shadowx-grid.png" alt="shadowx-grid" width="420"> |

| App menu | Power menu |
|---|---|
| <img src="assets/screenshots/app-menu.png" alt="App menu" width="420"> | <img src="assets/screenshots/power-menu.png" alt="Power menu" width="420"> |

| Wallpaper picker | Terminal (Ghostty) |
|---|---|
| <img src="assets/screenshots/wallpaper-picker.png" alt="Wallpaper picker" width="420"> | <img src="assets/screenshots/terminal.png" alt="Terminal" width="420"> |

### Lock screen

<img src="assets/screenshots/lock-screen.png" alt="Lock screen" width="520">

All images are generated locally by `generate-wallpaper.py` and `generate-screens.py`.

### Custom wallpaper

`assets/wallpapers/shadowx-custom-2190504.jpg` is a personal wallpaper (3840×2160)
added to the picker. Press `SUPER + P` to switch between all wallpapers.
The active one is stored in `~/.config/shadowx/wallpaper.current`
— that is also the image used for the lock screen background.

---

## Preview

[![SHADOWX // NOIR preview](assets/wallpapers/shadowx-void.png)](assets/preview.mp4)

[Watch the 16-second animated preview (MP4, 1920×1080)](assets/preview.mp4)

---

## Contents

- [Gallery](#gallery)
- [Preview](#preview)
- [Install](#install)
- [What's inside](#whats-inside)
- [Keybindings](#keybindings)
- [Customization](#customization)
- [Intel iGPU notes](#intel-igpu-notes)
- [Project structure](#project-structure)

---

## Install

```bash
git clone https://github.com/shadowx29/shadowx-noir.git
cd shadowx-noir
bash install.sh
```

The installer:

1. Installs the required packages with `apt`
2. Backs up existing configs to `~/.config-backup-shadowx-<timestamp>`
3. Deploys the dotfiles into `~/.config`
4. Installs both wallpapers into `~/Pictures/shadowx-wallpapers`
5. Sets `shadowx-void.png` as the boot wallpaper

After it finishes, **log out** and select **Hyprland** at the login screen.

> If Hyprland does not appear in your login menu, log in on a TTY
> (`Ctrl+Alt+F3`) and run `Hyprland` manually.

---

## What's inside

| Role | Program | Config location |
|---|---|---|
| Compositor | Hyprland | `~/.config/hypr/` |
| Status bar | Waybar (bottom rail) | `~/.config/waybar/` |
| App menu / window switch | rofi | `~/.config/rofi/shadowx.rasi` |
| Terminal | **Ghostty** (your existing one, config untouched) | `~/.config/ghostty/config.ghostty` |
| Terminal banner | Fastfetch | `~/.config/shadowx/fastfetch.jsonc` |
| System monitor | btop | `~/.config/btop/` |
| Notifications | dunst | `~/.config/dunst/dunstrc` |
| Wallpaper | swaybg + rofi picker | `~/.config/scripts/wallpaper.sh` |
| Media | mpv | `~/.config/mpv/mpv.conf` |
| Lock screen | swaylock + swayidle | `~/.config/swaylock/` |
| Power menu | rofi + systemctl | `~/.config/scripts/power-menu.sh` |
| Shell | Bash | `~/.bashrc` |

---

## Keybindings

These are mirrored from the XFCE shortcuts that were already on the laptop.

| Keys | Action |
|---|---|
| `ALT + F1` / `ALT + F3` / `CTRL + Escape` / `SUPER + Space` | App menu |
| `ALT + F2` / `SUPER + R` | Run dialog |
| `CTRL + ALT + T` / `SUPER + T` / `SUPER + Enter` | Terminal (Ghostty) |
| `CTRL + ALT + F` / `SUPER + E` / `SUPER + F` | File manager |
| `SUPER + W` / `XF86WWW` / `XF86HomePage` | Web browser |
| `XF86Calculator` | Calculator |
| `ALT + F4` / `SUPER + Q` | Close window |
| `CTRL + ALT + Escape` | Force-close window |
| `ALT + F11` | Fullscreen |
| `ALT + Tab` / `ALT + SHIFT + Tab` / `SUPER + Tab` | Cycle windows |
| `SUPER + 1` … `SUPER + 9` | Switch workspace |
| `ALT + 1` … `ALT + 7` | Move window to workspace |
| `Print`, `SHIFT + Print`, `ALT + Print`, `CTRL + Print`, `CTRL + ALT + Print`, `CTRL + SHIFT + Print`, `ALT + SHIFT + S` | Screenshot → file + clipboard |
| `CTRL + SHIFT + Escape` | Task manager (btop) |
| `CTRL + ALT + L` / `SUPER + L` | Lock screen (clock, date, `shadowx`, red ring) |
| `CTRL + ALT + Delete` | Power menu |
| `SUPER + P` | Wallpaper picker |
| `SUPER + M` | mpv (rice extra) |
| `SUPER + ALT + R` | Reload Hyprland |
| `SUPER + Escape` | Exit Hyprland |
| `SUPER + drag` / `SUPER + right-drag` | Move / resize window |
| Volume / brightness / media keys | pactl / brightnessctl / mpv |

Click the **power icon** at the bottom-right of the bar for
Logout / Suspend / Reboot / Shutdown.

---

## Customization

- **Monitor, scaling, keybindings:** `~/.config/hypr/user.conf`
  (this file is preserved by the installer)
- **Colors:** `~/.config/waybar/style.css`, `~/.config/ghostty/config.ghostty`,
  `~/.config/rofi/shadowx.rasi`, `~/.config/btop/themes/shadowx.theme`
- **Wallpapers:** `~/Pictures/shadowx-wallpapers/`
- **Regenerate wallpapers:** `python3 generate-wallpaper.py`
- **Lock screen username:** edit `USER = "shadowx"` in
  `~/.config/scripts/lock-bg.py`
- **Shell overrides:** `~/.bashrc.local`

---

## Intel iGPU notes

- Blur is disabled in `hyprland.conf` to keep composition light.
- If video tears, uncomment `env = LIBVA_DRIVER_NAME, iHD` in `user.conf`.
- If the session feels heavy, set `animations { enabled = false }` in
  `hyprland.conf`.
- To confirm your display name, run `hyprctl monitors` and update the
  `monitor = eDP-1, 1920x1080@60, 0x0, 1` line in `user.conf`.

---

## Project structure

```
shadowx-noir/
├── README.md
├── install.sh
├── generate-wallpaper.py
├── generate-screens.py
├── generate-preview.py
├── assets/
│   ├── preview.mp4
│   ├── screenshots/     # app-menu, power-menu, wallpaper-picker, terminal, lock-screen
│   └── wallpapers/
│       ├── shadowx-void.png
│       └── shadowx-grid.png
└── config/
    ├── hypr/        # hyprland.conf + user.conf
    ├── waybar/      # config.jsonc + style.css
    ├── fastfetch/   # config.jsonc (installed to ~/.config/shadowx/)
    ├── btop/        # btop.conf + shadowx.theme
    ├── rofi/        # shadowx.rasi
    ├── dunst/       # dunstrc
    ├── mpv/         # mpv.conf
    ├── swaylock/    # login screen styling
    ├── scripts/     # wallpaper, screenshot, lock, lock-bg, power-menu
    └── bash/        # .bashrc
```
