return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ModderTools` encountered an error loading the Darktide Mod Framework.")

		new_mod("ModderTools", {
			mod_script       = "ModderTools/scripts/mods/ModderTools/ModderTools",
			mod_data         = "ModderTools/scripts/mods/ModderTools/ModderTools_data",
			mod_localization = "ModderTools/scripts/mods/ModderTools/ModderTools_localization",
		})
	end,
	packages = {},
}
