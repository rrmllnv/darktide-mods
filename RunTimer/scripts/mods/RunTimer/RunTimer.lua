local mod = get_mod("RunTimer")

local Missions = require("scripts/settings/mission/mission_templates")
local Danger = require("scripts/utilities/danger")
local CircumstanceTemplates = nil

pcall(function()
	CircumstanceTemplates = require("scripts/settings/circumstance/circumstance_templates")
end)

mod._run_timer_chat_end_time = nil
mod._run_timer_chat_has_printed = false
mod._run_timer_chat_outcome = nil
mod._run_timer_chat_intro_seen = false

local NON_MISSION_GAME_MODES = {
	hub = true,
	prologue_hub = true,
	shooting_range = true,
}

local function is_in_mission_game_mode()
	local gm = Managers.state and Managers.state.game_mode

	if not gm or not gm.game_mode_name then
		return false
	end

	return not NON_MISSION_GAME_MODES[gm:game_mode_name()]
end

local function try_localize(key)
	local ok, s = pcall(function()
		return Managers.localization:localize(key)
	end)

	if ok and s and s ~= key and not s:match("^<") then
		return s
	end

	return nil
end

local function get_circumstance_display_name(circumstance_name)
	local base = circumstance_name:gsub("^mutator_", "")

	if CircumstanceTemplates and CircumstanceTemplates[circumstance_name] then
		local tpl = CircumstanceTemplates[circumstance_name]

		if tpl.display_name then
			local loc = try_localize(tpl.display_name)

			if loc then
				return loc
			end
		end

		if type(tpl.ui) == "table" then
			for _, field in ipairs({"display_name", "title", "name", "description"}) do
				if tpl.ui[field] then
					local loc = try_localize(tpl.ui[field])

					if loc then
						return loc
					end
				end
			end
		end

		if tpl.wwise_state then
			local wwise_base = tpl.wwise_state:gsub("_%d+$", "")
			local wwise_attempts = {
				"loc_circumstance_" .. wwise_base .. "_title",
				"loc_circumstance_" .. wwise_base .. "_name",
				"loc_" .. wwise_base .. "_title",
				"loc_" .. wwise_base,
			}

			for _, loc_key in ipairs(wwise_attempts) do
				local loc = try_localize(loc_key)

				if loc then
					return loc
				end
			end

			local clean_wwise = wwise_base:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest)
				return first:upper() .. rest:lower()
			end)

			if clean_wwise and #clean_wwise > 0 then
				return clean_wwise
			end
		end
	end

	local loc_attempts = {
		"loc_circumstance_" .. circumstance_name .. "_title",
		"loc_circumstance_" .. circumstance_name .. "_name",
		"loc_circumstance_" .. base .. "_title",
		"loc_circumstance_" .. base .. "_name",
		"loc_havoc_" .. base .. "_name",
		"loc_havoc_mutator_" .. base .. "_name",
		"loc_" .. circumstance_name .. "_title",
		"loc_" .. circumstance_name,
		"loc_" .. base,
	}

	for _, loc_key in ipairs(loc_attempts) do
		local loc = try_localize(loc_key)

		if loc then
			return loc
		end
	end

	local clean = base

	clean = clean:gsub("_mission_%d+$", "")
	clean = clean:gsub("^high_", ""):gsub("^low_", ""):gsub("^med_", "")
	clean = clean:gsub("_", " ")
	clean = clean:gsub("(%a)([%w]*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)

	return clean
end

local function get_mission_info_for_chat()
	local mech = Managers.mechanism and Managers.mechanism._mechanism
	local d = mech and mech._mechanism_data

	if not d then
		return "Unknown Mission", "?"
	end

	local tpl = Missions[d.mission_name]
	local m_name = tpl and Localize(tpl.mission_name) or "Unknown"
	local diff = Danger.danger_by_difficulty(d.challenge, d.resistance) or {}
	local d_name = diff.display_name and Localize(diff.display_name) or "?"
	local havoc_data = d.havoc_data

	if havoc_data and type(havoc_data) == "string" and havoc_data ~= "" then
		local rank = havoc_data:match("^[^;]+;([^;]+)")

		if rank and tonumber(rank) then
			d_name = "Havoc " .. rank
		end
	else
		local circumstance = d.circumstance_name

		if circumstance and circumstance ~= "default" and circumstance ~= "" then
			local circ_display = get_circumstance_display_name(circumstance)

			d_name = d_name .. ", " .. circ_display
		end
	end

	return m_name, d_name
end

local function format_chat_run_time(run_seconds)
	local fmt = mod:get("timer_format") or 2
	local minutes_total = run_seconds / 60
	local minutes_floor = math.floor(minutes_total)
	local seconds = math.floor(run_seconds % 60)
	local milliseconds = math.floor((run_seconds - math.floor(run_seconds)) * 1000)

	if fmt == 1 then
		return string.format("%02d", minutes_floor)
	elseif fmt == 3 then
		return string.format("%02d:%02d:%03d", minutes_floor, seconds, milliseconds)
	end

	return string.format("%02d:%02d", minutes_floor, seconds)
end

local function run_timer_chat_try_print()
	if not mod:get("chat_completion_message") then
		return
	end

	if not is_in_mission_game_mode() then
		return
	end

	if mod._run_timer_chat_has_printed then
		return
	end

	if not mod._run_timer_chat_end_time then
		return
	end

	local run_time = mod._run_timer_chat_end_time

	if (mod:get("exclude_intro_time") or 1) == 2 and mod._intro_end_time and mod._intro_end_time > 0 then
		run_time = run_time - mod._intro_end_time
	end

	if run_time < 0 then
		run_time = 0
	end

	local time_str = format_chat_run_time(run_time)
	local mission_name, difficulty = get_mission_info_for_chat()
	local blue_name = string.format("{#color(150,180,255)}%s{#reset()}", mission_name)
	local green_time = string.format("{#color(50,255,50)}%s{#reset()}", time_str)
	local result_word = (mod._run_timer_chat_outcome == "lost") and "failed" or "completed"

	mod:echo(string.format("%s (%s) %s in %s", blue_name, difficulty, result_word, green_time))
	mod._run_timer_chat_has_printed = true
end

local hud_elements = {
	{
		filename = "RunTimer/scripts/mods/RunTimer/HudElementRunTimer",
		class_name = "HudElementRunTimer",
		visibility_groups = {
			"alive",
		},
	},
}

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	for _, hud_element in ipairs(hud_elements) do
		if not table.find_by_key(elements, "class_name", hud_element.class_name) then
			table.insert(elements, {
				class_name = hud_element.class_name,
				filename = hud_element.filename,
				use_hud_scale = true,
				visibility_groups = hud_element.visibility_groups or {
					"alive",
				},
			})
		end
	end

	return func(self, elements, visibility_groups, params)
end)

