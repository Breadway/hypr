#!/usr/bin/env lua
-- scripts/system/sync-display.lua
-- Sync keybind layout based on whether the Redox keyboard is connected
local DEBUG = true  -- Set to false to suppress debug output

local home = os.getenv("HOME") or "/home/breadway"
local json = dofile(home .. "/.config/hypr/scripts/lib/json.lua")
local binds_path = home .. "/.config/hypr/binds.json"

local redox_usb_id = "4d44:5244"

local function debug_print(msg)
    if DEBUG then
        print("[sync-display] " .. msg)
    end
end

local function redox_keyboard_present()
    debug_print("Checking if Redox keyboard is present...")
    local handle = io.popen("lsusb -d '" .. redox_usb_id .. "' 2>/dev/null")
    if not handle then
        debug_print("ERROR: Failed to run lsusb")
        return false
    end

    local line = handle:read("*l")
    handle:close()

    if line and line ~= "" then
        debug_print("Redox keyboard detected: " .. line)
        return true
    else
        debug_print("Redox keyboard is not connected")
        return false
    end
end

local function set_bind_layout(layout)
    local config = json.load(binds_path)
    if type(config) ~= "table" then
        debug_print("ERROR: Unable to load binds config from " .. binds_path)
        return false
    end

    if config.active_layout == layout then
        debug_print("Keybind layout already set to " .. layout)
        return true
    end

    config.active_layout = layout

    local file = io.open(binds_path, "w")
    if not file then
        debug_print("ERROR: Unable to write binds config to " .. binds_path)
        return false
    end

    file:write(json.encode(config))
    file:close()

    debug_print("Updated keybind layout to " .. layout)
    return true
end

-- Main execution
debug_print("Starting keyboard-triggered bind sync...")
local keyboard_present = redox_keyboard_present()
local layout = keyboard_present and "colemak" or "qwerty"

set_bind_layout(layout)

if keyboard_present then
    debug_print("Redox keyboard detected, using colemak layout")
else
    debug_print("Redox keyboard not connected, using qwerty layout")
end
debug_print("Reloading Hyprland to apply keybind layout")
os.execute("hyprctl reload")
