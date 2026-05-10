-- scripts/system/autostart.lua
local home = os.getenv("HOME") or "/home/breadway"

local startup_commands = {
    "wal -R",
    home .. "/colorshell/build/release/colorshell",
    "awww-daemon",
    "awww restore",
    home .. "/hypr/scripts/system/keyboard_and_display_watcher.sh",
    home .. "/hypr/scripts/system/watch_hypr_scripts.sh",
    "systemctl --user daemon-reload",
    "systemctl --user start hypr-display-sync.service",
    "systemctl --user start hyprpolkitagent",
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "flatpak run dev.deedles.Trayscale",
    "wificonf init",
    "pkill -f hyprpaper",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(startup_commands) do
        hl.dispatch(hl.dsp.exec_cmd(command))
    end
end)
