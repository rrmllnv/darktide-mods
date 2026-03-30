local CommunicationCommandWheelSettings = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")
local get_hud_color = UIHudSettings.get_hud_color

local S = CommunicationCommandWheelSettings

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	pivot = {
		horizontal_alignment = "center",
		parent = "screen",
		vertical_alignment = "center",
		size = {
			0,
			0,
		},
		position = {
			0,
			0,
			0,
		},
	},
	line_pivot = {
		horizontal_alignment = "center",
		parent = "screen",
		vertical_alignment = "center",
		size = {
			100,
			100,
		},
		position = {
			200,
			-180,
			1,
		},
	},
	background = {
		horizontal_alignment = "center",
		parent = "pivot",
		vertical_alignment = "center",
		size = {
			S.center_circle_size,
			S.center_circle_size,
		},
		position = {
			0,
			0,
			1,
		},
	},
	page_indicators = {
		horizontal_alignment = "center",
		parent = "pivot",
		vertical_alignment = "top",
		size = {
			2 * S.page_indicator_size + S.page_indicator_spacing,
			S.page_indicator_size,
		},
		position = {
			0,
			-300,
			10,
		},
	},
}

local hover_color = get_hud_color("color_tint_main_1", 255)
local default_color = get_hud_color("color_tint_main_2", 255)
local icon_hover_color = get_hud_color("color_tint_main_2", 255)
local icon_default_color = get_hud_color("color_tint_main_3", 255)

local default_button_content = {
	on_released_sound = nil,
	on_hover_sound = UISoundEvents.default_mouse_hover,
	on_pressed_sound = UISoundEvents.default_select,
}

local simple_button_font_setting_name = "button_medium"
local simple_button_font_settings = UIFontSettings[simple_button_font_setting_name]
local simple_button_font_color = simple_button_font_settings.text_color

local button_pass_template = {
	{
		content_id = "hotspot",
		pass_type = "hotspot",
		content = default_button_content,
	},
	{
		pass_type = "texture",
		value = "content/ui/materials/hud/icons/weapon_icon_container",
		value_id = "icon",
		style_id = "icon",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			size = {
				96,
				96,
			},
			default_size = {
				96,
				96,
			},
			offset = {
				0,
				0,
				3,
			},
			color = get_hud_color("color_tint_main_2", 255),
			material_values = {},
		},
		change_function = function (content, style)
			local color = style.color
			local ignore_alpha = false
			local hotspot = content.hotspot
			local anim_hover_progress = hotspot.anim_hover_progress

			ColorUtilities.color_lerp(icon_default_color, icon_hover_color, anim_hover_progress, color, ignore_alpha)
		end,
	},
	{
		pass_type = "rotated_texture",
		value = "content/ui/materials/hud/communication_wheel/slice_eighth_line",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			size = {
				190,
				140,
			},
			offset = {
				0,
				0,
				4,
			},
			color = get_hud_color("color_tint_main_1", 255),
		},
		change_function = function (content, style)
			style.angle = math.pi + (content.angle or 0)

			local color = style.color
			local ignore_alpha = false
			local hotspot = content.hotspot
			local anim_hover_progress = hotspot.anim_hover_progress

			ColorUtilities.color_lerp(default_color, hover_color, anim_hover_progress, color, ignore_alpha)
		end,
	},
	{
		pass_type = "rotated_texture",
		value = "content/ui/materials/hud/communication_wheel/slice_eighth_highlight",
		style_id = "slice_highlight",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			offset = {
				0,
				0,
				2,
			},
			size = {
				190,
				140,
			},
			color = {
				150,
				0,
				0,
				0,
			},
		},
		change_function = function (content, style)
			style.angle = math.pi + (content.angle or 0)

			local hotspot = content.hotspot
			local color = style.color
			local ignore_alpha = false
			local anim_hover_progress = hotspot.anim_hover_progress

			ColorUtilities.color_lerp(icon_default_color, icon_hover_color, anim_hover_progress, color, ignore_alpha)
		end,
	},
	{
		pass_type = "rotated_texture",
		value = "content/ui/materials/hud/communication_wheel/slice_eighth",
		style_id = "slice",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			size = {
				190,
				140,
			},
			color = {
				150,
				0,
				0,
				0,
			},
		},
		change_function = function (content, style)
			style.angle = math.pi + (content.angle or 0)
		end,
	},
	{
		pass_type = "rect",
		style = {
			color = {
				200,
				40,
				40,
				40,
			},
			offset = {
				0,
				0,
				1,
			},
		},
		change_function = function (content, style)
			style.color[1] = math.max(content.hotspot.anim_hover_progress, content.hotspot.anim_select_progress) * 255
		end,
	},
	{
		pass_type = "text",
		value = "Button",
		value_id = "text",
		style = {
			text_horizontal_alignment = "center",
			text_vertical_alignment = "center",
			offset = {
				0,
				0,
				2,
			},
			font_type = simple_button_font_settings.font_type,
			font_size = simple_button_font_settings.font_size,
			text_color = simple_button_font_color,
			default_text_color = simple_button_font_color,
		},
		change_function = function (content, style)
			local default_text_color = style.default_text_color
			local text_color = style.text_color
			local progress = 1 - content.hotspot.anim_input_progress * 0.3

			text_color[2] = default_text_color[2] * progress
			text_color[3] = default_text_color[3] * progress
			text_color[4] = default_text_color[4] * progress
		end,
	},
}

