return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`RobocopHUD` encountered an error loading the Darktide Mod Framework.")

		new_mod("RobocopHUD", {
			mod_script       = "RobocopHUD/scripts/mods/RobocopHUD/RobocopHUD",
			mod_data         = "RobocopHUD/scripts/mods/RobocopHUD/data",
			mod_localization = "RobocopHUD/scripts/mods/RobocopHUD/localization",
		})
	end,
	packages = {},
}

