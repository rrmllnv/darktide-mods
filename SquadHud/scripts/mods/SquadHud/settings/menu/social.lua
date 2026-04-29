local mod = get_mod("SquadHud")

return {
	setting_id = "squadhud_social_group",
	type = "group",
	title = "squadhud_social_group",
	sub_widgets = {
		{
			setting_id = "squadhud_show_account_names_keybind",
			type = "keybind",
			title = "squadhud_show_account_names_keybind",
			tooltip_text = "squadhud_show_account_names_keybind_description",
			default_value = {},
			keybind_trigger = "held",
			keybind_type = "function_call",
			function_name = "squadhud_account_names_keybind",
		},
		{
			setting_id = "squadhud_account_names_keybind_mode",
			type = "dropdown",
			title = "squadhud_account_names_keybind_mode",
			tooltip_text = "squadhud_account_names_keybind_mode_description",
			default_value = "toggle",
			options = {
				{
					text = "squadhud_account_names_keybind_mode_toggle",
					value = "toggle",
				},
				{
					text = "squadhud_account_names_keybind_mode_hold",
					value = "hold",
				},
			},
		},
	},
}
