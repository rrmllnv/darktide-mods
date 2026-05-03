return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`CharacterMenuReorder` encountered an error loading the Darktide Mod Framework.")

		new_mod("CharacterMenuReorder", {
			mod_script       = "CharacterMenuReorder/scripts/mods/CharacterMenuReorder/CharacterMenuReorder",
			mod_data         = "CharacterMenuReorder/scripts/mods/CharacterMenuReorder/CharacterMenuReorder_data",
			mod_localization = "CharacterMenuReorder/scripts/mods/CharacterMenuReorder/CharacterMenuReorder_localization",
		})
	end,
	packages = {},
}

