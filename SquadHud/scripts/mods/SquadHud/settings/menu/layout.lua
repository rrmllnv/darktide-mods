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
	},
}
