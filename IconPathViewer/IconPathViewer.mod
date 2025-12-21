return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`IconPathViewer` encountered an error loading the Darktide Mod Framework.")

		new_mod("IconPathViewer", {
			mod_script       = "IconPathViewer/scripts/mods/IconPathViewer/IconPathViewer",
			mod_data         = "IconPathViewer/scripts/mods/IconPathViewer/IconPathViewer_data",
			mod_localization = "IconPathViewer/scripts/mods/IconPathViewer/IconPathViewer_localization",
		})
	end,
	packages = {},
}

