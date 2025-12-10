local mod = get_mod("TargetHunter")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "enable_bosses",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "enable_elites",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "max_distance",
				type = "numeric",
				default_value = 40,
				range = {10, 100},
			},
		},
	},
}


