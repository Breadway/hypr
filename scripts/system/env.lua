-- scripts/system/env.lua
local home = os.getenv("HOME") or "/home/breadway"

local env_vars = {
	XCURSOR_SIZE = "24",
	HYPRCURSOR_SIZE = "24",
	WALLPAPERS = home .. "/Pictures/",
	HYPERSHOT_DIR = home .. "/Pictures/Screenshots/",
}

for key, value in pairs(env_vars) do
	hl.env(key, value)
end
