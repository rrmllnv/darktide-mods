local M = {}

local function _is_unit_alive(unit)
	if not unit then
		return false
	end

	if Unit and Unit.alive and not Unit.alive(unit) then
		return false
	end

	local health_ext = ScriptUnit and ScriptUnit.has_extension and ScriptUnit.has_extension(unit, "health_system")

	if health_ext and type(health_ext.is_dead) == "function" then
		local ok, dead = pcall(function()
			return health_ext:is_dead()
		end)

		if ok and dead == true then
			return false
		end
	end

	return true
end

local function _resolve_side_system()
	local extension_manager = Managers.state and Managers.state.extension

	return extension_manager and extension_manager:system("side_system") or nil
end

local function _resolve_perception_map()
	local extension_manager = Managers.state and Managers.state.extension
	local perception_system = extension_manager and extension_manager:system("perception_system")

	if not perception_system or type(perception_system.unit_to_extension_map) ~= "function" then
		return nil
	end

	local ok, map = pcall(function()
		return perception_system:unit_to_extension_map()
	end)

	if ok and type(map) == "table" then
		return map
	end

	return nil
end

local function _resolve_game_session()
	local gsm = Managers.state and Managers.state.game_session

	if not gsm or type(gsm.game_session) ~= "function" then
		return nil
	end

	local ok, gs = pcall(gsm.game_session, gsm)

	return ok and gs or nil
end

local function _resolve_unit_spawner()
	return Managers.state and Managers.state.unit_spawner or nil
end

local function _local_player_unit()
	local player_manager = Managers.player

	if not player_manager then
		return nil
	end

	local player = player_manager.local_player_safe and player_manager:local_player_safe(1) or player_manager:local_player(1)

	return player and player.player_unit or nil
end

local function _is_enemy_side(player_unit, unit, side_system)
	if not side_system or not player_unit or not unit then
		return false
	end

	local side_by_unit = side_system.side_by_unit
	local player_side = side_by_unit and side_by_unit[player_unit]
	local target_side = side_by_unit and side_by_unit[unit]

	if not player_side or not target_side then
		return false
	end

	local enemy_side_names = player_side:relation_side_names("enemy")

	for i = 1, #enemy_side_names do
		if enemy_side_names[i] == target_side:name() then
			return true
		end
	end

	return false
end

local function _breed_for_unit(unit)
	local unit_data_extension = unit and ScriptUnit and ScriptUnit.has_extension and ScriptUnit.has_extension(unit, "unit_data_system")

	return unit_data_extension and unit_data_extension:breed() or nil
end

local function _threat_kind_for_breed(breed)
	if type(breed) ~= "table" then
		return nil
	end

	local tags = breed.tags or {}

	if tags.monster or breed.is_boss == true then
		return "monster"
	end

	if tags.special then
		return "special"
	end

	if tags.elite then
		return "elite"
	end

	if tags.horde or tags.roamer then
		return "trash"
	end

	return "trash"
end

local function _candidate_is_interesting(threat_kind)
	-- Accept everything except explicit horde trash.
	-- nil means breed couldn't be determined — include rather than skip.
	return threat_kind ~= "trash"
end

-- Read enemy's current perception target from the perception component directly (same pattern as DivisionHUD).
local function _target_from_perception_extension(perception_extension)
	local perception_component = perception_extension and perception_extension._perception_component
	local target_unit = perception_component and perception_component.target_unit

	if target_unit and Unit.alive and Unit.alive(target_unit) then
		return target_unit
	end

	return nil
end

