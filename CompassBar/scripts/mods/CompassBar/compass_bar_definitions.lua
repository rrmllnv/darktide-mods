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
}

local widget_definitions = {}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
}
