local mod = get_mod("CompassBar")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local CompassBarSettings = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_settings")

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	CompassBarContainer = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = {CompassBarSettings.width, CompassBarSettings.height},
		position = {CompassBarSettings.position_x, CompassBarSettings.position_y, 100},
	},
	debug_text_anchor = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {400, 200},
		position = {20, 20, 200},
	},
}

local widget_definitions = {
	debug_text = UIWidget.create_definition({
		{
			value = "",
			value_id = "text",
			pass_type = "text",
			style = {
				text_vertical_alignment = "top",
				text_horizontal_alignment = "left",
				text_color = Color.white(255, true),
				font_type = "machine_medium",
				font_size = 16,
			},
		},
	}, "debug_text_anchor"),
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
}
