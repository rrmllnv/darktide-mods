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
		{
			setting_id = "dynamic_hud_freeze_on_ads",
			type = "checkbox",
			title = "dynamic_hud_freeze_on_ads",
			tooltip_text = "dynamic_hud_freeze_on_ads_description",
			default_value = d("dynamic_hud_freeze_on_ads", true),
		},
	},
}
