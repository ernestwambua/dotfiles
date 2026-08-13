--[[
  Hyprland configuration — converted from the legacy hyprland.conf +
  keybindings.conf (hyprlang) to the Lua config introduced in Hyprland 0.55.
  hyprlang is deprecated as of 0.55; this is the currently-recommended format.
  Reference: https://wiki.hypr.land/Configuring/Start/

  NOTE: hyprlock.conf, hypridle.conf and hyprpaper.conf are NOT part of this
  migration. Those are separate ecosystem tools (not the core compositor) and
  still use the classic key = value config format — they were left untouched.

  Lines marked "-- TODO(verify):" are places where the old config was
  ambiguous, buggy, or where the exact Lua dispatcher signature couldn't be
  100% confirmed against your specific Hyprland build. Run `hyprctl reload`
  and check `journalctl --user -b -u hyprland` (or the on-screen error popup)
  after editing, and fix anything flagged.
--]]

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Toolkit backend variables
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- Xdg specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT variables
-- (old config set QT_AUTO_SCREEN_SCALE_FACTOR twice — deduplicated here)
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- Theming
hl.env("GTK_THEME", "Adwaita:dark")

------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "eDP-1",    mode = "highres", position = "1920x0", scale = 1.2 })
hl.monitor({ output = "DP-1",     mode = "highres", position = "0x0",    scale = "auto" })
hl.monitor({ output = "HDMI-A-1", mode = "highres", position = "0x0",    scale = "auto" })
hl.monitor({ output = "HDMI-A-2", mode = "highres", position = "0x0",    scale = "auto" })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
-- hl.env("GDK_SCALE", "1")

---------------------
---- MY PROGRAMS ----
---------------------
-- See https://wiki.hypr.land/Configuring/Basics/Variables/
local terminal     = "kitty"
local file_manager = terminal .. " -e yazi"
local xnotes       = "flatpak run md.obsidian.Obsidian"
local menu         = os.getenv("HOME") .. "/.config/rofi/scripts/launcher_t2" -- app launcher
local clipboard    = os.getenv("HOME") .. "/.config/rofi/scripts/launcher_t4" -- clipboard
local emoji_picker = os.getenv("HOME") .. "/.config/rofi/scripts/launcher_t1" -- emoji picker

-- local browser = "firefox"
local browser  = "flatpak run app.zen_browser.zen"
local obsidian = "flatpak run md.obsidian.Obsidian"
local yt_music = "flatpak run app.zen_browser.zen --new-window https://music.youtube.com"

-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Things that should only ever run once per session go inside hyprland.start.
hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/waybar/scripts/launch-waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    hl.exec_cmd("sleep 5 && syncthingtray --wait")
    -- hl.exec_cmd(os.getenv("HOME") .. "/.config/swaync/scripts/launch-swaync")
    hl.exec_cmd("pidof -x low-battery.sh  || " .. os.getenv("HOME") .. "/.config/hypr/scripts/low-battery.sh")
    hl.exec_cmd("pidof -x full-battery.sh || " .. os.getenv("HOME") .. "/.config/hypr/scripts/full-battery.sh")

    hl.exec_cmd(browser, { workspace = "1 silent" })
    -- hl.exec_cmd(yt_music, { workspace = "7 silent" })
    hl.exec_cmd(file_manager, { workspace = "8 silent" })
    -- hl.exec_cmd(terminal, { workspace = "2 silent" })
    -- hl.exec_cmd(obsidian, { workspace = "4 silent" })
    -- hl.exec_cmd("flatpak run com.github.wwmm.easyeffects", { workspace = "10 silent" })

    -- launch applications in special workspaces
    hl.exec_cmd(terminal .. " -e tmux", { workspace = "special:scratchpad silent" })
    -- TODO(verify): the old config referenced an exec-once for "$notes" into
    -- special:notes, but $notes was never defined anywhere (only $xnotes was).
    -- Point this at whatever app you actually meant, e.g.:
    -- hl.exec_cmd(xnotes, { workspace = "special:notes silent" })
