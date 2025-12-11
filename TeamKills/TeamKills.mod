return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TeamKills` encountered an error loading the Darktide Mod Framework.")

		new_mod("TeamKills", {
			mod_script       = "TeamKills/scripts/mods/TeamKills/TeamKills",
			mod_data         = "TeamKills/scripts/mods/TeamKills/TeamKills_data",
			mod_localization = "TeamKills/scripts/mods/TeamKills/TeamKills_localization",
		})
	end,
	packages = {},
}

