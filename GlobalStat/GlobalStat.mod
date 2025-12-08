return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`GlobalStat` encountered an error loading the Darktide Mod Framework.")

		new_mod("GlobalStat", {
			mod_script       = "GlobalStat/scripts/mods/GlobalStat/GlobalStat",
			mod_data         = "GlobalStat/scripts/mods/GlobalStat/GlobalStat_data",
			mod_localization = "GlobalStat/scripts/mods/GlobalStat/GlobalStat_localization",
		})
	end,
	packages = {},
}


