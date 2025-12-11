local mod = get_mod("TargetHunter")

local color_options = {}

for _, color_name in ipairs(Color.list) do
	table.insert(color_options, { text = color_name, value = color_name })
end

table.sort(color_options, function(a, b)
	return a.text < b.text
end)

local function get_color_options()
	return table.clone(color_options)
end

local function enemy_toggle(setting_id, default_enable, default_color)
	return {
		setting_id = setting_id,
		type = "checkbox",
		default_value = default_enable,
		sub_widgets = {
			-- {
			-- 	setting_id = setting_id .. "_color",
			-- 	type = "dropdown",
			-- 	default_value = default_color or "white",
			-- 	options = get_color_options(),
			-- },
		},
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "max_distance",
				type = "numeric",
				default_value = 40,
				range = { 10, 100 },
			},
			{
				setting_id = "bosses_group",
				type = "group",
				sub_widgets = {
					enemy_toggle("boss_beast_of_nurgle", true, "green"),
					enemy_toggle("boss_chaos_spawn", true, "orange"),
					enemy_toggle("boss_plague_ogryn", true, "red"),
					enemy_toggle("boss_daemonhost", true, "purple"),
					enemy_toggle("boss_renegade_captain", true, "yellow"),
					enemy_toggle("boss_renegade_twins", true, "gold"),
					enemy_toggle("boss_cultist_captain", true, "cyan"),
				},
			},
			{
				setting_id = "elites_group",
				type = "group",
				sub_widgets = {
					enemy_toggle("elite_chaos_ogryn_gunner", false, "orange"),
					enemy_toggle("elite_chaos_ogryn_executor", false, "red"),
					enemy_toggle("elite_chaos_ogryn_bulwark", false, "teal"),
					enemy_toggle("elite_renegade_shocktrooper", false, "yellow"),
					enemy_toggle("elite_renegade_plasma_gunner", false, "purple"),
					enemy_toggle("elite_renegade_radio_operator", false, "cyan"),
					enemy_toggle("elite_renegade_gunner", false, "blue"),
					enemy_toggle("elite_renegade_executor", false, "orange"),
					enemy_toggle("elite_renegade_berzerker", false, "red"),
					enemy_toggle("elite_cultist_shocktrooper", false, "yellow"),
					enemy_toggle("elite_cultist_gunner", false, "blue"),
					enemy_toggle("elite_cultist_berzerker", false, "orange"),
				},
			},
			{
				setting_id = "specials_group",
				type = "group",
				sub_widgets = {
					enemy_toggle("special_poxburster", false, "purple"),
					enemy_toggle("special_hound", false, "green"),
					enemy_toggle("special_mutant", false, "teal"),
					enemy_toggle("special_cultist_flamer", false, "orange"),
					enemy_toggle("special_cultist_grenadier", false, "red"),
					enemy_toggle("special_renegade_flamer", false, "orange"),
					enemy_toggle("special_renegade_grenadier", false, "red"),
					enemy_toggle("special_renegade_sniper", false, "cyan"),
					enemy_toggle("special_renegade_netgunner", false, "green"),
				},
			},
		},
	},
}