local mod = get_mod("CompassBar")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "hud_display",
				type = "group",
				title = "mod_compass_bar_hud_display_title",
				sub_widgets = {
					{
						setting_id = "width",
						type = "numeric",
						default_value = 600,
						range = {300, 1200},
						title = "mod_compass_bar_width_title",
						tooltip = "mod_compass_bar_width_description",
					},
					{
						setting_id = "opacity",
						type = "numeric",
						default_value = 100,
						range = {0, 100},
						title = "mod_compass_bar_opacity_title",
						tooltip = "mod_compass_bar_opacity_description",
					},
				},
			},
			{
				setting_id = "display",
				type = "group",
				title = "mod_compass_bar_display_title",
				sub_widgets = {
					{
						setting_id = "show_in_hub",
						type = "checkbox",
						default_value = false,
						title = "mod_compass_bar_show_in_hub_title",
						tooltip = "mod_compass_bar_show_in_hub_description",
					},
					{
						setting_id = "show_in_psykhanium",
						type = "checkbox",
						default_value = false,
						title = "mod_compass_bar_show_in_psykhanium_title",
						tooltip = "mod_compass_bar_show_in_psykhanium_description",
					},
					{
						setting_id = "show_in_mission",
						type = "checkbox",
						default_value = true,
						title = "mod_compass_bar_show_in_mission_title",
						tooltip = "mod_compass_bar_show_in_mission_description",
					},
				},
			},
		},
	},
}
