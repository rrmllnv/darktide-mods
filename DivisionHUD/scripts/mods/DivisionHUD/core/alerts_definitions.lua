local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local M = {}

function M.build(bar_width, bar_label_w, sc)
	local ALERTS_SLOT_GAP = sc(4)
	local ALERTS_STRIP_HEIGHT = sc(30)
	local ALERTS_BODY_HEIGHT = sc(48)
	local ALERT_DURATION_BAR_H = sc(3)
	local ALERTS_SLOT_HEIGHT = ALERTS_BODY_HEIGHT + ALERTS_STRIP_HEIGHT
	local ALERT_FEED_ORANGE = {
		230,
		255,
		151,
		29,
	}
	local ALERT_FEED_ORANGE_TEXT = {
		255,
		70,
		38,
		0,
	}
	local ALERT_DURATION_BAR_COLOR = {
		230,
		98,
		48,
		14,
	}
	local ALERTS_MAX_SLOTS = 5
	local ALERTS_STACK_TOTAL_HEIGHT = ALERTS_MAX_SLOTS * (ALERTS_SLOT_HEIGHT + ALERTS_SLOT_GAP) - ALERTS_SLOT_GAP
	local ALERTS_TOUGHNESS_GAP = sc(8)

	local scenegraph_definition = {
		alerts_column = {
			parent = "root",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { bar_width, ALERTS_STACK_TOTAL_HEIGHT },
			position = { bar_label_w, -(ALERTS_STACK_TOTAL_HEIGHT + ALERTS_TOUGHNESS_GAP), 0 },
		},
	}

	for alert_slot_index = 1, ALERTS_MAX_SLOTS do
		local y_offset = (alert_slot_index - 1) * (ALERTS_SLOT_HEIGHT + ALERTS_SLOT_GAP)

		scenegraph_definition["alert_slot_" .. alert_slot_index] = {
			parent = "alerts_column",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { bar_width, ALERTS_SLOT_HEIGHT },
			position = { 0, y_offset, 0 },
		}
	end

	local function create_alerts_slot_widget(scenegraph_id)
		local upper_bg_color = {
			ALERT_FEED_ORANGE[1],
			ALERT_FEED_ORANGE[2],
			ALERT_FEED_ORANGE[3],
			ALERT_FEED_ORANGE[4],
		}
		local upper_emitter_color = {
			ALERT_FEED_ORANGE[1],
			ALERT_FEED_ORANGE[2],
			ALERT_FEED_ORANGE[3],
			ALERT_FEED_ORANGE[4],
		}

		local message_text_style = table.clone(UIFontSettings.hud_body)

		message_text_style.horizontal_alignment = "left"
		message_text_style.vertical_alignment = "top"
		message_text_style.text_horizontal_alignment = "left"
		message_text_style.text_vertical_alignment = "top"
		message_text_style.font_size = sc(17)
		message_text_style.drop_shadow = true
		message_text_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
		message_text_style.size = { bar_width - sc(10), ALERTS_BODY_HEIGHT - sc(6) }
		message_text_style.offset = { sc(5), sc(2), 6 }

		local strip_label_style = table.clone(UIFontSettings.hud_body)

		strip_label_style.horizontal_alignment = "left"
		strip_label_style.vertical_alignment = "bottom"
		strip_label_style.text_horizontal_alignment = "center"
		strip_label_style.text_vertical_alignment = "center"
		strip_label_style.font_size = sc(20)
		strip_label_style.drop_shadow = true
		strip_label_style.text_color = {
			ALERT_FEED_ORANGE_TEXT[1],
			ALERT_FEED_ORANGE_TEXT[2],
			ALERT_FEED_ORANGE_TEXT[3],
			ALERT_FEED_ORANGE_TEXT[4],
		}
		strip_label_style.size = { bar_width, ALERTS_STRIP_HEIGHT }
		strip_label_style.offset = { 0, -1, 7 }

		return UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "alert_slot_upper_background",
				value = "content/ui/materials/hud/backgrounds/terminal_background_weapon",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "top",
					color = table.clone(upper_bg_color),
					default_color = table.clone(Color.terminal_background_gradient(255, true)),
					size = { bar_width, ALERTS_BODY_HEIGHT },
					offset = { 0, 0, 0 },
				},
			},
			{
				pass_type = "texture",
				style_id = "alert_slot_upper_emitter",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "top",
					size = { sc(4), ALERTS_BODY_HEIGHT },
					offset = { 0, 0, 5 },
					color = table.clone(upper_emitter_color),
					default_color = table.clone(Color.terminal_corner_hover(nil, true)),
				},
			},
			{
				pass_type = "rect",
				style_id = "alert_strip_background",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "bottom",
					size = { bar_width, ALERTS_STRIP_HEIGHT },
					offset = { 0, 0, 1 },
					color = {
						ALERT_FEED_ORANGE[1],
						ALERT_FEED_ORANGE[2],
						ALERT_FEED_ORANGE[3],
						ALERT_FEED_ORANGE[4],
					},
				},
			},
			{
				pass_type = "rect",
				style_id = "alert_duration_bar",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "bottom",
					size = { bar_width, ALERT_DURATION_BAR_H },
					offset = { 0, 0, 2 },
					color = {
						ALERT_DURATION_BAR_COLOR[1],
						ALERT_DURATION_BAR_COLOR[2],
						ALERT_DURATION_BAR_COLOR[3],
						ALERT_DURATION_BAR_COLOR[4],
					},
				},
			},
			{
				pass_type = "text",
				style_id = "alert_message_text",
				value_id = "alert_message_text",
				value = "",
				style = message_text_style,
			},
			{
				pass_type = "text",
				style_id = "alert_strip_label_text",
				value_id = "alert_strip_label_text",
				value = "",
				style = strip_label_style,
			},
		}, scenegraph_id, nil, { bar_width, ALERTS_SLOT_HEIGHT })
	end

	local widget_definitions = {}

	for alert_slot_index = 1, ALERTS_MAX_SLOTS do
		local slot_key = "alert_slot_" .. alert_slot_index

		widget_definitions[slot_key] = create_alerts_slot_widget(slot_key)
	end

	local alert_slot_widget_names = {}

	for alert_slot_index = 1, ALERTS_MAX_SLOTS do
		alert_slot_widget_names[alert_slot_index] = "alert_slot_" .. alert_slot_index
	end

	return {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
		alert_slot_widget_names = alert_slot_widget_names,
		ALERTS_MAX_SLOTS = ALERTS_MAX_SLOTS,
		ALERTS_SLOT_HEIGHT = ALERTS_SLOT_HEIGHT,
		ALERTS_STACK_TOTAL_HEIGHT = ALERTS_STACK_TOTAL_HEIGHT,
	}
end

return M
