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
}

mod.robocophud_definitions = M

return M

