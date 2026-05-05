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
	setting_id = "robocophud_super_scanner",
	type = "group",
	title = "scanner_group",
	sub_widgets = {
		{
			setting_id = "scanner_enabled",
			type = "checkbox",
			default_value = d("scanner_enabled", true),
		},
		{
			setting_id = "scanner_passive",
			type = "checkbox",
			default_value = d("scanner_passive", true),
		},
		{
			setting_id = "scanner_manual_pulse_keybind",
			type = "keybind",
			default_value = {},
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "robocophud_scanner_manual_pulse_keybind",
		},
		{
			setting_id = "scanner_sweep_seconds",
			type = "numeric",
			default_value = d("scanner_sweep_seconds", 2.0),
			range = { 0.25, 10.0 },
			decimals_number = 2,
		},
		{
			setting_id = "scanner_range_m",
			type = "numeric",
			default_value = d("scanner_range_m", 80.0),
			range = { 5.0, 120.0 },
			decimals_number = 1,
		},
		{
			setting_id = "scanner_max_blips",
			type = "numeric",
			default_value = d("scanner_max_blips", 24),
			range = { 1, 24 },
			decimals_number = 0,
		},
		{
			setting_id = "scanner_blip_fade_seconds",
			type = "numeric",
			default_value = d("scanner_blip_fade_seconds", 1.0),
			range = { 0.0, 5.0 },
			decimals_number = 2,
		},
		{
			setting_id = "scanner_offset_x",
			type = "numeric",
			default_value = d("scanner_offset_x", 0),
			range = { -960, 960 },
			decimals_number = 0,
		},
		{
			setting_id = "scanner_offset_y",
			type = "numeric",
			default_value = d("scanner_offset_y", 0),
			range = { -540, 540 },
			decimals_number = 0,
		},
	},
}

