return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`CompassBar` encountered an error loading the Darktide Mod Framework.")

		new_mod("CompassBar", {
			mod_script = "CompassBar/scripts/mods/CompassBar/CompassBar",
			mod_data = "CompassBar/scripts/mods/CompassBar/CompassBar_data",
			mod_localization = "CompassBar/scripts/mods/CompassBar/CompassBar_localization",
		})
	end,
	packages = {},
}
