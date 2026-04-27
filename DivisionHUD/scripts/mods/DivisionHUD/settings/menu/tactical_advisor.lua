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
	},
}
