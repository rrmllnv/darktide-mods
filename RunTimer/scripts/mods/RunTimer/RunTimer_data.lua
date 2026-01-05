local mod = get_mod("RunTimer")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			{
				setting_id = "timer_format",
				type = "dropdown",
				default_value = 2,
				options = {
					{text = "timer_format_minutes", value = 1},
					{text = "timer_format_minutes_seconds", value = 2},
					{text = "timer_format_minutes_seconds_ms", value = 3},
				},
			},
			{
				setting_id = "exclude_intro_time",
				type = "dropdown",
				default_value = 1,
				options = {
					{text = "exclude_intro_time_disabled", value = 1},
					{text = "exclude_intro_time_enabled", value = 2},
				},
			},
			{
				setting_id = "timer_position",
				type = "dropdown",
				default_value = "left",
				options = {
					{text = "timer_position_left", value = "left"},
					{text = "timer_position_center", value = "center"},
					{text = "timer_position_right", value = "right"},
				},
			},
			{
				setting_id = "show_background",
				type = "dropdown",
				default_value = 1,
				options = {
					{text = "show_background_show", value = 1},
					{text = "show_background_hide", value = 2},
				},
			},
			{
				setting_id = "font_color",
				type = "dropdown",
				default_value = "orange",
				options = {
					{text = "color_white", value = "white"},
					{text = "color_red", value = "red"},
					{text = "color_green", value = "green"},
					{text = "color_blue", value = "blue"},
					{text = "color_yellow", value = "yellow"},
					{text = "color_orange", value = "orange"},
					{text = "color_purple", value = "purple"},
					{text = "color_cyan", value = "cyan"},
					{text = "color_teal", value = "teal"},
					{text = "color_gold", value = "gold"},
					{text = "color_purple_deep", value = "purple_deep"},
					{text = "color_magenta", value = "magenta"},
					{text = "color_orange_dark", value = "orange_dark"},
					{text = "color_orange_medium", value = "orange_medium"},
					{text = "color_amber", value = "amber"},
					{text = "color_grey", value = "grey"},
				},
			},
			{
				setting_id = "font_size",
				type = "numeric",
				default_value = 20,
				range = {
					15,
					25,
				},
			},
			{
				setting_id = "opacity",
				type = "numeric",
				default_value = 100,
				range = {0, 100},
			},
			{
				setting_id = "group_speedometer",
				type = "group",
				sub_widgets = {
					{
						setting_id = "speedometer_enabled",
						type = "checkbox",
						default_value = false,
					},
				},
			},
		},
	},
}


