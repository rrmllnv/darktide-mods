local mod = get_mod("DivisionHUD")

local Text = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")

local DivisionHudModderToolsDisplay = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/modder_tools_display_runtime")

local function alerts_gameplay_time()
	local Hu = mod.hud_utils

	if Hu and type(Hu.safe_time_for_alerts) == "function" then
		return Hu.safe_time_for_alerts()
	end

	if Hu and type(Hu.safe_gameplay_time) == "function" then
		return Hu.safe_gameplay_time()
	end

	return nil
end

local Breeds = require("scripts/settings/breed/breeds")

local AlertsBreedTitle = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_breed_title")
local AlertsBossBreeds = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_boss_breeds")
local AlertsSpecialistBreeds = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_specialist_breeds")

local breeds_with_menu_toggle = {}

if type(AlertsBossBreeds) == "table" and type(AlertsBossBreeds.list) == "table" then
	for i = 1, #AlertsBossBreeds.list do
		breeds_with_menu_toggle[AlertsBossBreeds.list[i]] = true
	end
end

local spawn_util = {}

spawn_util.is_monster = function(clean_brd_name)
	if Breeds[clean_brd_name] and Breeds[clean_brd_name].is_boss then
		return true
	end

	return string.match(clean_brd_name, "(.+)_wk") ~= nil
end

spawn_util.clean_breed_name = function(breed_name, is_weakened)
	local breed_name_no_mutator_marker = string.match(breed_name, "(.+)_mutator$") or breed_name
	local is_monster = spawn_util.is_monster(breed_name_no_mutator_marker)

	if string.match(breed_name_no_mutator_marker, "(.+)_flamer") then
		return "flamer"
	elseif breed_name_no_mutator_marker == "cultist_captain" then
		return "renegade_captain"
	elseif breed_name_no_mutator_marker == "renegade_twin_captain_two" then
		return "renegade_twin_captain"
	else
		if is_monster and is_weakened then
			return breed_name_no_mutator_marker .. "_wk"
		else
			return breed_name_no_mutator_marker
		end
	end
end

spawn_util.is_weakened = function(unit)
	local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
	local breed = unit_data_ext and unit_data_ext:breed()
	local is_weakened = false

	if not breed then
		return is_weakened
	end

	if not breed.is_boss or breed.ignore_weakened_boss_name then
		return is_weakened
	end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local max_health = health_extension and health_extension:max_health()
	local initial_max_health = max_health and math.floor(Managers.state.difficulty:get_minion_max_health(breed.name))

	if not initial_max_health then
		return is_weakened
	end

	if max_health < initial_max_health then
		is_weakened = true
	else
		local is_havoc = Managers.state.difficulty:get_parsed_havoc_data()

		if is_havoc then
			local havoc_extension = Managers.state.game_mode:game_mode():extension("havoc")
			local havoc_health_override_value = havoc_extension and havoc_extension:get_modifier_value("modify_monster_health")

			if havoc_health_override_value then
				local multiplied_max_health = initial_max_health + initial_max_health * havoc_health_override_value

				if max_health < multiplied_max_health then
					is_weakened = true
				end
			end
		end
	end

	return is_weakened
end

local state = {
	active = {},
	pending = {},
}

local MISSION_STRIP_MERGE_WINDOW_SEC = 0.45

local function alerts_mission_strip_string_trim(s)
	if type(s) ~= "string" then
		return ""
	end

	local trimmed = s:match("^%s*(.-)%s*$")

	return trimmed or ""
end

local function alerts_mission_body_base_for_merge(body_text)
	local t = alerts_mission_strip_string_trim(body_text)

	if t == "" then
		return ""
	end

	local stripped = string.gsub(t, "\n%d+/%d+%s*$", "")

	return stripped
end

local function alerts_mission_parse_progress_max(text)
	if type(text) ~= "string" or text == "" then
		return nil
	end

	local _cur_s, max_s = string.match(text, "(%d+)/(%d+)%s*$")

	if not max_s then
		return nil
	end

	local mx = tonumber(max_s)

	if not mx or mx < 1 then
		return nil
	end

	return mx
end

