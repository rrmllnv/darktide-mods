local mod = get_mod("ClipIt")
local Color = Color
local UIFontSettings = mod:original_require("scripts/managers/ui/ui_font_settings")

local constants = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_constants")

local sessions_grid_size = constants.sessions_grid_size
local messages_grid_size = constants.messages_grid_size

local blueprints = {}

blueprints.session_entry = {
	size = {sessions_grid_size[1] - 20, 60},
	size_function = function()
		return {sessions_grid_size[1] - 20, 60}
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
			pass_type = "rect",
			style = {
				color = {100, 30, 30, 30},
				offset = {0, 0, 0},
			},
		},
		{
			pass_type = "rect",
			value_id = "is_selected",
			style = {
				color = {150, 100, 150, 50},
				offset = {0, 0, 0},
			},
			change_function = function(content, style)
				style.color[1] = content.is_selected and 150 or 0
			end,
		},
		{
			pass_type = "text",
			value_id = "text",
			style = {
				font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
				font_size = UIFontSettings.list_button.font_size or 24,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_body(255, true),
				default_color = Color.terminal_text_body(255, true),
				hover_color = Color.terminal_text_header_selected(255, true),
				offset = {15, 0, 1},
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
			value_id = "subtext",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 16,
				text_horizontal_alignment = "right",
				text_vertical_alignment = "center",
				text_color = {200, 180, 180, 180},
				offset = {-15, 0, 1},
			},
		},
	},
	init = function(parent, widget, element, callback_name)
		local content = widget.content
		local hotspot = content.hotspot
		
		if hotspot and callback_name then
			hotspot.pressed_callback = function()
				callback(parent, callback_name, widget, element)()
			end
		end
		
		content.text = element.text or ""
		content.subtext = element.subtext or ""
		content.entry_data = element.entry_data
		content.is_selected = false
	end,
}

blueprints.message_entry = {
	size = {messages_grid_size[1] - 20, 40},
	size_function = function()
		return {messages_grid_size[1] - 20, 40}
	end,
	pass_template = {
		{
			pass_type = "text",
			value_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 16,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = {255, 220, 220, 220},
				word_wrap = true,
				offset = {15, 5, 1},
				size = {messages_grid_size[1] - 50, nil},
			},
		},
	},
	init = function(_, widget, element)
		widget.content.text = element.text or ""
	end,
}

return blueprints
