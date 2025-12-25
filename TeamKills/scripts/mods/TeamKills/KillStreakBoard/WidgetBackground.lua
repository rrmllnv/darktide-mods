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
	
	-- Используем минимальную высоту как начальный размер, чтобы избежать смещения при первом отображении
	-- Размер будет обновлен через adjust_killsboard_size после создания строк
	local initial_height = settings.killsboard_min_height or settings.killsboard_size[2]
	local rows_height = initial_height - settings.killsboard_rows_top_offset - settings.killsboard_rows_bottom_offset
	
	return {
		vertical_alignment = "top",
		parent = "killsboard",
		horizontal_alignment = "center",
		size = {settings.killsboard_size[1], rows_height},
		-- position[3] = 10, так как parent "killsboard" уже имеет base_z, итоговая z будет base_z + 10
		-- Это обеспечивает, что строки будут поверх всех элементов фона и других слоев
		-- (фон: base_z+1, dividers: base_z+2, строки: base_z+10)
		position = {0, settings.killsboard_rows_top_offset, 10}
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
				-- offset[3] = 0, так как scenegraph "killsboard" уже имеет position[3] = base_z
				-- Итоговая z = base_z + 0 = 200, что ниже строк (base_z + 10 + 11 = 221)
				offset = {
					base_x,
					0,
					1,
				},
				color = Color.terminal_grid_background(255, true),
			},
		},
		{
			pass_type = "rect",
			style = {
				color = Color.black(240, true)
			},
			-- offset[3] = -1, чтобы rect был ниже background texture
			-- Итоговая z = base_z - 1 = 199
			offset = {
				base_x,
				0,
				-1
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
				-- offset[3] = 1, чтобы divider был выше background texture (0), но ниже строк (10+)
				-- Итоговая z = base_z + 1 = 201
				offset = {
					base_x,
					-20,
					1,
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
				-- offset[3] = 1, чтобы divider был выше background texture (0), но ниже строк (10+)
				-- Итоговая z = base_z + 1 = 201
				offset = {
					base_x,
					20,
					1,
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