local wheel_font_style = table.clone(UIFontSettings.hud_body)

wheel_font_style.font_size = 28
wheel_font_style.horizontal_alignment = "center"
wheel_font_style.vertical_alignment = "center"
wheel_font_style.text_horizontal_alignment = "center"
wheel_font_style.text_vertical_alignment = "center"
wheel_font_style.offset = {
	0,
	0,
	4,
}

local page_indicators_definition = UIWidget.create_definition({
	{
		pass_type = "rect",
		value_id = "page_1",
		style_id = "page_1",
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "center",
			size = {
				S.page_indicator_size,
				S.page_indicator_size,
			},
			offset = {
				0,
				0,
				2,
			},
			color = {
				255,
				255,
				255,
				255,
			},
		},
	},
	{
		pass_type = "rect",
		value_id = "page_2",
		style_id = "page_2",
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "center",
			size = {
				S.page_indicator_size,
				S.page_indicator_size,
			},
			offset = {
				S.page_indicator_size + S.page_indicator_spacing,
				0,
				2,
			},
			color = {
				150,
				150,
				150,
				150,
			},
		},
	},
}, "page_indicators")

local widget_definitions = {
	wheel_background = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/hud/communication_wheel/middle_box",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = {
					S.rhombus_width or S.center_circle_size,
					S.rhombus_height or (S.center_circle_size * 0.256),
				},
				offset = {
					0,
					0,
					100,
				},
				color = S.rhombus_color,
			},
			change_function = function (content, style)
				local rw = S.rhombus_width or S.center_circle_size
				local rh = S.rhombus_height or (S.center_circle_size * 0.256)

				style.size[1] = rw
				style.size[2] = rh
			end,
			visibility_function = function (content, style)
				return content.force_hover
			end,
		},
		{
			pass_type = "text",
			value = "n/a",
			value_id = "text",
			style = wheel_font_style,
			visibility_function = function (content, style)
				return content.force_hover
			end,
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/hud/communication_wheel/middle_circle",
			style = {
				offset = {
					0,
					0,
					0,
				},
				color = {
					255,
					0,
					0,
					0,
				},
			},
		},
		{
			pass_type = "rotated_texture",
			style_id = "mark",
			value = "content/ui/materials/hud/communication_wheel/arrow",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = {
					20,
					28,
				},
				pivot = {
					10,
					147,
				},
				offset = {
					0,
					-133,
					100,
				},
				color = get_hud_color("color_tint_main_1", 255),
			},
			change_function = function (content, style)
				style.angle = math.pi - (content.angle or 0)

				local scale = S.center_circle_size / 250
				local arrow_size_y = 28 * scale
				local arrow_pivot_y = 147 * scale
				local arrow_offset_y = -133 * scale

				style.size[2] = arrow_size_y
				style.pivot[2] = arrow_pivot_y
				style.offset[2] = arrow_offset_y

				local color = style.color
				local ignore_alpha = true
				local anim_hover_progress = content.force_hover and 1 or 0

				ColorUtilities.color_lerp(default_color, hover_color, anim_hover_progress, color, ignore_alpha)
			end,
		},
	}, "background"),
	page_indicators = page_indicators_definition,
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	entry_widget_definition = UIWidget.create_definition(button_pass_template, "pivot"),
}
