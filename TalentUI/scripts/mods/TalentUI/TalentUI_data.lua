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
				setting_id = "group_teammate_weapon_primary",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_teammate_weapon_primary_icon",
						type = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id = "group_teammate_weapon_secondary",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_teammate_weapon_secondary_icon",
						type = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id = "group_teammate_ability_common",
				type = "group",
				sub_widgets = {
					{
						setting_id = "teammate_ability_vertical_offset",
						type = "numeric",
						default_value = -10,
						range = { -50, 100 },
						decimals_number = 0,
					},
					{
						setting_id = "teammate_ability_horizontal_offset",
						type = "numeric",
						default_value = 0,
						range = { -50, 400 },
						decimals_number = 0,
					},
					{
						setting_id = "teammate_ability_orientation",
						type = "dropdown",
						default_value = "vertical",
						options = {
							{ text = "vertical", value = "vertical" },
							{ text = "horizontal", value = "horizontal" },
						},
					},
					{
						setting_id = "teammate_ability_text_alignment",
						type = "dropdown",
						default_value = "left",
						options = {
							{ text = "left", value = "left" },
							{ text = "top", value = "top" },
							{ text = "right", value = "right" },
							{ text = "bottom", value = "bottom" },
							{ text = "center", value = "center" },
						},
					},
					{
						setting_id = "teammate_ability_cooldown_font_size",
						type = "numeric",
						default_value = 12,
						range = { 10, 30 },
						decimals_number = 0,
					},
					{
						setting_id = "teammate_ability_icon_size",
						type = "numeric",
						default_value = 33,
						range = { 30, 100 },
						decimals_number = 0,
					},
				},
			},
			{
				setting_id = "group_teammate_weapon_common",
				type = "group",
				sub_widgets = {
					{
						setting_id = "teammate_weapon_vertical_offset",
						type = "numeric",
						default_value = 20,
						range = { -50, 350 },
						decimals_number = 0,
					},
					{
						setting_id = "teammate_weapon_horizontal_offset",
						type = "numeric",
						default_value = 330,
						range = { -50, 400 },
						decimals_number = 0,
					},
					{
						setting_id = "teammate_weapon_orientation",
						type = "dropdown",
						default_value = "vertical",
						options = {
							{ text = "vertical", value = "vertical" },
							{ text = "horizontal", value = "horizontal" },
						},
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
			{
				setting_id = "reset_talent_ui_settings",
				type = "dropdown",
				default_value = 0,
				options = {
					{ text = "", value = 0 },
					{ text = "reset_talent_ui_settings", value = 1 },
				},
			},
		},
	},
}

