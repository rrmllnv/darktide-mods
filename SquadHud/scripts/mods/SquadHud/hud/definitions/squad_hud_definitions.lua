local mod = get_mod("SquadHud")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local Settings = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/squad_hud_definition_settings")
local PassTemplates = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/pass_templates")
local AbilityIconDefinitions = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/ability_icon_definitions")
local PlayerInfoDefinitions = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/player_info_definitions")
local InventoryDefinitions = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/inventory_definitions")
local BarDefinitions = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/bar_definitions")
local ExpandedViewDefinitions = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/expanded_view_definitions")

local M = {
	settings = Settings,
}

local function create_scenegraph_definition()
	local scenegraph_definition = {
		screen = UIWorkspaceSettings.screen,
		squadhud_root = {
			horizontal_alignment = "left",
			parent = "screen",
			vertical_alignment = "top",
			size = {
				Settings.panel_width,
				Settings.root_height,
			},
			position = {
				20,
				130,
				1,
			},
		},
	}

	for i = 1, Settings.max_players do
		scenegraph_definition["squadhud_panel_" .. i] = {
			horizontal_alignment = "left",
			parent = "squadhud_root",
			vertical_alignment = "top",
			size = {
				Settings.panel_width,
				Settings.panel_height,
			},
			position = {
				0,
				(i - 1) * (Settings.panel_height + Settings.panel_gap),
				1,
			},
		}
	end

	ExpandedViewDefinitions.append_scenegraph(scenegraph_definition, Settings)

	return scenegraph_definition
end

local function create_panel_definition(scenegraph_id)
	local passes = {}

	PlayerInfoDefinitions.append_passes(passes, Settings, PassTemplates)
	AbilityIconDefinitions.append_passes(passes, Settings, PassTemplates)
	InventoryDefinitions.append_passes(passes, Settings, PassTemplates)
	BarDefinitions.append_passes(passes, Settings, PassTemplates)

	return UIWidget.create_definition(passes, scenegraph_id)
end

local function create_widget_definitions()
	local widget_definitions = {}

	for i = 1, Settings.max_players do
		widget_definitions["panel_" .. i] = create_panel_definition("squadhud_panel_" .. i)
	end

	widget_definitions.expanded_view_hint = ExpandedViewDefinitions.create_widget_definition("squadhud_expanded_view_hint", Settings, PassTemplates)

	return widget_definitions
end

M.scenegraph_definition = create_scenegraph_definition()
M.widget_definitions = create_widget_definitions()

return M
