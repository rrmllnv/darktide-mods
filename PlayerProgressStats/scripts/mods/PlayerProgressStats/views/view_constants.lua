local constants = {}

constants.DEBUG = false

constants.category_panel_size = {500, 820}
constants.stats_panel_size = {1000, 820}
constants.tab_height = 64
constants.tab_spacing = 6
constants.scrollbar_width = 10
constants.grid_size = {constants.stats_panel_size[1] - 140, constants.stats_panel_size[2] - 120}
constants.mask_size = {constants.grid_size[1] + 32, constants.grid_size[2] + 32}

constants.tabs_definitions = {
	{key = "tab_general", fallback = "GENERAL"},
	{key = "tab_enemies", fallback = "ENEMIES"},
	{key = "tab_missions", fallback = "MISSIONS"},
	{key = "tab_mission_progress", fallback = "MISSION PROGRESS"},
	-- {key = "tab_records", fallback = "RECORDS"}, -- временно скрываем кнопку "Рекорды"
}

if constants.DEBUG then
	table.insert(constants.tabs_definitions, {key = "tab_localization_debug", fallback = "LOCALIZATION"})
end

constants.legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "cb_on_back_pressed",
		display_name = "loc_settings_menu_close_menu",
		alignment = "left_alignment",
	},
}

return constants

