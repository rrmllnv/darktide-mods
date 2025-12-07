return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`FriendlyFireNotify` encountered an error loading the Darktide Mod Framework.")

		new_mod("FriendlyFireNotify", {
			mod_script       = "FriendlyFireNotify/scripts/mods/FriendlyFireNotify/FriendlyFireNotify",
			mod_data         = "FriendlyFireNotify/scripts/mods/FriendlyFireNotify/FriendlyFireNotify_data",
			mod_localization = "FriendlyFireNotify/scripts/mods/FriendlyFireNotify/FriendlyFireNotify_localization",
		})
	end,
	packages = {},
}

