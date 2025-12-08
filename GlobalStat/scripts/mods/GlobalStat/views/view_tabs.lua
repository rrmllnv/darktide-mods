local mod = get_mod("GlobalStat")
local constants = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/view_constants")

local TabGeneral = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/tabs/tab_general")
local TabEnemies = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/tabs/tab_enemies")
local TabMissions = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/tabs/tab_missions")
local TabMissionProgress = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/tabs/tab_mission_progress")
local TabRecords = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/tabs/tab_records")

local tab_modules = {
	TabGeneral,
	TabEnemies,
	TabMissions,
	TabMissionProgress,
	TabRecords,
}

if constants.DEBUG then
	local TabLocalizationDebug = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/tabs/tab_localization_debug")
	if TabLocalizationDebug then
		table.insert(tab_modules, TabLocalizationDebug)
	end
end

return tab_modules

