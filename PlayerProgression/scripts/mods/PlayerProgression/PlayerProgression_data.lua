local mod = get_mod("PlayerProgression")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "keybindings_supergroup",
				type = "group",
				title = "i18n_keybindings_section",
				sub_widgets = {
					{
						setting_id = "hotkeys_group",
						type = "group",
						title = "i18n_hotkeys_section",
						sub_widgets = {
							{
								setting_id = "keybind_toggle_stats",
								type = "keybind",
								default_value = {},
								keybind_global = false,
								keybind_trigger = "pressed",
								keybind_type = "function_call",
								function_name = "toggle_stats_display",
							},
						},
					},
				},
			},
			{
				setting_id = "controller_supergroup",
				type = "group",
				title = "i18n_controller_section",
				sub_widgets = {
					{
						setting_id = "playstation_group",
						type = "group",
						title = "i18n_playstation_section",
						sub_widgets = {
							{
								setting_id = "playstation_controller_button",
								type = "dropdown",
								default_value = "default",
								title = "playstation_controller_button",
								tooltip_text = "playstation_controller_button_description",
								options = {
									{ text = "playstation_controller_button_default", value = "default" },
									{ text = "playstation_controller_button_l1", value = "ps4_controller_l1" },
									{ text = "playstation_controller_button_l2", value = "ps4_controller_l2" },
									{ text = "playstation_controller_button_l3", value = "ps4_controller_l3" },
									{ text = "playstation_controller_button_r1", value = "ps4_controller_r1" },
									{ text = "playstation_controller_button_r2", value = "ps4_controller_r2" },
									{ text = "playstation_controller_button_r3", value = "ps4_controller_r3" },
									{ text = "playstation_controller_button_triangle", value = "ps4_controller_triangle" },
									{ text = "playstation_controller_button_circle", value = "ps4_controller_circle" },
									{ text = "playstation_controller_button_cross", value = "ps4_controller_cross" },
									{ text = "playstation_controller_button_square", value = "ps4_controller_square" },
									{ text = "playstation_controller_button_d_up", value = "ps4_controller_d_up" },
									{ text = "playstation_controller_button_d_down", value = "ps4_controller_d_down" },
									{ text = "playstation_controller_button_d_left", value = "ps4_controller_d_left" },
									{ text = "playstation_controller_button_d_right", value = "ps4_controller_d_right" },
									{ text = "playstation_controller_button_options", value = "ps4_controller_options" },
									{ text = "playstation_controller_button_touch", value = "ps4_controller_touch" },
								},
							},
						},
					},
					{
						setting_id = "xbox_group",
						type = "group",
						title = "i18n_xbox_section",
						sub_widgets = {
							{
								setting_id = "xbox_controller_button",
								type = "dropdown",
								default_value = "default",
								title = "xbox_controller_button",
								tooltip_text = "xbox_controller_button_description",
								options = {
									{ text = "xbox_controller_button_default", value = "default" },
									{ text = "xbox_controller_button_left_shoulder", value = "xbox_controller_left_shoulder" },
									{ text = "xbox_controller_button_left_trigger", value = "xbox_controller_left_trigger" },
									{ text = "xbox_controller_button_left_thumb", value = "xbox_controller_left_thumb" },
									{ text = "xbox_controller_button_right_shoulder", value = "xbox_controller_right_shoulder" },
									{ text = "xbox_controller_button_right_trigger", value = "xbox_controller_right_trigger" },
									{ text = "xbox_controller_button_right_thumb", value = "xbox_controller_right_thumb" },
									{ text = "xbox_controller_button_y", value = "xbox_controller_y" },
									{ text = "xbox_controller_button_x", value = "xbox_controller_x" },
									{ text = "xbox_controller_button_a", value = "xbox_controller_a" },
									{ text = "xbox_controller_button_b", value = "xbox_controller_b" },
									{ text = "xbox_controller_button_d_up", value = "xbox_controller_d_up" },
									{ text = "xbox_controller_button_d_down", value = "xbox_controller_d_down" },
									{ text = "xbox_controller_button_d_left", value = "xbox_controller_d_left" },
									{ text = "xbox_controller_button_d_right", value = "xbox_controller_d_right" },
									{ text = "xbox_controller_button_start", value = "xbox_controller_start" },
									{ text = "xbox_controller_button_back", value = "xbox_controller_back" },
								},
							},
						},
					},
				},
			},
			{
				setting_id = "group_system_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "reset_selected_items",
						type = "dropdown",
						default_value = 0,
						options = {
							{ text = "", value = 0 },
							{ text = "reset_selected_items", value = 1 },
						},
					},
				},
			},
		},
	},
}


