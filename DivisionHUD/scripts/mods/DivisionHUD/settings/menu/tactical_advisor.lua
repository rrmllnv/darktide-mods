local mod = get_mod("DivisionHUD")

local Defaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/defaults")

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

return {
	setting_id = "divisionhud_super_tactical_advisor",
	type = "group",
	title = "divisionhud_super_tactical_advisor",
	sub_widgets = {
		{
			setting_id = "tactical_advisor_enabled",
			type = "checkbox",
			title = "tactical_advisor_enabled",
			tooltip_text = "tactical_advisor_enabled_description",
			default_value = d("tactical_advisor_enabled", true),
		},
		{
			setting_id = "tactical_advisor_blink_intensity",
			type = "numeric",
			title = "tactical_advisor_blink_intensity",
			tooltip_text = "tactical_advisor_blink_intensity_description",
			default_value = d("tactical_advisor_blink_intensity", 100),
			range = { 25, 200 },
			decimals_number = 0,
		},
		{
			setting_id = "tactical_advisor_ammo_group",
			type = "group",
			title = "tactical_advisor_ammo_group",
			tooltip_text = "tactical_advisor_ammo_group_description",
			sub_widgets = {
				{
					setting_id = "tactical_advisor_low_ammo_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_ammo_enabled",
					tooltip_text = "tactical_advisor_low_ammo_enabled_description",
					default_value = d("tactical_advisor_low_ammo_enabled", true),
				},
				{
					setting_id = "tactical_advisor_low_ammo_threshold",
					type = "numeric",
					title = "tactical_advisor_low_ammo_threshold",
					tooltip_text = "tactical_advisor_low_ammo_threshold_description",
					default_value = d("tactical_advisor_low_ammo_threshold", 25),
					range = { 0, 100 },
					decimals_number = 0,
				},
				{
					setting_id = "tactical_advisor_low_ammo_alert_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_ammo_alert_enabled",
					tooltip_text = "tactical_advisor_low_ammo_alert_enabled_description",
					default_value = d("tactical_advisor_low_ammo_alert_enabled", true),
				},
			},
		},
		{
			setting_id = "tactical_advisor_health_group",
			type = "group",
			title = "tactical_advisor_health_group",
			tooltip_text = "tactical_advisor_health_group_description",
			sub_widgets = {
				{
					setting_id = "tactical_advisor_low_health_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_health_enabled",
					tooltip_text = "tactical_advisor_low_health_enabled_description",
					default_value = d("tactical_advisor_low_health_enabled", true),
				},
				{
					setting_id = "tactical_advisor_low_health_threshold",
					type = "numeric",
					title = "tactical_advisor_low_health_threshold",
					tooltip_text = "tactical_advisor_low_health_threshold_description",
					default_value = d("tactical_advisor_low_health_threshold", 25),
					range = { 0, 100 },
					decimals_number = 0,
				},
				{
					setting_id = "tactical_advisor_low_health_alert_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_health_alert_enabled",
					tooltip_text = "tactical_advisor_low_health_alert_enabled_description",
					default_value = d("tactical_advisor_low_health_alert_enabled", true),
				},
			},
		},
		{
			setting_id = "tactical_advisor_wounds_group",
			type = "group",
			title = "tactical_advisor_wounds_group",
			tooltip_text = "tactical_advisor_wounds_group_description",
			sub_widgets = {
				{
					setting_id = "tactical_advisor_low_wounds_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_wounds_enabled",
					tooltip_text = "tactical_advisor_low_wounds_enabled_description",
					default_value = d("tactical_advisor_low_wounds_enabled", true),
				},
				{
					setting_id = "tactical_advisor_low_wounds_threshold",
					type = "numeric",
					title = "tactical_advisor_low_wounds_threshold",
					tooltip_text = "tactical_advisor_low_wounds_threshold_description",
					default_value = d("tactical_advisor_low_wounds_threshold", 1),
					range = { 1, 5 },
					decimals_number = 0,
				},
				{
					setting_id = "tactical_advisor_low_wounds_alert_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_wounds_alert_enabled",
					tooltip_text = "tactical_advisor_low_wounds_alert_enabled_description",
					default_value = d("tactical_advisor_low_wounds_alert_enabled", true),
				},
			},
		},
		{
			setting_id = "tactical_advisor_corruption_group",
			type = "group",
			title = "tactical_advisor_corruption_group",
			tooltip_text = "tactical_advisor_corruption_group_description",
			sub_widgets = {
				{
					setting_id = "tactical_advisor_high_corruption_enabled",
					type = "checkbox",
					title = "tactical_advisor_high_corruption_enabled",
					tooltip_text = "tactical_advisor_high_corruption_enabled_description",
					default_value = d("tactical_advisor_high_corruption_enabled", true),
				},
				{
					setting_id = "tactical_advisor_high_corruption_threshold",
					type = "numeric",
					title = "tactical_advisor_high_corruption_threshold",
					tooltip_text = "tactical_advisor_high_corruption_threshold_description",
					default_value = d("tactical_advisor_high_corruption_threshold", 25),
					range = { 0, 100 },
					decimals_number = 0,
				},
				{
					setting_id = "tactical_advisor_high_corruption_alert_enabled",
					type = "checkbox",
					title = "tactical_advisor_high_corruption_alert_enabled",
					tooltip_text = "tactical_advisor_high_corruption_alert_enabled_description",
					default_value = d("tactical_advisor_high_corruption_alert_enabled", true),
				},
			},
		},
		{
			setting_id = "tactical_advisor_grenade_group",
			type = "group",
			title = "tactical_advisor_grenade_group",
			tooltip_text = "tactical_advisor_grenade_group_description",
			sub_widgets = {
				{
					setting_id = "tactical_advisor_low_grenade_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_grenade_enabled",
					tooltip_text = "tactical_advisor_low_grenade_enabled_description",
					default_value = d("tactical_advisor_low_grenade_enabled", true),
				},
				{
					setting_id = "tactical_advisor_low_grenade_threshold",
					type = "numeric",
					title = "tactical_advisor_low_grenade_threshold",
					tooltip_text = "tactical_advisor_low_grenade_threshold_description",
					default_value = d("tactical_advisor_low_grenade_threshold", 35),
					range = { 0, 100 },
					decimals_number = 0,
				},
				{
					setting_id = "tactical_advisor_low_grenade_alert_enabled",
					type = "checkbox",
					title = "tactical_advisor_low_grenade_alert_enabled",
					tooltip_text = "tactical_advisor_low_grenade_alert_enabled_description",
					default_value = d("tactical_advisor_low_grenade_alert_enabled", true),
				},
			},
		},
	},
}
