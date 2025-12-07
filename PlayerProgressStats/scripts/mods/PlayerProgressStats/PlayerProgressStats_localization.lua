local mod = get_mod("PlayerProgressStats")
local localization = {}

local function merge(into, from)
	for k, v in pairs(from) do
		into[k] = v
	end
end

local function load(path)
	-- mod:io_dofile сам добавляет .lua и ищет в папке мода
	local chunk = mod:io_dofile(path)
	if chunk then
		merge(localization, chunk)
	end
end

load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/core")
load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/tab_general")
load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/tab_enemies")
load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/tab_records")
load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/tab_missions")
load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/tab_mission_progress")
load("PlayerProgressStats/scripts/mods/PlayerProgressStats/localization/tab_localization")

return localization

