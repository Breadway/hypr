-- scripts/ui/devices.lua
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- PS5 DualSense controller (both USB and Bluetooth)
hl.device({
    name             = "dualsense wireless controller",
    enabled          = true,
    natural_scroll   = false,
})

-- Alternative name pattern for Bluetooth connection
hl.device({
    name             = "dualsense",
    enabled          = true,
    natural_scroll   = false,
})
