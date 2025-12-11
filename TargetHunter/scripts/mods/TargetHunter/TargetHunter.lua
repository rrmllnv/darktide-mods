local mod = get_mod("TargetHunter")
local Breeds = require("scripts/settings/breed/breeds")

mod._tracked_markers = {}
mod._marker_seq = 0
mod._pending_smart_tag = {}
local DEFAULT_MAX_DISTANCE = 40
local COLOR_FALLBACK_BOSS = Color.ui_hud_yellow_medium(255, true)
local COLOR_FALLBACK_ELITE = Color.ui_hud_red_light(255, true)

local enemy_settings = {
	-- Bosses
	["chaos_beast_of_nurgle"] = { setting = "boss_beast_of_nurgle", color_setting = "boss_beast_of_nurgle_color", is_boss = true, default_enabled = true },
	["chaos_spawn"] = { setting = "boss_chaos_spawn", color_setting = "boss_chaos_spawn_color", is_boss = true, default_enabled = true },
	["chaos_plague_ogryn"] = { setting = "boss_plague_ogryn", color_setting = "boss_plague_ogryn_color", is_boss = true, default_enabled = true },
	["chaos_daemonhost"] = { setting = "boss_daemonhost", color_setting = "boss_daemonhost_color", is_boss = true, default_enabled = true },
	["renegade_captain"] = { setting = "boss_renegade_captain", color_setting = "boss_renegade_captain_color", is_boss = true, default_enabled = true },
	["renegade_twin_captain"] = { setting = "boss_renegade_twins", color_setting = "boss_renegade_twins_color", is_boss = true, default_enabled = true },
	["renegade_twin_captain_two"] = { setting = "boss_renegade_twins", color_setting = "boss_renegade_twins_color", is_boss = true, default_enabled = true },
	["cultist_captain"] = { setting = "boss_cultist_captain", color_setting = "boss_cultist_captain_color", is_boss = true, default_enabled = true },

	-- Elites
	["chaos_ogryn_gunner"] = { setting = "elite_chaos_ogryn_gunner", color_setting = "elite_chaos_ogryn_gunner_color", default_enabled = true },
	["chaos_ogryn_executor"] = { setting = "elite_chaos_ogryn_executor", color_setting = "elite_chaos_ogryn_executor_color", default_enabled = false },
	["chaos_ogryn_bulwark"] = { setting = "elite_chaos_ogryn_bulwark", color_setting = "elite_chaos_ogryn_bulwark_color", default_enabled = false },
	["renegade_shocktrooper"] = { setting = "elite_renegade_shocktrooper", color_setting = "elite_renegade_shocktrooper_color", default_enabled = false },
	["renegade_plasma_gunner"] = { setting = "elite_renegade_plasma_gunner", color_setting = "elite_renegade_plasma_gunner_color", default_enabled = false },
	["renegade_radio_operator"] = { setting = "elite_renegade_radio_operator", color_setting = "elite_renegade_radio_operator_color", default_enabled = false },
	["renegade_gunner"] = { setting = "elite_renegade_gunner", color_setting = "elite_renegade_gunner_color", default_enabled = false },
	["renegade_executor"] = { setting = "elite_renegade_executor", color_setting = "elite_renegade_executor_color", default_enabled = false },
	["renegade_berzerker"] = { setting = "elite_renegade_berzerker", color_setting = "elite_renegade_berzerker_color", default_enabled = false },
	["cultist_shocktrooper"] = { setting = "elite_cultist_shocktrooper", color_setting = "elite_cultist_shocktrooper_color", default_enabled = false },
	["cultist_gunner"] = { setting = "elite_cultist_gunner", color_setting = "elite_cultist_gunner_color", default_enabled = false },
	["cultist_berzerker"] = { setting = "elite_cultist_berzerker", color_setting = "elite_cultist_berzerker_color", default_enabled = false },

	-- Specials (третаем как elites для маркеров)
	["chaos_poxwalker_bomber"] = { setting = "special_poxburster", color_setting = "special_poxburster_color", default_enabled = false },
	["chaos_hound"] = { setting = "special_hound", color_setting = "special_hound_color", default_enabled = false },
	["chaos_hound_mutator"] = { setting = "special_hound", color_setting = "special_hound_color", default_enabled = false },
	["cultist_mutant"] = { setting = "special_mutant", color_setting = "special_mutant_color", default_enabled = false },
	["cultist_mutant_mutator"] = { setting = "special_mutant", color_setting = "special_mutant_color", default_enabled = false },
	["cultist_flamer"] = { setting = "special_cultist_flamer", color_setting = "special_cultist_flamer_color", default_enabled = false },
	["cultist_grenadier"] = { setting = "special_cultist_grenadier", color_setting = "special_cultist_grenadier_color", default_enabled = false },
	["renegade_flamer"] = { setting = "special_renegade_flamer", color_setting = "special_renegade_flamer_color", default_enabled = false },
	["renegade_flamer_mutator"] = { setting = "special_renegade_flamer", color_setting = "special_renegade_flamer_color", default_enabled = false },
	["renegade_grenadier"] = { setting = "special_renegade_grenadier", color_setting = "special_renegade_grenadier_color", default_enabled = false },
	["renegade_sniper"] = { setting = "special_renegade_sniper", color_setting = "special_renegade_sniper_color", default_enabled = true },
	["renegade_netgunner"] = { setting = "special_renegade_netgunner", color_setting = "special_renegade_netgunner_color", default_enabled = false },
}

