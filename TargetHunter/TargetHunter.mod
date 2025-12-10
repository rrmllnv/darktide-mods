return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TargetHunter` encountered an error loading the Darktide Mod Framework.")

		new_mod("TargetHunter", {
			mod_script = "TargetHunter/scripts/mods/TargetHunter/TargetHunter",
			mod_data = "TargetHunter/scripts/mods/TargetHunter/TargetHunter_data",
			mod_localization = "TargetHunter/scripts/mods/TargetHunter/TargetHunter_localization",
		})
	end,
	packages = {},
}


