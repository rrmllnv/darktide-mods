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
	setting_id = "divisionhud_super_proximity",
	type = "group",
	title = "divisionhud_super_proximity",
	sub_widgets = {
		{
			setting_id = "proximity_enabled",
			type = "checkbox",
			title = "proximity_enabled",
			tooltip_text = "proximity_enabled_description",
			default_value = d("proximity_enabled", true),
		},
		{
			setting_id = "proximity_radius",
			type = "numeric",
			title = "proximity_radius",
			tooltip_text = "proximity_radius_description",
			default_value = d("proximity_radius", 15),
			range = { 5, 30 },
			decimals_number = 0,
		},
		{
			setting_id = "proximity_show_medical_station",
			type = "checkbox",
			title = "proximity_show_medical_station",
			tooltip_text = "proximity_show_medical_station_description",
			default_value = d("proximity_show_medical_station", true),
		},
		{
			setting_id = "proximity_show_medical",
			type = "checkbox",
			title = "proximity_show_medical",
			tooltip_text = "proximity_show_medical_description",
			default_value = d("proximity_show_medical", true),
		},
		{
			setting_id = "proximity_show_medical_deployed",
			type = "checkbox",
			title = "proximity_show_medical_deployed",
			tooltip_text = "proximity_show_medical_deployed_description",
			default_value = d("proximity_show_medical_deployed", true),
		},
		{
			setting_id = "proximity_show_stimm",
			type = "checkbox",
			title = "proximity_show_stimm",
			tooltip_text = "proximity_show_stimm_description",
			default_value = d("proximity_show_stimm", true),
		},
		{
			setting_id = "proximity_show_ammo_small",
			type = "checkbox",
			title = "proximity_show_ammo_small",
			tooltip_text = "proximity_show_ammo_small_description",
			default_value = d("proximity_show_ammo_small", true),
		},
		{
			setting_id = "proximity_show_ammo_large",
			type = "checkbox",
			title = "proximity_show_ammo_large",
			tooltip_text = "proximity_show_ammo_large_description",
			default_value = d("proximity_show_ammo_large", true),
		},
		{
			setting_id = "proximity_show_ammo_crate",
			type = "checkbox",
			title = "proximity_show_ammo_crate",
			tooltip_text = "proximity_show_ammo_crate_description",
			default_value = d("proximity_show_ammo_crate", true),
		},
		{
			setting_id = "proximity_show_ammo_crate_deployed",
			type = "checkbox",
			title = "proximity_show_ammo_crate_deployed",
			tooltip_text = "proximity_show_ammo_crate_deployed_description",
			default_value = d("proximity_show_ammo_crate_deployed", true),
		},
		{
			setting_id = "proximity_show_grenade",
			type = "checkbox",
			title = "proximity_show_grenade",
			tooltip_text = "proximity_show_grenade_description",
			default_value = d("proximity_show_grenade", true),
		},
		{
			setting_id = "proximity_show_grimoire",
			type = "checkbox",
			title = "proximity_show_grimoire",
			tooltip_text = "proximity_show_grimoire_description",
			default_value = d("proximity_show_grimoire", true),
		},
		{
			setting_id = "proximity_show_tome",
			type = "checkbox",
			title = "proximity_show_tome",
			tooltip_text = "proximity_show_tome_description",
			default_value = d("proximity_show_tome", true),
		},
	},
}