local function get_color_from_setting(setting_id, fallback)
	local name = mod:get(setting_id)
	if type(name) == "string" and Color[name] then
		return Color[name](255, true)
	end

	return fallback
end

local function is_unit(value)
	return type(value) == "userdata" and Unit and Unit.alive and Unit.alive(value)
end

local function fetch_breed(unit)
	local unit_data = ScriptUnit.has_extension and ScriptUnit.has_extension(unit, "unit_data_system")

	return unit_data and unit_data:breed()
end

local function resolve_unit(unit_or_position_or_id)
	if is_unit(unit_or_position_or_id) then
		return unit_or_position_or_id
	end

	if Application and Application.flow_callback_context_unit then
		local context_unit = Application.flow_callback_context_unit()

		if is_unit(context_unit) then
			return context_unit
		end
	end

	return nil
end

local function should_track_breed(breed)
	if not breed or not breed.tags then
		return false
	end

	local config = enemy_settings[breed.name]

	-- Если враг описан явно
	if config then
		local enabled = mod:get(config.setting)
		if enabled == nil then
			enabled = config.default_enabled
		end

		if not enabled then
			return false, false
		end

		return true, config.is_boss
	end

	-- Фолбэк по тегам, если брид неизвестен в таблице: боссы показываем, элиты/спеши выключены по умолчанию
	-- local tags = breed.tags
	-- local is_boss = tags.boss or tags.monster
	-- local is_elite = tags.elite or tags.special

	-- if is_boss then
	-- 	return true, true
	-- end

	-- if is_elite then
	-- 	return false, false
	-- end

	return false, false
end

-- Страховка: сбрасываем активный smart tag, если у маркера нет smart_tag_system (вешаем один раз)
if not mod._hooked_handle_interaction_draw then
	mod._hooked_handle_interaction_draw = true

	mod:hook_safe("HudElementSmartTagging", "_handle_interaction_draw", function(self, dt, t, input_service, ui_renderer, render_settings)
		local active = self._active_interaction_data
		local marker = active and active.marker

		if marker then
			local unit = marker.unit
			if not (unit and ScriptUnit.has_extension(unit, "smart_tag_system")) then
				self._active_interaction_data = nil
				return
			end
		end
	end)
end

local function remove_marker(unit, entry)
	if entry and entry.marker_id then
		Managers.event:trigger("remove_world_marker", entry.marker_id)
	end

	mod._tracked_markers[unit] = nil
end

local function enqueue_unit(unit, breed, is_boss)
	if not unit then
		return
	end

	if mod._tracked_markers[unit] then
		return
	end

	if mod._pending_smart_tag[unit] then
		return
	end

	mod._pending_smart_tag[unit] = {
		breed = breed,
		is_boss = is_boss,
		attempts = 0,
	}