local function alerts_mission_merge_next_count(prev, incoming_body, existing_line_text)
	local next_count = prev + 1
	local max_cap = alerts_mission_parse_progress_max(incoming_body)

	if type(max_cap) ~= "number" then
		max_cap = alerts_mission_parse_progress_max(existing_line_text)
	end

	if type(max_cap) == "number" and max_cap > 0 then
		next_count = math.min(next_count, max_cap)
	end

	return next_count
end

local function alerts_mission_strip_merge_key(strip_label, body_text)
	local strip_part = alerts_mission_strip_string_trim(strip_label)
	local body_part = alerts_mission_body_base_for_merge(body_text)

	return strip_part .. "\x1e" .. body_part
end

local function alerts_mission_grouped_line_text(base_body, count)
	if type(base_body) ~= "string" or base_body == "" then
		return ""
	end

	if type(count) ~= "number" or count ~= count or count < 2 then
		return base_body
	end

	count = math.floor(count + 0.5)

	local loc = mod:localize("alerts_message_mission_objective_grouped", base_body, count)

	if type(loc) == "string" and loc ~= "" and not string.find(loc, "^<unlocalized") then
		return loc
	end

	return string.format("%s x%d", base_body, count)
end

local function alerts_try_merge_mission_strip_burst(strip_label, body_text, game_t, duration)
	if type(body_text) ~= "string" or body_text == "" then
		return false
	end

	if alerts_mission_strip_string_trim(body_text) == "" then
		return false
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return false
	end

	if type(duration) ~= "number" or duration ~= duration or duration <= 0 then
		return false
	end

	local merge_key = alerts_mission_strip_merge_key(strip_label, body_text)

	if merge_key == "" then
		return false
	end

	for i = #state.active, 1, -1 do
		local e = state.active[i]

		if type(e) == "table" and e.alert_line_category == "mission" and e.mission_merge_key == merge_key and type(e.expire_t) == "number" and game_t < e.expire_t then
			local first_t = type(e.mission_merge_first_t) == "number" and e.mission_merge_first_t or game_t

			if game_t - first_t <= MISSION_STRIP_MERGE_WINDOW_SEC then
				local prev = type(e.mission_merge_count) == "number" and e.mission_merge_count or 1
				local incoming_base = alerts_mission_body_base_for_merge(body_text)
				local next_count = alerts_mission_merge_next_count(prev, body_text, e.text)
				local base_body = type(e.mission_merge_base_body) == "string" and e.mission_merge_base_body ~= "" and e.mission_merge_base_body or incoming_base

				if incoming_base ~= "" then
					base_body = incoming_base
				end

				e.mission_merge_count = next_count
				e.mission_merge_base_body = base_body
				e.text = alerts_mission_grouped_line_text(base_body, next_count)
				e.expire_t = game_t + duration
				e.duration_sec = duration

				return true
			end
		end
	end

	for i = #state.pending, 1, -1 do
		local e = state.pending[i]

		if type(e) == "table" and e.alert_line_category == "mission" and e.mission_merge_key == merge_key then
			local first_t = type(e.mission_merge_first_t) == "number" and e.mission_merge_first_t or game_t

			if game_t - first_t <= MISSION_STRIP_MERGE_WINDOW_SEC then
				local prev = type(e.mission_merge_count) == "number" and e.mission_merge_count or 1
				local incoming_base = alerts_mission_body_base_for_merge(body_text)
				local next_count = alerts_mission_merge_next_count(prev, body_text, e.text)
				local base_body = type(e.mission_merge_base_body) == "string" and e.mission_merge_base_body ~= "" and e.mission_merge_base_body or incoming_base

				if incoming_base ~= "" then
					base_body = incoming_base
				end

				e.mission_merge_count = next_count
				e.mission_merge_base_body = base_body
				e.text = alerts_mission_grouped_line_text(base_body, next_count)
				e.duration = duration

				return true
			end
		end
	end

	return false
end

local function alerts_base_breed_from_clean(clean_breed_name)
	return string.match(clean_breed_name, "^(.+)_wk$") or clean_breed_name
end

local function alerts_globally_enabled()
	local s = mod._settings

	if type(s) ~= "table" then
		return false
	end

	local v = s.alerts_enabled

	if v == false or v == 0 then
		return false
	end

	return true
end

