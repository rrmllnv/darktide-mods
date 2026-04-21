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

local POSITION_RANGE_X = { -960, 960 }
local POSITION_RANGE_Y = { -540, 540 }

return {
	setting_id = "divisionhud_super_layout",
	type = "group",
	title = "divisionhud_super_layout",
	sub_widgets = {
		{
			setting_id = "divisionhud_visible",
			type = "checkbox",
			title = "divisionhud_visible",
			tooltip_text = "divisionhud_visible_description",
			default_value = d("divisionhud_visible", true),
		},
		{
			setting_id = "divisionhud_toggle_visible_keybind",
			type = "keybind",
			title = "divisionhud_toggle_visible_keybind",
			tooltip = "divisionhud_toggle_visible_keybind_description",
			default_value = {},
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "divisionhud_toggle_visible_keybind",
		},
		{
			setting_id = "divisionhud_auto_switch",
			type = "group",
			title = "divisionhud_auto_switch",
			sub_widgets = {
				{
					setting_id = "divisionhud_auto_first_person",
					type = "checkbox",
					title = "divisionhud_auto_first_person",
					tooltip_text = "divisionhud_auto_first_person_description",
					default_value = d("divisionhud_auto_first_person", true),
				},
				{
					setting_id = "divisionhud_auto_third_person",
					type = "checkbox",
					title = "divisionhud_auto_third_person",
					tooltip_text = "divisionhud_auto_third_person_description",
					default_value = d("divisionhud_auto_third_person", true),
				},
				{
					setting_id = "divisionhud_auto_slot_device",
					type = "checkbox",
					title = "divisionhud_auto_slot_device",
					tooltip_text = "divisionhud_auto_slot_device_description",
					default_value = d("divisionhud_auto_slot_device", false),
				},
			},
		},
		{
			setting_id = "divisionhud_placement",
			type = "group",
			title = "divisionhud_placement",
			sub_widgets = {
				{
					setting_id = "position_x",
					type = "numeric",
					title = "position_x",
					tooltip_text = "position_x_description",
					default_value = d("position_x", 400),
					range = POSITION_RANGE_X,
					decimals_number = 0,
				},
				{
					setting_id = "position_y",
					type = "numeric",
					title = "position_y",
					tooltip_text = "position_y_description",
					default_value = d("position_y", 200),
					range = POSITION_RANGE_Y,
					decimals_number = 0,
				},
				{
					setting_id = "opacity",
					type = "numeric",
					title = "opacity",
					default_value = d("opacity", 1.0),
					range = { 0.1, 1.0 },
					decimals_number = 1,
				},
				{
					setting_id = "hud_layout_scale",
					type = "numeric",
					title = "hud_scale",
					tooltip_text = "hud_scale_description",
					default_value = d("hud_layout_scale", 0.8),
					range = { 0.5, 2.0 },
					decimals_number = 2,
				},
			},
		},
	},
}
