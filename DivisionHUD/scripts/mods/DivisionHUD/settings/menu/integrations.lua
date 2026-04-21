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
	setting_id = "divisionhud_super_integrations",
	type = "group",
	title = "divisionhud_integrations",
	sub_widgets = {
		{
			setting_id = "integration_custom_hud",
			type = "checkbox",
			title = "integration_custom_hud",
			tooltip_text = "integration_custom_hud_description",
			default_value = d("integration_custom_hud", false),
		},
		{
			setting_id = "integration_stimm_countdown",
			type = "checkbox",
			title = "integration_stimm_countdown",
			tooltip_text = "integration_stimm_countdown_description",
			default_value = d("integration_stimm_countdown", true),
		},
		{
			setting_id = "integration_recolor_stimms",
			type = "checkbox",
			title = "integration_recolor_stimms",
			tooltip_text = "integration_recolor_stimms_description",
			default_value = d("integration_recolor_stimms", false),
		},
	},
}
