local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local hud_body_font_settings = UIFontSettings.hud_body or {}

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	root = {
		parent = "screen",
		scale = "fit",
		size = {1920, 1080},
		position = {0, 0, 0},
	},
	panel = {
		parent = "root",
		scale = "fit",
		size = {1200, 800},
		position = {0, -50, 1},
	},
}

local widget_definitions = {
	title = UIWidget.create_definition({
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			value = "Killsboard (WIP)",
			style = {
				font_type = hud_body_font_settings.font_type or "machine_medium",
				font_size = 28,
				text_horizontal_alignment = "center",
				text_vertical_alignment = "top",
				text_color = {255, 255, 255, 255},
				offset = {0, 360, 2},
				size = {1200, 40},
			},
		},
	}, "panel"),
	background = UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "bg",
			style = {
				color = {180, 10, 10, 10},
				size = {1200, 800},
				offset = {0, 0, 0},
			},
		},
	}, "panel"),
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
}

