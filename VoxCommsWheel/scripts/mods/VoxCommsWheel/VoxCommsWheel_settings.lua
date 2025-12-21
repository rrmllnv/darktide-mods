local command_wheel_settings = {
	anim_speed = 25,
	max_radius = 190,
	min_radius = 150,
	center_circle_size = 250,
	rhombus_width = nil,
	rhombus_height = nil,
	hover_min_distance = 130,
	hover_angle_degrees = 30,
	scan_delay = 0.1,
	hover_grace_period = 0.1,
	wheel_slots = 10,
	slice_width = 156,
	slice_height = 134,
	slice_uv_left = 0.0,
	slice_uv_right = 1.0,
	slice_uv_top = 0.1,
	slice_uv_bottom = 1.0,
	icon_size = 50, -- Размер иконок на кнопках
	line_width = 200,
	line_height = 147,
	line_height_scale = 2.5,
	slice_curvature_scale_x = 1.0,
	slice_curvature_scale_y = 1.0,
	background_color = {255, 0, 0, 0},
	rhombus_color = {120, 0, 0, 0},
	button_color_default = {190, 0, 0, 0},
	button_color_hover = {220, 0, 0, 0},
	icon_color_default = {255, 255, 255, 255}, -- Белый цвет иконок по умолчанию
	icon_color_hover = {255, 255, 200, 255}, -- Светло-желтый цвет при наведении
	line_color_default = nil,
	line_color_hover = nil,
	-- Настройки для текста
	text_font_size = 16,
	text_color = {255, 255, 255, 255},
	text_color_hover = {255, 255, 200, 255},
	-- Настройки для страниц
	page_indicator_size = 20,
	page_indicator_spacing = 10,
}

return settings("CommandWheelSettings", command_wheel_settings)

