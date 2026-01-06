local mod = get_mod("ConsoleLog")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "toggle_visibility",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "kb_toggle_visibility",
			},
			{
				setting_id = "enabled",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "max_lines",
				type = "numeric",
				default_value = 20,
				range = {5, 50},
			},
			{
				setting_id = "font_size",
				type = "numeric",
				default_value = 16,
				range = {10, 24},
			},
			{
				setting_id = "position",
				type = "dropdown",
				default_value = "top_left",
				options = {
					{text = "position_top_left", value = "top_left"},
					{text = "position_top_right", value = "top_right"},
					{text = "position_bottom_left", value = "bottom_left"},
					{text = "position_bottom_right", value = "bottom_right"},
				},
			},
			{
				setting_id = "background_opacity",
				type = "numeric",
				default_value = 200,
				range = {0, 255},
			},
		},
	},
}

