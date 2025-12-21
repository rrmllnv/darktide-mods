local mod = get_mod("PrivateModeBypass")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "enabled",
				type = "checkbox",
				default_value = true,
				title = "mod_private_mode_bypass_enabled_title",
				tooltip = "mod_private_mode_bypass_enabled_description",
			},
		},
	},
}

