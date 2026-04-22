local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}

local ABILITY_ICON_GAP = 6
local ABILITY_ICON_SIZE = 32
local ABILITY_ICON_OVERLAP = 8
local ABILITY_ICON_ENTER_DUR = 0.2
local ABILITY_ICON_EXIT_DUR = 0.16
local ABILITY_ICON_MATERIAL = "content/ui/materials/icons/talents/hud/combat_container"

local function build_scenegraph(ability_bar_width, ability_bar_strip_height)
	local area_width = ABILITY_ICON_SIZE
	local area_height = ABILITY_ICON_SIZE
	local anchor_x = ability_bar_width + ABILITY_ICON_GAP

	return {
		div_ability_icon_anchor = {
			parent = "ability_bar",
			horizontal_alignment = "left",
			vertical_alignment = "bottom",
			size = { area_width, area_height },
			position = { anchor_x, 0, 10 },
		},
		div_ability_icon_area = {
			parent = "div_ability_icon_anchor",
			horizontal_alignment = "left",
			vertical_alignment = "bottom",
			size = { area_width, area_height },
			position = { 0, 0, 0 },
		},
	}
end

local function build_widget_definition()
	local size = ABILITY_ICON_SIZE

	return UIWidget.create_definition({
		{
			pass_type = "texture",
			value = ABILITY_ICON_MATERIAL,
			style_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				material_values = {
					progress = 1,
					talent_icon = nil,
				},
				size = { size, size },
				offset = { 0, 0, 1 },
				color = { 255, 255, 255, 255 },
			},
			change_function = function(content, style)
				style.material_values.progress = content.duration_progress or 1
			end,
		},
	}, "div_ability_icon_area")
end

function M.build(ability_bar_width, ability_bar_strip_height)
	local scenegraph_definition = build_scenegraph(ability_bar_width, ability_bar_strip_height)

	return {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = {
			ability_icon = build_widget_definition(),
		},
		ABILITY_ICON_SIZE = ABILITY_ICON_SIZE,
		ABILITY_ICON_OVERLAP = ABILITY_ICON_OVERLAP,
		ABILITY_ICON_ENTER_DUR = ABILITY_ICON_ENTER_DUR,
		ABILITY_ICON_EXIT_DUR = ABILITY_ICON_EXIT_DUR,
	}
end

return M
