local mod = get_mod("CharacterMenuReorder")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	allow_rehooking = false,
	options = {
		widgets = {
			{
				setting_id = "general_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "enabled",
						type = "checkbox",
						default_value = true,
						tooltip_text = "enabled_description",
					},
				},
			},
		},
	},
}

