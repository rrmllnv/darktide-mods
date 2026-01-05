local mod = get_mod("PerspectivesRedux")
local CameraSettings = require("scripts/settings/camera/camera_settings")

-- Константы FOV
local FOV_NORMAL = 62.5
local FOV_ZOOM = 55.0
local CUSTOM_MULT = 0.75

-- Кэшированные значения настроек
local custom_distance = 0.0
local custom_offset = 0.0
local custom_distance_zoom = 0.0
local custom_offset_zoom = 0.0

-- Смещения камеры
-- +x/-x = right/left
-- +y/-y = forward/back
-- +z/-z = up/down
local ogryn_offset = {
	x = 0.0,
	y = 0.0,
	z = 0.0,
}

local shoulder_offset = {
	x = 0.5,
	y = 0.0,
	z = 0.0,
}

-- Запечённое смещение для огрина (обновляется при рефреше)
local ogryn_shoulder_bake = { x = 0.0, y = 0.0, z = 0.0 }

-- Флаг необходимости обновления дерева камеры
local camera_tree_needs_update = false

-- Применить трансформацию смещения
-- flip: true (зеркально), false (как есть), nil (центр)
-- is_zoom: применить зум-настройки
-- ignore_custom_offset: игнорировать кастомное смещение
local _transform_offset = function(offset, flip, is_zoom, ignore_custom_offset)
	-- Корректировка дистанции при зуме
	if is_zoom then
		offset.y = offset.y + custom_distance - custom_distance_zoom
	end

	-- Применение кастомного смещения
	if not ignore_custom_offset then
		local offset_amt = is_zoom and (custom_offset_zoom - custom_offset) or custom_offset
		if flip == nil then
			-- Центральная позиция - смещение по Z
			offset.z = offset.z + offset_amt
		else
			-- Боковая позиция - смещение по X
			offset.x = offset.x + offset_amt
		end
	end

	-- Зеркалирование для левой стороны
	if flip then
		offset.x = -offset.x
	end

	return offset
end

-- Получить смещение плеча
local _get_shoulder_offset = function(left)
	return _transform_offset(table.clone(shoulder_offset), left)
end

-- Получить смещение плеча с зумом
local _get_shoulder_zoom_offset = function(left)
	return _transform_offset({
		x = -0.1,
		y = 0.65,
		z = -0.1,
	}, left, true)
end

-- Получить смещение плеча для огрина
local _get_ogryn_shoulder_offset = function(left)
	return _transform_offset(table.clone(ogryn_shoulder_bake), left, false, true)
end

-- Получить смещение плеча с зумом для огрина
local _get_ogryn_shoulder_zoom_offset = function(left)
	return _transform_offset({
		x = -0.1,
		y = 0.65,
		z = 0.0,
	}, left, true)
end

-- Найти индекс дочернего узла по имени
local _node_get_child_idx = function(node, child_name)
	for i, n in pairs(node) do
		if i ~= "_node" then
			if n._node.name == child_name then
				return i
			end
		end
	end
	return #node + 1
end

-- Добавить дочерний узел к родителю
local _node_add_child = function(parent, child)
	parent[_node_get_child_idx(parent, child._node.name)] = child
end

-- Создать узел камеры
local _create_node = function(name, offset, fov)
	return {
		near_range = 0.025,
		name = name,
		class = "TransformCamera",
		custom_vertical_fov = fov,
		vertical_fov = fov,
		offset_position = offset
	}
end

