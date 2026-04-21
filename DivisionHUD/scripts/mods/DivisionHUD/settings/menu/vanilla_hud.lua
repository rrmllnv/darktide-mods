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
			default_value = d("hide_vanilla_player_buffs_background", true),
		},
		{
			setting_id = "hide_vanilla_mission_objectives",
			type = "checkbox",
			title = "hide_vanilla_mission_objectives",
			tooltip_text = "hide_vanilla_mission_objectives_description",
			default_value = d("hide_vanilla_mission_objectives", true),
		},
	},
}
