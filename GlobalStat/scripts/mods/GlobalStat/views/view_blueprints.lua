local Color = Color
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local constants = get_mod("GlobalStat"):io_dofile("GlobalStat/scripts/mods/GlobalStat/views/view_constants")

local grid_size = constants.grid_size

local blueprints = {}

blueprints.stat_line = {
	size = {grid_size[1] - 20, 50},
	size_function = function()
		return {grid_size[1] - 20, 50}
	end,
	pass_template = {
		{
			content_id = "hotspot",
			pass_type = "hotspot",
			content = {
				use_is_focused = false,
			},
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/backgrounds/default_square",
			style = {
				color = Color.terminal_background_selected(0, true),
				offset = {0, 0, 0},
			},
			change_function = function(content, style)
				local hotspot = content.hotspot
				local is_empty = (content.text == nil or content.text == "") and (content.value == nil or content.value == "")
				local hover_progress = is_empty and 0 or (hotspot.anim_hover_progress or 0)
				local alpha = 100 * hover_progress
				style.color[1] = alpha
			end,
		},
		{
			pass_type = "text",
			value_id = "text",
			style = {
				text_vertical_alignment = "center",
				text_horizontal_alignment = "left",
				font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
				font_size = UIFontSettings.list_button.font_size or 24,
				text_color = Color.terminal_text_body(255, true),
				default_color = Color.terminal_text_body(255, true),
				hover_color = Color.terminal_text_header_selected(255, true),
				offset = {10, 0, 1},
			},
			change_function = function(content, style)
				local hotspot = content.hotspot
				local is_empty = (content.text == nil or content.text == "") and (content.value == nil or content.value == "")
				local default_color = style.default_color
				local hover_color = style.hover_color
				local hover_progress = is_empty and 0 or (hotspot.anim_hover_progress or 0)
				local color = style.text_color

				color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
				color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
				color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
			end,
		},
		{
			pass_type = "text",
			value_id = "value",
			style = {
				text_vertical_alignment = "center",
				text_horizontal_alignment = "right",
				font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
				font_size = UIFontSettings.list_button.font_size or 24,
				text_color = Color.terminal_text_header(255, true),
				default_color = Color.terminal_text_header(255, true),
				hover_color = Color.terminal_text_header_selected(255, true),
				offset = {-10, 0, 1},
			},
			change_function = function(content, style)
				local hotspot = content.hotspot
				local is_empty = (content.text == nil or content.text == "") and (content.value == nil or content.value == "")
				local default_color = style.default_color
				local hover_color = style.hover_color
				local hover_progress = is_empty and 0 or (hotspot.anim_hover_progress or 0)
				local color = style.text_color

				color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
				color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
				color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
			end,
		},
	},
	init = function(_, widget, element)
		widget.content.text = element.text or ""
		widget.content.value = element.value or ""
	end,
}

blueprints.stat_line_with_description = {
	size = {grid_size[1] - 20, 65},
	size_function = function()
		return {grid_size[1] - 20, 65} -- фиксированная высота, без динамики
	end,
	pass_template = {
		{
			content_id = "hotspot",
			pass_type = "hotspot",
			content = {
				use_is_focused = false,
			},
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/backgrounds/default_square",
			style = {
				color = Color.terminal_background_selected(0, true),
				offset = {0, 0, 0},
			},
			change_function = function(content, style)
				local hotspot = content.hotspot
				local hover_progress = hotspot.anim_hover_progress or 0
				local alpha = 100 * hover_progress
				style.color[1] = alpha
			end,
		},
		{
			pass_type = "text",
			value_id = "text",
			style = {
				text_vertical_alignment = "top",
				text_horizontal_alignment = "left",
				font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
				font_size = UIFontSettings.list_button.font_size or 24,
				text_color = Color.terminal_text_body(255, true),
				default_color = Color.terminal_text_body(255, true),
				hover_color = Color.terminal_text_header_selected(255, true),
				offset = {10, 8, 1},
			},
			change_function = function(content, style)
				local hotspot = content.hotspot
				local default_color = style.default_color
				local hover_color = style.hover_color
				local hover_progress = hotspot.anim_hover_progress or 0
				local color = style.text_color

				color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
				color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
				color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
			end,
		},
		{
			pass_type = "text",
			value_id = "value",
			style = {
				text_vertical_alignment = "top",
				text_horizontal_alignment = "right",
				font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
				font_size = UIFontSettings.list_button.font_size or 24,
				text_color = Color.terminal_text_header(255, true),
				default_color = Color.terminal_text_header(255, true),
				hover_color = Color.terminal_text_header_selected(255, true),
				offset = {-10, 8, 1},
			},
			change_function = function(content, style)
				local hotspot = content.hotspot
				local default_color = style.default_color
				local hover_color = style.hover_color
				local hover_progress = hotspot.anim_hover_progress or 0
				local color = style.text_color

				color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
				color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
				color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
			end,
		},
		{
			pass_type = "text",
			value_id = "description",
			style = {
				text_vertical_alignment = "top",
				text_horizontal_alignment = "left",
				word_wrap = true,
				font_type = "proxima_nova_bold",
				font_size = 18,
				text_color = Color.terminal_text_body_dark(180, true),
				offset = {14, 34, 1}, -- под фиксированную высоту
			},
		},
	},
	init = function(_, widget, element)
		widget.content.text = element.text or ""
		widget.content.value = element.value or ""
		widget.content.description = element.description or ""
	end,
}

