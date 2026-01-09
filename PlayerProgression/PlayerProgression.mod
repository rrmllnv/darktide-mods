return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PlayerProgression` encountered an error loading the Darktide Mod Framework.")

		new_mod("PlayerProgression", {
			mod_script       = "PlayerProgression/scripts/mods/PlayerProgression/PlayerProgression",
			mod_data         = "PlayerProgression/scripts/mods/PlayerProgression/PlayerProgression_data",
			mod_localization = "PlayerProgression/scripts/mods/PlayerProgression/PlayerProgression_localization",
		})
	end,
	packages = {},
}


