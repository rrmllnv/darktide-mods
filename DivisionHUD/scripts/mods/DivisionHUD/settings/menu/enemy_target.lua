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
	setting_id = "divisionhud_super_enemy_target",
	type = "group",
	title = "divisionhud_super_enemy_target",
	sub_widgets = {
		{
			setting_id = "enemy_target_enabled",
			type = "checkbox",
			title = "enemy_target_enabled",
			tooltip_text = "enemy_target_enabled_description",
			default_value = d("enemy_target_enabled", true),
		},
		{
			setting_id = "enemy_target_sources",
			type = "group",
			title = "enemy_target_sources",
			tooltip_text = "enemy_target_sources_description",
			sub_widgets = {
				{
					setting_id = "enemy_target_show_on_hover",
					type = "checkbox",
					title = "enemy_target_show_on_hover",
					tooltip_text = "enemy_target_show_on_hover_description",
					default_value = d("enemy_target_show_on_hover", false),
				},
				{
					setting_id = "enemy_target_show_on_hit",
					type = "checkbox",
					title = "enemy_target_show_on_hit",
					tooltip_text = "enemy_target_show_on_hit_description",
					default_value = d("enemy_target_show_on_hit", true),
				},
			},
		},
		{
			setting_id = "enemy_target_hold_time",
			type = "numeric",
			title = "enemy_target_hold_time",
			tooltip_text = "enemy_target_hold_time_description",
			default_value = d("enemy_target_hold_time", 5),
			range = { 1, 15 },
			decimals_number = 0,
		},
		{
			setting_id = "enemy_target_groups",
			type = "group",
			title = "enemy_target_groups",
			tooltip_text = "enemy_target_groups_description",
			sub_widgets = {
				{
					setting_id = "enemy_target_show_boss",
					type = "checkbox",
					title = "enemy_target_show_boss",
					tooltip_text = "enemy_target_show_boss_description",
					default_value = d("enemy_target_show_boss", true),
				},
				{
					setting_id = "enemy_target_show_elite",
					type = "checkbox",
					title = "enemy_target_show_elite",
					tooltip_text = "enemy_target_show_elite_description",
					default_value = d("enemy_target_show_elite", false),
				},
				{
					setting_id = "enemy_target_show_special",
					type = "checkbox",
					title = "enemy_target_show_special",
					tooltip_text = "enemy_target_show_special_description",
					default_value = d("enemy_target_show_special", false),
				},
			},
		},
	},
}
