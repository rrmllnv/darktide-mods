local mod = get_mod("ThirdPersonAimCorrection")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "general_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "enable_mod",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "only_third_person",
						type = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id = "correction_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "max_distance",
						type = "numeric",
						default_value = 100,
						range = { 10, 150 },
						decimals_number = 0,
						unit = "m",
					},
				},
			},
		},
	},
}
