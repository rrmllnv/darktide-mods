return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PlayerProgressStats` encountered an error loading the Darktide Mod Framework.")

		new_mod("PlayerProgressStats", {
			mod_script       = "PlayerProgressStats/scripts/mods/PlayerProgressStats/PlayerProgressStats",
			mod_data         = "PlayerProgressStats/scripts/mods/PlayerProgressStats/PlayerProgressStats_data",
			mod_localization = "PlayerProgressStats/scripts/mods/PlayerProgressStats/PlayerProgressStats_localization",
		})
	end,
	packages = {},
}

