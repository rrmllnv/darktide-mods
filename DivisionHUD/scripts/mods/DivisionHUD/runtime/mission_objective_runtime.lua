local mod = get_mod("DivisionHUD")

local SessionVector = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/session_vector")

if not SessionVector.can_continue() then
	return mod
end

local function alert_time_for_mission_strip()
	local Hu = mod.hud_utils

	if Hu and type(Hu.safe_time_for_alerts) == "function" then
		return Hu.safe_time_for_alerts()
	end

	if Hu and type(Hu.safe_gameplay_time) == "function" then
		return Hu.safe_gameplay_time()
	end

	return nil
end

local function vanilla_mission_popup_hidden()
	local s = mod._settings

	if type(s) ~= "table" then
		return false
	end

	return s.hide_vanilla_mission_objectives == true or s.hide_vanilla_mission_objectives == 1
end

local function mission_alert_setting_enabled(setting_id)
	local s = mod._settings
	local v = type(s) == "table" and s[setting_id]

	if v == false or v == 0 then
		return false
	end

	return true
end

local function objective_uses_hud(objective)
	if not objective then
		return false
	end

	if type(objective.use_hud) ~= "function" then
		return false
	end

	return objective:use_hud() == true
end

local function enqueue_mission_objective_alert(strip_label, body_text)
	local body = type(body_text) == "string" and body_text or ""

	if body == "" and type(strip_label) == "string" and strip_label ~= "" then
		body = strip_label
	end

	if body == "" then
		return
	end

	if not mod.alerts_enqueue_strip_body then
		return
	end

	local t = alert_time_for_mission_strip()

	if type(t) ~= "number" or t ~= t then
		return
	end

	mod.alerts_enqueue_strip_body(strip_label, body, t, "mission")
end

mod.divisionhud_mission_objective_apply_settings = function(setting_id)
	local relevant = setting_id == "divisionhud_reset_all_settings"
		or setting_id == "hide_vanilla_mission_objectives"
		or setting_id == "alert_mission_objective_start"
		or setting_id == "alert_mission_objective_progress"
		or setting_id == "alert_mission_objective_complete"
		or setting_id == "alert_mission_objective_custom_popup"

	if not relevant then
		return
	end

	local Hu = mod.hud_utils
	local hud_element = Hu and Hu.resolve_division_hud_instance and Hu.resolve_division_hud_instance()

	if hud_element then
		hud_element._div_alert_next_enter_t = nil
	end
end

mod:hook("HudElementMissionObjectivePopup", "event_mission_objective_start", function(func, self, objective)
	if not objective_uses_hud(objective) then
		return func(self, objective)
	end

	local alert = objective:ui_state() == "alert"
	local description_text = objective:header()
	local title_text

	if objective:title_text() and objective:title_text() ~= "" then
		title_text = objective:title_text()
	else
		title_text = alert and Localize("loc_objective_op_train_alert_header") or Localize("loc_hud_mission_objective_popup_title_start")
	end

	if type(description_text) ~= "string" then
		description_text = ""
	end

	if description_text == "" and type(objective.name) == "function" then
		local nm = objective:name()

		if type(nm) == "string" and nm ~= "" then
			description_text = nm
		end
	end

	if mission_alert_setting_enabled("alert_mission_objective_start") then
		enqueue_mission_objective_alert(title_text, description_text)
	end

	if vanilla_mission_popup_hidden() then
		return
	end

	return func(self, objective)
end)

mod:hook("HudElementMissionObjectivePopup", "event_mission_objective_update", function(func, self, objective)
	if not objective_uses_hud(objective) then
		return func(self, objective)
	end

	if mission_alert_setting_enabled("alert_mission_objective_progress") then
		if objective.show_progression_popup_on_update and objective:show_progression_popup_on_update() then
			local max_counter_amount = objective:max_incremented_progression()

			if type(max_counter_amount) == "number" and max_counter_amount ~= 0 then
				local current_counter_amount = objective:incremented_progression()
				local update_text

				if current_counter_amount and max_counter_amount then
					update_text = tostring(current_counter_amount) .. "/" .. tostring(max_counter_amount)
				end

				local description_text = objective:header()

				if type(description_text) ~= "string" then
					description_text = ""
				end

				if type(update_text) == "string" and update_text ~= "" then
					description_text = description_text .. "\n" .. update_text
				end

				local title_text = Localize("loc_hud_mission_objective_popup_title_update")

				enqueue_mission_objective_alert(title_text, description_text)
			end
		end
	end

	if vanilla_mission_popup_hidden() then
		return
	end

	return func(self, objective)
end)

mod:hook("HudElementMissionObjectivePopup", "event_mission_objective_complete", function(func, self, objective)
	if not objective_uses_hud(objective) then
		return func(self, objective)
	end

	if mission_alert_setting_enabled("alert_mission_objective_complete") then
		local description_text = objective:header()
		local title_text = Localize("loc_hud_mission_objective_popup_title_complete")

		if type(description_text) ~= "string" then
			description_text = ""
		end

		if description_text == "" and type(objective.name) == "function" then
			local nm = objective:name()

			if type(nm) == "string" and nm ~= "" then
				description_text = nm
			end
		end

		enqueue_mission_objective_alert(title_text, description_text)
	end

	if vanilla_mission_popup_hidden() then
		return
	end

	return func(self, objective)
end)

mod:hook("HudElementMissionObjectivePopup", "on_event_show_objective_popup", function(func, self, event_title, event_subtitle, ui_sound_event, style)
	if mission_alert_setting_enabled("alert_mission_objective_custom_popup") then
		local title_text = event_subtitle and Localize(event_subtitle) or ""
		local description_text = event_title and Localize(event_title) or ""

		if type(title_text) ~= "string" then
			title_text = ""
		end

		if type(description_text) ~= "string" then
			description_text = ""
		end

		if title_text ~= "" or description_text ~= "" then
			if title_text == "" then
				title_text = mod:localize("mission_objective_custom_popup_strip_fallback")
			end

			enqueue_mission_objective_alert(title_text, description_text)
		end
	end

	if vanilla_mission_popup_hidden() then
		return
	end

	return func(self, event_title, event_subtitle, ui_sound_event, style)
end)

mod:hook("HudElementMissionObjectivePopup", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and (s.hide_vanilla_mission_objectives == true or s.hide_vanilla_mission_objectives == 1) then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

mod.mission_objective_mirror_wants_alerts_ui = function()
	local s = mod._settings

	if type(s) ~= "table" then
		return false
	end

	local function mission_alert_row_enabled(setting_id)
		local v = s[setting_id]

		if v == false or v == 0 then
			return false
		end

		return true
	end

	return mission_alert_row_enabled("alert_mission_objective_start")
		or mission_alert_row_enabled("alert_mission_objective_progress")
		or mission_alert_row_enabled("alert_mission_objective_complete")
		or mission_alert_row_enabled("alert_mission_objective_custom_popup")
end

return mod
