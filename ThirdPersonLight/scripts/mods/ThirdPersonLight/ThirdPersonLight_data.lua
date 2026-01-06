local mod = get_mod("ThirdPersonLight")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "enable_light",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "light_intensity",
				type = "numeric",
				default_value = 20,
				range = {1, 100},
				decimals_number = 0,
			},
			{
				setting_id = "light_range",
				type = "numeric",
				default_value = 30,
				range = {5, 100},
				decimals_number = 0,
			},
			{
				setting_id = "light_angle",
				type = "numeric",
				default_value = 35,
				range = {10, 90},
				decimals_number = 0,
			},
			{
				setting_id = "cast_shadows",
				type = "checkbox",
				default_value = true,
			},
		}
	}
}