blueprints.stat_header = {
	size = {grid_size[1] - 20, 40},
	size_function = function()
		return {grid_size[1] - 20, 40}
	end,
	pass_template = {
		{
			pass_type = "text",
			value_id = "text",
			style = {
				text_vertical_alignment = "center",
				text_horizontal_alignment = "left",
				font_type = UIFontSettings.list_button.font_type or "glass_gothic_medium",
				font_size = (UIFontSettings.list_button.font_size or 24) + 6,
				text_color = Color.terminal_text_header(255, true),
				offset = {10, 0, 1},
			},
		},
	},
	init = function(_, widget, element)
		widget.content.text = element.text or ""
	end,
}

if constants.DEBUG then
	blueprints.debug_line = {
		size = {grid_size[1] - 20, 70},
		size_function = function()
			return {grid_size[1] - 20, 70}
		end,
		pass_template = {
			{
				content_id = "hotspot",
				pass_type = "hotspot",
				content = {
					use_is_focused = false,
				},
			},
			{
				pass_type = "texture",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					color = Color.terminal_background_selected(0, true),
					offset = {0, 0, 0},
				},
				change_function = function(content, style)
					local hotspot = content.hotspot
					local hover_progress = hotspot.anim_hover_progress or 0
					local alpha = 100 * hover_progress
					style.color[1] = alpha
				end,
			},
			{
				pass_type = "text",
				value_id = "text",
				style = {
					text_vertical_alignment = "top",
					text_horizontal_alignment = "left",
					font_type = UIFontSettings.list_button.font_type or "glass_gothic_medium",
					font_size = (UIFontSettings.list_button.font_size or 24) - 2,
					text_color = Color.terminal_text_body(255, true),
					default_color = Color.terminal_text_body(255, true),
					hover_color = Color.terminal_text_header_selected(255, true),
					offset = {10, 5, 1},
				},
				change_function = function(content, style)
					local hotspot = content.hotspot
					local default_color = style.default_color
					local hover_color = style.hover_color
					local hover_progress = hotspot.anim_hover_progress or 0
					local color = style.text_color

					color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
					color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
					color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
				end,
			},
			{
				pass_type = "text",
				value_id = "value",
				style = {
					text_vertical_alignment = "bottom",
					text_horizontal_alignment = "right",
					font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
					font_size = 20,
					text_color = Color.terminal_text_header(255, true),
					default_color = Color.terminal_text_header(255, true),
					hover_color = Color.terminal_text_header_selected(255, true),
					offset = {-10, -5, 1},
				},
				change_function = function(content, style)
					local hotspot = content.hotspot
					local default_color = style.default_color
					local hover_color = style.hover_color
					local hover_progress = hotspot.anim_hover_progress or 0
					local color = style.text_color

					color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
					color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
					color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
				end,
			},
		},
		init = function(_, widget, element)
			widget.content.text = element.text or ""
			widget.content.value = element.value or ""
		end,
	}
end

return blueprints

