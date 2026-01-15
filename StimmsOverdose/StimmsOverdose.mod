return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`StimmsOverdose` encountered an error loading the Darktide Mod Framework.")

		new_mod("StimmsOverdose", {
			mod_script = "StimmsOverdose/scripts/mods/StimmsOverdose/StimmsOverdose",
			mod_data = "StimmsOverdose/scripts/mods/StimmsOverdose/StimmsOverdose_data",
			mod_localization = "StimmsOverdose/scripts/mods/StimmsOverdose/StimmsOverdose_localization",
		})
	end,
	packages = {},
}