end

local function register_marker(unit, breed, is_boss)
	if mod._tracked_markers[unit] then
		return
	end
	-- Требуем готовый smart_tag_extension; иначе выходим (ожидание происходит в очереди)
	if not (unit and ScriptUnit.has_extension(unit, "smart_tag_system")) then
		return
	end

	-- проверяем дистанцию перед созданием, если игрок уже известен
	local max_distance = tonumber(mod:get("max_distance")) or DEFAULT_MAX_DISTANCE
	local player_manager = Managers.player
	local connection_manager = Managers.connection

	if player_manager and connection_manager and connection_manager:is_initialized() then
		local player = player_manager.local_player_safe and player_manager:local_player_safe(1) or player_manager:local_player(1)
		local player_unit = player and player.player_unit
		local player_pos = player_unit and POSITION_LOOKUP[player_unit]

		if player_pos and max_distance and max_distance > 0 and is_unit(unit) then
			local unit_pos = POSITION_LOOKUP[unit]

			if unit_pos then
				local dist = Vector3.distance(player_pos, unit_pos)

				if dist > max_distance then
					return
				end
			end
		end
	end

	mod._marker_seq = mod._marker_seq + 1

	local tag_id = string.format("target_hunter_%s_%d", breed.name or "enemy", mod._marker_seq)
	local marker_type = is_boss and "unit_threat_veteran" or "unit_threat"

	local data = {
		tag_id = tag_id,
		visual_type = "default",
	}

	local function cb(marker_id)
		mod._tracked_markers[unit] = {
			marker_id = marker_id,
			breed_name = breed.name,
			is_boss = is_boss,
		}
	end

	Managers.event:trigger("add_world_marker_unit", marker_type, unit, cb, data)
end

local function try_track_unit(unit_or_position_or_id)
	local unit = resolve_unit(unit_or_position_or_id)

	if not unit or mod._tracked_markers[unit] then
		return
	end

	local breed = fetch_breed(unit)
	local should_track, is_boss = should_track_breed(breed)

	if should_track then
		enqueue_unit(unit, breed, is_boss)
	end
end

local function cleanup_dead_units()
	for unit, entry in pairs(mod._tracked_markers) do
		if not is_unit(unit) then
			remove_marker(unit, entry)
		end
	end
end

local function reset_if_in_hub()
	local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()

	if game_mode_name == "hub" or not game_mode_name then
		for unit, entry in pairs(mod._tracked_markers) do
			remove_marker(unit, entry)
		end
	end
end

-- Ставим маркер сразу при спавне (через событие minion_unit_spawned)
mod:hook_safe(Managers.event, "trigger", function(self, event_name, unit, ...)
	if event_name == "minion_unit_spawned" and unit then
		try_track_unit(unit)
	end
end)

-- Дополнительный ловец спавнов, аналогично SpecialsTracker: хостовые сети
mod:hook_safe(CLASS.UnitSpawnerManager, "_add_network_unit", function(self, unit, game_object_id, is_husk)
	if not unit then
		return
	end

	-- Пытаемся взять breed из game_session (как в SpecialsTracker), чтобы не зависеть от наличия unit_data_extension в момент спавна
	local game_session_manager = Managers.state and Managers.state.game_session
	local game_session = game_session_manager and game_session_manager:game_session()

	if game_session and GameSession.has_game_object_field(game_session, game_object_id, "breed_id") then
		local breed_id = GameSession.game_object_field(game_session, game_object_id, "breed_id")
		local breed_name = NetworkLookup.breed_names[breed_id]
		local breed = breed_name and Breeds[breed_name]

		if breed then
			local should_track, is_boss = should_track_breed(breed)

			if should_track then
				enqueue_unit(unit, breed, is_boss)
				return
			end
		end
	end

	-- Фолбэк: если breed не извлекли, пробуем как раньше
	try_track_unit(unit)
end)

