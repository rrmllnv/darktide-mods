local mod = get_mod("ThirdPersonLight")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "enabled",
				type          = "checkbox",
				default_value = true,
				title         = mod:localize("enabled"),
			},
			{
				setting_id      = "light_intensity",
				type            = "numeric",
				default_value   = 5.0,
				range           = { 0.1, 20.0 },
				decimals_number = 1,
				title           = mod:localize("light_intensity"),
			},
			{
				setting_id      = "light_radius",
				type            = "numeric",
				default_value   = 10.0,
				range           = { 1.0, 50.0 },
				decimals_number = 1,
				title           = mod:localize("light_radius"),
			},
			{
				setting_id      = "light_color_r",
				type            = "numeric",
				default_value   = 255,
				range           = { 0, 255 },
				decimals_number = 0,
				title           = mod:localize("light_color_r"),
			},
			{
				setting_id      = "light_color_g",
				type            = "numeric",
				default_value   = 255,
				range           = { 0, 255 },
				decimals_number = 0,
				title           = mod:localize("light_color_g"),
			},
			{
				setting_id      = "light_color_b",
				type            = "numeric",
				default_value   = 255,
				range           = { 0, 255 },
				decimals_number = 0,
				title           = mod:localize("light_color_b"),
			},
			{
				setting_id    = "only_in_darkness",
				type          = "checkbox",
				default_value = false,
				title         = mod:localize("only_in_darkness"),
			},
		}
	}
}

