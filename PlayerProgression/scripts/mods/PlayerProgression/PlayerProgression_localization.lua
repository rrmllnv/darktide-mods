local mod = get_mod("PlayerProgression")
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

load("PlayerProgression/scripts/mods/PlayerProgression/localization/core")
load("PlayerProgression/scripts/mods/PlayerProgression/localization/tab_general")
load("PlayerProgression/scripts/mods/PlayerProgression/localization/tab_enemies")
load("PlayerProgression/scripts/mods/PlayerProgression/localization/tab_records")
load("PlayerProgression/scripts/mods/PlayerProgression/localization/tab_missions")
load("PlayerProgression/scripts/mods/PlayerProgression/localization/tab_mission_progress")
load("PlayerProgression/scripts/mods/PlayerProgression/localization/tab_localization")

return localization


