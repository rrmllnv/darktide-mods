return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MourningstarCommandWheel` encountered an error loading the Darktide Mod Framework.")

		new_mod("MourningstarCommandWheel", {
			mod_script       = "MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel",
			mod_data         = "MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_data",
			mod_localization = "MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_localization",
		})
	end,
	packages = {},
}
