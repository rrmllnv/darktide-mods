local constants = {}

-- Размеры панелей (как в GlobalStat)
constants.category_panel_size = {450, 820}
constants.messages_panel_size = {1050, 820}
constants.scrollbar_width = 10

-- Размеры сеток
constants.grid_size = {constants.messages_panel_size[1] - 140, constants.messages_panel_size[2] - 120}
constants.mask_size = {constants.grid_size[1] + 32, constants.grid_size[2] + 32}

-- Размеры кнопок в левой панели
constants.button_height = 80
constants.button_spacing = 6

-- Легенда кнопок
constants.legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "cb_on_back_pressed",
		display_name = "loc_settings_menu_close_menu",
		alignment = "left_alignment",
	},
}

return constants

