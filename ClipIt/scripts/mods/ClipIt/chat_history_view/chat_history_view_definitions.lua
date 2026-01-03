local mod = get_mod("ClipIt")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")

local constants = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_constants")

local sessions_panel_size = constants.sessions_panel_size
local messages_panel_size = constants.messages_panel_size

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	dim_background = {
		parent = "screen",
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = {1920, 1080},
		position = {0, 0, -5},
	},
	background = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = {1250, 800},
		position = {0, 0, 0},
	},
	title_bar = {
		parent = "background",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = {1250, 60},
		position = {0, 0, 10},
	},
	sessions_panel = {
		parent = "background",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = sessions_panel_size,
		position = {20, 80, 0},
	},
	sessions_panel_background = {
		parent = "sessions_panel",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = sessions_panel_size,
		position = {0, 0, -1},
	},
	sessions_grid_pivot = {
		parent = "sessions_panel",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {0, 0},
		position = {20, 20, 3},
	},
	sessions_grid_background = {
		parent = "sessions_panel",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = sessions_panel_size,
		position = {0, 0, 0},
	},
	messages_panel = {
		parent = "background",
		vertical_alignment = "top",
		horizontal_alignment = "right",
		size = messages_panel_size,
		position = {-20, 80, 0},
	},
	messages_panel_background = {
		parent = "messages_panel",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = messages_panel_size,
		position = {0, 0, -1},
	},
	messages_grid_pivot = {
		parent = "messages_panel",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {0, 0},
		position = {20, 20, 3},
	},
	messages_grid_background = {
		parent = "messages_panel",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = messages_panel_size,
		position = {0, 0, 0},
	},
}

local widget_definitions = {
	dim_background = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = {180, 0, 0, 0},
			},
		},
	}, "dim_background"),
	
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
	
	sessions_panel_background = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = {180, 0, 0, 0},
			},
		},
	}, "sessions_panel_background"),
	
	messages_panel_background = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = {180, 0, 0, 0},
			},
		},
	}, "messages_panel_background"),
}

local legend_inputs = constants.legend_inputs

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	legend_inputs = legend_inputs,
}

