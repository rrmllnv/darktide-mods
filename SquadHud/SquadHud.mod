return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SquadHud` encountered an error loading the Darktide Mod Framework.")

		new_mod("SquadHud", {
			mod_script       = "SquadHud/scripts/mods/SquadHud/SquadHud",
			mod_data         = "SquadHud/scripts/mods/SquadHud/data",
			mod_localization = "SquadHud/scripts/mods/SquadHud/localization",
		})
	end,
	packages = {},
}
