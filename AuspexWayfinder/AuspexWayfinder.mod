return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AuspexWayfinder` encountered an error loading the Darktide Mod Framework.")

		new_mod("AuspexWayfinder", {
			mod_script = "AuspexWayfinder/scripts/mods/AuspexWayfinder/AuspexWayfinder",
			mod_data = "AuspexWayfinder/scripts/mods/AuspexWayfinder/AuspexWayfinder_data",
			mod_localization = "AuspexWayfinder/scripts/mods/AuspexWayfinder/AuspexWayfinder_localization",
		})
	end,
	packages = {},
}
