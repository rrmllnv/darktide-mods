local mod = get_mod("DivisionHUD")

local function alerts_gameplay_time()
	local Hu = mod.hud_utils

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

local specialists_with_menu_toggle = {}

if type(AlertsSpecialistBreeds) == "table" and type(AlertsSpecialistBreeds.list) == "table" then
	for i = 1, #AlertsSpecialistBreeds.list do
		specialists_with_menu_toggle[AlertsSpecialistBreeds.list[i]] = true
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
		n = 3
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

	if not specialists_with_menu_toggle[stripped_raw] then
		return false
	end

	local b = Breeds[stripped_raw]

	if not b or b.is_boss == true then
		return false
	end

	if not b.tags or b.tags.special ~= true then
		return false
	end

	local s = mod._settings
	local key = "alert_specialist_" .. stripped_raw
	local v = type(s) == "table" and s[key]

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

local function alerts_promote_from_pending(game_t)
	local max_vis = alerts_max_visible_clamped()
	local duration = alerts_duration_sec_clamped()

	while #state.active < max_vis and #state.pending > 0 do
		local p = table.remove(state.pending, 1)

		if type(p) == "table" and type(p.text) == "string" and p.text ~= "" then
			local dur = type(p.duration) == "number" and p.duration or duration

			state.active[#state.active + 1] = {
				text = p.text,
				expire_t = game_t + dur,
				duration_sec = dur,
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

mod.alerts_sync = function(game_t)
	if type(game_t) ~= "number" or game_t ~= game_t then
		return
	end

	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)
	alerts_prune_expired(game_t)
	alerts_promote_from_pending(game_t)
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
	}

	if #state.active < max_vis then
		state.active[#state.active + 1] = {
			text = text,
			expire_t = game_t + duration,
			duration_sec = duration,
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
	local text = alerts_boss_approach_message(display_name)

	if text == "" then
		return
	end

	mod.alerts_enqueue(text, game_t)
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

	local display_name = alerts_specialist_display_name(unit, stripped, raw_breed_name)
	local text = alerts_specialist_approach_message(display_name)

	if text == "" then
		return
	end

	mod.alerts_enqueue(text, game_t)
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
