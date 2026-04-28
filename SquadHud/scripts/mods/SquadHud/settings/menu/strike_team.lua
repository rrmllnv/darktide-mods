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

local function status_checkbox(setting_id)
	return {
		setting_id = setting_id,
		type = "checkbox",
		title = setting_id,
		tooltip_text = setting_id .. "_description",
		default_value = d(setting_id, true),
	}
end

return {
	setting_id = "squadhud_strike_team_group",
	type = "group",
	title = "squadhud_strike_team_group",
	sub_widgets = {
		status_checkbox("squadhud_show_status_rescuing"),
		status_checkbox("squadhud_show_status_reviving"),
		status_checkbox("squadhud_show_status_rescue_available"),
		status_checkbox("squadhud_show_status_dead"),
		status_checkbox("squadhud_show_status_unconscious"),
		status_checkbox("squadhud_show_status_disabled"),
		status_checkbox("squadhud_show_status_pounced"),
		status_checkbox("squadhud_show_status_netted"),
		status_checkbox("squadhud_show_status_warp_grabbed"),
		status_checkbox("squadhud_show_status_vortex_grabbed"),
		status_checkbox("squadhud_show_status_mutant_charged"),
		status_checkbox("squadhud_show_status_consumed"),
		status_checkbox("squadhud_show_status_grabbed"),
		status_checkbox("squadhud_show_status_ledge_hanging"),
		status_checkbox("squadhud_show_status_critical_health"),
		status_checkbox("squadhud_show_status_luggable"),
	},
}
