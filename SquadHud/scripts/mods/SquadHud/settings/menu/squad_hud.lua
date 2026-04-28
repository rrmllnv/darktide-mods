local mod = get_mod("SquadHud")

local Defaults = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/defaults")

if type(Defaults) ~= "table" then
	Defaults = {}
end

local function d(key, fallback)
	local value = Defaults[key]

	if value ~= nil then
		return value
	end

	return fallback
end

return {
	setting_id = "squadhud_elements_group",
	type = "group",
	title = "squadhud_elements_group",
	sub_widgets = {
		{
			setting_id = "squadhud_show_class_icon",
			type = "checkbox",
			title = "squadhud_show_class_icon",
			default_value = d("squadhud_show_class_icon", true),
		},
		{
			setting_id = "squadhud_show_ability_icon",
			type = "checkbox",
			title = "squadhud_show_ability_icon",
			default_value = d("squadhud_show_ability_icon", true),
		},
		{
			setting_id = "squadhud_coherency_group",
			type = "group",
			title = "squadhud_coherency_group",
			sub_widgets = {
				{
					setting_id = "squadhud_show_teammate_distance",
					type = "checkbox",
					title = "squadhud_show_teammate_distance",
					tooltip_text = "squadhud_show_teammate_distance_description",
					default_value = d("squadhud_show_teammate_distance", true),
				},
			},
		},
		{
			setting_id = "squadhud_inventory_group",
			type = "group",
			title = "squadhud_inventory_group",
			sub_widgets = {
				{
					setting_id = "squadhud_show_grenade",
					type = "checkbox",
					title = "squadhud_show_grenade",
					default_value = d("squadhud_show_grenade", true),
				},
				{
					setting_id = "squadhud_show_ammo",
					type = "checkbox",
					title = "squadhud_show_ammo",
					default_value = d("squadhud_show_ammo", true),
				},
				{
					setting_id = "squadhud_show_stimm",
					type = "checkbox",
					title = "squadhud_show_stimm",
					default_value = d("squadhud_show_stimm", true),
				},
				{
					setting_id = "squadhud_show_medical_crate",
					type = "checkbox",
					title = "squadhud_show_medical_crate",
					default_value = d("squadhud_show_medical_crate", true),
				},
				{
					setting_id = "squadhud_show_ammo_crate",
					type = "checkbox",
					title = "squadhud_show_ammo_crate",
					default_value = d("squadhud_show_ammo_crate", true),
				},
			},
		},
		{
			setting_id = "squadhud_health_toughness_group",
			type = "group",
			title = "squadhud_health_toughness_group",
			sub_widgets = {
				{
					setting_id = "squadhud_show_health_value",
					type = "checkbox",
					title = "squadhud_show_health_value",
					default_value = d("squadhud_show_health_value", true),
				},
				{
					setting_id = "squadhud_show_toughness_value",
					type = "checkbox",
					title = "squadhud_show_toughness_value",
					default_value = d("squadhud_show_toughness_value", true),
				},
			},
		},
	},
}
