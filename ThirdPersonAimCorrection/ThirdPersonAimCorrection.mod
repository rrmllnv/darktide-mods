return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ThirdPersonAimCorrection` encountered an error loading the Darktide Mod Framework.")

		new_mod("ThirdPersonAimCorrection", {
			mod_script = "ThirdPersonAimCorrection/scripts/mods/ThirdPersonAimCorrection/ThirdPersonAimCorrection",
			mod_data = "ThirdPersonAimCorrection/scripts/mods/ThirdPersonAimCorrection/ThirdPersonAimCorrection_data",
			mod_localization = "ThirdPersonAimCorrection/scripts/mods/ThirdPersonAimCorrection/ThirdPersonAimCorrection_localization",
		})
	end,
}
