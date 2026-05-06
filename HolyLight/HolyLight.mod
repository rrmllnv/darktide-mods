return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`HolyLight` encountered an error loading the Darktide Mod Framework.")

		new_mod("HolyLight", {
			mod_script = "HolyLight/scripts/mods/HolyLight/HolyLight",
			mod_data = "HolyLight/scripts/mods/HolyLight/HolyLight_data",
			mod_localization = "HolyLight/scripts/mods/HolyLight/HolyLight_localization",
		})
	end,
	packages = {},
}
