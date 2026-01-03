local constants = {}

constants.sessions_panel_size = {400, 700}
constants.messages_panel_size = {800, 700}
constants.scrollbar_width = 10
constants.sessions_grid_size = {constants.sessions_panel_size[1] - 40, constants.sessions_panel_size[2] - 40}
constants.messages_grid_size = {constants.messages_panel_size[1] - 40, constants.messages_panel_size[2] - 40}
constants.sessions_mask_size = {constants.sessions_grid_size[1] + 32, constants.sessions_grid_size[2] + 32}
constants.messages_mask_size = {constants.messages_grid_size[1] + 32, constants.messages_grid_size[2] + 32}

constants.legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "cb_on_back_pressed",
		display_name = "loc_class_selection_button_back",
		alignment = "left_alignment",
	},
}

return constants