local function alerts_max_visible_clamped()
	local s = mod._settings
	local n = type(s) == "table" and s.alerts_max_visible

	if type(n) ~= "number" or n ~= n then
		n = 2
	end

	return math.clamp(math.floor(n + 0.5), 1, 5)
end

local function alerts_duration_sec_clamped()
	local s = mod._settings
	local d = type(s) == "table" and s.alerts_duration_sec

	if type(d) ~= "number" or d ~= d then
		d = 6
	end

	return math.clamp(d, 1, 60)
end

local function alerts_boss_category_allowed_for_base(base)
	if type(base) ~= "string" or base == "" then
		return false
	end

	local b = Breeds[base]

	if not b or b.is_boss ~= true then
		return false
	end

	if not breeds_with_menu_toggle[base] then
		return true
	end

	local s = mod._settings
	local key = "alert_boss_" .. base
	local v = type(s) == "table" and s[key]

	if v == false or v == 0 then
		return false
	end

	return true
end

local function alerts_boss_display_name(unit, raw_breed_name)
	if type(raw_breed_name) ~= "string" or raw_breed_name == "" then
		return ""
	end

	if type(AlertsBreedTitle) == "table" and type(AlertsBreedTitle.try_override) == "function" then
		local from_override = AlertsBreedTitle.try_override(mod, raw_breed_name)

		if from_override then
			return from_override
		end
	end

	local b = Breeds[raw_breed_name]

	if unit and ScriptUnit.has_extension(unit, "boss_system") then
		local boss_ext = ScriptUnit.extension(unit, "boss_system")

		if boss_ext and type(boss_ext.display_name) == "function" then
			local name_key = boss_ext:display_name()

			if type(name_key) == "string" and name_key ~= "" then
				local from_boss = Localize(name_key)

				if type(from_boss) == "string" and from_boss ~= "" then
					return from_boss
				end
			end
		end
	end

	if b and type(b.display_name) == "string" and b.display_name ~= "" then
		local from_breed = Localize(b.display_name)

		if type(from_breed) == "string" and from_breed ~= "" then
			return from_breed
		end
	end

	return raw_breed_name
end

local function alerts_boss_approach_message(display_name)
	if type(display_name) ~= "string" or display_name == "" then
		return ""
	end

	local text = mod:localize("alerts_message_boss_approach", display_name)

	if type(text) ~= "string" or text == "" then
		return string.format("Detected %s", display_name)
	end

	return text
end

local function alerts_target_message(base_text, display_name, target_display_name)
	if type(base_text) ~= "string" or base_text == "" then
		return ""
	end

	if type(target_display_name) ~= "string" or target_display_name == "" then
		return base_text
	end

	if type(display_name) ~= "string" or display_name == "" then
		return base_text
	end

	local text = mod:localize("alerts_message_spawn_target", display_name, target_display_name)

	if type(text) ~= "string" or text == "" or string.find(text, "^<unlocalized") then
		return string.format("Spotted %s, pursuing %s", display_name, target_display_name)
	end

	return text
end

local function alerts_resolve_game_session()
	local game_session_manager = Managers.state and Managers.state.game_session

	if not game_session_manager or type(game_session_manager.game_session) ~= "function" then
		return nil
	end

	local ok, game_session = pcall(function()
		return game_session_manager:game_session()
	end)

	if ok then
		return game_session
	end

	return nil
end

local function alerts_resolve_target_unit(unit)
	if not unit or not Unit.alive(unit) then
		return nil
	end

	local game_session = alerts_resolve_game_session()
	local unit_spawner = Managers.state and Managers.state.unit_spawner

	if not game_session or not unit_spawner then
		return nil
	end

	local ok_game_object_id, game_object_id = pcall(function()
		return unit_spawner:game_object_id(unit)
	end)

	if not ok_game_object_id or not game_object_id then
		return nil
	end

	local ok_has_target_unit_id, has_target_unit_id = pcall(function()
		return GameSession.has_game_object_field(game_session, game_object_id, "target_unit_id")
	end)

	if not ok_has_target_unit_id or has_target_unit_id ~= true then
		return nil
	end

	local ok_target_unit_id, target_unit_id = pcall(function()
		return GameSession.game_object_field(game_session, game_object_id, "target_unit_id")
	end)

	if
		not ok_target_unit_id
		or not target_unit_id
		or target_unit_id == NetworkConstants.invalid_game_object_id
	then
		return nil
	end

	local ok_target_unit, target_unit = pcall(function()
		return unit_spawner:unit(target_unit_id)
	end)

	if ok_target_unit and target_unit and Unit.alive(target_unit) then
		return target_unit
	end

	return nil
