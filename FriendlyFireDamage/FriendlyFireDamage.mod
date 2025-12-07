return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`FriendlyFireDamage` encountered an error loading the Darktide Mod Framework.")

		new_mod("FriendlyFireDamage", {
			mod_script       = "FriendlyFireDamage/scripts/mods/FriendlyFireDamage/FriendlyFireDamage",
			mod_data         = "FriendlyFireDamage/scripts/mods/FriendlyFireDamage/FriendlyFireDamage_data",
			mod_localization = "FriendlyFireDamage/scripts/mods/FriendlyFireDamage/FriendlyFireDamage_localization",
		})
	end,
	packages = {},
}

