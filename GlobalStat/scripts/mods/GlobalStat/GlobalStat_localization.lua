local mod = get_mod("GlobalStat")
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

load("GlobalStat/scripts/mods/GlobalStat/localization/core")
load("GlobalStat/scripts/mods/GlobalStat/localization/tab_general")
load("GlobalStat/scripts/mods/GlobalStat/localization/tab_enemies")
load("GlobalStat/scripts/mods/GlobalStat/localization/tab_records")
load("GlobalStat/scripts/mods/GlobalStat/localization/tab_missions")
load("GlobalStat/scripts/mods/GlobalStat/localization/tab_mission_progress")
load("GlobalStat/scripts/mods/GlobalStat/localization/tab_localization")

return localization


