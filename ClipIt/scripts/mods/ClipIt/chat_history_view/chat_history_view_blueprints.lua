local mod = get_mod("ClipIt")
local ButtonPassTemplates = mod:original_require("scripts/ui/pass_templates/button_pass_templates")
local UIFontSettings = mod:original_require("scripts/managers/ui/ui_font_settings")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Color = Color

local constants = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_constants")

local grid_size = constants.grid_size
local category_panel_size = constants.category_panel_size
local button_height = constants.button_height

local blueprints = {}

-- Blueprint для кнопок сессий в левой панели (как tabs в GlobalStat)
blueprints.session_button = {
	size = {category_panel_size[1] - 20, button_height},
	size_function = function()
		return {category_panel_size[1] - 20, button_height}
	end,
	pass_template = ButtonPassTemplates.list_button,
	init = function(parent, widget, element, callback_name)
		local content = widget.content
		local style = widget.style
		
		content.text = element.text or ""
		content.sub_text = element.subtext or ""
		content.entry_data = element.entry_data
		
		if callback_name and element.pressed_callback then
			content.hotspot.pressed_callback = element.pressed_callback
		end
	end,
}

-- Blueprint для сообщений в правой панели
blueprints.message_entry = {
	size = {grid_size[1], nil},
	size_function = function(parent, element, ui_renderer)
		local text = element.text or ""
		local text_style = UIFontSettings.body or {}
		local font_type = text_style.font_type or "proxima_nova_bold"
		local font_size = text_style.font_size or 18
		local text_options = UIFonts.get_font_options_by_style(text_style)
		
		local width = grid_size[1] - 40
		local _, text_height = UIRenderer.text_size(ui_renderer, text, font_type, font_size, {width, 0}, text_options)
		
		local height = math.max(text_height + 20, 40)
		
		return {grid_size[1], height}
	end,
	pass_template = {
		{
			pass_type = "text",
			value_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 18,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = Color.terminal_text_body(255, true),
				word_wrap = true,
				offset = {20, 10, 1},
				size = {grid_size[1] - 40, nil},
			},
		},
	},
	init = function(parent, widget, element)
		widget.content.text = element.text or ""
	end,
}

-- Blueprint для заголовка категории (если потребуется)
blueprints.category_header = {
	size = {grid_size[1], 50},
	pass_template = {
		{
			pass_type = "text",
			value_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 24,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_header(255, true),
				offset = {20, 0, 1},
			},
		},
	},
	init = function(parent, widget, element)
		widget.content.text = element.text or ""
	end,
}

return blueprints
