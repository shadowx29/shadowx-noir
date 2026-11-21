-- ═══════════════════════════════════════════════════════════
--  SHADOWX // NOIR — native Lua Hyprland config
-- ═══════════════════════════════════════════════════════════

local cfghome = os.getenv("XDG_CONFIG_HOME")
if not cfghome or cfghome == "" then cfghome = os.getenv("HOME") .. "/.config" end

local function exec(cmd) return hl.dsp.exec_cmd(cmd) end
local function script(name) return "'" .. cfghome .. "/scripts/" .. name .. "'" end

-- ── Monitor / environment ───────────────────────────────────
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
local p = os.getenv("PATH") or "/usr/local/bin:/usr/bin:/bin"
local lb = os.getenv("HOME") .. "/.local/bin"
if not (":" .. p .. ":"):find(":" .. lb .. ":", 1, true) then p = lb .. ":" .. p end
hl.env("PATH", p)

-- ── Settings ────────────────────────────────────────────────
hl.config({
    general = {
        gaps_in = 5, gaps_out = 10, border_size = 2,
        col = { active_border = "rgba(cc1515ff)", inactive_border = "rgba(1a1814aa)" },
        layout = "dwindle",
    },
    decoration = { rounding = 0, blur = { enabled = false }, shadow = { enabled = false } },
    dwindle = { preserve_split = true },
    input = {
        kb_layout = "us", follow_mouse = 1, sensitivity = 0, accel_profile = "adaptive",
        touchpad = { natural_scroll = true, tap_to_click = true },
    },
    misc = {
        disable_hyprland_logo = true, vrr = 0,
        disable_watchdog_warning = true, disable_hyprland_guiutils_check = true,
        disable_xdg_env_checks = true,
    },
})

hl.curve("shadowx", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "shadowx", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "shadowx", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "shadowx" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "shadowx", style = "slidevert" })

-- ── Startup ─────────────────────────────────────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaybg -i $HOME/Pictures/shadowx-wallpapers/shadowx.jpg -m fill")
    hl.exec_cmd("dunst")
    hl.exec_cmd("/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1 &")
    hl.exec_cmd("nm-applet --indicator &")
end)

-- ── Shortcuts: menus, apps ──────────────────────────────────
local rofi = "rofi -show drun -theme $HOME/.config/rofi/shadowx.rasi"
hl.bind("ALT + F1", exec(rofi))
hl.bind("ALT + F3", exec(rofi))
hl.bind("ALT + F2", exec("rofi -show run -theme $HOME/.config/rofi/shadowx.rasi"))
hl.bind("CTRL + Escape", exec(rofi))
hl.bind("SUPER + R", exec("rofi -show run -theme $HOME/.config/rofi/shadowx.rasi"))
hl.bind("SUPER + Space", exec(rofi))
hl.bind("SUPER + F1", exec("xdotool mousemove 960 540"))

local term = "ghostty --gtk-single-instance=true"
hl.bind("CTRL + ALT + T", exec(term))
hl.bind("CTRL + SHIFT + ALT + T", exec(term))
hl.bind("SUPER + Return", exec(term))
hl.bind("SUPER + T", exec(term))

hl.bind("CTRL + ALT + F", exec("nautilus"))
hl.bind("SUPER + E", exec("nautilus"))
hl.bind("SUPER + F", exec("nautilus"))
hl.bind("SUPER + W", exec("firefox"))
hl.bind("XF86Explorer", exec("nautilus"))
hl.bind("XF86HomePage", exec("firefox"))
hl.bind("XF86WWW", exec("firefox"))
hl.bind("XF86Calculator", exec("mate-calc"))
hl.bind("SUPER + M", exec("mpv"))

-- ── Screenshots ─────────────────────────────────────────────
local shot = script("screenshot.sh")
hl.bind("Print", exec(shot .. " --region"))
hl.bind("SHIFT + Print", exec(shot .. " --region"))
hl.bind("ALT + Print", exec(shot .. " --window"))
hl.bind("CTRL + Print", exec(shot .. " --full"))
hl.bind("CTRL + ALT + Print", exec(shot .. " --window"))
hl.bind("CTRL + SHIFT + Print", exec(shot .. " --region"))
hl.bind("ALT + SHIFT + S", exec(shot .. " --region"))

-- ── Windows ─────────────────────────────────────────────────
hl.bind("CTRL + ALT + Escape", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("ALT + F11", hl.dsp.window.fullscreen())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + D", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Escape", hl.dsp.exit())
hl.bind("CTRL + SHIFT + Escape", exec("btop"))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))

-- ── Workspaces ──────────────────────────────────────────────
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
for i = 1, 7 do
    hl.bind("ALT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ── Focus / move ────────────────────────────────────────────
local dirs = { Left = "left", Right = "right", Up = "up", Down = "down" }
for key, dir in pairs(dirs) do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Desktop features ────────────────────────────────────────
hl.bind("SUPER + Tab", exec(script("control-center.sh")))
hl.bind("SUPER + N", exec(script("notes.sh")))
hl.bind("SUPER + C", exec(script("clipboard.sh")))
hl.bind("SUPER + SHIFT + Return", exec(script("player.sh")))
hl.bind("SUPER + P", exec(script("wallpaper.sh")))
hl.bind("CTRL + ALT + Delete", exec(script("power-menu.sh")))
hl.bind("SUPER + ALT + R", exec("hyprctl reload"))

-- ── Hardware ────────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume", exec("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", exec("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioMute", exec("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86MonBrightnessUp", exec("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"))

-- Personal overrides (preserved by the installer)
require("user")
