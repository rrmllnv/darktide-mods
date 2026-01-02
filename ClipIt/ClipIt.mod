return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ClipIt` encountered an error loading the Darktide Mod Framework.")

		new_mod("ClipIt", {
			mod_script       = "ClipIt/scripts/mods/ClipIt/ClipIt",
			mod_data         = "ClipIt/scripts/mods/ClipIt/ClipIt_data",
			mod_localization = "ClipIt/scripts/mods/ClipIt/ClipIt_localization",
		})
	end,
	packages = {},
}

