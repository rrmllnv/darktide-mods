local M = {}

local TWO_PI = math.pi * 2

local function _safe_number(v, fallback)
	if type(v) == "number" and v == v then
		return v
	end

	return fallback
end

local function _local_player_unit()
	local player_manager = Managers.player

	if not player_manager then
		return nil
	end

	local player = player_manager.local_player_safe and player_manager:local_player_safe(1) or player_manager:local_player(1)

	return player and player.player_unit or nil
end

local function _resolve_side_system()
	local extension_manager = Managers.state and Managers.state.extension

	return extension_manager and extension_manager:system("side_system") or nil
end

local function _is_unit_alive(unit)
	if not unit then
		return false
	end

	if HEALTH_ALIVE and HEALTH_ALIVE[unit] == false then
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
	-- Match ThreatQuery: accept everything except explicit horde trash.
	return threat_kind ~= "trash"
end

local function _append_blip(blips, max_blips, angle, radius01, t, fade_s)
	local idx = #blips + 1

	if idx > max_blips then
		return
	end

	local e = blips[idx]
	if not e then
		e = {}
		blips[idx] = e
	end

	e.angle = angle
	e.radius01 = radius01
	e.start_t = t
	e.end_t = t + fade_s
end

local function _update_blip_angles(blips, t, player_pos, camera_forward, camera_right, range_m)
	for i = 1, #blips do
		local e = blips[i]
		local unit = e and e.unit

		if unit and _is_unit_alive(unit) then
			local unit_pos = POSITION_LOOKUP and POSITION_LOOKUP[unit]
			if unit_pos and player_pos then
				local dir = unit_pos - player_pos
				dir.z = 0
				if Vector3.length_squared(dir) > 0.0001 then
					local dist = Vector3.length(dir)
					dir = Vector3.normalize(dir)
					local forward_dot = Vector3.dot(camera_forward, dir)
					local right_dot = Vector3.dot(camera_right, dir)
					e.angle = math.atan2(right_dot, forward_dot)
					e.radius01 = math.clamp(dist / range_m, 0, 1)
				else
					e.angle = 0
					e.radius01 = 0
				end
			end
		else
			-- Drop dead/invalid units quickly.
			e.end_t = t
		end
	end
end

local function _prune_and_count(blips, t)
	local write = 1
	local n = #blips

	for read = 1, n do
		local e = blips[read]
		local end_t = e and e.end_t
		if type(end_t) == "number" and t <= end_t then
			if write ~= read then
				blips[write] = e
			end
			write = write + 1
		end
	end

	for i = write, n do
		blips[i] = nil
	end

	return write - 1
end

-- settings:
-- - enabled [bool]
-- - passive [bool]
-- - sweep_seconds [number] (time for full 360°)
-- - range_m [number]
-- - max_blips [number]
-- - blip_fade_seconds [number]
-- - camera [camera]
-- - manual_pulse [bool] (one-shot; will be reset by caller)
M.update = function(state, dt, t, settings)
	state = state or {}
	settings = settings or {}

	state.blips = state.blips or {}

	if settings.enabled ~= true then
		state.active_until_t = nil
		state.angle = 0
		_prune_and_count(state.blips, t or 0)
		state.visible = false
		return state
	end

	local passive = settings.passive == true
	local sweep_seconds = _safe_number(settings.sweep_seconds, 2.0)
	local range_m = _safe_number(settings.range_m, 80.0)
	local max_blips = math.floor(_safe_number(settings.max_blips, 24))
	local fade_s = _safe_number(settings.blip_fade_seconds, 1.0)

	if sweep_seconds <= 0 then
		sweep_seconds = 0.01
	end
	if range_m <= 0 then
		range_m = 1
	end
	if max_blips < 1 then
		max_blips = 1
	elseif max_blips > 64 then
		max_blips = 64
	end
	if fade_s < 0 then
		fade_s = 0
	end

	local manual_pulse = settings.manual_pulse == true

	-- Activate window
	if manual_pulse then
		state.active_until_t = (t or 0) + sweep_seconds
	elseif passive then
		state.active_until_t = nil
	end

	local active_until_t = state.active_until_t
	local active = passive or (type(active_until_t) == "number" and (t or 0) <= active_until_t)

	state.visible = active

	-- Advance sweep angle
	if active then
		local ang = _safe_number(state.angle, 0)
		local delta = TWO_PI * (_safe_number(dt, 0) / sweep_seconds)
		ang = (ang + delta) % TWO_PI
		state.angle = ang
	else
		state.angle = _safe_number(state.angle, 0)
	end

	-- Ping on manual pulse, or once per full sweep period (when angle wraps)
	local do_ping = false
	if manual_pulse then
		do_ping = true
	else
		local next_ping_t = state.next_ping_t
		if active and (type(next_ping_t) ~= "number" or (t or 0) >= next_ping_t) then
			do_ping = true
			state.next_ping_t = (t or 0) + sweep_seconds
		end
	end

	-- Update existing blips (remove expired)
	_prune_and_count(state.blips, t or 0)

	-- Keep existing blips oriented to current camera.
	local side_system = _resolve_side_system()
	local player_unit = _local_player_unit()
	local player_pos = player_unit and POSITION_LOOKUP and POSITION_LOOKUP[player_unit]
	local camera = settings.camera
	local camera_forward = nil
	local camera_right = nil

	if camera and player_pos then
		local camera_rotation = Camera.local_rotation(camera)
		camera_forward = Quaternion.forward(camera_rotation)
		camera_forward.z = 0
		camera_forward = Vector3.normalize(camera_forward)
		camera_right = Vector3.cross(camera_forward, Vector3.up())

		_update_blip_angles(state.blips, t or 0, player_pos, camera_forward, camera_right, range_m)
		_prune_and_count(state.blips, t or 0)
	end

	if do_ping and active then
		local side_system = _resolve_side_system()
		local player_unit = _local_player_unit()
		local side_by_unit = side_system and side_system.side_by_unit
		local player_pos = player_unit and POSITION_LOOKUP and POSITION_LOOKUP[player_unit]
		local camera = settings.camera

		if side_by_unit and player_unit and player_pos and camera then
			local camera_rotation = Camera.local_rotation(camera)
			local camera_forward = Quaternion.forward(camera_rotation)
			camera_forward.z = 0
			camera_forward = Vector3.normalize(camera_forward)
			local camera_right = Vector3.cross(camera_forward, Vector3.up())

			for unit, _ in pairs(side_by_unit) do
				if #state.blips >= max_blips then
					break
				end

				if unit ~= player_unit and _is_unit_alive(unit) and _is_enemy_side(player_unit, unit, side_system) then
					local unit_pos = POSITION_LOOKUP and POSITION_LOOKUP[unit]
					if unit_pos then
						local dist = Vector3.distance(player_pos, unit_pos)
						if dist <= range_m then
							local breed = _breed_for_unit(unit)
							local threat_kind = _threat_kind_for_breed(breed)

							if _candidate_is_interesting(threat_kind) then
								local dir = unit_pos - player_pos
								dir.z = 0
								if Vector3.length_squared(dir) > 0.0001 then
									dir = Vector3.normalize(dir)
									local forward_dot = Vector3.dot(camera_forward, dir)
									local right_dot = Vector3.dot(camera_right, dir)
									local angle = math.atan2(right_dot, forward_dot)
									local r01 = math.clamp(dist / range_m, 0, 1)
									_append_blip(state.blips, max_blips, angle, r01, t or 0, fade_s)
									state.blips[#state.blips].unit = unit
								end
							end
						end
					end
				end
			end
		end
	end

	state.blip_count = #state.blips

	return state
end

return M

