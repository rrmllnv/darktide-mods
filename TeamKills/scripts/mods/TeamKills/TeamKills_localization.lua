local mod = get_mod("TeamKills")
local localization = {}

local function merge(into, from)
	for k, v in pairs(from) do
		into[k] = v
	end
end

local function load(path)
	local success, chunk = pcall(function()
		return mod:io_dofile(path)
	end)
	if success and chunk then
		merge(localization, chunk)
	else
		mod:error("Failed to load localization file: %s", path)
	end
end

load("TeamKills/scripts/mods/TeamKills/Localization/Core")
load("TeamKills/scripts/mods/TeamKills/Localization/Data")
load("TeamKills/scripts/mods/TeamKills/Localization/Widget")
load("TeamKills/scripts/mods/TeamKills/Localization/Notifications")

return localization