end

local function alerts_player_for_unit(unit)
	local player_unit_spawn_manager = Managers.state and Managers.state.player_unit_spawn

	return player_unit_spawn_manager and player_unit_spawn_manager:owner(unit) or nil
end

local function alerts_colored_player_name(player)
	if type(player) ~= "table" then
		return ""
	end

	local raw = type(player.name) == "function" and player:name() or ""

	if type(raw) ~= "string" or raw == "" then
		return ""
	end

	if DivisionHudModderToolsDisplay and type(DivisionHudModderToolsDisplay.resolve_plain_player_name) == "function" then
		raw = DivisionHudModderToolsDisplay.resolve_plain_player_name(raw, player)
	end

	if type(raw) ~= "string" or raw == "" then
		return ""
	end

	local slot = type(player.slot) == "function" and player:slot() or nil
	local colors = UISettings.player_slot_colors
	local col = slot and colors and colors[slot]

	if col then
		return Text.apply_color_to_text(raw, col)
	end

	return raw
end

local function alerts_target_display_name(unit)
	local target_unit = alerts_resolve_target_unit(unit)
	local target_player = alerts_player_for_unit(target_unit)

	return alerts_colored_player_name(target_player)
end

local function alerts_specialist_raw_stripped(raw_breed_name)
	if type(raw_breed_name) ~= "string" or raw_breed_name == "" then
		return ""
	end

	return string.match(raw_breed_name, "^(.+)_mutator$") or raw_breed_name
end

local function alerts_specialist_category_allowed(stripped_raw)
	if type(stripped_raw) ~= "string" or stripped_raw == "" then
		return false
	end

	local b = Breeds[stripped_raw]

	if not b or b.is_boss == true then
		return false
	end

	if not b.tags or b.tags.special ~= true then
		return false
	end

	local setting_id = type(AlertsSpecialistBreeds.alert_setting_id_for_stripped) == "function" and AlertsSpecialistBreeds.alert_setting_id_for_stripped(stripped_raw) or nil

	if type(setting_id) ~= "string" or setting_id == "" then
		return false
	end

	local s = mod._settings
	local v = type(s) == "table" and s[setting_id]

	if v == false or v == 0 then
		return false
	end

	return true
end

local function alerts_specialist_display_name(unit, stripped_raw, raw_breed_name)
	if type(stripped_raw) ~= "string" or stripped_raw == "" then
		return ""
	end

	if type(AlertsBreedTitle) == "table" and type(AlertsBreedTitle.try_override) == "function" then
		if type(raw_breed_name) == "string" and raw_breed_name ~= "" then
			local from_raw = AlertsBreedTitle.try_override(mod, raw_breed_name)

			if from_raw then
				return from_raw
			end
		end

		local from_stripped = AlertsBreedTitle.try_override(mod, stripped_raw)

		if from_stripped then
			return from_stripped
		end
	end

	local b = Breeds[stripped_raw]

	if unit and ScriptUnit.has_extension(unit, "boss_system") then
		local boss_ext = ScriptUnit.extension(unit, "boss_system")

		if boss_ext and type(boss_ext.display_name) == "function" then
			local name_key = boss_ext:display_name()

			if type(name_key) == "string" and name_key ~= "" then
				local from_boss = Localize(name_key)

				if type(from_boss) == "string" and from_boss ~= "" then
					return from_boss
				end
			end
		end
	end

	if b and type(b.display_name) == "string" and b.display_name ~= "" then
		local from_breed = Localize(b.display_name)

		if type(from_breed) == "string" and from_breed ~= "" then
			return from_breed
		end
	end

	return stripped_raw
end

local function alerts_specialist_approach_message(display_name)
	if type(display_name) ~= "string" or display_name == "" then
		return ""
	end

	local text = mod:localize("alerts_message_specialist_approach", display_name)

	if type(text) ~= "string" or text == "" then
		return string.format("Detected %s", display_name)
	end

	return text
