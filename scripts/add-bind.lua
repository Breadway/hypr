#!/usr/bin/env lua
-- scripts/add-bind.lua — interactive Hyprland bind adder

local home = os.getenv("HOME") or "/home/breadway"
local json = dofile(home .. "/.config/hypr/scripts/lib/json.lua")

local BINDS_FILE = home .. "/.config/hypr/binds.json"

-- ANSI color codes
local C = {
    RESET = "\27[0m",
    BOLD = "\27[1m",
    DIM = "\27[2m",
    CYAN = "\27[36m",
    GREEN = "\27[32m",
    YELLOW = "\27[33m",
    RED = "\27[31m",
    BLUE = "\27[34m",
    MAGENTA = "\27[35m",
    WHITE = "\27[37m",
    BG_BLUE = "\27[44m",
    BG_GREEN = "\27[42m",
}

local ACTIONS = {
    "exec",
    "kill",
    "exit",
    "float",
    "fullscreen",
    "layout",
    "focus",
    "move",
    "drag",
    "resize",
}

local ACTION_DESC = {
    exec = "Execute a command",
    kill = "Kill the active window",
    exit = "Exit Hyprland",
    float = "Toggle floating mode",
    fullscreen = "Toggle fullscreen",
    layout = "Change layout",
    focus = "Focus a direction or workspace",
    move = "Move window to workspace",
    drag = "Drag windows (usually with mouse)",
    resize = "Resize windows (usually with mouse)",
}

local ACTION_FIELDS = {
    exec = { "command" },
    kill = {},
    exit = {},
    float = {},
    fullscreen = {},
    layout = { "layout" },
    focus = { "direction", "workspace" },
    move = { "workspace" },
    drag = {},
    resize = {},
}

local MOD_PRESETS = {
    none = {},
    SUPER = { "SUPER" },
    SHIFT = { "SHIFT" },
    CTRL = { "CTRL" },
    ALT = { "ALT" },
    ["SUPER+SHIFT"] = { "SUPER", "SHIFT" },
    ["SUPER+CTRL"] = { "SUPER", "CTRL" },
    ["SUPER+ALT"] = { "SUPER", "ALT" },
    ["CTRL+ALT"] = { "CTRL", "ALT" },
}

local function trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

local function prompt(label, default, hint)
    io.write(C.CYAN .. label .. C.RESET)
    if default then
        io.write(" " .. C.DIM .. "[" .. default .. "]" .. C.RESET)
    end
    if hint then
        io.write(" " .. C.DIM .. "(" .. hint .. ")" .. C.RESET)
    end
    io.write(": ")
    io.flush()
    local input = trim(io.read())
    return input ~= "" and input or default
end

