return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`CommunicationCommandWheel` encountered an error loading the Darktide Mod Framework.")

		new_mod("CommunicationCommandWheel", {
			mod_script = "CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel",
			mod_data = "CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_data",
			mod_localization = "CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_localization",
		})
	end,
	packages = {},
}