-- Дополнительный ловец спавнов для публичных игр (husk)
mod:hook_safe(CLASS.UnitSpawnerManager, "spawn_husk_unit", function(self, game_object_id, owner_id)
	local unit_spawner_manager = Managers.state.unit_spawner
	if not unit_spawner_manager then
		return
	end

	local unit = unit_spawner_manager._network_units and unit_spawner_manager._network_units[game_object_id]

	if not unit then
		return
	end

	-- breed через game_session (как в SpecialsTracker)
	local game_session_manager = Managers.state and Managers.state.game_session
	local game_session = game_session_manager and game_session_manager:game_session()

	if game_session and GameSession.has_game_object_field(game_session, game_object_id, "breed_id") then
		local breed_id = GameSession.game_object_field(game_session, game_object_id, "breed_id")
		local breed_name = NetworkLookup.breed_names[breed_id]
		local breed = breed_name and Breeds[breed_name]

		if breed then
			local should_track, is_boss = should_track_breed(breed)

			if should_track then
				enqueue_unit(unit, breed, is_boss)
				return
			end
		end
	end

	-- Фолбэк
	try_track_unit(unit)
end)

function mod.update(dt)
	reset_if_in_hub()
	cleanup_dead_units()

	-- Повторные попытки навесить маркер на юниты, у которых extension появляется с задержкой
	local pending = mod._pending_smart_tag
	if next(pending) then
		for unit, data in pairs(pending) do
			if not is_unit(unit) then
				pending[unit] = nil
			else
				data.attempts = (data.attempts or 0) + 1

				if ScriptUnit.has_extension(unit, "smart_tag_system") then
					register_marker(unit, data.breed, data.is_boss)
					pending[unit] = nil
				elseif data.attempts > 300 then
					-- бросаем попытки после ~5 минут при 60fps
					pending[unit] = nil
				end
			end
		end
	end

	-- Защита от испорченного fixed_time_step (некоторые моды могут подменять)
	if not mod._fixed_time_step_guard_done then
		local game_session = Managers.state and Managers.state.game_session
		local fixed_time_step = game_session and game_session.fixed_time_step

		if game_session and type(fixed_time_step) ~= "number" then
			game_session.fixed_time_step = (GameParameters and GameParameters.fixed_time_step) or 1 / 60
			mod._fixed_time_step_guard_done = true
		end
	end

	local player_manager = Managers.player
	local connection_manager = Managers.connection

	if not player_manager or not connection_manager or not connection_manager:is_initialized() then
		return
	end

	local player = player_manager:local_player_safe(1)

	if not player and player_manager.local_player then
		-- fallback для старых версий, если safe отсутствует
		player = player_manager:local_player(1)
	end

	if not player then
		return
	end

	local player_unit = player.player_unit
	if not player_unit or not player:unit_is_alive() then
		return
	end

	local player_pos = POSITION_LOOKUP[player_unit]

	if not player_pos then
		local camera_manager = Managers.state and Managers.state.camera
		player_pos = camera_manager and camera_manager:camera_position()
	end

	local max_distance = tonumber(mod:get("max_distance")) or DEFAULT_MAX_DISTANCE

	if player_pos and max_distance and max_distance > 0 then
		for unit, entry in pairs(mod._tracked_markers) do
			local unit_pos = is_unit(unit) and (POSITION_LOOKUP[unit] or (Unit and Unit.alive and Unit.alive(unit) and Unit.world_position(unit, 1)))

			if unit_pos then
				local dist = Vector3.distance(player_pos, unit_pos)

				if dist > max_distance then
					remove_marker(unit, entry)
				end
			else
				remove_marker(unit, entry)
			end
		end
	end
end

function mod.on_setting_changed(setting_id)
	if setting_id == "enable_bosses" or setting_id == "enable_elites" then
		for unit, entry in pairs(mod._tracked_markers) do
			local breed = fetch_breed(unit)
			local should_track = should_track_breed(breed)

			if not should_track then
				remove_marker(unit, entry)
			end
		end
	end
end

function mod.on_unload()
	for unit, entry in pairs(mod._tracked_markers) do
		remove_marker(unit, entry)
	end
end