end

local function alerts_spawn_line_text(category, display_name, count, target_display_name)
	if type(display_name) ~= "string" or display_name == "" then
		return ""
	end

	if type(count) ~= "number" or count ~= count or count < 1 then
		count = 1
	end

	count = math.floor(count + 0.5)

	if count <= 1 then
		local base_text

		if category == "boss" then
			base_text = alerts_boss_approach_message(display_name)
		else
			base_text = alerts_specialist_approach_message(display_name)
		end

		return alerts_target_message(base_text, display_name, target_display_name)
	end

	local loc = mod:localize("alerts_message_spawn_grouped", display_name, count)

	if type(loc) == "string" and loc ~= "" and not string.find(loc, "^<unlocalized") then
		return loc
	end

	return string.format("Detected %s x%d", display_name, count)
end

local function alerts_try_merge_spawn_group(group_key, category, display_name, game_t, duration)
	if type(group_key) ~= "string" or group_key == "" then
		return false
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return false
	end

	if type(duration) ~= "number" or duration ~= duration or duration <= 0 then
		return false
	end

	for i = #state.active, 1, -1 do
		local e = state.active[i]

		if type(e) == "table" and e.group_key == group_key and type(e.expire_t) == "number" and game_t < e.expire_t then
			local prev = type(e.spawn_count) == "number" and e.spawn_count or 1
			local next_count = prev + 1

			e.spawn_count = next_count
			e.text = alerts_spawn_line_text(category, display_name, next_count)
			e.expire_t = game_t + duration
			e.duration_sec = duration
			e.alert_line_category = category
			e.alert_instance_id = "spawn:" .. group_key
			e.spawn_source_unit = nil
			e.spawn_display_name = nil
			e.spawn_target_resolved = true

			return true
		end
	end

	for i = #state.pending, 1, -1 do
		local e = state.pending[i]

		if type(e) == "table" and e.group_key == group_key then
			local prev = type(e.spawn_count) == "number" and e.spawn_count or 1
			local next_count = prev + 1

			e.spawn_count = next_count
			e.text = alerts_spawn_line_text(category, display_name, next_count)
			e.duration = duration
			e.alert_line_category = category
			e.alert_instance_id = "spawn:" .. group_key
			e.spawn_source_unit = nil
			e.spawn_display_name = nil
			e.spawn_target_resolved = true

			return true
		end
	end

	return false
end

local function alerts_try_refresh_spawn_target_line(e)
	if type(e) ~= "table" or e.spawn_target_resolved == true then
		return
	end

	local sc = type(e.spawn_count) == "number" and e.spawn_count or 1

	if sc > 1 then
		e.spawn_source_unit = nil
		e.spawn_display_name = nil
		e.spawn_target_resolved = true

		return
	end

	local unit = e.spawn_source_unit

	if not unit or not Unit.alive(unit) then
		return
	end

	local target_display_name = alerts_target_display_name(unit)

	if type(target_display_name) ~= "string" or target_display_name == "" then
		return
	end

	local category = e.alert_line_category
	local display_name = e.spawn_display_name

	if category ~= "boss" and category ~= "specialist" then
		return
	end

	if type(display_name) ~= "string" or display_name == "" then
		return
	end

	e.text = alerts_spawn_line_text(category, display_name, 1, target_display_name)
	e.spawn_target_resolved = true
end

local function alerts_refresh_spawn_target_lines()
	for i = 1, #state.active do
		alerts_try_refresh_spawn_target_line(state.active[i])
	end

	for i = 1, #state.pending do
		alerts_try_refresh_spawn_target_line(state.pending[i])
	end
end

