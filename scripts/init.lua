-- scripts/init.lua — shared entrypoint for modular Hyprland config
local home = os.getenv("HOME") or "/home/breadway"
local config_dir = home .. "/.config/hypr/"
local script_dir = config_dir .. "scripts/"
local binds = dofile(script_dir .. "input/binds.lua")(config_dir .. "binds.json")
local keybinds = dofile(script_dir .. "input/keybinds.lua")

keybinds({
	default_mods = binds.default_mods,
	bindings = binds.bindings,
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

for _, module_path in ipairs(modules) do
	dofile(script_dir .. module_path)
end
