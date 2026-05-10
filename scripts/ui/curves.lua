-- scripts/ui/curves.lua
local curves = {
	easeOutQuint = { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } },
	easeInOutCubic = { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } },
	almostLinear = { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } },
	quick = { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } },
}

for name, curve in pairs(curves) do
	hl.curve(name, curve)
end
