-- scripts/input/binds.lua
local json = dofile("/home/breadway/.config/hypr/scripts/lib/json.lua")

local DEFAULT_CONFIG_PATH = "/home/breadway/.config/hypr/binds.json"
local DEFAULT_LAYOUT = "qwerty"

local function normalize_mods(value, fallback)
    local mods = {}

    local function append_mod(mod)
        mod = mod:gsub("^%s+", ""):gsub("%s+$", "")
        if mod ~= "" then
            mods[#mods + 1] = mod
        end
    end

    if type(value) == "string" then
        for mod in value:gmatch("[^+]+") do
            append_mod(mod)
        end
    elseif type(value) == "table" then
        for _, item in ipairs(value) do
            if type(item) == "string" then
                for mod in item:gmatch("[^+]+") do
                    append_mod(mod)
                end
            end
        end
    end

    if #mods == 0 then
        for _, mod in ipairs(fallback or {}) do
            if type(mod) == "string" and mod ~= "" then
                mods[#mods + 1] = mod
            end
        end
    end

    return mods
end

local function select_bindings(parsed)
    local layout = parsed.active_layout
    if type(layout) ~= "string" or layout == "" then
        layout = os.getenv("HYPR_BIND_LAYOUT") or DEFAULT_LAYOUT
    end

    if type(parsed.layouts) == "table" then
        local selected = parsed.layouts[layout]
        if type(selected) ~= "table" then
            selected = parsed.layouts[DEFAULT_LAYOUT]
        end
        if type(selected) ~= "table" then
            for _, candidate in pairs(parsed.layouts) do
                if type(candidate) == "table" then
                    selected = candidate
                    break
                end
            end
        end

        local globals = type(parsed.globals) == "table" and parsed.globals or {}
        if #globals == 0 and type(parsed.global_bindings) == "table" then
            globals = parsed.global_bindings
        end
        local merged = {}

        for _, entry in ipairs(selected or {}) do
            if type(entry) == "table" then
                merged[#merged + 1] = entry
            end
        end
        for _, entry in ipairs(globals) do
            if type(entry) == "table" then
                merged[#merged + 1] = entry
            end
        end

        return merged
    end

    if type(parsed.bindings) ~= "table" then
        return {}
    end

    return parsed.bindings
end

return function(configPath)
    local parsed = json.load(configPath or DEFAULT_CONFIG_PATH)
    if type(parsed) ~= "table" then
        return { default_mods = { "SUPER" }, bindings = {} }
    end

    return {
        default_mods = normalize_mods(parsed.default_mods, { "SUPER" }),
        bindings = select_bindings(parsed),
    }
end
