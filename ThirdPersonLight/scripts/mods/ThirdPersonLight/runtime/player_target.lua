local mod = get_mod("ThirdPersonLight")

if type(mod.tpl_player_target) == "table" then
	return mod.tpl_player_target
end

local PlayerTarget = {}

local _cached_unit = nil
local _cached_player = nil

function PlayerTarget.invalidate()
	_cached_unit = nil
	_cached_player = nil
end

function PlayerTarget.get()
	if _cached_unit and ALIVE[_cached_unit] then
		return _cached_player, _cached_unit
	end

	_cached_unit = nil
	_cached_player = nil

	local player_manager = Managers.player

	if not player_manager then
		return nil, nil
	end

	local player = player_manager:local_player(1)

	if not player then
		return nil, nil
	end

	local unit = player.player_unit

	if not unit or not ALIVE[unit] then
		return nil, nil
	end

	_cached_player = player
	_cached_unit = unit

	return player, unit
end

function PlayerTarget.camera_pose(player)
	local state_mgr = Managers.state
	local camera_manager = state_mgr and state_mgr.camera

	if not camera_manager then
		return nil, nil
	end

	local viewport_name = player and player.viewport_name

	if not viewport_name then
		return nil, nil
	end

	local camera = camera_manager:camera(viewport_name)

	if not camera then
		return nil, nil
	end

	return Camera.world_position(camera), Camera.world_rotation(camera)
end

function PlayerTarget.get_world()
	local world_manager = Managers.world

	if not world_manager or not world_manager:has_world("level_world") then
		return nil
	end

	return world_manager:world("level_world")
end

mod.tpl_player_target = PlayerTarget

return PlayerTarget
