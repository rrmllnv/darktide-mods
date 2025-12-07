return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`StimmCountdown` encountered an error loading the Darktide Mod Framework.")

		new_mod("StimmCountdown", {
			mod_script = "StimmCountdown/scripts/mods/StimmCountdown/StimmCountdown",
			mod_data = "StimmCountdown/scripts/mods/StimmCountdown/StimmCountdown_data",
			mod_localization = "StimmCountdown/scripts/mods/StimmCountdown/StimmCountdown_localization",
		})
	end,
	packages = {},
}
