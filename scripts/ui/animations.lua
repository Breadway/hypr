-- scripts/ui/animations.lua
local animations = {
	{ leaf = "global", enabled = true, speed = 10, bezier = "default" },
	{ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" },
	{ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" },
	{ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" },
	{ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" },
	{ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" },
	{ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" },
	{ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" },
}

for _, animation in ipairs(animations) do
	hl.animation(animation)
end
