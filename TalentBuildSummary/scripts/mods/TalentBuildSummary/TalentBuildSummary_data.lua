local mod = get_mod("TalentBuildSummary")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "general_group",
				type = "group",
				text = mod:localize("general_group"),
				sub_widgets = {
					{
						setting_id = "enable_mod",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "show_panel",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "debug_panel",
						type = "checkbox",
						default_value = false,
					},
				},
			},
		},
	},
}