end)

-- These used plain "exec =" in the old config (re-run on every reload, not
-- just on startup), so they stay as top-level calls rather than inside
-- hl.on("hyprland.start", ...).
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')     -- for GTK3 apps
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')   -- for GTK4 apps

-- Clipboard tool
hl.exec_cmd("wl-paste --type text --watch cliphist store")
hl.exec_cmd("wl-paste --type images --watch cliphist store")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

-- Waybar / rofi / swaync blur
-- See https://wiki.hypr.land/Configuring/Basics/Layer-Rules/
-- TODO(verify): the old "ignore_alpha on" boolean toggle became a numeric
-- threshold in the new API — 1 is used here as the closest equivalent, adjust
-- to taste (0.0–1.0).
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 1, blur_popups = true })
hl.layer_rule({ match = { namespace = "rofi" },   blur = true, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "^(swaync-control-center)$" }, blur = true })

hl.window_rule({ match = { class = "imv" }, float = true })
hl.window_rule({ match = { class = "kitty" },   opacity = "1.0 0.6" })
hl.window_rule({ match = { class = "Spotify" }, opacity = "0.75" })
-- hl.window_rule({ match = { class = "vesktop" }, opacity = "0.8" })
-- hl.window_rule({ match = { class = "obsidian" }, opacity = "0.9" })
-- hl.window_rule({ match = { class = "org.mozilla.Thunderbird" }, opacity = "0.9" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,

        border_size = 1,

        col = {
            active_border   = "rgba(98971Aee)",
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
        -- layout = "master",
    },

    decoration = {
        rounding = 5,

        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        -- inactive_opacity = 0.8,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 10,
            passes = 3,
            vibrancy = 0.14,
            ignore_opacity = true,
            popups = true,
        },
    },

    animations = {
        enabled = true, -- old config had "enabled = yes, please :)"; Lua wants a plain boolean
    },
})

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/ for more
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",         enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",         enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",        enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",      enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 1.49, bezier = "linear",        style = "popin 87%" })
hl.animation({ leaf = "fadeIn",         enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",        enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",           enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",         enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",       enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",      enabled = true, speed = 1.5,  bezier = "linear",        style = "fade" })
hl.animation({ leaf = "fadeLayersIn",   enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",  enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",     enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",   enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut",  enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1", match = { float = false, workspace = "f[1]" }, border_size = 0, rounding = 0 })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
-- NOTE: dwindle.pseudotile was removed as a config key in Hyprland 0.55+.
-- Pseudotiling is now purely per-window via the `pseudo` dispatcher, which
-- is already bound to mainMod + P down in the keybindings section — no
-- config option needed to "enable" it anymore.
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
    misc = {
        force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})

---------------
---- INPUT ----
---------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout = "us,gb",
        kb_variant = "",
        kb_model = "",
        -- The old config set kb_options twice (grp:alt_shift_toggle, then
        -- ctrl:nocaps), which in hyprlang meant the second line silently
        -- overwrote the first. kb_options takes a comma-separated list, so
        -- both are combined here to actually apply both options.
        kb_options = "grp:alt_shift_toggle,ctrl:nocaps",
        -- kb_options = "caps:swapescape",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + SHIFT + END", hl.dsp.exec_cmd("shutdown now"))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal .. " -e tmux"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
-- TODO(verify): fullscreen() args — old config used bare `fullscreen,` (mode
-- 0). If this doesn't behave like before, try hl.dsp.window.fullscreen({ mode = 0 }).
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen()) -- dwindle
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

-- Rofi stuff
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(emoji_picker))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("cliphist list | " .. clipboard .. " | cliphist decode | wl-copy"))

-- Browser stuff
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --new-window"))
hl.bind("ALT + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window"))

