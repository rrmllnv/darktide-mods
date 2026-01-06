local mod = get_mod("PerspectivesRedux")

-- ============================================================================
-- КОНСТАНТЫ
-- ============================================================================
local MAX_RAYCAST_DISTANCE = 1000

-- ============================================================================
-- СОСТОЯНИЕ
-- ============================================================================
local world = nil
local line_object = nil
local is_enabled = false

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

-- Инициализация системы визуализации
local _init_tracer_system = function()
	-- Проверяем, что Managers.world доступен
	if not Managers.world then
		return
	end
	
	if not world then
		world = Managers.world:world("level_world")
		if world then
			-- Очищаем старый line_object если он был (на случай переинициализации)
			if line_object then
				LineObject.reset(line_object)
				LineObject.dispatch(world, line_object)
				World.destroy_line_object(world, line_object)
			end
			line_object = World.create_line_object(world)
		end
	end
end

-- Очистка системы визуализации
local _cleanup_tracer_system = function()
	if line_object and world then
		LineObject.reset(line_object)
		LineObject.dispatch(world, line_object)
		World.destroy_line_object(world, line_object)
		line_object = nil
	end
	-- Сбрасываем world чтобы при следующем включении система переинициализировалась
	world = nil
end

-- Получить позицию дула оружия (muzzle position) для игрока
local _get_muzzle_position = function(player_unit)
	if not player_unit then
		return nil
	end
	
	-- Получаем visual_loadout_extension для доступа к оружию
	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
	if not visual_loadout_extension then
		return nil
	end
	
	-- Получаем текущий слот оружия
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	if not unit_data_extension then
		return nil
	end
	
	local inventory_component = unit_data_extension:read_component("inventory")
	if not inventory_component then
		return nil
	end
	
	local wielded_slot = inventory_component.wielded_slot
	if not wielded_slot or wielded_slot == "none" then
		return nil
	end
	
	-- Получаем юниты оружия (1P и 3P) и их attachments
	local unit_1p, unit_3p, attachments_by_unit_1p, attachments_by_unit_3p = visual_loadout_extension:unit_and_attachments_from_slot(wielded_slot)
	
	-- Получаем weapon_template для доступа к fx_sources
	local weapon_template = visual_loadout_extension:weapon_template_from_slot(wielded_slot)
	if not weapon_template or not weapon_template.fx_sources then
		return nil
	end
	
	-- Используем метод visual_loadout_extension для получения ноды дула
	-- Ключ "_muzzle" используется для поиска в fx_sources
	local node_name = "_muzzle"
	local node_unit_1p, node_index_1p, node_unit_3p, node_index_3p = visual_loadout_extension:unit_and_node_from_node_name(wielded_slot, node_name)
	
	-- Приоритет отдаем 1P ноде (для первого лица)
	local muzzle_unit = node_unit_1p
	local muzzle_node = node_index_1p
	
	-- Если нет 1P ноды, используем 3P
	if not muzzle_unit then
		muzzle_unit = node_unit_3p
		muzzle_node = node_index_3p
	end
	
	if not muzzle_unit or not muzzle_node then
		return nil
	end
	
	local muzzle_position = Unit.world_position(muzzle_unit, muzzle_node)
	return muzzle_position
end

-- Получить позицию и направление прицеливания
local _get_aim_data = function()
	local player_unit = mod.get_player_unit()
	if not player_unit then
		return nil, nil
	end
	
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	if not unit_data_extension then
		return nil, nil
	end
	
	local first_person_component = unit_data_extension:read_component("first_person")
	if not first_person_component then
		return nil, nil
	end
	
	local rotation = first_person_component.rotation
	if not rotation then
		return nil, nil
	end
	
	local direction = Quaternion.forward(rotation)
	
	-- Пытаемся получить позицию дула оружия
	local muzzle_position = _get_muzzle_position(player_unit)
	
	-- Если не удалось получить позицию дула, используем позицию из first_person_component
	local position = muzzle_position or first_person_component.position
	
	if not position then
		return nil, nil
	end
	
	return position, direction
end

-- Выполнить raycast для определения точки попадания
local _raycast_hit = function(position, direction)
	if not world then
		return nil, position + direction * MAX_RAYCAST_DISTANCE
	end
	
	local physics_world = World.get_data(world, "physics_world")
	if not physics_world then
		return nil, position + direction * MAX_RAYCAST_DISTANCE
	end
	
	local result = PhysicsWorld.immediate_raycast(
		physics_world,
		position,
		direction,
		MAX_RAYCAST_DISTANCE,
		"all",
		"types",
		"both",
		"collision_filter",
		"filter_player_character_shooting_raycast_statics"
	)
	
	if result and #result > 0 then
		local hit = result[1]
		local hit_position = hit[1]
		return hit_position, hit_position
	end
	
	return nil, position + direction * MAX_RAYCAST_DISTANCE
end

-- Обновить отрисовку луча
local _update_beam = function()
	if not line_object or not world or not is_enabled then
		return
	end
	
	-- Получаем позицию и направление прицеливания
	local position, direction = _get_aim_data()
	if not position or not direction then
		LineObject.reset(line_object)
		LineObject.dispatch(world, line_object)
		return
	end
	
	-- Выполняем raycast для определения точки попадания
	local hit_position, end_position = _raycast_hit(position, direction)
	
	-- Получаем цвет из настроек
	local color_array = {
		mod:get("tracer_color_r"),
		mod:get("tracer_color_g"),
		mod:get("tracer_color_b")
	}
	
	local alpha = 255
	local final_color = Color(alpha, color_array[1], color_array[2], color_array[3])
	
	-- Отрисовываем луч
	LineObject.reset(line_object)
	
	-- Основной луч от позиции до точки попадания
	LineObject.add_segmented_line(line_object, final_color, position, end_position, 0, 1)
	
	-- Если есть точка попадания, рисуем крестик на месте попадания
	if hit_position then
		local up_vector = Vector3(0, 0, 1)
		local right_vector = Vector3.cross(direction, up_vector)
		
		if Vector3.length(right_vector) < 0.001 then
			right_vector = Vector3(1, 0, 0)
		else
			right_vector = Vector3.normalize(right_vector)
		end
		
		local forward_vector = Vector3.cross(right_vector, direction)
		forward_vector = Vector3.normalize(forward_vector)
		
		local hit_marker_size = 0.1
		local hit_offset1 = right_vector * hit_marker_size
		local hit_offset2 = forward_vector * hit_marker_size
		
		LineObject.add_line(line_object, final_color, hit_position - hit_offset1, hit_position + hit_offset1)
		LineObject.add_line(line_object, final_color, hit_position - hit_offset2, hit_position + hit_offset2)
	end
	
	LineObject.dispatch(world, line_object)
end

-- ============================================================================
-- ЭКСПОРТИРУЕМЫЕ ФУНКЦИИ
-- ============================================================================

-- Включить/выключить систему
mod.set_tracer_enabled = function(enabled)
	is_enabled = enabled
	if enabled then
		-- При включении сразу пытаемся инициализировать систему
		_init_tracer_system()
	else
		-- При выключении очищаем систему
		_cleanup_tracer_system()
	end
end

-- Обновление системы (вызывается каждый кадр)
mod.update_tracer_system = function()
	if is_enabled then
		_init_tracer_system()
		_update_beam()
	end
end

-- Очистка при выгрузке
mod.cleanup_tracer_system = function()
	_cleanup_tracer_system()
end

