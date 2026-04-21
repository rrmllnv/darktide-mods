local HudElementDodgeCounterSettings = require("scripts/ui/hud/elements/dodge_counter/hud_element_dodge_counter_settings")
local HudElementStaminaSettings = require("scripts/ui/hud/elements/blocking/hud_element_stamina_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}
local DANGER_ZONE_EXTRA_HEIGHT = 4
local DANGER_ZONE_WARNING_WIDTH = 84
local DANGER_ZONE_WARNING_OVERLAP = 10
local DANGER_ZONE_WARNING_ENTER_DUR = 0.2
local DANGER_ZONE_WARNING_EXIT_DUR = 0.16

local function build_scenegraph(main_row_height, track_width_px, prox_block_gap)
	local stm_height = HudElementStaminaSettings.area_size[2]
	local ddg_height = HudElementDodgeCounterSettings.area_size[2]
	local ddg_bar_height = HudElementDodgeCounterSettings.bar_size[2]
	local stamina_top = main_row_height + 6
	local between_centers = HudElementDodgeCounterSettings.center_offset - HudElementStaminaSettings.center_offset
	local stamina_center_y = stamina_top + stm_height * 0.5
	local dodge_center_y = stamina_center_y + between_centers
	local dodge_top = math.floor(dodge_center_y - ddg_height * 0.5 + 0.5)
	local dodge_visual_bottom_local = math.max(-5 + 10, 2 + ddg_bar_height)
	local bottom_y = dodge_top + dodge_visual_bottom_local
	local area_height = math.max(1, bottom_y - stamina_top + DANGER_ZONE_EXTRA_HEIGHT)

	return {
		div_danger_zone_area = {
			horizontal_alignment = "center",
			parent = "boxes_row",
			vertical_alignment = "top",
			size = { track_width_px, area_height },
			position = { 0, stamina_top, 0 },
		},
		div_danger_zone_warning_anchor = {
			horizontal_alignment = "left",
			parent = "boxes_row",
			vertical_alignment = "top",
			size = { DANGER_ZONE_WARNING_WIDTH, area_height },
			position = { track_width_px + math.max(0, prox_block_gap or 0), stamina_top, -1 },
		},
		div_danger_zone_warning_area = {
			horizontal_alignment = "left",
			parent = "div_danger_zone_warning_anchor",
			vertical_alignment = "top",
			size = { DANGER_ZONE_WARNING_WIDTH, area_height },
			position = { 0, 0, -1 },
		},
	}
end

local function build_widget_definition(track_width_px, block_height)
	local area_height = math.max(1, block_height or 1)
	block_height = area_height
	local icon_size = 16
	local icon_left_inset = 6
	local distance_width = 52
	local content_width = math.max(1, track_width_px)
	local text_color = table.clone(UIHudSettings.color_tint_main_1)
	local danger_color = table.clone(UIHudSettings.color_tint_alert_2)
	local icon_offset_y = math.floor((block_height - icon_size) * 0.5 + 0.5)
	local title_top = math.max(0, math.floor(block_height * 0.04 + 0.5))
	local title_height = 16
	local source_top = title_top + title_height - 1
	local source_height = 12

	local title_style = table.clone(UIFontSettings.hud_body)
	title_style.font_size = 14
	title_style.drop_shadow = true
	title_style.horizontal_alignment = "center"
	title_style.vertical_alignment = "top"
	title_style.text_horizontal_alignment = "center"
	title_style.text_vertical_alignment = "top"
	title_style.text_color = text_color
	title_style.size = { content_width, title_height }
	title_style.offset = { 0, title_top, 4 }

	local source_style = table.clone(UIFontSettings.hud_body)
	source_style.font_size = 12
	source_style.drop_shadow = true
	source_style.horizontal_alignment = "center"
	source_style.vertical_alignment = "top"
	source_style.text_horizontal_alignment = "center"
	source_style.text_vertical_alignment = "top"
	source_style.text_color = text_color
	source_style.size = { content_width, source_height }
	source_style.offset = { 0, source_top, 4 }

	local distance_style = table.clone(UIFontSettings.hud_body)
	distance_style.font_size = 18
	distance_style.drop_shadow = true
	distance_style.horizontal_alignment = "right"
	distance_style.vertical_alignment = "center"
	distance_style.text_horizontal_alignment = "right"
	distance_style.text_vertical_alignment = "center"
	distance_style.text_color = text_color
	distance_style.size = { distance_width, 18 }
	distance_style.offset = { -6, 0, 4 }

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				offset = { 0, 0, 1 },
				size = { content_width, block_height },
				color = { 125, UIHudSettings.color_tint_0[2], UIHudSettings.color_tint_0[3], UIHudSettings.color_tint_0[4] },
			},
		},
		{
			pass_type = "rect",
			style_id = "accent",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				offset = { 0, 1, 2 },
				size = { content_width, 2 },
				color = danger_color,
			},
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/icons/generic/danger",
			value_id = "icon",
			style_id = "icon",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = { icon_size, icon_size },
				default_size = { icon_size, icon_size },
				offset = { icon_left_inset, icon_offset_y, 3 },
				default_offset = { icon_left_inset, icon_offset_y, 3 },
				color = danger_color,
			},
		},
		{
			pass_type = "text",
			value = "Опасная зона",
			value_id = "label_text",
			style_id = "label_text",
			style = title_style,
		},
		{
			pass_type = "text",
			value = "",
			value_id = "source_text",
			style_id = "source_text",
			style = source_style,
		},
		{
			pass_type = "text",
			value = "0m",
			value_id = "distance_text",
			style_id = "distance_text",
			style = distance_style,
		},
	}, "div_danger_zone_area")
