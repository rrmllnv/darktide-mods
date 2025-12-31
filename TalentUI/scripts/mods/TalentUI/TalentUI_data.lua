local mod = get_mod("TalentUI")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "show_teammate_ability_icon",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_teammate_ability_cooldown",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_local_ability_cooldown",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "cooldown_format",
				type = "dropdown",
				default_value = "time",
				options = {
					{ text = "cooldown_format_time", value = "time" },
					{ text = "cooldown_format_percent", value = "percent" },
				},
			},
			{
				setting_id = "ability_icon_size",
				type = "numeric",
				default_value = 128,
				range = { 60, 200 },
				decimals_number = 0,
			},
			{
				setting_id = "cooldown_font_size",
				type = "numeric",
				default_value = 18,
				range = { 10, 30 },
				decimals_number = 0,
			},
			{
				setting_id = "local_cooldown_font_size",
				type = "numeric",
				default_value = 40,
				range = { 30, 50 },
				decimals_number = 0,
			},
		},
	},
}

