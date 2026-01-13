return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`CopyChatMessage` encountered an error loading the Darktide Mod Framework.")

		new_mod("CopyChatMessage", {
			mod_script       = "CopyChatMessage/scripts/mods/CopyChatMessage/CopyChatMessage",
			mod_data         = "CopyChatMessage/scripts/mods/CopyChatMessage/CopyChatMessage_data",
			mod_localization = "CopyChatMessage/scripts/mods/CopyChatMessage/CopyChatMessage_localization",
		})
	end,
	packages = {},
}
