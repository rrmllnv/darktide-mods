local mod = get_mod("SquadHud")

local function panel_scenegraph_id(panel)
	local data = panel and panel._data

	return data and data.scenegraph_id or nil
end

local function panel_is_team_handler_local_player(panel)
	return panel_scenegraph_id(panel) == "local_player"
end

local function panel_is_team_handler_teammate(panel)
	local scenegraph_id = panel_scenegraph_id(panel)

	return scenegraph_id == "player_1" or scenegraph_id == "player_2" or scenegraph_id == "player_3"
end

mod.squadhud_vanilla_hud_apply_settings = function(setting_id)
	local relevant = setting_id == "squadhud_reset_all_settings"
		or setting_id == "hide_vanilla_team_panel_local"
		or setting_id == "hide_vanilla_team_panel_teammates"

	if not relevant then
		return
	end
end

local function hook_local_player_panel_draw(class_name)
	mod:hook(class_name, "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
		local settings = mod._settings

		if type(settings) == "table" and settings.hide_vanilla_team_panel_local == true and panel_is_team_handler_local_player(self) then
			return
		end

		return func(self, dt, t, ui_renderer, render_settings, input_service)
	end)
end

local function hook_teammate_panel_draw(class_name)
	mod:hook(class_name, "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
		local settings = mod._settings

		if type(settings) == "table" and settings.hide_vanilla_team_panel_teammates == true and panel_is_team_handler_teammate(self) then
			return
		end

		return func(self, dt, t, ui_renderer, render_settings, input_service)
	end)
end

hook_local_player_panel_draw("HudElementPersonalPlayerPanel")
hook_local_player_panel_draw("HudElementPersonalPlayerPanelHub")
hook_teammate_panel_draw("HudElementTeamPlayerPanel")
hook_teammate_panel_draw("HudElementTeamPlayerPanelHub")

return mod
