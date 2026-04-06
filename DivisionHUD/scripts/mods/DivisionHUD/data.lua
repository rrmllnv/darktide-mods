local mod = get_mod("DivisionHUD")

local Defaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/settings_defaults")

if type(Defaults) ~= "table" then
	Defaults = {}
end

local function d(key, fallback)
	local v = Defaults[key]

	if v ~= nil then
		return v
	end

	return fallback
end

local POSITION_RANGE_X = { -960, 960 }
local POSITION_RANGE_Y = { -540, 540 }

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "divisionhud_super_layout",
				type = "group",
				title = "divisionhud_super_layout",
				sub_widgets = {
					{
						setting_id = "position_x",
						type = "numeric",
						title = "position_x",
						tooltip_text = "position_x_description",
						default_value = d("position_x", 400),
						range = POSITION_RANGE_X,
						decimals_number = 0,
					},
					{
						setting_id = "position_y",
						type = "numeric",
						title = "position_y",
						tooltip_text = "position_y_description",
						default_value = d("position_y", 200),
						range = POSITION_RANGE_Y,
						decimals_number = 0,
					},
					{
						setting_id = "opacity",
						type = "numeric",
						default_value = d("opacity", 1.0),
						range = { 0.1, 1.0 },
						decimals_number = 1,
					},
				},
			},
			{
				setting_id = "divisionhud_super_bars",
				type = "group",
				title = "divisionhud_super_bars",
				sub_widgets = {
					{
						setting_id = "show_stamina_bar",
						type = "checkbox",
						default_value = d("show_stamina_bar", true),
					},
					{
						setting_id = "show_toughness_bar",
						type = "checkbox",
						default_value = d("show_toughness_bar", true),
					},
					{
						setting_id = "show_health_bar",
						type = "checkbox",
						default_value = d("show_health_bar", true),
					},
					{
						setting_id = "show_ability_timer",
						type = "checkbox",
						default_value = d("show_ability_timer", true),
					},
				},
			},
			{
				setting_id = "divisionhud_super_dynamic",
				type = "group",
				title = "divisionhud_super_dynamic",
				sub_widgets = {
					{
						setting_id = "dynamic_hud",
						type = "checkbox",
						default_value = d("dynamic_hud", true),
					},
					{
						setting_id = "dynamic_hud_strength",
						type = "numeric",
						default_value = d("dynamic_hud_strength", 110),
						range = { 0, 320 },
						decimals_number = 0,
					},
					{
						setting_id = "dynamic_hud_pitch_ratio",
						type = "numeric",
						default_value = d("dynamic_hud_pitch_ratio", 1),
						range = { 0.0, 2.0 },
						decimals_number = 2,
					},
					{
						setting_id = "dynamic_hud_decay",
						type = "numeric",
						default_value = d("dynamic_hud_decay", 11),
						range = { 2, 28 },
						decimals_number = 0,
					},
					{
						setting_id = "dynamic_hud_max_offset",
						type = "numeric",
						default_value = d("dynamic_hud_max_offset", 100),
						range = { 8, 220 },
						decimals_number = 0,
					},
				},
			},
			{
				setting_id = "divisionhud_super_vanilla_hide",
				type = "group",
				title = "divisionhud_super_vanilla_hide",
				sub_widgets = {
					{
						setting_id = "hide_vanilla_team_panel_local",
						type = "checkbox",
						default_value = d("hide_vanilla_team_panel_local", false),
					},
					{
						setting_id = "hide_vanilla_stamina_area",
						type = "checkbox",
						default_value = d("hide_vanilla_stamina_area", true),
					},
					{
						setting_id = "hide_vanilla_dodge_area",
						type = "checkbox",
						default_value = d("hide_vanilla_dodge_area", true),
					},
					{
						setting_id = "hide_vanilla_weapon_pivot",
						type = "checkbox",
						default_value = d("hide_vanilla_weapon_pivot", false),
					},
					{
						setting_id = "hide_vanilla_combat_ability_slot",
						type = "checkbox",
						default_value = d("hide_vanilla_combat_ability_slot", false),
					},
					{
						setting_id = "hide_vanilla_player_buffs_background",
						type = "checkbox",
						default_value = d("hide_vanilla_player_buffs_background", false),
					},
				},
			},
			{
				setting_id = "divisionhud_super_integrations",
				type = "group",
				title = "divisionhud_integrations",
				sub_widgets = {
					{
						setting_id = "integration_custom_hud",
						type = "checkbox",
						title = "integration_custom_hud",
						tooltip_text = "integration_custom_hud_description",
						default_value = d("integration_custom_hud", false),
					},
				},
			},
			{
				setting_id = "divisionhud_super_system",
				type = "group",
				title = "divisionhud_super_system",
				sub_widgets = {
					{
						setting_id = "divisionhud_reset_all_settings",
						type = "dropdown",
						default_value = 0,
						title = "divisionhud_reset_all_settings",
						tooltip_text = "divisionhud_reset_all_settings_description",
						options = {
							{
								text = "",
								value = 0,
							},
							{
								text = "divisionhud_reset_confirm",
								value = 1,
							},
						},
					},
				},
			},
		},
	},
}