-- Модифицировать дерево камеры third_person
local function _alter_third_person_tree(node)
	if node then
		if node._node.name == "third_person" then
			-- Добавляем все кастомные узлы камеры для мода
			_node_add_child(node, {
				{
					{
						{
							_node = _create_node("pspv_right_zoom_ogryn", _get_ogryn_shoulder_zoom_offset(false), FOV_ZOOM)
						},
						_node = _create_node("pspv_right_ogryn", _get_ogryn_shoulder_offset(false))
					},
					{
						_node = _create_node("pspv_right_zoom", _get_shoulder_zoom_offset(false), FOV_ZOOM)
					},
					_node = _create_node("pspv_right", _get_shoulder_offset(false))
				},
				{
					{
						{
							_node = _create_node("pspv_left_zoom_ogryn", _get_ogryn_shoulder_zoom_offset(true), FOV_ZOOM)
						},
						_node = _create_node("pspv_left_ogryn", _get_ogryn_shoulder_offset(true))
					},
					{
						_node = _create_node("pspv_left_zoom", _get_shoulder_zoom_offset(true), FOV_ZOOM)
					},
					_node = _create_node("pspv_left", _get_shoulder_offset(true))
				},
				{
					{
						{
							_node = _create_node("pspv_center_zoom_ogryn", _transform_offset({
								x = 0.0,
								y = 1.8,
								z = -0.2,
							}, nil, true), FOV_ZOOM)
						},
						_node = _create_node("pspv_center_ogryn", _transform_offset(ogryn_offset, nil, false, true))
					},
					{
						_node = _create_node("pspv_center_zoom", _transform_offset({
							x = 0.0,
							y = 1.0,
							z = -0.3,
						}, nil, true), FOV_ZOOM)
					},
					_node = _create_node("pspv_center", _transform_offset({
						x = 0.0,
						y = 0.0,
						z = 0.2,
					}, nil))
				},
				{
					{
						_node = _create_node("pspv_lookaround_ogryn", ogryn_offset)
					},
					_node = _create_node("pspv_lookaround", {
						x = 0.0,
						y = -0.5,
						z = -0.5,
					})
				},
				_node = _create_node("pspv_root", {
					x = 0.0,
					y = 0.5 - custom_distance,
					z = -0.1,
				}, FOV_NORMAL)
			})
		end

		-- Рекурсивно обработать дочерние узлы
		for i, n in pairs(node) do
			if i ~= "_node" then
				_alter_third_person_tree(n)
			end
		end
	end
end

-- Обновить дерево камеры
local _refresh_camera_trees = function()
	-- Запечь смещение плеча для огрина
	ogryn_shoulder_bake.x = ogryn_offset.x + shoulder_offset.x
	ogryn_shoulder_bake.y = ogryn_offset.y + shoulder_offset.y
	ogryn_shoulder_bake.z = ogryn_offset.z + shoulder_offset.z
	
	-- Модифицировать дерево камеры
	_alter_third_person_tree(CameraSettings.player_third_person)
	
	-- Безопасно перезагрузить camera handler
	local camera_handler = mod.get_camera_handler()
	if camera_handler then
		local success, error_msg = pcall(function()
			if camera_handler.on_reload then
				camera_handler:on_reload()
			end
		end)
		
		if not success then
			mod:error("Failed to reload camera handler: %s", error_msg)
		end
	end
	
	camera_tree_needs_update = false
end

-- Инициализация дерева камеры
_refresh_camera_trees()

-- Отметить дерево камеры для обновления (отложенное обновление)
mod.mark_camera_tree_dirty = function()
	camera_tree_needs_update = true
end

-- Применить обновление если нужно
mod.apply_camera_tree_update = function()
	if camera_tree_needs_update then
		_refresh_camera_trees()
	end
end

-- Применить кастомные настройки viewpoint
mod.apply_custom_viewpoint = function()
	ogryn_offset.y = -mod:get("custom_distance_ogryn") * CUSTOM_MULT - 0.75
	ogryn_offset.z = mod:get("custom_offset_ogryn") * CUSTOM_MULT - 0.1
	custom_distance = mod:get("custom_distance") * CUSTOM_MULT
	custom_offset = mod:get("custom_offset") * CUSTOM_MULT
	custom_distance_zoom = mod:get("custom_distance_zoom") * CUSTOM_MULT
	custom_offset_zoom = mod:get("custom_offset_zoom") * CUSTOM_MULT
	_refresh_camera_trees()
end

