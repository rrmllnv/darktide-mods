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
		{
			setting_id = "stimm_slot_icon_tint_by_type",
			type = "checkbox",
			title = "stimm_slot_icon_tint_by_type",
			tooltip_text = "stimm_slot_icon_tint_by_type_description",
			default_value = d("stimm_slot_icon_tint_by_type", true),
		},
		{
			setting_id = "ammo_text_color_by_fraction",
			type = "checkbox",
			title = "ammo_text_color_by_fraction",
			tooltip_text = "ammo_text_color_by_fraction_description",
			default_value = d("ammo_text_color_by_fraction", true),
		},
		{
			setting_id = "grenade_color_by_fraction",
			type = "checkbox",
			title = "grenade_color_by_fraction",
			tooltip_text = "grenade_color_by_fraction_description",
			default_value = d("grenade_color_by_fraction", true),
		},
		{
			setting_id = "wielded_weapon_icon_state_colors",
			type = "checkbox",
			title = "wielded_weapon_icon_state_colors",
			tooltip_text = "wielded_weapon_icon_state_colors_description",
			default_value = d("wielded_weapon_icon_state_colors", true),
		},
		{
			setting_id = "buff_rows_enabled",
			type = "checkbox",
			title = "buff_rows_enabled",
			tooltip_text = "buff_rows_enabled_description",
			default_value = d("buff_rows_enabled", true),
		},
		{
			setting_id = "main_strip_background_fill",
			type = "dropdown",
			title = "main_strip_background_fill",
			tooltip_text = "main_strip_background_fill_description",
			default_value = d("main_strip_background_fill", 0),
			options = {
				{
					text = "main_strip_background_fill_weapon_hud_plain",
					value = 0,
				},
				{
					text = "main_strip_background_fill_weapon_hud",
					value = 1,
				},
				{
					text = "main_strip_background_fill_terminal",
					value = 2,
				},
				{
					text = "main_strip_background_fill_black",
					value = 3,
				},
			},
		},
		{
			setting_id = "proximity_strip_background_fill",
			type = "dropdown",
			title = "proximity_strip_background_fill",
			tooltip_text = "proximity_strip_background_fill_description",
			default_value = d("proximity_strip_background_fill", 1),
			options = {
				{
					text = "main_strip_background_fill_weapon_hud",
					value = 0,
				},
				{
					text = "main_strip_background_fill_terminal",
					value = 1,
				},
				{
					text = "main_strip_background_fill_black",
					value = 2,
				},
			},
		},
	},
}
