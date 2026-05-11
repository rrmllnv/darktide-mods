return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MelksContractTimer` encountered an error loading the Darktide Mod Framework.")

		new_mod("MelksContractTimer", {
			mod_script = "MelksContractTimer/scripts/mods/MelksContractTimer/MelksContractTimer",
			mod_data = "MelksContractTimer/scripts/mods/MelksContractTimer/MelksContractTimer_data",
			mod_localization = "MelksContractTimer/scripts/mods/MelksContractTimer/MelksContractTimer_localization",
		})
	end,
	packages = {},
}

