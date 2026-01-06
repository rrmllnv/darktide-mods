local mod = get_mod("ThirdPersonLight")

local CLASS = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/classes")

local _light_unit = nil
local _light_object = nil
local _is_third_person = false
local _player_unit = nil

local function _is_in_third_person()
	if not _player_unit or not Unit.alive(_player_unit) then
		return false
	end

	local first_person_extension = ScriptUnit.has_extension(_player_unit, "first_person_system")
	if not first_person_extension then
		return false
	end

	local first_person_mode_component = ScriptUnit.extension(_player_unit, "unit_data_system"):read_component("first_person_mode")
	if not first_person_mode_component then
		return false
	end

	return not first_person_mode_component.wants_1p_camera
end

local function _get_camera_position()
	if not _player_unit or not Unit.alive(_player_unit) then
		return nil, nil
	end

	local player = Managers.state.player_unit_spawn:owner(_player_unit)
	if not player then
		return nil, nil
	end

	local viewport_name = player.viewport_name
	if not viewport_name then
		return nil, nil
	end

	local camera_manager = Managers.state.camera
	if not camera_manager then
		return nil, nil
	end

	local camera_position = camera_manager:camera_position(viewport_name)
	local camera_rotation = camera_manager:camera_rotation(viewport_name)

	return camera_position, camera_rotation
end

local function _create_light_unit(world, position, rotation)
	if _light_unit and Unit.alive(_light_unit) then
		return _light_unit
	end

	local light_unit_name = "content/units/light/spot_light"
	local pose = Matrix4x4.from_quaternion_position(rotation or Quaternion.identity(), position)
	local light_unit = World.spawn_unit_ex(world, light_unit_name, nil, pose)

	if not light_unit then
		mod:error("Failed to spawn light unit")
		return nil
	end

	_light_unit = light_unit

	if Unit.num_lights(light_unit) > 0 then
		_light_object = Unit.light(light_unit, 1)
	end

	return light_unit
end

local function _update_light_settings()
	if not _light_object then
		return
	end

	local intensity = mod:get("light_intensity")
	local radius = mod:get("light_radius")
	local color_r = mod:get("light_color_r") / 255.0
	local color_g = mod:get("light_color_g") / 255.0
	local color_b = mod:get("light_color_b") / 255.0

	Light.set_intensity(_light_object, intensity)
	Light.set_falloff_start(_light_object, 0.0)
	Light.set_falloff_end(_light_object, radius)
	Light.set_color(_light_object, Vector3(color_r, color_g, color_b))
	Light.set_enabled(_light_object, true)
end

local function _destroy_light_unit()
	if _light_unit and Unit.alive(_light_unit) then
		local world = Unit.world(_light_unit)
		if world then
			World.destroy_unit(world, _light_unit)
		end
		_light_unit = nil
		_light_object = nil
	end
end

local function _update_light_position()
	if not mod:get("enabled") then
		if _light_object then
			Light.set_enabled(_light_object, false)
		end
		return
	end

	local is_third_person = _is_in_third_person()

	if not is_third_person then
		if _light_object then
			Light.set_enabled(_light_object, false)
		end
		_is_third_person = false
		return
	end

	if not _is_third_person then
		_is_third_person = true
	end

	local camera_position, camera_rotation = _get_camera_position()
	if not camera_position then
		return
	end

	local world = Managers.world:world("level_world")
	if not world then
		return
	end

	if not _light_unit or not Unit.alive(_light_unit) then
		_create_light_unit(world, camera_position, camera_rotation or Quaternion.identity())
		_update_light_settings()
	else
		local world_pose = Matrix4x4.from_quaternion_position(camera_rotation or Quaternion.identity(), camera_position)
		Unit.set_world_pose(_light_unit, 1, world_pose)
	end

	if _light_object then
		Light.set_enabled(_light_object, true)
		_update_light_settings()
	end
end

mod.on_game_state_changed = function(status, state_name)
	if status == "enter" and state_name == "GameplayStateMain" then
		_player_unit = nil
		_is_third_person = false
		_destroy_light_unit()
	elseif status == "exit" and state_name == "GameplayStateMain" then
		_destroy_light_unit()
		_player_unit = nil
		_is_third_person = false
	end
end

mod.on_player_unit_spawned = function(player_unit)
	if not player_unit then
		return
	end

	local player = Managers.state.player_unit_spawn:owner(player_unit)
	if not player then
		return
	end

	if not player:is_human_controlled() or not player.local_player then
		return
	end

	_player_unit = player_unit
	_is_third_person = false
end

mod.on_player_unit_despawned = function(player_unit)
	if _player_unit == player_unit then
		_destroy_light_unit()
		_player_unit = nil
		_is_third_person = false
	end
end

mod.update = function(dt)
	if not _player_unit or not Unit.alive(_player_unit) then
		if _light_object then
			Light.set_enabled(_light_object, false)
		end
		return
	end

	_update_light_position()
end

mod.on_destroy = function()
	_destroy_light_unit()
	_player_unit = nil
	_light_unit = nil
	_light_object = nil
	_is_third_person = false
end

