local FLAG = "/tmp/bread-dock-active"

local function is_dock_active()
    local f = io.open(FLAG, "r")
    if not f then return false end
    local s = f:read("*l")
    f:close()
    return s == "1"
end

hl.on("monitor.added", function(monitor)
    if not is_dock_active() then return end
    local refresh = math.floor(monitor.refresh_rate + 0.5)
    local mode = monitor.width .. "x" .. monitor.height .. "@" .. refresh
    hl.monitor({ output = monitor.name, mode = mode, position = "0x0", scale = "1" })
    hl.monitor({ output = "eDP-1", mode = mode, position = "auto", scale = "1", mirror = monitor.name })
end)

hl.on("monitor.removed", function(monitor)
    if not is_dock_active() then return end
    hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "auto", scale = "1" })
end)
