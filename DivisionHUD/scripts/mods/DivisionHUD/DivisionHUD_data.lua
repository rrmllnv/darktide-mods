local mod = get_mod("DivisionHUD")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "position_x",
				type = "numeric",
				default_value = 0,
				range = {-960, 960},
				decimals_number = 0,
			},
			{
				setting_id = "position_y",
				type = "numeric",
				default_value = 0,
				range = {-540, 540},
				decimals_number = 0,
			},
			{
				setting_id = "scale",
				type = "numeric",
				default_value = 1.0,
				range = {0.5, 2.0},
				decimals_number = 1,
			},
			{
				setting_id = "opacity",
				type = "numeric",
				default_value = 1.0,
				range = {0.1, 1.0},
				decimals_number = 1,
			},
			{
				setting_id = "show_stamina_bar",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_health_bar",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_ability_timer",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_ammo",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_special",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_ultimate",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_stimm",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_grenades",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_pickups",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_buffs",
				type = "checkbox",
				default_value = true,
			},
		},
	},
}

