return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ConsoleLog` encountered an error loading the Darktide Mod Framework.")

		new_mod("ConsoleLog", {
			mod_script       = "ConsoleLog/scripts/mods/ConsoleLog/ConsoleLog",
			mod_data         = "ConsoleLog/scripts/mods/ConsoleLog/ConsoleLog_data",
			mod_localization = "ConsoleLog/scripts/mods/ConsoleLog/ConsoleLog_localization",
		})
	end,
	packages = {},
}

