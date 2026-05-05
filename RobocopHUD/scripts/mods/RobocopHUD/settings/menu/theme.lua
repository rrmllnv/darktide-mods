local mod = get_mod("RobocopHUD")

local Defaults = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/defaults")

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
	setting_id = "robocophud_super_theme",
	type = "group",
	title = "theme_group",
	sub_widgets = {
		{
			setting_id = "theme_id",
			type = "dropdown",
			default_value = d("theme_id", "classic_green"),
			options = {
				{ text = "theme_classic_green", value = "classic_green" },
				{ text = "theme_amber_tactical", value = "amber_tactical" },
				{ text = "theme_police_blue", value = "police_blue" },
			},
		},
		{
			setting_id = "hud_opacity",
			type = "numeric",
			default_value = d("hud_opacity", 1.0),
			range = { 0.1, 1.0 },
			decimals_number = 2,
			interval = 0.05,
		},
		{
			setting_id = "hud_scale",
			type = "numeric",
			default_value = d("hud_scale", 1.0),
			range = { 0.5, 1.5 },
			decimals_number = 2,
			interval = 0.05,
		},
	},
}