-- Переменная для хранения времени окончания intro
mod._intro_end_time = nil

-- Хук на init системы - проверяем есть ли intro вообще
mod:hook_safe("CinematicSceneSystem", "init", function(self, extension_init_context, system_init_data)
	-- Проверяем что мы на миссии, а не в хабе
	local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
	local is_in_hub = not game_mode_name or game_mode_name == "hub"

	if is_in_hub then
		return
	end

	if self._skip_intro_cinematic then
		-- Если intro пропущен (нет в миссии) - устанавливаем 0
		mod._intro_end_time = 0
	else
		-- Intro есть, ждем его окончания
		mod._intro_end_time = nil
	end

	mod._run_timer_chat_end_time = nil
	mod._run_timer_chat_has_printed = false
	mod._run_timer_chat_outcome = nil
	mod._run_timer_chat_intro_seen = false
end)

-- Хук на update CinematicManager — intro для таймера; outro для сообщения в чат (логика как в MissionSpeedrunTimer).
mod:hook("CinematicManager", "update", function(func, self, dt, t)
	local story = self._active_story
	local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
	local is_in_hub = not game_mode_name or game_mode_name == "hub"

	if story and not is_in_hub then
		local scene_name = story.cinematic_scene_name

		if scene_name == "intro_abc" then
			mod._run_timer_chat_intro_seen = true
			local story_id = story.story_id
			local story_time = self._storyteller:time(story_id)
			local length = self._storyteller:length(story_id)
			local story_done = length < story_time

			if story_done and mod._intro_end_time == nil and Managers.time and Managers.time:has_timer("gameplay") then
				mod._intro_end_time = Managers.time:time("gameplay")
			end
		elseif scene_name ~= "intro_abc"
			and mod._intro_end_time ~= nil
			and mod._run_timer_chat_end_time == nil
		then
			if Managers.time and Managers.time:has_timer("gameplay") then
				mod._run_timer_chat_end_time = Managers.time:time("gameplay")

				if scene_name == "outro_win" then
					mod._run_timer_chat_outcome = "won"
				elseif scene_name == "outro_fail" then
					mod._run_timer_chat_outcome = "lost"
				else
					local mech = Managers.mechanism and Managers.mechanism._mechanism
					local mech_data = mech and mech._mechanism_data
					local end_result = mech_data and mech_data.end_result

					if end_result == "won" or end_result == true then
						mod._run_timer_chat_outcome = "won"
					elseif end_result ~= nil then
						mod._run_timer_chat_outcome = "lost"
					end
				end

				run_timer_chat_try_print()
			end
		end
	end

	return func(self, dt, t)
end)