-- applications launcher
hl.bind("ALT + K", hl.dsp.exec_cmd("kitty"))
hl.bind("ALT + H", hl.dsp.exec_cmd(terminal .. " -e btop"))
hl.bind("ALT + Y", hl.dsp.exec_cmd(terminal .. " -e yazi"))
hl.bind("ALT + F", hl.dsp.exec_cmd(file_manager))

-- toggle special workspace
hl.bind("ALT + SPACE", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("ALT + N", hl.dsp.workspace.toggle_special("notes"))

-- move active window to special workspace, silently
hl.bind("ALT + SHIFT + SPACE", hl.dsp.window.move({ workspace = "special:scratchpad", silent = true }))
hl.bind("ALT + SHIFT + N", hl.dsp.window.move({ workspace = "special:notes", silent = true }))

-- Lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Take screenshots
local focusedMonitor = [[$(hyprctl monitors | awk '/Monitor/{mon=$2} /focused: yes/{print mon}')]]
local screenshotsDir = "$HOME/Pictures/Screenshots/$(date +'Screenshot_%y-%m-%d_%T-%N.png')"
hl.bind("PRINT", hl.dsp.exec_cmd('grim -o "' .. focusedMonitor .. '" ' .. screenshotsDir))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd('grim -o "' .. focusedMonitor .. '" - | wl-copy'))
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" ' .. screenshotsDir))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | swappy -f - -o ' .. screenshotsDir))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd('grim -o "' .. focusedMonitor .. '" - | swappy -f - -o ' .. screenshotsDir))

-- # Screen Recordings
-- local screenrecsDir = "$HOME/Videos/'Screen Recordings'/$(date +'Recording_%y-%m-%d_%T-%N.mp4')"
-- hl.bind("ALT + PRINT", hl.dsp.exec_cmd('wf-recorder -f ' .. screenrecsDir .. ' & notify-send "Recording Started"'))
-- hl.bind("ALT + SHIFT + PRINT", hl.dsp.exec_cmd('wf-recorder -g "$(slurp)" ' .. screenrecsDir .. ' && notify-send "Recording Started"'))
-- hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd('killall -s SIGINT wf-recorder && notify-send "Recording Stopped"'))

-- Resize active window — will switch to a submap called "resize"
hl.define_submap("resize", function()
    -- repeatable binds for resizing the active window
    hl.bind("right", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

    -- use "reset" to go back to the global submap
    hl.bind("escape", hl.dsp.submap("reset"))
end)
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Swap active window mainMod + SHIFT + arrow keys
-- TODO(verify): swapwindow's typed-table form isn't documented with a
-- worked example yet; hl.dsp.window.swap({ direction = ... }) follows the
-- same pattern as window.move/window.resize but confirm against `hyprctl
-- dispatch 'hl.dsp.window.swap({direction="l"})'` on your build.
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ALT + [0-9] / ALT + SHIFT + [0-9] -> workspaces 11-20
for i = 1, 10 do
    local key = i % 10
    hl.bind("ALT + " .. key, hl.dsp.focus({ workspace = i + 10 }))
    hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = i + 10 }))
end

-- Move current workspace to monitor
-- There's no standalone "move_to_monitor" dispatcher — workspace.move()
-- handles both switching workspace AND moving it to a monitor, keyed off
-- the *current* workspace's id, resolved at press-time via a function bind.
local function moveCurrentWorkspaceToMonitor(direction)
    return function()
        local ws = hl.get_active_workspace()
        hl.dispatch(hl.dsp.workspace.move({ workspace = ws.id, monitor = direction }))
    end
end
hl.bind(mainMod .. " + ALT + left",  moveCurrentWorkspaceToMonitor("l"))
hl.bind(mainMod .. " + ALT + right", moveCurrentWorkspaceToMonitor("r"))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })
-- (the old config also had a second, non-repeating bind for the same two
-- brightness keys further down — that was a redundant duplicate and has
-- been dropped here)

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})
