local mod = get_mod("TeamKills")
local localization = {}

local function merge(into, from)
	for k, v in pairs(from) do
		into[k] = v
	end
end

local function load(path)
	local chunk = mod:io_dofile(path)
	if chunk then
		merge(localization, chunk)
	end
end

load("TeamKills/scripts/mods/TeamKills/Localization/Core")
load("TeamKills/scripts/mods/TeamKills/Localization/Data")
load("TeamKills/scripts/mods/TeamKills/Localization/Widget")

return localization

