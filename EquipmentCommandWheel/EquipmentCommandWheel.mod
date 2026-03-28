return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`EquipmentCommandWheel` encountered an error loading the Darktide Mod Framework.")

		new_mod("EquipmentCommandWheel", {
			mod_script       = "EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel",
			mod_data         = "EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_data",
			mod_localization = "EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_localization",
		})
	end,
	packages = {},
}