end

local function build_warning_widget_definition(block_height)
	local area_height = math.max(1, block_height or 1)
	local warning_width = DANGER_ZONE_WARNING_WIDTH
	local text_color = table.clone(UIHudSettings.color_tint_main_1)
	local danger_color = table.clone(UIHudSettings.color_tint_alert_2)
	local text_style = table.clone(UIFontSettings.hud_body)

	text_style.font_size = 12
	text_style.drop_shadow = true
	text_style.horizontal_alignment = "center"
	text_style.vertical_alignment = "center"
	text_style.text_horizontal_alignment = "center"
	text_style.text_vertical_alignment = "center"
	text_style.text_color = text_color
	text_style.size = { warning_width, area_height }
	text_style.offset = { 0, 0, 4 }

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				offset = { 0, 0, 0 },
				size = { warning_width, area_height },
				color = { 115, UIHudSettings.color_tint_0[2], UIHudSettings.color_tint_0[3], UIHudSettings.color_tint_0[4] },
			},
		},
		{
			pass_type = "rect",
			style_id = "accent",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "top",
				offset = { 0, 1, 1 },
				size = { warning_width, 2 },
				color = danger_color,
			},
		},
		{
			pass_type = "text",
			value = "В зоне\nпоражения",
			value_id = "warning_text",
			style_id = "warning_text",
			style = text_style,
		},
	}, "div_danger_zone_warning_area")
end

function M.build(main_row_height, track_width_px, prox_block_gap)
	local scenegraph_definition = build_scenegraph(main_row_height, track_width_px, prox_block_gap)
	local area_height = scenegraph_definition.div_danger_zone_area
		and scenegraph_definition.div_danger_zone_area.size
		and scenegraph_definition.div_danger_zone_area.size[2]
		or 1

	return {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = {
			danger_zone = build_widget_definition(track_width_px, area_height),
			danger_zone_warning = build_warning_widget_definition(area_height),
		},
		DANGER_ZONE_WARNING_WIDTH = DANGER_ZONE_WARNING_WIDTH,
		DANGER_ZONE_WARNING_OVERLAP = DANGER_ZONE_WARNING_OVERLAP,
		DANGER_ZONE_WARNING_ENTER_DUR = DANGER_ZONE_WARNING_ENTER_DUR,
		DANGER_ZONE_WARNING_EXIT_DUR = DANGER_ZONE_WARNING_EXIT_DUR,
		DANGER_ZONE_WARNING_PROX_GAP = math.max(0, prox_block_gap or 0),
	}
end

return M
