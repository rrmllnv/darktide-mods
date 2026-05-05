local mod = get_mod("RobocopHUD")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}

M.color = {
	white = { 255, 255, 255, 255 },
	black = { 255, 0, 0, 0 },
	transparent = { 0, 255, 255, 255 },
	alert = UIHudSettings.color_tint_alert_2 or { 255, 255, 0, 0 },
}

M.default_draw_layer = 305

M.scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	root = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = { 1920, 1080 },
		position = { 0, 0, 10 },
	},
	top_left = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = { 600, 80 },
		position = { 20, 20, 20 },
	},
	top_right = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "right",
		size = { 520, 240 },
		position = { -20, 20, 20 },
	},
	center = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = { 300, 300 },
		position = { 0, 0, 30 },
	},
	scanner = {
		parent = "center",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = { 360, 360 },
		position = { 0, 0, 5 },
	},
	target_info = {
		parent = "center",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = { 360, 260 },
		position = { 0, 0, 6 },
	},
	bottom = {
		parent = "screen",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = { 1100, 90 },
		position = { 0, -20, 20 },
	},
}

local base_text_style = {
	font_type = "machine_medium",
	font_size = 18,
	text_horizontal_alignment = "left",
	text_vertical_alignment = "top",
	offset = { 0, 0, 0 },
	text_color = { 255, 120, 255, 160 },
	drop_shadow = false,
}

local base_right_style = table.merge_recursive(table.clone(base_text_style), {
	font_size = 16,
	text_horizontal_alignment = "right",
	text_vertical_alignment = "top",
	line_spacing = 1.05,
})

local base_center_style = table.merge_recursive(table.clone(base_text_style), {
	font_size = 20,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
})

