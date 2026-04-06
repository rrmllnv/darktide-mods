return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`DivisionHUD` encountered an error loading the Darktide Mod Framework.")

		new_mod("DivisionHUD", {
			mod_script       = "DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD",
			mod_data         = "DivisionHUD/scripts/mods/DivisionHUD/data",
			mod_localization = "DivisionHUD/scripts/mods/DivisionHUD/localization",
		})
	end,
	packages = {},
}

