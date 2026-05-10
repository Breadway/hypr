-- scripts/input/keybinds.lua
return function(ctx)
    local function split_mods(value)
        local mods = {}

        for raw_mod in tostring(value):gmatch("[^+]+") do
            local mod = raw_mod:gsub("^%s+", ""):gsub("%s+$", "")
            if mod ~= "" then
                mods[#mods + 1] = mod
            end
        end

        return mods
    end

    local function normalize_mods(value, fallback, allow_empty)
        if value == nil then
            return fallback
        end

        if type(value) == "string" then
            return split_mods(value)
        end

        if type(value) ~= "table" then
            return fallback
        end

        if #value == 0 then
            return allow_empty and {} or fallback
        end

        local mods = {}
        for _, item in ipairs(value) do
            if type(item) == "string" then
                for _, mod in ipairs(split_mods(item)) do
                    mods[#mods + 1] = mod
                end
            end
        end

        if #mods == 0 then
            return fallback
        end

        return mods
    end

    local defaultMods = normalize_mods(ctx.default_mods, { "SUPER" }, false)
    local bindings = ctx.bindings or {}

    local function bind_string(mods, key)
        if type(key) ~= "string" or key == "" then
            return nil
        end

        if #mods == 0 then
            return key
        end

        return table.concat(mods, " + ") .. " + " .. key
    end

    local action_builders = {
        exec = function(entry)
            return hl.dsp.exec_cmd(entry.command)
        end,
        kill = function()
            return hl.dsp.window.kill()
        end,
        exit = function()
            return hl.dsp.exit()
        end,
        float = function()
            return hl.dsp.window.float({ action = "toggle" })
        end,
        fullscreen = function()
            return hl.dsp.window.fullscreen({ action = "toggle" })
        end,
        layout = function(entry)
            return hl.dsp.layout(entry.layout)
        end,
        focus = function(entry)
            return hl.dsp.focus({ direction = entry.direction, workspace = entry.workspace })
        end,
        move = function(entry)
            return hl.dsp.window.move({ workspace = entry.workspace })
        end,
        drag = function()
            return hl.dsp.window.drag()
        end,
        resize = function()
            return hl.dsp.window.resize()
        end,
    }

    for _, entry in ipairs(bindings) do
        local builder = action_builders[entry.action]
        assert(builder, "Unsupported bind action: " .. tostring(entry.action))

        local mods = normalize_mods(entry.mods, defaultMods, true)
        local bind = bind_string(mods, entry.key)
        local action = builder(entry)

        if bind and action then
            hl.bind(bind, action, entry.options)
        end
    end
end
