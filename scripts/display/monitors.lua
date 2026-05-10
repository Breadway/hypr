-- scripts/display/monitors.lua
local DEBUG = false

local internal_output = "eDP-1"

local function is_internal_connector(connector)
    if not connector then
        return false
    end

    return connector == internal_output or connector:match("eDP%-1$") ~= nil
end

local function get_connected_statuses()
    local handle = io.popen("sh -c 'for file in /sys/class/drm/*/status; do [ -e \"$file\" ] || continue; printf \"%s:%s\\n\" \"$file\" \"$(cat \"$file\")\"; done' 2>/dev/null")
    if not handle then
        return {}
    end

    local statuses = {}
    for line in handle:lines() do
        local path, status = line:match("^(.-):([^:]+)$")
        if path and status then
            statuses[#statuses + 1] = {
                path = path,
                connector = path:match("/([^/]+)/status$"),
                status = status,
            }
        end
    end

    handle:close()
    return statuses
end

local function has_external_monitor()
    for _, entry in ipairs(get_connected_statuses()) do
        if entry.connector and not is_internal_connector(entry.connector) and entry.status == "connected" then
            return true
        end
    end

    return false
end

local function get_internal_mode()
    if has_external_monitor() then
        return "1920x1080@60"
    end

    return "1920x1200@60"
end

hl.monitor({
    output   = internal_output,
    mode     = get_internal_mode(),
    position = "0x0",
    scale    = "1",
})

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1",
    mirror   = internal_output,
})
