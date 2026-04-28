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

return {
	setting_id = "squadhud_system_group",
	type = "group",
	title = "squadhud_system_group",
	sub_widgets = {
		{
			setting_id = "debug",
			type = "checkbox",
			title = "debug",
			tooltip_text = "debug_description",
			default_value = d("debug", false),
		},
	},
}
