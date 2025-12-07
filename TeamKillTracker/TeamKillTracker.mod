return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TeamKillTracker` encountered an error loading the Darktide Mod Framework.")

		new_mod("TeamKillTracker", {
			mod_script       = "TeamKillTracker/scripts/mods/TeamKillTracker/TeamKillTracker",
			mod_data         = "TeamKillTracker/scripts/mods/TeamKillTracker/TeamKillTracker_data",
			mod_localization = "TeamKillTracker/scripts/mods/TeamKillTracker/TeamKillTracker_localization",
		})
	end,
	packages = {},
}