local CompassBarSettings = {
	-- Размеры компаса
	width = 600,
	height = 40,
	
	-- Позиция (по умолчанию вверху по центру)
	position_x = 0,
	position_y = 20,
	
	-- Количество делений (360 градусов / steps)
	steps = 72, -- 5 градусов на деление
	
	-- Видимые деления (сколько показывать одновременно)
	-- Правила:
	-- - Минимум: 2 (иначе деление на 0 в marker_spacing)
	-- - Максимум: steps (не больше общего количества делений)
	-- - Рекомендуется: 10-30 для читаемости
	-- - Чем больше значение, тем больше делений видно, но они ближе друг к другу
	visible_steps = 20,
	
	-- Размеры делений
	step_width = 2,
	step_height_small = 15,
	step_height_large = 25,
	
	-- Расстояние между делениями (автоматически вычисляется)
	marker_spacing = nil, -- Будет вычислено в init
	
	-- Цвета
	step_color = {255, 255, 255, 255}, -- Белый
	text_color = {255, 255, 255, 255}, -- Белый
	cardinal_color = {255, 255, 200, 0}, -- Желтый для N/S/E/W
	
	-- Настройки текста
	font_size_small = 12,
	font_size_big = 16,
	font_type = "machine_medium",
	
	-- Начало затухания (0.0 - 1.0)
	step_fade_start = 0.6,
	
	-- Направления (N, S, E, W)
	degree_direction_abbreviations = {
		[0] = "N",
		[90] = "E",
		[180] = "S",
		[270] = "W",
	},
	
	-- Настройки маркеров тимейтов
	teammate_icon_size = 20, -- Размер иконки тимейта
	teammate_icon_offset_y = -30, -- Смещение иконки по Y (отрицательное = выше компаса)
}

-- Вычисляем расстояние между делениями
CompassBarSettings.marker_spacing = CompassBarSettings.width / (CompassBarSettings.visible_steps - 1)

return CompassBarSettings
