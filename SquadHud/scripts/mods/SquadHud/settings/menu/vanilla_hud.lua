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
	setting_id = "squadhud_vanilla_hud_group",
	type = "group",
	title = "squadhud_vanilla_hud_group",
	sub_widgets = {
		{
			setting_id = "hide_vanilla_team_panel_local",
			type = "checkbox",
			title = "hide_vanilla_team_panel_local",
			default_value = d("hide_vanilla_team_panel_local", true),
		},
		{
			setting_id = "hide_vanilla_team_panel_teammates",
			type = "checkbox",
			title = "hide_vanilla_team_panel_teammates",
			default_value = d("hide_vanilla_team_panel_teammates", true),
		},
	},
}
