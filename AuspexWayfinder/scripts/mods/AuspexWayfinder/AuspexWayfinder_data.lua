local mod = get_mod("AuspexWayfinder")

local color_options = {
	{ text = "awf_color_warp_high", value = "ui_hud_warp_charge_high" },
	{ text = "awf_color_header", value = "terminal_text_header" },
	{ text = "awf_color_body", value = "terminal_text_body" },
	{ text = "awf_color_red_light", value = "ui_hud_red_light" },
	{ text = "awf_color_red_medium", value = "ui_hud_red_medium" },
	{ text = "awf_color_orange", value = "ui_orange_light" },
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "path_enabled",
				type = "checkbox",
				default_value = true,
				title = "path_enabled",
			},
			{
				setting_id = "path_propagation_box",
				type = "numeric",
				default_value = 120,
				range = { 20, 400 },
				decimals = 0,
				title = "path_propagation_box",
				tooltip_text = "path_propagation_box_description",
			},
			{
				setting_id = "path_line_thickness",
				type = "numeric",
				default_value = 0,
				range = { 0, 5 },
				decimals = 1,
				title = "path_line_thickness",
			},
			{
				setting_id = "path_height",
				type = "numeric",
				default_value = 0.25,
				range = { 0, 3 },
				decimals = 2,
				title = "path_height",
			},
			{
				setting_id = "path_color",
				type = "dropdown",
				default_value = "ui_hud_warp_charge_high",
				options = color_options,
				title = "path_color",
			},
			{
				setting_id = "path_echo_on_fail",
				type = "checkbox",
				default_value = true,
				title = "path_echo_on_fail",
			},
		},
	},
}
