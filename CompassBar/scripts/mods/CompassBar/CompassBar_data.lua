local mod = get_mod("CompassBar")

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
				title = mod:localize("mod_compass_bar_enabled_title"),
				tooltip = mod:localize("mod_compass_bar_enabled_description"),
			},
			{
				setting_id = "position_y",
				type = "numeric",
				default_value = 20,
				range = {0, 400},
				title = mod:localize("mod_compass_bar_position_y_title"),
				tooltip = mod:localize("mod_compass_bar_position_y_description"),
			},
			{
				setting_id = "width",
				type = "numeric",
				default_value = 600,
				range = {300, 1200},
				title = mod:localize("mod_compass_bar_width_title"),
				tooltip = mod:localize("mod_compass_bar_width_description"),
			},
			{
				setting_id = "opacity",
				type = "numeric",
				default_value = 100,
				range = {0, 100},
				title = mod:localize("mod_compass_bar_opacity_title"),
				tooltip = mod:localize("mod_compass_bar_opacity_description"),
			},
		},
	},
}
