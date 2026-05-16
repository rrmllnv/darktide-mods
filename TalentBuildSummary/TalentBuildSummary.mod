return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TalentBuildSummary` encountered an error loading the Darktide Mod Framework.")

		new_mod("TalentBuildSummary", {
			mod_script = "TalentBuildSummary/scripts/mods/TalentBuildSummary/TalentBuildSummary",
			mod_data = "TalentBuildSummary/scripts/mods/TalentBuildSummary/TalentBuildSummary_data",
			mod_localization = "TalentBuildSummary/scripts/mods/TalentBuildSummary/TalentBuildSummary_localization",
		})
	end,
	packages = {},
}

