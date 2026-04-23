local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}

function M.build(params)
	local sc = params.sc
	local right_gap = params.right_gap
	local right_bottom_row_y = params.right_bottom_row_y
	local right_bottom_slot_width = params.right_bottom_slot_width
	local right_bottom_slot_height = params.right_bottom_slot_height
	local slot_text_font = params.slot_text_font
	local expedition_salvage_slot_w = math.max(right_bottom_slot_width, sc(72))
	local expedition_salvage_slot_x = -(expedition_salvage_slot_w + right_gap)

	local text_style = table.clone(UIFontSettings.hud_body)

	text_style.font_size = slot_text_font
	text_style.drop_shadow = true
	text_style.horizontal_alignment = "right"
	text_style.vertical_alignment = "center"
	text_style.text_horizontal_alignment = "right"
	text_style.text_vertical_alignment = "center"
	text_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
	text_style.size = { expedition_salvage_slot_w, right_bottom_slot_height }
	text_style.offset = { 0, 0, 3 }

	return {
		scenegraph_definition = {
			division_expedition_salvage_slot = {
				parent = "boxes_row",
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = { expedition_salvage_slot_w, right_bottom_slot_height },
				position = { expedition_salvage_slot_x, right_bottom_row_y, 0 },
			},
		},
		widget_definitions = {
			expedition_salvage = UIWidget.create_definition({
				{
					pass_type = "text",
					value_id = "text",
					value = "0",
					style_id = "text",
					style = text_style,
				},
			}, "division_expedition_salvage_slot"),
		},
		EXPEDITION_SALVAGE_SLOT_W = expedition_salvage_slot_w,
		EXPEDITION_SALVAGE_SLOT_X = expedition_salvage_slot_x,
	}
end

return M
