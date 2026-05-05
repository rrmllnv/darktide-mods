local mod = get_mod("RobocopHUD")

local Defaults = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/defaults")

if type(Defaults) ~= "table" then
	Defaults = {}
end

local function d(_key, fallback)
	return fallback
end

return {
	setting_id = "robocophud_super_warnings",
	type = "group",
	title = "warnings_group",
	sub_widgets = {
		{
			setting_id = "warnings_enabled",
			type = "checkbox",
			default_value = d("warnings_enabled", true),
		},
	},
}

