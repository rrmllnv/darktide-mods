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
	setting_id = "robocophud_super_targeting",
	type = "group",
	title = "targeting_group",
	sub_widgets = {
		{
			setting_id = "targeting_enabled",
			type = "checkbox",
			default_value = d("targeting_enabled", true),
		},
		{
			setting_id = "target_hold_seconds",
			type = "numeric",
			default_value = d("target_hold_seconds", 1.0),
			range = { 0.0, 3.0 },
			interval = 0.05,
		},
		{
			setting_id = "lock_scan_seconds",
			type = "numeric",
			default_value = d("lock_scan_seconds", 0.20),
			range = { 0.0, 1.0 },
			interval = 0.01,
		},
		{
			setting_id = "lock_track_seconds",
			type = "numeric",
			default_value = d("lock_track_seconds", 0.25),
			range = { 0.0, 1.0 },
			interval = 0.01,
		},
	},
}

