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

local POSITION_RANGE_X = { 0, 1920 }
local POSITION_RANGE_Y = { 0, 1080 }

return {
	setting_id = "squadhud_layout_group",
	type = "group",
	title = "squadhud_layout_group",
	sub_widgets = {
		{
			setting_id = "squadhud_enabled",
			type = "checkbox",
			title = "squadhud_enabled",
			tooltip_text = "squadhud_enabled_description",
			default_value = d("squadhud_enabled", true),
		},
		{
			setting_id = "squadhud_placement",
			type = "group",
			title = "squadhud_placement",
			sub_widgets = {
				{
					setting_id = "position_x",
					type = "numeric",
					title = "position_x",
					tooltip_text = "position_x_description",
					default_value = d("position_x", 50),
					range = POSITION_RANGE_X,
					decimals_number = 0,
				},
				{
					setting_id = "position_y",
					type = "numeric",
					title = "position_y",
					tooltip_text = "position_y_description",
					default_value = d("position_y", 800),
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