mod:hook_safe("GameModeManager", "_set_end_conditions_met", function(self, outcome, ...)
	if not is_in_mission_game_mode() then return end
	if mod._run_timer_chat_has_printed or mod._run_timer_chat_end_time ~= nil then return end

	if outcome == "won" or outcome == true then
		mod._run_timer_chat_outcome = "won"
	else
		mod._run_timer_chat_outcome = "lost"
	end

	if Managers.time and Managers.time:has_timer("gameplay") then
		mod._run_timer_chat_end_time = Managers.time:time("gameplay")
	end

	run_timer_chat_try_print()
end)

local LATE_JOIN_GAMEPLAY_THRESHOLD = 15

mod.update = function(_dt)
	if mod._intro_end_time ~= nil then return end
	if mod._run_timer_chat_intro_seen then return end
	if not Managers.time or not Managers.time:has_timer("gameplay") then return end
	if not is_in_mission_game_mode() then return end

	local gameplay_time = Managers.time:time("gameplay")

	if gameplay_time >= LATE_JOIN_GAMEPLAY_THRESHOLD then
		mod._intro_end_time = 0
	end
end

function mod.on_setting_changed(setting_id)
	if not mod._run_timer_hud_element then
		return
	end

	if setting_id == "font_type" or setting_id == "font_size" or setting_id == "font_color" or setting_id == "opacity" then
		if setting_id == "font_type" or setting_id == "font_size" then
			mod._run_timer_hud_element._cached_timer_text_column_width = nil
			mod._run_timer_hud_element._timer_width_style_key = nil
		end
		mod._run_timer_hud_element:_apply_style()
		if setting_id == "font_type" or setting_id == "font_size" then
			mod._run_timer_hud_element:_apply_layout()
		end
	elseif setting_id == "timer_position" or setting_id == "timer_vertical_position" then
		mod._run_timer_hud_element:_apply_layout()
	elseif setting_id == "timer_background" then
		mod._run_timer_hud_element:_apply_layout()
		mod._run_timer_hud_element:_apply_style()
	elseif setting_id == "timer_format" then
		mod._run_timer_hud_element._cached_timer_format = mod:get("timer_format") or 2
		mod._run_timer_hud_element._cached_timer_text_column_width = nil
		mod._run_timer_hud_element._timer_width_style_key = nil
		mod._run_timer_hud_element:_apply_style()
		mod._run_timer_hud_element:_apply_layout()
	elseif setting_id == "exclude_intro_time" then
		mod._run_timer_hud_element._cached_exclude_intro = mod:get("exclude_intro_time") or 1
	end
end

