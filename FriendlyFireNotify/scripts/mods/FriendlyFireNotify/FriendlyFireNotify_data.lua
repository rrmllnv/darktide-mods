local mod = get_mod("FriendlyFireNotify")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "min_damage_threshold",
				type = "numeric",
				default_value = 1,
				range = {1, 100},
			},
			{
				setting_id = "show_total_damage",
				type = "checkbox",
				default_value = true,
			},
		},
	},
}

