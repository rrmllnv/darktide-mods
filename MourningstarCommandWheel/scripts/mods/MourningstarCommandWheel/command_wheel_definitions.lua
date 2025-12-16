local mod = get_mod("MourningstarCommandWheel")

-- Загружаем settings через io_dofile, чтобы settings() зарегистрировал глобальный объект
mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")
local CommandWheelSettings = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")
local get_hud_color = UIHudSettings.get_hud_color

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
	background = {
		horizontal_alignment = "center",
		parent = "pivot",
		vertical_alignment = "center",
		size = {
			CommandWheelSettings.center_circle_size,
			CommandWheelSettings.center_circle_size,
		},
		position = {
			0,
			0,
			1,
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

local entry_widget_definition = UIWidget.create_definition({
	{
		content_id = "hotspot",
		pass_type = "hotspot",
		content = default_button_content,
	},
	{
		pass_type = "texture",
		value_id = "icon",
		value = "content/ui/materials/base/ui_default_base",
		style_id = "icon",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			size = {
				CommandWheelSettings.icon_size,
				CommandWheelSettings.icon_size,
			},
			offset = {
				0,
				0,
				3,
			},
			color = get_hud_color("color_tint_main_2", 255),
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
		style_id = "slice_line",
		style = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			size = {
				CommandWheelSettings.line_width,
				CommandWheelSettings.line_height or ((CommandWheelSettings.max_radius - CommandWheelSettings.min_radius) * CommandWheelSettings.line_height_scale),
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

			-- Вычисляем высоту линии на основе радиусов, если не задана явно
			local line_height = CommandWheelSettings.line_height
			if line_height == nil then
				line_height = (CommandWheelSettings.max_radius - CommandWheelSettings.min_radius) * CommandWheelSettings.line_height_scale
			end
			style.size[1] = CommandWheelSettings.line_width
			style.size[2] = line_height

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
				CommandWheelSettings.slice_width,
				CommandWheelSettings.slice_height,
			},
			uvs = {
				{ 0.1, 0 },
				{ 0.9, 1 },
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

			-- Применяем корректировку кривизны
			local base_width = CommandWheelSettings.slice_width
			local base_height = CommandWheelSettings.slice_height
			style.size[1] = base_width * CommandWheelSettings.slice_curvature_scale_x
			style.size[2] = base_height * CommandWheelSettings.slice_curvature_scale_y

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
				CommandWheelSettings.slice_width,
				CommandWheelSettings.slice_height,
			},
			uvs = {
				{ 0.1, 0 },
				{ 0.9, 1 },
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

			-- Применяем корректировку кривизны
			local base_width = CommandWheelSettings.slice_width
			local base_height = CommandWheelSettings.slice_height
			style.size[1] = base_width * CommandWheelSettings.slice_curvature_scale_x
			style.size[2] = base_height * CommandWheelSettings.slice_curvature_scale_y
		end,
	},
	{
		pass_type = "text",
		value_id = "text",
		value = "",
		style_id = "text",
		style = {
			text_horizontal_alignment = "center",
			text_vertical_alignment = "center",
			offset = {
				0,
				0,
				5,
			},
			font_type = simple_button_font_settings.font_type,
			font_size = 16,
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
}, "pivot")

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

local widget_definitions = {
	wheel_background = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/hud/communication_wheel/middle_box",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = {
					CommandWheelSettings.rhombus_width or CommandWheelSettings.center_circle_size,
					CommandWheelSettings.rhombus_height or (CommandWheelSettings.center_circle_size * 0.256),
				},
				offset = {
					0,
					0,
					1,
				},
				color = {
					120,
					0,
					0,
					0,
				},
			},
			change_function = function (content, style)
				-- Обновляем размер ромба динамически
				local rhombus_width = CommandWheelSettings.rhombus_width or CommandWheelSettings.center_circle_size
				local rhombus_height = CommandWheelSettings.rhombus_height or (CommandWheelSettings.center_circle_size * 0.256)
				style.size[1] = rhombus_width
				style.size[2] = rhombus_height
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
					6,
				},
				color = get_hud_color("color_tint_main_1", 255),
			},
			change_function = function (content, style)
				style.angle = math.pi - (content.angle or 0)

				-- Обновляем позицию стрелки в зависимости от размера центрального круга
				-- Оригинальные значения: pivot (10, 147), offset (0, -133)
				-- Масштабируем пропорционально center_circle_size (оригинал был 250)
				local scale = CommandWheelSettings.center_circle_size / 250
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
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	entry_widget_definition = entry_widget_definition,
}
