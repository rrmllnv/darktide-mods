return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`EffectAggregate` encountered an error loading the Darktide Mod Framework.")

		new_mod("EffectAggregate", {
			mod_script       = "EffectAggregate/scripts/mods/EffectAggregate/EffectAggregate",
			mod_data         = "EffectAggregate/scripts/mods/EffectAggregate/EffectAggregate_data",
			mod_localization = "EffectAggregate/scripts/mods/EffectAggregate/EffectAggregate_localization",
		})
	end,
	packages = {},
}

