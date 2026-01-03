local mod = get_mod("ClipIt")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	canvas = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = {1920, 1080},
		position = {0, 0, 0},
	},
	corner_top_left = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {0, 0},
		position = {0, 0, 0},
	},
	corner_top_right = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "right",
		size = {0, 0},
		position = {0, 0, 0},
	},
	corner_bottom_left = {
		parent = "screen",
		vertical_alignment = "bottom",
		horizontal_alignment = "left",
		size = {0, 0},
		position = {0, 0, 0},
	},
	corner_bottom_right = {
		parent = "screen",
		vertical_alignment = "bottom",
		horizontal_alignment = "right",
		size = {0, 0},
		position = {0, 0, 0},
	},
	background = {
		parent = "canvas",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = {1000, 800},
		position = {0, 0, 0},
	},
	title_bar = {
		parent = "background",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = {1000, 60},
		position = {0, 0, 10},
	},
	grid_background = {
		parent = "background",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = {900, 680},
		position = {0, -40, 1},
	},
	grid = {
		parent = "grid_background",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {880, 660},
		position = {10, 10, 1},
	},
	grid_content = {
		parent = "grid",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {880, 0},
		position = {0, 0, 1},
	},
	scrollbar = {
		parent = "grid",
		vertical_alignment = "center",
		horizontal_alignment = "right",
		size = {20, 660},
		position = {20, 0, 10},
	},
}

local widget_definitions = {
	background = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/backgrounds/default_square",
			style = {
				color = {220, 0, 0, 0},
			},
		},
	}, "background"),
	
	title = UIWidget.create_definition({
		{
			pass_type = "text",
			value = "Chat History",
			value_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 32,
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				text_color = {255, 255, 255, 255},
				offset = {0, 0, 2},
			},
		},
	}, "title_bar"),
	
	grid_background = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/backgrounds/default_square",
			style = {
				color = {180, 10, 10, 10},
			},
		},
	}, "grid_background"),
}

local legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "_on_back_pressed",
		display_name = "loc_class_selection_button_back",
		alignment = "left_alignment",
	},
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	legend_inputs = legend_inputs,
}

