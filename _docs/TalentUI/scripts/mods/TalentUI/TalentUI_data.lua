local mod = get_mod("TalentUI")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "group_teammate_ability",
				type = "group",
				sub_widgets = {
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
				},
			},
			{
				setting_id = "group_teammate_blitz",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_teammate_blitz_icon",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "show_teammate_blitz_charges",
						type = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id = "group_teammate_aura",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_teammate_aura_icon",
						type = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id = "group_local_player",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_local_ability_cooldown",
						type = "checkbox",
						default_value = false,
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
						setting_id = "local_cooldown_font_size",
						type = "numeric",
						default_value = 40,
						range = { 30, 50 },
						decimals_number = 0,
					},
				},
			},
		},
	},
}

