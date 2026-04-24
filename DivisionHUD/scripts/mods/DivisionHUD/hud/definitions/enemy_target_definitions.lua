local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}
local MAX_DEBUFF_ROWS = 9
local ENEMY_TARGET_ENTER_DUR = 0.2
local ENEMY_TARGET_EXIT_DUR = 0.16

function M.build(params)
	local sc = params.sc
	local right_gap = params.right_gap
	local right_bottom_slot_width = params.right_bottom_slot_width
	local main_row_height = params.main_row_height
	local slot_text_font = params.slot_text_font or sc(20)
	local expedition_salvage_slot_w = math.max(right_bottom_slot_width, sc(72))
	local expedition_salvage_slot_x = -(expedition_salvage_slot_w + right_gap)
	local padding_x = sc(6)
	local top_y = sc(3)
	local title_font = slot_text_font
	local health_text_font = slot_text_font
	local name_height = sc(24)
	local health_bar_width = sc(8)
	local health_bar_gap = sc(4)
	local content_right_inset = padding_x + health_bar_width + health_bar_gap
	local health_info_y = top_y + name_height + sc(3)
	local health_text_height = sc(24)
	local debuff_value_font = slot_text_font
	local debuff_name_font = slot_text_font
	local debuff_value_max_chars = 6
	local debuff_value_char_width_mul = 0.58
	local debuff_icon_size = sc(24)
	local debuff_row_height = sc(24)
	local debuff_start_y = health_info_y + health_text_height + sc(4)
	local debuff_gap = sc(4)
	local debuff_name_min_width = sc(220)
	local value_width = math.max(sc(48), math.ceil(debuff_value_font * debuff_value_max_chars * debuff_value_char_width_mul))
	local block_width = math.max(sc(352), expedition_salvage_slot_w + sc(276))
	local block_x = expedition_salvage_slot_x + expedition_salvage_slot_w - block_width
	local slide_px = math.max(sc(40), block_width - expedition_salvage_slot_w)
	local content_width = block_width - padding_x - content_right_inset
	local health_bar_height = main_row_height
	local block_height = math.max(main_row_height, debuff_start_y + debuff_row_height * MAX_DEBUFF_ROWS + sc(5))
	local bar_x = block_width - padding_x - health_bar_width
	local content_right_x = block_width - content_right_inset
	local icon_x = content_right_x - debuff_icon_size
	local value_x = icon_x - debuff_gap - value_width
	local name_x = padding_x
	local name_width = math.max(debuff_name_min_width, value_x - debuff_gap - name_x)

	local title_style = table.clone(UIFontSettings.body_small)

	title_style.font_size = title_font
	title_style.drop_shadow = true
	title_style.horizontal_alignment = "right"
	title_style.vertical_alignment = "top"
	title_style.text_horizontal_alignment = "right"
	title_style.text_vertical_alignment = "top"
	title_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
	title_style.size = { content_width, name_height }
	title_style.offset = { -content_right_inset, top_y, 4 }
	title_style.truncated = true
	title_style.max_lines = 1

	local health_text_style = table.clone(UIFontSettings.body_small)

	health_text_style.font_size = health_text_font
	health_text_style.drop_shadow = true
	health_text_style.horizontal_alignment = "right"
	health_text_style.vertical_alignment = "top"
	health_text_style.text_horizontal_alignment = "right"
	health_text_style.text_vertical_alignment = "top"
	health_text_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
	health_text_style.size = { content_width, health_text_height }
	health_text_style.offset = { -content_right_inset, health_info_y, 4 }
	health_text_style.truncated = true
	health_text_style.max_lines = 1

	local passes = {
		{
			pass_type = "text",
			value_id = "name_text",
			value = "",
			style_id = "name_text",
			style = title_style,
		},
		{
			pass_type = "rect",
			style_id = "health_bar_background",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				offset = { bar_x, 0, 3 },
				size = { health_bar_width, health_bar_height },
				color = { 140, UIHudSettings.color_tint_0[2], UIHudSettings.color_tint_0[3], UIHudSettings.color_tint_0[4] },
			},
		},
		{
			pass_type = "rect",
			style_id = "health_bar_fill",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				offset = { bar_x, 0, 4 },
				default_offset = { bar_x, 0, 4 },
				size = { health_bar_width, health_bar_height },
				default_size = { health_bar_width, health_bar_height },
				color = table.clone(UIHudSettings.color_tint_alert_2),
			},
		},
		{
			pass_type = "text",
			value_id = "health_text",
			value = "",
			style_id = "health_text",
			style = health_text_style,
		},
	}

	for i = 1, MAX_DEBUFF_ROWS do
		local icon_id = "debuff_icon_" .. i
		local value_id = "debuff_value_" .. i
		local name_id = "debuff_name_" .. i

		passes[#passes + 1] = {
			pass_type = "texture",
			style_id = icon_id,
			value_id = icon_id,
			visibility_function = function(content)
				return content[icon_id] ~= nil
			end,
		}

		passes[#passes + 1] = {
			pass_type = "text",
			style_id = value_id,
			value_id = value_id,
			visibility_function = function(content)
				return content[value_id] ~= ""
			end,
		}

		passes[#passes + 1] = {
			pass_type = "text",
			style_id = value_id .. "_outline",
			value_id = value_id,
			visibility_function = function(content)
				return content[value_id] ~= ""
			end,
		}

		passes[#passes + 1] = {
			pass_type = "text",
			style_id = name_id,
			value_id = name_id,
			visibility_function = function(content)
				return content[name_id] ~= ""
			end,
		}
	end

	local definition = UIWidget.create_definition(passes, "division_enemy_target_area")

	for i = 1, MAX_DEBUFF_ROWS do
		local row_y = debuff_start_y + (i - 1) * debuff_row_height
		local icon_id = "debuff_icon_" .. i
		local value_id = "debuff_value_" .. i
		local name_id = "debuff_name_" .. i

		definition.content[icon_id] = nil
		definition.content[value_id] = ""
		definition.content[name_id] = ""
		definition.style[icon_id] = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = { icon_x, row_y, 5 },
			size = { debuff_icon_size, debuff_icon_size },
			color = { 255, 255, 255, 255 },
		}
		definition.style[value_id] = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			text_horizontal_alignment = "right",
			text_vertical_alignment = "center",
			offset = { value_x, row_y, 7 },
			font_type = UIFontSettings.body_small.font_type,
			font_size = debuff_value_font,
			text_color = table.clone(UIHudSettings.color_tint_main_1),
			size = { value_width, debuff_row_height },
			drop_shadow = true,
			shadow_offset = { 1, -1 },
			shadow_color = { 200, 0, 0, 0 },
		}
		definition.style[value_id .. "_outline"] = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			text_horizontal_alignment = "right",
			text_vertical_alignment = "center",
			offset = { value_x + sc(1), row_y, 6 },
			font_type = UIFontSettings.body_small.font_type,
			font_size = debuff_value_font,
			text_color = { 255, 0, 0, 0 },
			size = { value_width, debuff_row_height },
		}
		definition.style[name_id] = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			text_horizontal_alignment = "right",
			text_vertical_alignment = "center",
			offset = { name_x, row_y, 6 },
			font_type = UIFontSettings.body_small.font_type,
			font_size = debuff_name_font,
			text_color = table.clone(UIHudSettings.color_tint_main_1),
			size = { name_width, debuff_row_height },
			truncated = true,
			max_lines = 1,
			drop_shadow = true,
			shadow_offset = { 1, -1 },
			shadow_color = { 200, 0, 0, 0 },
		}
	end

	local widget_definitions = {
		enemy_target = definition,
	}

	return {
		scenegraph_definition = {
			division_enemy_target_anchor = {
				parent = "boxes_row",
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = { block_width, block_height },
				position = { block_x, 0, 0 },
			},
			division_enemy_target_area = {
				parent = "division_enemy_target_anchor",
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = { block_width, block_height },
				position = { 0, 0, 0 },
			},
		},
		widget_definitions = widget_definitions,
		ENEMY_TARGET_MAX_DEBUFF_SLOTS = MAX_DEBUFF_ROWS,
		ENEMY_TARGET_SLIDE_PX = slide_px,
		ENEMY_TARGET_ENTER_DUR = ENEMY_TARGET_ENTER_DUR,
		ENEMY_TARGET_EXIT_DUR = ENEMY_TARGET_EXIT_DUR,
	}
end

return M