local function alerts_promote_from_pending(game_t)
	local max_vis = alerts_max_visible_clamped()
	local duration = alerts_duration_sec_clamped()

	while #state.active < max_vis and #state.pending > 0 do
		local p = table.remove(state.pending, 1)

		if type(p) == "table" and type(p.text) == "string" and p.text ~= "" then
			local dur = type(p.duration) == "number" and p.duration or duration
			local sc = type(p.spawn_count) == "number" and p.spawn_count or 1

			state.active[#state.active + 1] = {
				text = p.text,
				expire_t = game_t + dur,
				duration_sec = dur,
				group_key = p.group_key,
				spawn_count = sc,
				alert_line_category = p.alert_line_category,
				strip_label = p.strip_label,
				alert_instance_id = p.alert_instance_id,
				mission_merge_key = p.mission_merge_key,
				mission_merge_first_t = p.mission_merge_first_t,
				mission_merge_count = p.mission_merge_count,
				mission_merge_base_body = p.mission_merge_base_body,
				spawn_source_unit = p.spawn_source_unit,
				spawn_display_name = p.spawn_display_name,
				spawn_target_resolved = p.spawn_target_resolved,
			}
		end
	end
end

local function alerts_prune_expired(game_t)
	local i = 1

	while i <= #state.active do
		if type(state.active[i].expire_t) == "number" and game_t >= state.active[i].expire_t then
			table.remove(state.active, i)
		else
			i = i + 1
		end
	end
end

mod.alerts_clear = function()
	state.active = {}
	state.pending = {}
end

mod.alerts_prune_for_master_off_mirror = function(keep_mission, keep_team)
	if not keep_mission and not keep_team then
		return
	end

	local function alerts_mirror_keep_category(cat)
		if keep_mission and cat == "mission" then
			return true
		end

		if keep_team and cat == "team" then
			return true
		end

		return false
	end

	local i = 1

	while i <= #state.active do
		local e = state.active[i]

		if type(e) == "table" and not alerts_mirror_keep_category(e.alert_line_category) then
			table.remove(state.active, i)
		else
			i = i + 1
		end
	end

	i = 1

	while i <= #state.pending do
		local e = state.pending[i]

		if type(e) == "table" and not alerts_mirror_keep_category(e.alert_line_category) then
			table.remove(state.pending, i)
		else
			i = i + 1
		end
	end
end

mod.alerts_prune_non_mission_lines = function()
	mod.alerts_prune_for_master_off_mirror(true, false)
end

mod.alerts_sync = function(game_t)
	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)
	alerts_refresh_spawn_target_lines()
	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)
	alerts_refresh_spawn_target_lines()
end

mod.alerts_get_lines = function()
	return state.active
end

