local home = os.getenv("HOME") or "/home/breadway"
local script_dir = home .. "/.config/hypr/scripts/"

local binds = dofile(script_dir .. "input/binds.lua")(home .. "/.config/hypr/binds.json")
dofile(script_dir .. "input/keybinds.lua")({
    default_mods = binds.default_mods,
    bindings     = binds.bindings,
})

local modules = {
    "display/monitors.lua",
    "display/dock.lua",
    "system/autostart.lua",
    "system/env.lua",
    "ui/settings.lua",
    "ui/curves.lua",
    "ui/animations.lua",
    "ui/gestures.lua",
    "ui/devices.lua",
    "ui/rules.lua",
}

for _, module in ipairs(modules) do
    dofile(script_dir .. module)
end
