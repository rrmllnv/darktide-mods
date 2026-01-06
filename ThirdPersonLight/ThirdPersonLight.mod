return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ThirdPersonLight` encountered an error loading the Darktide Mod Framework.")

		new_mod("ThirdPersonLight", {
			mod_script       = "ThirdPersonLight/scripts/mods/ThirdPersonLight/ThirdPersonLight",
			mod_data         = "ThirdPersonLight/scripts/mods/ThirdPersonLight/ThirdPersonLight_data",
			mod_localization = "ThirdPersonLight/scripts/mods/ThirdPersonLight/ThirdPersonLight_localization",
		})
	end,
	packages = {},
}

