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
	setting_id = "divisionhud_super_system",
	type = "group",
	title = "divisionhud_super_system",
	sub_widgets = {
		{
			setting_id = "debug",
			type = "checkbox",
			title = "debug",
			tooltip_text = "debug_description",
			default_value = d("debug", false),
		},
		{
			setting_id = "divisionhud_reset_all_settings",
			type = "dropdown",
			default_value = 0,
			title = "divisionhud_reset_all_settings",
			tooltip_text = "divisionhud_reset_all_settings_description",
			options = {
				{
					text = "",
					value = 0,
				},
				{
					text = "divisionhud_reset_confirm",
					value = 1,
				},
			},
		},
	},
}
