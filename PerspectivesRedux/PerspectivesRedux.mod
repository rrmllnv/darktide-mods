return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PerspectivesRedux` encountered an error loading the Darktide Mod Framework.")

		new_mod("PerspectivesRedux", {
			mod_script       = "PerspectivesRedux/scripts/mods/PerspectivesRedux/PerspectivesRedux",
			mod_data         = "PerspectivesRedux/scripts/mods/PerspectivesRedux/PerspectivesRedux_data",
			mod_localization = "PerspectivesRedux/scripts/mods/PerspectivesRedux/PerspectivesRedux_localization",
		})
	end,
	packages = {},
}

