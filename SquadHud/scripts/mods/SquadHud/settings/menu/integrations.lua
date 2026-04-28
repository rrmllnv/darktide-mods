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
	setting_id = "squadhud_integrations_group",
	type = "group",
	title = "squadhud_integrations_group",
	sub_widgets = {
		{
			setting_id = "integration_custom_hud",
			type = "checkbox",
			title = "integration_custom_hud",
			tooltip_text = "integration_custom_hud_description",
			default_value = d("integration_custom_hud", false),
		},
	},
}
