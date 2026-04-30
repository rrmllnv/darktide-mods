local mod = get_mod("SquadHud")

return {
	setting_id = "squadhud_expanded_view_group",
	type = "group",
	title = "squadhud_expanded_view_group",
	sub_widgets = {
		{
			setting_id = "squadhud_expanded_view_mode",
			type = "dropdown",
			title = "squadhud_expanded_view_mode",
			tooltip_text = "squadhud_expanded_view_mode_description",
			default_value = "full",
			options = {
				{
					text = "squadhud_expanded_view_mode_short",
					value = "short",
				},
				{
					text = "squadhud_expanded_view_mode_full",
					value = "full",
				},
			},
		},
		{
			setting_id = "squadhud_expanded_view_keybind",
			type = "keybind",
			title = "squadhud_expanded_view_keybind",
			tooltip_text = "squadhud_expanded_view_keybind_description",
			default_value = {
				"left ctrl",
			},
			keybind_trigger = "held",
			keybind_type = "function_call",
			function_name = "squadhud_expanded_view_keybind",
		},
		{
			setting_id = "squadhud_expanded_view_keybind_mode",
			type = "dropdown",
			title = "squadhud_expanded_view_keybind_mode",
			tooltip_text = "squadhud_expanded_view_keybind_mode_description",
			default_value = "hold",
			options = {
				{
					text = "squadhud_expanded_view_keybind_mode_toggle",
					value = "toggle",
				},
				{
					text = "squadhud_expanded_view_keybind_mode_hold",
					value = "hold",
				},
			},
		},
	},
}
