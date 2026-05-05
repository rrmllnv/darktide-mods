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
	setting_id = "robocophud_super_system",
	type = "group",
	title = "debug_group",
	sub_widgets = {
		{
			setting_id = "debug_overlay",
			type = "checkbox",
			default_value = d("debug_overlay", false),
		},
	},
}

