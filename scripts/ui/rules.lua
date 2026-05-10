-- scripts/ui/rules.lua
hl.window_rule({
    name = "goldwarden-autofill",
    match = { class = "^(com.quexten.goldwarden)$" },
    float = true,
    size = "600 400",
    center = true,
    pin = true,
    stay_focused = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

local REDOX_PADDING_RIGHT = 30   -- increase/decrease right margin
local REDOX_PADDING_BOTTOM = 10  -- increase/decrease bottom margin

hl.window_rule({
    name = "redox-layout",
    match = { title = "^Redox layout$" },
    float = true,
    pin = true,
    border_size = 0,
    rounding = 0,
    no_shadow = true,
    no_blur = true,
    opacity = 0.2,
    size = { 500, 300 }, -- Changed to a Lua table
    no_focus = true,
    -- Using strings for the coordinates often resolves the 'ignored' status
    move = {"1400", "900"}
})