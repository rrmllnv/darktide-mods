local mod = get_mod("ThirdPersonLight")

-- Простая проверка режима третьего лица
local function check_third_person_mode()
	-- Безопасная проверка всех необходимых объектов
	if not Managers then
		return false
	end
	
	if not Managers.player then
		return false
	end

	-- Используем local_player_safe для безопасного получения игрока
	local player = Managers.player:local_player_safe(1)
	if not player then
		return false
	end

	-- Проверяем что у player есть player_unit
	if not player.player_unit then
		return false
	end

	local player_unit = player.player_unit
	if not Unit.alive(player_unit) then
		return false
	end

	-- Безопасная проверка расширения
	local first_person_extension = ScriptUnit.has_extension(player_unit, "first_person_system")
	if first_person_extension then
		-- Проверяем _force_third_person_mode от модов третьего лица
		if first_person_extension._force_third_person_mode == true then
			return true
		end

		-- Безопасный вызов wants_first_person_camera
		local wants_first_person_success, wants_first_person = pcall(function()
			return first_person_extension:wants_first_person_camera()
		end)
		
		if wants_first_person_success and wants_first_person ~= nil then
			return not wants_first_person
		end
	end

	return false
end

-- =========================================================================================
-- Камера-свет (независимый источник), по образцу `servo_friend`
-- =========================================================================================

local CAMERA_LIGHT_UNIT = "content/weapons/player/attachments/flashlights/flashlight_01/flashlight_01"
local CAMERA_LIGHT_IES_PROFILE = "content/environment/ies_profiles/narrow/flashlight_custom_02"
local CAMERA_LIGHT_COLOR_TEMPERATURE = 8000
local CAMERA_LIGHT_VOLUMETRIC_INTENSITY = 0.1

local _world = nil
local _camera_light_world = nil
local _camera_light_unit = nil
local _camera_light = nil

local function _get_level_world()
	if not Managers or not Managers.world then
		return nil
	end

	_world = _world or Managers.world:world("level_world")

	return _world
end

local function _destroy_camera_light()
	-- ВАЖНО: world для юнита должен совпадать с миром, в котором он был создан.
	-- Иначе `World.update_unit_and_children` / `World.destroy_unit` будут падать с "Unit not found".
	local world = _camera_light_world or _get_level_world()

	if _camera_light then
		_camera_light = nil
	end

	if world and _camera_light_unit and Unit.alive(_camera_light_unit) then
		pcall(function()
			World.destroy_unit(world, _camera_light_unit)
		end)
	end

	_camera_light_world = nil
	_camera_light_unit = nil
end

local function _apply_camera_light_settings()
	if not _camera_light or not _camera_light_unit or not Unit.alive(_camera_light_unit) then
		return
	end

	local intensity = mod:get("light_intensity") or 20
	local range = mod:get("light_range") or 30
	local angle_deg = mod:get("light_angle") or 35
	local cast_shadows = mod:get("cast_shadows") == true

	-- В шаблонах игры spot_angle хранится в радианах (см. `FlashlightTemplates`).
	local angle_rad = math.rad(angle_deg)

	Light.set_enabled(_camera_light, true)
	Light.set_casts_shadows(_camera_light, cast_shadows)
	Light.set_ies_profile(_camera_light, CAMERA_LIGHT_IES_PROFILE)
	Light.set_correlated_color_temperature(_camera_light, CAMERA_LIGHT_COLOR_TEMPERATURE)
	Light.set_intensity(_camera_light, intensity)
	Light.set_volumetric_intensity(_camera_light, CAMERA_LIGHT_VOLUMETRIC_INTENSITY)
	Light.set_spot_angle_start(_camera_light, 0)
	Light.set_spot_angle_end(_camera_light, angle_rad)
	Light.set_spot_reflector(_camera_light, false)
	Light.set_falloff_start(_camera_light, 0)
	Light.set_falloff_end(_camera_light, range)

	local color = Light.color_with_intensity(_camera_light)

	if color then
		Unit.set_vector3_for_materials(_camera_light_unit, "light_color", color)
	end
end

local function _ensure_camera_light()
	local world = _get_level_world()

	if not world then
		return false
	end

	if _camera_light_unit and Unit.alive(_camera_light_unit) and _camera_light then
		-- Если по какой-то причине мир не сохранён, фиксируем его,
		-- чтобы последующие `World.*` шли в корректный world.
		_camera_light_world = _camera_light_world or world

		return true
	end

	_destroy_camera_light()

	-- Спавним юнит фонарика (пакет уже прописан в `ThirdPersonLight.mod`).
	local spawn_success, spawned_unit = pcall(function()
		return World.spawn_unit_ex(world, CAMERA_LIGHT_UNIT, nil, Vector3.zero(), Quaternion.identity())
	end)

	if not spawn_success then
		_destroy_camera_light()
		return false
	end

	_camera_light_unit = spawned_unit
	_camera_light_world = world

	if not _camera_light_unit or not Unit.alive(_camera_light_unit) then
		_destroy_camera_light()
		return false
	end

	if Unit.num_lights(_camera_light_unit) <= 0 then
		_destroy_camera_light()
		return false
	end

	_camera_light = Unit.light(_camera_light_unit, 1)

	if not _camera_light then
		_destroy_camera_light()
		return false
	end

	_apply_camera_light_settings()
	return true
end

mod.update = function(dt)
	if not mod:get("enable_light") then
		_destroy_camera_light()
		return
	end

	if not check_third_person_mode() then
		_destroy_camera_light()
		return
	end

	local player_manager = Managers and Managers.player
	local camera_manager = Managers and Managers.state and Managers.state.camera

	if not player_manager or not camera_manager then
		return
	end

	local player = player_manager:local_player_safe(1)
	local viewport_name = player and player.viewport_name

	if not viewport_name or not camera_manager.camera_position or not camera_manager.camera_rotation then
		return
	end

	-- Защита от краша: viewport может быть ещё не создан (см. `CameraManager.has_viewport` в исходниках).
	if camera_manager.has_viewport and not camera_manager:has_viewport(viewport_name) then
		return
	end

	if not _ensure_camera_light() then
		return
	end
	
	-- Юнит мог быть удалён между кадрами/переходами (хаб/миссия). Проверяем максимально рано.
	if not _camera_light_unit or not Unit.alive(_camera_light_unit) then
		_destroy_camera_light()
		return
	end

	local camera_position = camera_manager:camera_position(viewport_name)
	local camera_rotation = camera_manager:camera_rotation(viewport_name)

	if not camera_position or not camera_rotation then
		return
	end

	Unit.set_local_position(_camera_light_unit, 1, camera_position)
	Unit.set_local_rotation(_camera_light_unit, 1, camera_rotation)

	local world = _camera_light_world or _get_level_world()

	if world then
		local ok = pcall(function()
			World.update_unit_and_children(world, _camera_light_unit)
		end)

		if not ok then
			_destroy_camera_light()
			return
		end
	end
end

-- Обработка изменения настроек
mod.on_setting_changed = function(setting_id)
	_apply_camera_light_settings()
end

-- Выгрузка мода
mod.on_unload = function(exit_game)
	_destroy_camera_light()
end
