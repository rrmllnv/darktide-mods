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
				local is_empty = (content.original_text == nil or content.original_text == "") and (content.value == nil or content.value == "")
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
				local is_empty = (content.original_text == nil or content.original_text == "") and (content.value == nil or content.value == "")
				local default_color = style.default_color
				local hover_color = style.hover_color
				local hover_progress = is_empty and 0 or (hotspot.anim_hover_progress or 0)
				local color = style.text_color

				color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
				color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
				color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
				
				if not is_empty then
					local prefix = content.checked and "✓ " or ""
					local original_text = content.original_text or ""
					content.text = prefix .. original_text
				end
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
				local is_empty = (content.original_text == nil or content.original_text == "") and (content.value == nil or content.value == "")
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
	init = function(parent, widget, element)
		local mod = get_mod("GlobalStat")
		local original_text = element.text or ""
		widget.content.original_text = original_text
		widget.content.value = element.value or ""
		
		-- Проверяем, является ли строка пустой
		local is_empty = (original_text == nil or original_text == "") and (widget.content.value == nil or widget.content.value == "")
		
		-- Сохраняем данные из element
		widget.content.text_key = element.text_key
		widget.content.stat_name = element.stat_name
		widget.content.description_key = element.description_key
		widget.content.tab_key = element.tab_key
		
		-- Создаем уникальный element_id с учетом tab_key только для непустых строк
		widget.content.element_id = nil
		if not is_empty then
			local tab_key = element.tab_key or ""
			local text_key = element.text_key or ""
			local stat_name = element.stat_name or ""
			widget.content.element_id = element.id or (tab_key .. "_" .. text_key .. "_" .. stat_name)
		end
		
		widget.content.checked = false
		
		-- Загружаем состояние только для непустых строк с element_id
		if not is_empty and widget.content.element_id and widget.content.element_id ~= "" then
			local checkbox_states = mod:get("globalstat_checkbox_states") or {}
			widget.content.checked = checkbox_states[widget.content.element_id] or false
		end
		
		local prefix = widget.content.checked and "✓ " or ""
		widget.content.text = prefix .. original_text
	end,
	update = function(parent, widget, input_service, dt, t)
		local content = widget.content
		local hotspot = content.hotspot
		
		if hotspot and hotspot.on_pressed then
			local is_empty = (content.original_text == nil or content.original_text == "") and (content.value == nil or content.value == "")
			
			if not is_empty then
				local mod = get_mod("GlobalStat")
				content.checked = not content.checked
				
				if content.element_id and content.element_id ~= "" then
					local checkbox_states = mod:get("globalstat_checkbox_states") or {}
					checkbox_states[content.element_id] = content.checked
					mod:set("globalstat_checkbox_states", checkbox_states)
					
					-- Сохраняем полные данные выбранной строки
					local selected_items = mod:get("globalstat_selected_items") or {}
					local selected_items_order = mod:get("globalstat_selected_items_order") or {}
					
					if content.checked then
						selected_items[content.element_id] = {
							text_key = content.text_key,
							stat_name = content.stat_name,
							description_key = content.description_key,
							tab_key = content.tab_key,
						}
						-- Добавляем в порядок, если еще нет
						local found = false
						for _, id in ipairs(selected_items_order) do
							if id == content.element_id then
								found = true
								break
							end
						end
						if not found then
							table.insert(selected_items_order, content.element_id)
						end
					else
						-- Удаляем из выбранных при снятии отметки
						selected_items[content.element_id] = nil
						-- Удаляем из порядка
						for i = #selected_items_order, 1, -1 do
							if selected_items_order[i] == content.element_id then
								table.remove(selected_items_order, i)
								break
							end
						end
					end
					
					mod:set("globalstat_selected_items", selected_items)
					mod:set("globalstat_selected_items_order", selected_items_order)
					
					-- Принудительно сохраняем в файл
					local dmf = get_mod("DMF")
					if dmf and dmf.save_unsaved_settings_to_file then
						dmf.save_unsaved_settings_to_file()
					end
				end
				
				local prefix = content.checked and "✓ " or ""
				local original_text = content.original_text or ""
				content.text = prefix .. original_text
				
				hotspot.on_pressed = false
			end
		end
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
				
				local prefix = content.checked and "✓ " or ""
				local original_text = content.original_text or ""
				content.text = prefix .. original_text
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
	init = function(parent, widget, element)
		local mod = get_mod("GlobalStat")
		local original_text = element.text or ""
		widget.content.original_text = original_text
		widget.content.value = element.value or ""
		widget.content.description = element.description or ""
		
		-- Проверяем, является ли строка пустой
		local is_empty = (original_text == nil or original_text == "") and (widget.content.value == nil or widget.content.value == "")
		
		-- Сохраняем данные из element
		widget.content.text_key = element.text_key
		widget.content.stat_name = element.stat_name
		widget.content.description_key = element.description_key
		widget.content.tab_key = element.tab_key
		
		-- Создаем уникальный element_id с учетом tab_key только для непустых строк
		widget.content.element_id = nil
		if not is_empty then
			local tab_key = element.tab_key or ""
			local text_key = element.text_key or ""
			local stat_name = element.stat_name or ""
			widget.content.element_id = element.id or (tab_key .. "_" .. text_key .. "_" .. stat_name)
		end
		
		widget.content.checked = false
		
		-- Загружаем состояние только для непустых строк с element_id
		if not is_empty and widget.content.element_id and widget.content.element_id ~= "" then
			local checkbox_states = mod:get("globalstat_checkbox_states") or {}
			widget.content.checked = checkbox_states[widget.content.element_id] or false
		end
		
		local prefix = widget.content.checked and "✓ " or ""
		widget.content.text = prefix .. original_text
	end,
	update = function(parent, widget, input_service, dt, t)
		local content = widget.content
		local hotspot = content.hotspot
		
		if hotspot and hotspot.on_pressed then
			local is_empty = (content.original_text == nil or content.original_text == "") and (content.value == nil or content.value == "")
			
			if not is_empty then
				local mod = get_mod("GlobalStat")
				content.checked = not content.checked
				
				if content.element_id and content.element_id ~= "" then
					local checkbox_states = mod:get("globalstat_checkbox_states") or {}
					checkbox_states[content.element_id] = content.checked
					mod:set("globalstat_checkbox_states", checkbox_states)
					
					-- Сохраняем полные данные выбранной строки
					local selected_items = mod:get("globalstat_selected_items") or {}
					local selected_items_order = mod:get("globalstat_selected_items_order") or {}
					
					if content.checked then
						selected_items[content.element_id] = {
							text_key = content.text_key,
							stat_name = content.stat_name,
							description_key = content.description_key,
							tab_key = content.tab_key,
						}
						-- Добавляем в порядок, если еще нет
						local found = false
						for _, id in ipairs(selected_items_order) do
							if id == content.element_id then
								found = true
								break
							end
						end
						if not found then
							table.insert(selected_items_order, content.element_id)
						end
					else
						-- Удаляем из выбранных при снятии отметки
						selected_items[content.element_id] = nil
						-- Удаляем из порядка
						for i = #selected_items_order, 1, -1 do
							if selected_items_order[i] == content.element_id then
								table.remove(selected_items_order, i)
								break
							end
						end
					end
					
					mod:set("globalstat_selected_items", selected_items)
					mod:set("globalstat_selected_items_order", selected_items_order)
					
					-- Принудительно сохраняем в файл
					local dmf = get_mod("DMF")
					if dmf and dmf.save_unsaved_settings_to_file then
						dmf.save_unsaved_settings_to_file()
					end
				end
				
				local prefix = content.checked and "✓ " or ""
				local original_text = content.original_text or ""
				content.text = prefix .. original_text
				
				hotspot.on_pressed = false
			end
		end
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