local function prompt_options(label, options, descriptions)
    io.write("\n" .. C.CYAN .. label .. C.RESET .. "\n")
    for i, opt in ipairs(options) do
        if descriptions and descriptions[opt] then
            io.write(string.format("  %s%d%s) %-15s %s— %s%s\n", C.YELLOW, i, C.RESET, opt, C.DIM, descriptions[opt], C.RESET))
        else
            io.write(string.format("  %s%d%s) %s\n", C.YELLOW, i, C.RESET, opt))
        end
    end
    io.write(C.CYAN .. "Choice [1-" .. #options .. "]: " .. C.RESET)
    io.flush()
    local choice = tonumber(io.read())
    if choice and choice >= 1 and choice <= #options then
        return options[choice]
    end
    io.write(C.RED .. "❌ Invalid choice. Please try again." .. C.RESET .. "\n")
    return prompt_options(label, options, descriptions)
end

local function read_config()
    local parsed = json.load(BINDS_FILE)
    if type(parsed) ~= "table" then
        return { default_mods = { "SUPER" }, bindings = {} }
    end

    if type(parsed.active_layout) ~= "string" or parsed.active_layout == "" then
        parsed.active_layout = "qwerty"
    end

    return parsed
end

local function get_active_layout_name(config)
    local layout = type(config.active_layout) == "string" and config.active_layout or "qwerty"
    if type(config.layouts) ~= "table" then
        return layout
    end

    if type(config.layouts[layout]) == "table" then
        return layout
    end

    if type(config.layouts.qwerty) == "table" then
        return "qwerty"
    end

    for name, entries in pairs(config.layouts) do
        if type(entries) == "table" then
            return name
        end
    end

    return layout
end

local function get_layout_binds(config)
    if type(config.layouts) == "table" then
        local layout = get_active_layout_name(config)
        config.active_layout = layout
        if type(config.layouts[layout]) ~= "table" then
            config.layouts[layout] = {}
        end
        return config.layouts[layout]
    end

    if type(config.bindings) ~= "table" then
        config.bindings = {}
    end

    return config.bindings
end

local function get_global_binds(config)
    if type(config.globals) == "table" then
        return config.globals
    end

    if type(config.global_bindings) == "table" then
        config.globals = config.global_bindings
        return config.globals
    end

    config.globals = {}
    return config.globals
end

local function save_config(config)
    local file = io.open(BINDS_FILE, "w")
    if not file then
        error("Cannot open " .. BINDS_FILE .. " for writing")
    end
    file:write(json.encode(config))
    file:close()
end

local function find_conflicting_binds(config, key, mods)
    local conflicts = {}
    local combined = {}
    for _, bind in ipairs(get_layout_binds(config)) do
        combined[#combined + 1] = bind
    end
    for _, bind in ipairs(get_global_binds(config)) do
        combined[#combined + 1] = bind
    end

    for _, bind in ipairs(combined) do
        if bind.key == key then
            local bind_mods = bind.mods or config.default_mods or {}
            if #mods == #bind_mods then
                local match = true
                for i = 1, #mods do
                    if mods[i] ~= bind_mods[i] then
                        match = false
                        break
                    end
                end
                if match then
                    table.insert(conflicts, bind)
                end
            end
        end
    end
    return conflicts
end

local function format_bind(bind)
    local mods_str = ""
    if bind.mods then
        mods_str = table.concat(bind.mods, "+") .. "+"
    end
    local key_str = mods_str .. bind.key
    local action_str = bind.action
    if bind.command then
        action_str = action_str .. " " .. bind.command
    elseif bind.direction then
        action_str = action_str .. " " .. bind.direction
    elseif bind.workspace then
        action_str = action_str .. " ws:" .. bind.workspace
    elseif bind.layout then
        action_str = action_str .. " " .. bind.layout
    end
    return string.format("%-20s → %s", key_str, action_str)
end

local function list_binds(config)
    local layout_name = get_active_layout_name(config)
    local layout_binds = get_layout_binds(config)
    local globals = get_global_binds(config)

    io.write("\n" .. C.BOLD .. C.CYAN .. "📋 Current Binds:" .. C.RESET .. "\n")
    if #layout_binds == 0 and #globals == 0 then
        io.write(C.DIM .. "  (no binds configured)\n\n" .. C.RESET)
        return
    end

    io.write(C.GREEN .. "  Layout: " .. layout_name .. C.RESET .. "\n")
    local index = 0
    for _, bind in ipairs(layout_binds) do
        index = index + 1
        io.write(string.format("  %s%2d%s. %s\n", C.YELLOW, index, C.RESET, format_bind(bind)))
    end

    if #globals > 0 then
        io.write("\n" .. C.GREEN .. "  Globals:" .. C.RESET .. "\n")
    end
    for _, bind in ipairs(globals) do
        index = index + 1
        io.write(string.format("  %s%2d%s. %s\n", C.YELLOW, index, C.RESET, format_bind(bind)))
    end
    io.write("\n")
end

local function show_help()
    io.write("\n" .. C.BOLD .. C.CYAN .. "📖 Hyprland Bind Keys Reference:" .. C.RESET .. "\n")
    io.write(C.DIM)
    io.write("  Letters/Numbers: A-Z, 0-9\n")
    io.write("  Special Keys: RETURN, SPACE, ESCAPE, TAB, BACKSPACE, DELETE\n")
    io.write("  Arrow Keys: left, right, up, down\n")
    io.write("  Function Keys: F1-F12\n")
    io.write("  Mouse Buttons: mouse:272 (left), mouse:273 (right), mouse:274 (middle)\n")
    io.write("  Media Keys: XF86AudioRaiseVolume, XF86AudioLowerVolume, etc.\n")
    io.write("  Scroll: mouse_down, mouse_up\n")
    io.write(C.RESET .. "\n")
end

local function main()
    io.write("\n")
    io.write(C.BOLD .. C.BG_BLUE .. C.WHITE)
    io.write("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    io.write("  🎮 Hyprland Interactive Bind Manager\n")
    io.write("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    io.write(C.RESET .. "\n")

    local config = read_config()

    -- Main menu
    local menu_choice = prompt_options(
        "What would you like to do?",
        { "Add new bind", "View current binds", "Show key reference", "Exit" },
        {
            ["Add new bind"] = "Create a new keybind",
            ["View current binds"] = "List all configured binds",
            ["Show key reference"] = "Display available keys",
            Exit = "Exit the tool",
        }
    )

    if menu_choice == "Exit" then
        io.write("\n" .. C.MAGENTA .. "Goodbye! 👋\n\n" .. C.RESET)
        return
    elseif menu_choice == "View current binds" then
        list_binds(config)
        io.write(C.CYAN .. "Press Enter to return to menu..." .. C.RESET)
        local _ = io.read()
        return main()
    elseif menu_choice == "Show key reference" then
        show_help()
        io.write(C.CYAN .. "Press Enter to return to menu..." .. C.RESET)
        local _ = io.read()
        return main()
    end

    io.write("\n" .. C.BOLD .. string.rep("─", 47) .. "\n")
    io.write(C.GREEN .. "📝 Adding New Bind\n")
    io.write(C.RESET .. string.rep("─", 47) .. "\n\n" .. C.RESET)

    -- Get key
    local key = prompt("Key", nil, "e.g., E, RETURN, mouse:272")
    if not key or key == "" then
        io.write(C.RED .. "❌ Key is required.\n\n" .. C.RESET)
        return main()
    end

    -- Get mods
    io.write("\n")
    local preset_names = {}
    for name in pairs(MOD_PRESETS) do
        table.insert(preset_names, name)
    end
    table.sort(preset_names)
    local preset_name = prompt_options("Modifier(s)", preset_names)
    local mods = MOD_PRESETS[preset_name]

    -- Check for conflicts
    local conflicts = find_conflicting_binds(config, key, mods)
    if #conflicts > 0 then
        io.write("\n" .. C.YELLOW .. "⚠️  This key combination already exists:\n" .. C.RESET)
        for _, conflict in ipairs(conflicts) do
            io.write(C.DIM .. "    " .. format_bind(conflict) .. C.RESET .. "\n")
        end
        io.write("\n" .. C.CYAN .. "Continue anyway? (y/n): " .. C.RESET)
        io.flush()
        local confirm = io.read()
        if confirm ~= "y" and confirm ~= "Y" then
            io.write(C.YELLOW .. "Cancelled.\n\n" .. C.RESET)
            return main()
        end
        io.write("\n")
    end

    -- Get action
    local action = prompt_options("Action", ACTIONS, ACTION_DESC)

    -- Get action-specific fields
    local entry = {
        key = key,
        action = action,
    }

    if #mods > 0 then
        entry.mods = mods
    end

    local required_fields = ACTION_FIELDS[action] or {}
    for _, field in ipairs(required_fields) do
        io.write("\n")
        if field == "command" then
            local cmd = prompt("Command", nil, "e.g., firefox, spotify")
            if not cmd or cmd == "" then
                io.write(C.RED .. "❌ Command is required.\n\n" .. C.RESET)
                return main()
            end
            entry[field] = cmd
        elseif field == "direction" then
            entry[field] = prompt_options("Direction", { "left", "right", "up", "down" })
        elseif field == "workspace" then
            local ws = tonumber(prompt("Workspace", nil, "1-10"))
            if not ws or ws < 1 or ws > 10 then
                io.write(C.RED .. "❌ Workspace must be 1-10.\n\n" .. C.RESET)
                return main()
            end
            entry[field] = ws
        elseif field == "layout" then
            local layout = prompt("Layout", "togglesplit", "e.g., togglesplit, dwindle")
            if layout == "" then layout = "togglesplit" end
            entry[field] = layout
        end
    end

    -- Show preview
    io.write("\n" .. C.BOLD .. string.rep("─", 47) .. "\n")
    io.write(C.GREEN .. "✅ Preview\n")
    io.write(C.RESET .. string.rep("─", 47) .. "\n")
    io.write(C.BOLD .. "  " .. format_bind(entry) .. C.RESET .. "\n")
    io.write("\n")

    -- Confirm
    io.write(C.CYAN .. "Save this bind? (y/n): " .. C.RESET)
    io.flush()
    local confirm = io.read()
    if confirm ~= "y" and confirm ~= "Y" then
        io.write(C.YELLOW .. "Cancelled.\n\n" .. C.RESET)
        return main()
    end

    -- Save
    table.insert(get_layout_binds(config), entry)
    save_config(config)

    io.write("\n" .. C.GREEN .. "✨ Bind added successfully!\n")
    io.write("   " .. format_bind(entry) .. C.RESET .. "\n\n")
    io.write(C.CYAN .. "Press Enter to return to menu..." .. C.RESET)
    local _ = io.read()
    return main()
end

main()
