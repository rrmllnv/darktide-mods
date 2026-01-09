local mod = get_mod("PlayerProgression")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "keybind_toggle_stats",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "toggle_stats_display",
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


