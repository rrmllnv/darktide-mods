return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TalentUI` encountered an error loading the Darktide Mod Framework.")

		new_mod("TalentUI", {
			mod_script       = "TalentUI/scripts/mods/TalentUI/TalentUI",
			mod_data         = "TalentUI/scripts/mods/TalentUI/TalentUI_data",
			mod_localization = "TalentUI/scripts/mods/TalentUI/TalentUI_localization",
		})
	end,
	packages = {},
}

