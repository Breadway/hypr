-- scripts/system/autostart.lua
local home = os.getenv("HOME") or "/home/breadway"

local startup_commands = {
    "wal -R",
    home .. "/colorshell/build/colorshell",
    "awww-daemon",
    "awww restore",
    home .. "/.config/hypr/watch_hypr_scripts.sh",
    "systemctl --user daemon-reload",
    "systemctl --user start hypr-display-sync.service",
    "systemctl --user start hyprpolkitagent",
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE",
    "systemctl --user restart breadd",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "flatpak run dev.deedles.Trayscale",
    "wificonf init",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(startup_commands) do
        hl.dispatch(hl.dsp.exec_cmd(command))
    end
end)

hl.dispatch(hl.dsp.exec_cmd("pkill -f hyprpaper"))
