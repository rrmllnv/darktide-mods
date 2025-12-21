return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PrivateModeBypass` encountered an error loading the Darktide Mod Framework.")

		new_mod("PrivateModeBypass", {
			mod_script = "PrivateModeBypass/scripts/mods/PrivateModeBypass/PrivateModeBypass",
			mod_data = "PrivateModeBypass/scripts/mods/PrivateModeBypass/PrivateModeBypass_data",
			mod_localization = "PrivateModeBypass/scripts/mods/PrivateModeBypass/PrivateModeBypass_localization",
		})
	end,
	packages = {},
}