-- Read enemy's target from the game session network object (same pattern as DivisionHUD threat_advisor_runtime).
local function _target_from_game_object(enemy_unit, game_session, unit_spawner)
	if not enemy_unit or not game_session or not unit_spawner then
		return nil
	end

	local ok_id, gobj_id = pcall(function()
		return unit_spawner:game_object_id(enemy_unit)
	end)

	if not ok_id or not gobj_id then
		return nil
	end

	local ok_has, has_field = pcall(function()
		return GameSession.has_game_object_field(game_session, gobj_id, "target_unit_id")
	end)

	if not ok_has or not has_field then
		return nil
	end

	local ok_tid, target_unit_id = pcall(function()
		return GameSession.game_object_field(game_session, gobj_id, "target_unit_id")
	end)

	if not ok_tid or not target_unit_id then
		return nil
	end

	if NetworkConstants and target_unit_id == NetworkConstants.invalid_game_object_id then
		return nil
	end

	local ok_tu, target_unit = pcall(function()
		return unit_spawner:unit(target_unit_id)
	end)

	if ok_tu and target_unit and Unit.alive and Unit.alive(target_unit) then
		return target_unit
	end

	return nil
end

local function _target_for_enemy(enemy_unit, perception_map, game_session, unit_spawner)
	local from_go = _target_from_game_object(enemy_unit, game_session, unit_spawner)

	if from_go then
		return from_go
	end

	return _target_from_perception_extension(perception_map and perception_map[enemy_unit])
end

M.acquire = function(state, t, settings)
	state = state or {}
	state.candidates = state.candidates or {}

	local scan_interval = (settings and settings.target_scan_interval) or 0.10

	if type(scan_interval) ~= "number" or scan_interval ~= scan_interval or scan_interval <= 0 then
		scan_interval = 0.10
	end

	local last_scan_t = state.last_scan_t or -1000

	if t and (t - last_scan_t) < scan_interval then
		return state.candidates, state.candidate_count or 0, state
	end

	state.last_scan_t = t or last_scan_t

	local side_system = _resolve_side_system()
	local perception_map = _resolve_perception_map()
	local player_unit = _local_player_unit()
	local game_session = _resolve_game_session()
	local unit_spawner = _resolve_unit_spawner()

	local out = state.candidates
	local count = 0

	local max_candidates = (settings and settings.max_candidates) or 64

	if type(max_candidates) ~= "number" or max_candidates ~= max_candidates or max_candidates < 8 then
		max_candidates = 64
	end

	local camera = settings and settings.camera

	-- Iterate side_by_unit (same pattern as DivisionHUD) — contains ALL registered units,
	-- while perception_map only covers units with a perception extension, which may miss enemies.
	local side_by_unit = side_system and side_system.side_by_unit

	if side_by_unit and player_unit and Unit.alive(player_unit) then
		local player_pos = POSITION_LOOKUP and POSITION_LOOKUP[player_unit]

		if player_pos then
			for unit, _ in pairs(side_by_unit) do
				if count >= max_candidates then
					break
				end

				if _is_unit_alive(unit) and _is_enemy_side(player_unit, unit, side_system) then
					local unit_pos = POSITION_LOOKUP and POSITION_LOOKUP[unit]

					if unit_pos then
						local breed = _breed_for_unit(unit)
						local threat_kind = _threat_kind_for_breed(breed)

						if _candidate_is_interesting(threat_kind) then
							-- Frustum check: skip enemies outside camera's field of view.
							-- Uses torso node when available for accuracy, falls back to ground pos.
							local check_pos = unit_pos
							local node_torso = Unit.has_node(unit, "enemy_aim_target_02") and Unit.node(unit, "enemy_aim_target_02") or nil

							if node_torso then
								check_pos = Unit.world_position(unit, node_torso) or unit_pos
							end

							if camera and Camera.inside_frustum and Camera.inside_frustum(camera, check_pos) <= 0 then
								-- Enemy not in field of view — skip as candidate.
							else
								-- Determine if this enemy is currently targeting the local player.
								local enemy_target = _target_for_enemy(unit, perception_map, game_session, unit_spawner)
								local targeting_player = (enemy_target == player_unit)

								count = count + 1

								local entry = out[count]

								if not entry then
									entry = {}
									out[count] = entry
								end

								entry.unit = unit
								entry.breed = breed
								entry.threat_kind = threat_kind
								entry.distance = Vector3.distance(player_pos, unit_pos)
								entry.targeting_player = targeting_player
							end
						end
					end
				end
			end
		end
	end

	for i = count + 1, #out do
		out[i] = nil
	end

	state.candidate_count = count

	return out, count, state
end

return M
