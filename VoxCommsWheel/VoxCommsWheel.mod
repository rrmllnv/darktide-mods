return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`VoxCommsWheel` encountered an error loading the Darktide Mod Framework.")

		new_mod("VoxCommsWheel", {
			mod_script       = "VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel",
			mod_data         = "VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_data",
			mod_localization = "VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_localization",
		})
	end,
	packages = {},
}