mod.alerts_enqueue = function(text, game_t)
	if not alerts_globally_enabled() then
		return
	end

	if type(text) ~= "string" or text == "" then
		return
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	local duration = alerts_duration_sec_clamped()
	local max_vis = alerts_max_visible_clamped()

	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)

	local entry = {
		text = text,
		duration = duration,
		alert_line_category = "default",
	}

	if #state.active < max_vis then
		state.active[#state.active + 1] = {
			text = text,
			expire_t = game_t + duration,
			duration_sec = duration,
			alert_line_category = "default",
		}
	else
		state.pending[#state.pending + 1] = entry
	end
end

mod.alerts_enqueue_spawn_grouped = function(group_key, category, display_name, game_t, target_display_name, source_unit)
	if not alerts_globally_enabled() then
		return
	end

	if type(group_key) ~= "string" or group_key == "" then
		return
	end

	if category ~= "boss" and category ~= "specialist" then
		return
	end

	if type(display_name) ~= "string" or display_name == "" then
		return
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	local duration = alerts_duration_sec_clamped()
	local max_vis = alerts_max_visible_clamped()

	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)

	if alerts_try_merge_spawn_group(group_key, category, display_name, game_t, duration) then
		return
	end

	local line_text = alerts_spawn_line_text(category, display_name, 1, target_display_name)

	if line_text == "" then
		return
	end

	local target_resolved = type(target_display_name) == "string" and target_display_name ~= ""
	local spawn_source_unit = target_resolved and nil or source_unit

	local entry = {
		text = line_text,
		duration = duration,
		group_key = group_key,
		spawn_count = 1,
		alert_line_category = category,
		alert_instance_id = "spawn:" .. group_key,
		spawn_source_unit = spawn_source_unit,
		spawn_display_name = display_name,
		spawn_target_resolved = target_resolved,
	}

	if #state.active < max_vis then
		state.active[#state.active + 1] = {
			text = line_text,
			expire_t = game_t + duration,
			duration_sec = duration,
			group_key = group_key,
			spawn_count = 1,
			alert_line_category = category,
			alert_instance_id = entry.alert_instance_id,
			spawn_source_unit = entry.spawn_source_unit,
			spawn_display_name = entry.spawn_display_name,
			spawn_target_resolved = entry.spawn_target_resolved,
		}
	else
		state.pending[#state.pending + 1] = entry
	end
end

mod.alerts_enqueue_strip_body = function(strip_label, body_text, game_t, alert_line_category, alert_options)
	local allow_strip = alerts_globally_enabled()

	if not allow_strip and alert_line_category == "mission" and mod.mission_objective_mirror_wants_alerts_ui and mod.mission_objective_mirror_wants_alerts_ui() then
		allow_strip = true
	end

	if not allow_strip and alert_line_category == "team" and mod.team_alerts_wants_alerts_ui and mod.team_alerts_wants_alerts_ui() then
		allow_strip = true
	end

	if not allow_strip then
		return
	end

	if type(body_text) ~= "string" or body_text == "" then
		return
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	local duration = alerts_duration_sec_clamped()
	local max_vis = alerts_max_visible_clamped()
	local cat = "default"
	local instance_id = type(alert_options) == "table" and alert_options.instance_id or nil

	if alert_line_category == "boss" then
		cat = "boss"
	elseif alert_line_category == "mission" then
		cat = "mission"
	elseif alert_line_category == "team" then
		cat = "team"
	elseif alert_line_category == "tactical_advisor" then
		cat = "tactical_advisor"
	elseif alert_line_category == "threat_advisor" then
		cat = "threat_advisor"
	elseif alert_line_category == "debug" then
		cat = "debug"
	end

	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)

	if cat == "mission" and alerts_try_merge_mission_strip_burst(strip_label, body_text, game_t, duration) then
		return
	end

	local mission_merge_key = nil
	local mission_merge_first_t = nil
	local mission_merge_count = nil
	local mission_merge_base_body = nil

	if cat == "mission" then
		mission_merge_key = alerts_mission_strip_merge_key(strip_label, body_text)
		mission_merge_first_t = game_t
		mission_merge_count = 1
		mission_merge_base_body = alerts_mission_body_base_for_merge(body_text)

		if mission_merge_base_body == "" then
			mission_merge_base_body = body_text
		end
	end

	local strip_val = type(strip_label) == "string" and strip_label ~= "" and strip_label or nil

	local entry = {
		text = body_text,
		duration = duration,
		alert_line_category = cat,
		strip_label = strip_val,
		alert_instance_id = instance_id,
		mission_merge_key = mission_merge_key,
		mission_merge_first_t = mission_merge_first_t,
		mission_merge_count = mission_merge_count,
		mission_merge_base_body = mission_merge_base_body,
	}

	if #state.active < max_vis then
		state.active[#state.active + 1] = {
			text = body_text,
			expire_t = game_t + duration,
			duration_sec = duration,
			alert_line_category = cat,
			strip_label = strip_val,
			alert_instance_id = instance_id,
			mission_merge_key = mission_merge_key,
			mission_merge_first_t = mission_merge_first_t,
			mission_merge_count = mission_merge_count,
			mission_merge_base_body = mission_merge_base_body,
		}
	else
		state.pending[#state.pending + 1] = entry
	end
end

local function alerts_try_enqueue_boss_approach_from_spawn(unit, raw_breed_name, clean_breed_name, game_t)
	if not alerts_globally_enabled() then
		return
	end

	if type(clean_breed_name) ~= "string" or clean_breed_name == "" then
		return
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	local base = alerts_base_breed_from_clean(clean_breed_name)

	if not alerts_boss_category_allowed_for_base(base) then
		return
	end

	local display_name = alerts_boss_display_name(unit, raw_breed_name)
	if alerts_boss_approach_message(display_name) == "" then
		return
	end

	mod.alerts_enqueue_spawn_grouped("boss:" .. clean_breed_name, "boss", display_name, game_t, alerts_target_display_name(unit), unit)
end

local function alerts_try_enqueue_specialist_approach_from_spawn(unit, raw_breed_name, game_t)
	if not alerts_globally_enabled() then
		return
	end

	if type(raw_breed_name) ~= "string" or raw_breed_name == "" or not unit then
		return
	end

	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	local stripped = alerts_specialist_raw_stripped(raw_breed_name)

	if not alerts_specialist_category_allowed(stripped) then
		return
	end

	local mg = type(AlertsSpecialistBreeds.merge_group_for_stripped) == "function" and AlertsSpecialistBreeds.merge_group_for_stripped(stripped) or nil
	local display_name
	local spawn_key

	if type(mg) == "table" and type(mg.title_breed_id) == "string" and mg.title_breed_id ~= "" and type(mg.spawn_group_key) == "string" and mg.spawn_group_key ~= "" then
		if type(AlertsBreedTitle) == "table" and type(AlertsBreedTitle.resolve) == "function" then
			display_name = AlertsBreedTitle.resolve(mod, mg.title_breed_id)
		else
			display_name = ""
		end

		if type(display_name) ~= "string" or display_name == "" then
			local tb = Breeds[mg.title_breed_id]

			if tb and type(tb.display_name) == "string" and tb.display_name ~= "" then
				display_name = Localize(tb.display_name)
			end
		end

		if type(display_name) ~= "string" or display_name == "" then
			display_name = mg.title_breed_id
		end

		spawn_key = "spec:" .. mg.spawn_group_key
	else
		display_name = alerts_specialist_display_name(unit, stripped, raw_breed_name)
		spawn_key = "spec:" .. stripped
	end

	if alerts_specialist_approach_message(display_name) == "" then
		return
	end

	mod.alerts_enqueue_spawn_grouped(spawn_key, "specialist", display_name, game_t, alerts_target_display_name(unit), unit)
end

local function alerts_on_unit_spawn_for_alert_categories(raw_breed_name, unit, game_t)
	if type(raw_breed_name) ~= "string" or raw_breed_name == "" or not unit then
		return
	end

	local is_weakened = spawn_util.is_weakened(unit)
	local clean_breed_name = spawn_util.clean_breed_name(raw_breed_name, is_weakened)

	alerts_try_enqueue_boss_approach_from_spawn(unit, raw_breed_name, clean_breed_name, game_t)
	alerts_try_enqueue_specialist_approach_from_spawn(unit, raw_breed_name, game_t)
end

mod.alerts_on_unit_spawner_spawn_husk = function(spawner_manager, game_object_id)
	if not spawner_manager or game_object_id == nil then
		return
	end

	local unit = spawner_manager._network_units and spawner_manager._network_units[game_object_id]

	if not unit then
		return
	end

	local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
	local breed = unit_data_ext and unit_data_ext:breed()
	local raw_breed_name = breed and breed.name
	local t = alerts_gameplay_time()

	if not t then
		return
	end

	alerts_on_unit_spawn_for_alert_categories(raw_breed_name, unit, t)
end

if not mod._divisionhud_alerts_spawn_hooked then
	mod._divisionhud_alerts_spawn_hooked = true

	mod:hook_safe("UnitSpawnerManager", "_add_network_unit", function(self, unit, game_object_id, is_husk)
		local game_session = Managers.state.game_session and Managers.state.game_session:game_session()

		if not game_session then
			return
		end

		local is_server = Managers.state.game_session:is_server()

		if not is_server then
			return
		end

		if not GameSession.has_game_object_field(game_session, game_object_id, "breed_id") then
			return
		end

		local breed_id = GameSession.game_object_field(game_session, game_object_id, "breed_id")
		local raw_breed_name = NetworkLookup.breed_names[breed_id]
		local t = alerts_gameplay_time()

		if not t then
			return
		end

		alerts_on_unit_spawn_for_alert_categories(raw_breed_name, unit, t)
	end)
end

mod.divisionhud_alerts_apply_settings = function(setting_id)
	local relevant = setting_id == "divisionhud_reset_all_settings"
		or setting_id == "alerts_enabled"
		or setting_id == "alerts_max_visible"
		or setting_id == "alerts_duration_sec"
		or setting_id == "alerts_show_duration_bar"

	if not relevant then
		return
	end

	local HudUtils = mod.hud_utils
	local hud_element = HudUtils and HudUtils.resolve_division_hud_instance and HudUtils.resolve_division_hud_instance()

	if not hud_element then
		return
	end

	hud_element._div_alert_next_enter_t = nil
end

return mod