M.widget_definitions = {
	status_text = UIWidget.create_definition({
		{
			value = "",
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = table.merge_recursive(table.clone(base_text_style), {
				offset = { 0, 22, 0 },
			}),
			visibility_function = function()
				return mod:get("debug_overlay") == true
			end,
		},
	}, "top_left"),

	recorder_text = UIWidget.create_definition({
		{
			value = "",
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = table.clone(base_text_style),
		},
	}, "top_left"),

	lock_frame = UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "frame_top",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 220, 2 },
				offset = { 0, 110, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "frame_bottom",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 220, 2 },
				offset = { 0, -110, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "frame_left",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 2, 220 },
				offset = { -110, 0, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "frame_right",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 2, 220 },
				offset = { 110, 0, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "line_top",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 2, 40 },
				offset = { 0, 150, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "line_bottom",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 2, 40 },
				offset = { 0, -150, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "line_left",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 40, 2 },
				offset = { -150, 0, 0 },
			},
		},
		{
			pass_type = "rect",
			style_id = "line_right",
			style = {
				color = { 180, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 40, 2 },
				offset = { 150, 0, 0 },
			},
		},
		{
			value = "",
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = table.clone(base_center_style),
		},
	}, "center"),

	threat_ladder = UIWidget.create_definition({
		{
			value = "",
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = table.clone(base_right_style),
		},
	}, "top_right"),

	directives = UIWidget.create_definition({
		{
			value = "",
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = table.merge_recursive(table.clone(base_center_style), {
				font_size = 18,
				text_vertical_alignment = "bottom",
			}),
		},
	}, "bottom"),

	scanner_sweep = UIWidget.create_definition({
		{
			pass_type = "rotated_texture",
			style_id = "radar",
			value = "content/ui/materials/backgrounds/scanner/scanner_map_background",
			style = {
				hdr = true,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				color = { 90, 120, 255, 160 },
				size = { 320, 320 },
				angle = 0,
				pivot = { 160, 160 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "texture",
			style_id = "radar_fx",
			value = "content/ui/materials/backgrounds/scanner/scanner_map_radar",
			style = {
				hdr = true,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				color = { 70, 120, 255, 160 },
				size = { 320, 320 },
				offset = { 0, 0, 1 },
			},
		},
		{
			pass_type = "rect",
			style_id = "player_dot",
			style = {
				color = { 255, 255, 255, 255 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 3 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_01",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_02",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_03",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_04",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_05",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_06",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_07",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_08",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_09",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_10",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_11",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_12",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_13",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_14",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_15",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_16",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_17",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_18",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_19",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_20",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_21",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_22",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_23",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "blip_24",
			style = {
				color = { 0, 120, 255, 160 },
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 4, 4 },
				offset = { 0, 0, 2 },
			},
		},
	}, "scanner"),

	enemy_target = UIWidget.create_definition({
		{
			pass_type = "text",
			value = "",
			value_id = "name_text",
			style_id = "name_text",
			style = table.merge_recursive(table.clone(base_text_style), {
				font_size = 18,
				offset = { 12, 6, 3 },
				size = { 230, 24 },
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				truncated = true,
				max_lines = 1,
			}),
		},
		{
			pass_type = "rect",
			style_id = "health_bar_background",
			style = {
				color = { 60, 120, 255, 160 },
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = { 220, 6 },
				offset = { 12, 34, 2 },
			},
		},
		{
			pass_type = "rect",
			style_id = "health_bar_fill",
			style = {
				color = { 220, 60, 255, 120 },
				horizontal_alignment = "left",
				vertical_alignment = "top",
				size = { 220, 6 },
				default_size = { 220, 6 },
				offset = { 12, 34, 3 },
			},
		},
		{
			pass_type = "text",
			value = "",
			value_id = "health_text",
			style_id = "health_text",
			style = table.merge_recursive(table.clone(base_text_style), {
				font_size = 13,
				offset = { 238, 24, 3 },
				size = { 48, 20 },
				text_horizontal_alignment = "right",
				text_vertical_alignment = "center",
			}),
		},
		{
			pass_type = "text",
			value = "",
			value_id = "type_text",
			style_id = "type_text",
			style = table.merge_recursive(table.clone(base_text_style), {
				font_size = 12,
				offset = { 12, 43, 3 },
				size = { 250, 18 },
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				truncated = true,
				max_lines = 1,
			}),
		},
	}, "target_info"),
}

do
	local enemy_target_definition = M.widget_definitions.enemy_target
	local debuff_icon_size = 16
	local debuff_row_height = 18
	local debuff_text_x = 34
	local debuff_icon_x = 12
	local debuff_start_y = 64

	for i = 1, 16 do
		local row_y = debuff_start_y + (i - 1) * debuff_row_height
		local icon_id = "debuff_icon_" .. i
		local text_id = "debuff_text_" .. i
		local outline_id = text_id .. "_outline_text"

		enemy_target_definition.content[icon_id] = nil
		enemy_target_definition.content[text_id] = ""
		enemy_target_definition.content[outline_id] = ""

		enemy_target_definition.style[icon_id] = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			offset = { debuff_icon_x, row_y, 4 },
			size = { debuff_icon_size, debuff_icon_size },
			color = { 255, 120, 255, 160 },
		}

		enemy_target_definition.style[text_id] = {
			font_type = "machine_medium",
			font_size = 13,
			text_horizontal_alignment = "left",
			text_vertical_alignment = "center",
			offset = { debuff_text_x, row_y - 1, 6 },
			size = { 250, debuff_row_height },
			text_color = { 255, 120, 255, 160 },
			truncated = true,
			max_lines = 1,
			drop_shadow = true,
			shadow_offset = { 1, -1 },
			shadow_color = { 180, 0, 0, 0 },
		}

		enemy_target_definition.style[text_id .. "_outline"] = {
			font_type = "machine_medium",
			font_size = 13,
			text_horizontal_alignment = "left",
			text_vertical_alignment = "center",
			offset = { debuff_text_x + 1, row_y, 5 },
			size = { 250, debuff_row_height },
			text_color = { 255, 0, 0, 0 },
			truncated = true,
			max_lines = 1,
		}

		enemy_target_definition.passes[#enemy_target_definition.passes + 1] = {
			pass_type = "texture",
			style_id = icon_id,
			value_id = icon_id,
			visibility_function = function(content)
				return content[icon_id] ~= nil
			end,
		}

		enemy_target_definition.passes[#enemy_target_definition.passes + 1] = {
			pass_type = "text",
			style_id = text_id,
			value_id = text_id,
			visibility_function = function(content)
				return content[text_id] ~= ""
			end,
		}

		enemy_target_definition.passes[#enemy_target_definition.passes + 1] = {
			pass_type = "text",
			style_id = text_id .. "_outline",
			value_id = outline_id,
			visibility_function = function(content)
				return content[outline_id] ~= ""
			end,
		}
	end
end

mod.robocophud_definitions = M

return M

