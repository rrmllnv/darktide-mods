local mod = get_mod("TeamKills")

local Color = Color

-- Функция для создания определения scenegraph для основного контейнера доски
-- Используется в WidgetDefinitions.lua и TacticalOverlay.lua
local function create_killsboard_scenegraph(settings, base_z)
	base_z = base_z or settings.killsboard_base_z or 200
	
	return {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = {settings.killsboard_size[1], settings.killsboard_size[2]},
		position = {0, 0, base_z}
	}
end

-- Функция для создания определения scenegraph для строк таблицы
-- Используется в WidgetDefinitions.lua и TacticalOverlay.lua
local function create_killsboard_rows_scenegraph(settings, base_z)
	base_z = base_z or settings.killsboard_base_z or 200
	
	-- Вычисляем начальную высоту области строк: общая высота минус отступы сверху и снизу
	-- При vertical_alignment = "top" размер ограничивает область снизу, создавая отступ снизу
	-- Если killsboard_rows_bottom_offset = 10, то rows_height будет на 10 пикселей меньше,
	-- что создаст визуальный отступ снизу (строки не будут доходить до низа фона)
	-- Этот размер будет обновлен динамически через adjust_killsboard_size
	local rows_height = settings.killsboard_size[2] - settings.killsboard_rows_top_offset - settings.killsboard_rows_bottom_offset
	
	return {
		vertical_alignment = "top",
		parent = "killsboard",
		horizontal_alignment = "center",
		size = {settings.killsboard_size[1], rows_height},
		position = {0, settings.killsboard_rows_top_offset, base_z + 1}
	}
end

-- Функция для создания определения фона доски
-- Используется в WidgetDefinitions.lua и TacticalOverlay.lua
local function create_killsboard_background_passes(settings, base_x, base_z)
	base_x = base_x or 0
	base_z = base_z or settings.killsboard_base_z or 200
	
	return {
		{
			pass_type = "texture",
			style_id = "background",
			value = "content/ui/materials/backgrounds/terminal_basic",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "center",
				size_addition = {
					30,
					30,
				},
				offset = {
					base_x,
					0,
					base_z + 1,
				},
				color = Color.terminal_grid_background(255, true),
			},
		},
		{
			pass_type = "rect",
			style = {
				color = Color.black(240, true)
			},
			offset = {
				base_x,
				0,
				base_z + 1
			}
		},
		{
			pass_type = "texture_uv",
			style_id = "top_divider",
			value = "content/ui/materials/dividers/horizontal_frame_big_lower",
			value_id = "top_divider",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "top",
				size_addition = {
					20,
					0,
				},
				size = {
					nil,
					36,
				},
				offset = {
					base_x,
					-20,
					base_z + 2,
				},
				uvs = {
					{
						0,
						1,
					},
					{
						1,
						0,
					},
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "bottom_divider",
			value = "content/ui/materials/dividers/horizontal_frame_big_lower",
			value_id = "bottom_divider",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "bottom",
				size_addition = {
					20,
					0,
				},
				size = {
					nil,
					36,
				},
				offset = {
					base_x,
					20,
					base_z + 2,
				},
			},
		},
	}
end

return {
	create_killsboard_background_passes = create_killsboard_background_passes,
	create_killsboard_scenegraph = create_killsboard_scenegraph,
	create_killsboard_rows_scenegraph = create_killsboard_rows_scenegraph,
}

