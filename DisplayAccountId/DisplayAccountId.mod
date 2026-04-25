return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`DisplayAccountId` encountered an error loading the Darktide Mod Framework.")

		new_mod("DisplayAccountId", {
			mod_script = "DisplayAccountId/scripts/mods/DisplayAccountId/DisplayAccountId",
			mod_data = "DisplayAccountId/scripts/mods/DisplayAccountId/DisplayAccountId_data",
			mod_localization = "DisplayAccountId/scripts/mods/DisplayAccountId/DisplayAccountId_localization",
		})
	end,
	packages = {},
}
