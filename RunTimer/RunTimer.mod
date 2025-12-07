return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`RunTimer` encountered an error loading the Darktide Mod Framework.")

		new_mod("RunTimer", {
			mod_script = "RunTimer/scripts/mods/RunTimer/RunTimer",
			mod_data = "RunTimer/scripts/mods/RunTimer/RunTimer_data",
			mod_localization = "RunTimer/scripts/mods/RunTimer/RunTimer_localization",
		})
	end,
	packages = {},
}


