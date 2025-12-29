local mod = get_mod("TeamKills")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Color = Color
local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
local WidgetBackground = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetBackground")
local base_z = KillstreakWidgetSettings.killsboard_base_z

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    killsboard = WidgetBackground.create_killsboard_scenegraph(KillstreakWidgetSettings, base_z),
    killsboard_rows = WidgetBackground.create_killsboard_rows_scenegraph(KillstreakWidgetSettings, base_z),
}

local widget_definitions = {}

local base_x = 0
local background_passes = WidgetBackground.create_killsboard_background_passes(KillstreakWidgetSettings, base_x, base_z)

widget_definitions.killsboard = UIWidget.create_definition(background_passes, "killsboard")

local KillsboardViewDefinitions = {
    widget_definitions = widget_definitions,
    scenegraph_definition = scenegraph_definition
}

return settings("KillstreakWidgetDefinitions", KillsboardViewDefinitions)
