local mod = get_mod("ClipIt")

local ViewElementGrid = mod:original_require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local ViewElementInputLegend = mod:original_require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local UIFontSettings = mod:original_require("scripts/managers/ui/ui_font_settings")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")
local UIWidgetGrid = mod:original_require("scripts/ui/widget_logic/ui_widget_grid")

local constants = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_constants")
local blueprints = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_blueprints")
local scenegraph_module = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_definitions")
local Layout = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_layout")

local button_height = constants.button_height
local button_spacing = constants.button_spacing
local scrollbar_width = constants.scrollbar_width
local grid_size = scenegraph_module.grid_size
local mask_size = scenegraph_module.mask_size
local category_panel_size = constants.category_panel_size

local definitions = {
	scenegraph_definition = scenegraph_module.scenegraph_definition,
	widget_definitions = scenegraph_module.widget_definitions,
	legend_inputs = scenegraph_module.legend_inputs,
}

local ChatHistoryView = class("ChatHistoryView", "BaseView")

function ChatHistoryView:init(settings, context)
	ChatHistoryView.super.init(self, definitions, settings, context)
	self._context = context
	self._selected_session_index = 1
	self._session_entries = {}
end

function ChatHistoryView:on_enter()
	ChatHistoryView.super.on_enter(self)
	
	self:_setup_input_legend()
	self:_setup_session_buttons()
	self:_setup_messages_grid()
	self:_update_title()
	self:_load_sessions()
end

function ChatHistoryView:_setup_input_legend()
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
	local legend_inputs = definitions.legend_inputs
	
	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)
		
		self._input_legend_element:add_entry(legend_input.display_name, legend_input.input_action, legend_input.visibility_function, on_pressed_callback, legend_input.alignment)
	end
end

function ChatHistoryView:_setup_session_buttons()
	-- Кнопки будут созданы динамически в _load_sessions
	self._session_buttons = {}
	self._session_button_widgets = {}
end

function ChatHistoryView:_setup_messages_grid()
	local grid_settings = {
		scrollbar_width = scrollbar_width,
		grid_spacing = {0, 5},
		grid_size = grid_size,
		mask_size = mask_size,
		title_height = 0,
		edge_padding = 0,
		use_terminal_background = false,
		hide_dividers = true,
		hide_background = true,
		enable_gamepad_scrolling = true,
	}
	
	local layer = 10
	self._messages_grid = self:_add_element(ViewElementGrid, "messages_grid", layer, grid_settings, "grid_pivot")
end

function ChatHistoryView:_update_title()
	local title_widget = self._widgets_by_name.title_text
	
	if not title_widget then
		return
	end
	
	local success, title_text = pcall(function()
		return mod:localize("chat_history_view_title")
	end)
	
	if success and title_text and title_text ~= "" then
		title_widget.content.text = title_text
	else
		title_widget.content.text = "ИСТОРИЯ ЧАТА"
	end
	
	title_widget.dirty = true
end

function ChatHistoryView:_load_sessions()
	mod:echo("[ChatHistoryView] _load_sessions called")
	
	-- Очищаем grid кнопок если существует
	if self._session_buttons_grid then
		mod:echo("[ChatHistoryView] Destroying existing grid")
		self._session_buttons_grid = nil
	end
	
	-- Удаляем и уничтожаем старые виджеты
	if self._session_button_widgets and self._ui_renderer then
		mod:echo("[ChatHistoryView] Destroying " .. tostring(#self._session_button_widgets) .. " old widgets")
		for i = 1, #self._session_button_widgets do
			local widget = self._session_button_widgets[i]
			if widget then
				if widget.name then
					self:_unregister_widget_name(widget.name)
				end
				-- Уничтожаем widget через UIWidget.destroy
				UIWidget.destroy(self._ui_renderer, widget)
			end
		end
	end
	self._session_button_widgets = {}
	
	-- Получаем список сессий (используем кеш, не сканируем каждый раз)
	self._session_entries = mod.history:get_history_entries(false)
	
	mod:echo("[ChatHistoryView] Total session entries: " .. tostring(#self._session_entries))
	
	if #self._session_entries == 0 then
		mod:echo("[ChatHistoryView] No sessions found, displaying empty list")
		self._selected_session_index = nil
		if self._messages_grid then
			self._messages_grid:present_grid_layout({}, blueprints)
		end
		return
	end
	
	-- Создаём кнопки для каждой сессии
	self:_create_session_buttons()
	
	-- Выбираем первую сессию и загружаем её сообщения
	self._selected_session_index = 1
	self:_update_session_selection()
	self:_load_session_messages()
end

function ChatHistoryView:_create_session_buttons()
	mod:echo("[ChatHistoryView] _create_session_buttons: creating " .. tostring(#self._session_entries) .. " buttons")
	
	local widgets = {}
	local alignment_list = {}
	
	for index, entry in ipairs(self._session_entries) do
		-- Получаем информацию для отображения
		local mission_name = Layout.get_session_display_name(entry, mod)
		local time_str = entry.date or ""
		
		-- Формат: время - название миссии
		local display_text = time_str .. " - " .. mission_name
		
		mod:echo("[ChatHistoryView] Creating button " .. tostring(index) .. ": " .. display_text)
		
		-- Создаём widget definition
		local widget_definition = UIWidget.create_definition(
			blueprints.session_button.pass_template, 
			"sessions_list_pivot", 
			nil, 
			blueprints.session_button.size
		)
		
		local widget_name = "session_button_widget_" .. index
		local widget = self:_create_widget(widget_name, widget_definition)
		
		-- Инициализируем widget
		widget.content.text = display_text
		widget.content.sub_text = ""
		widget.content.entry_data = entry
		widget.file = entry.file
		
		-- Устанавливаем callback
		local hotspot = widget.content.hotspot
		if hotspot then
			hotspot.pressed_callback = callback(self, "_on_session_button_pressed", index)
		end
		
		widgets[index] = widget
		alignment_list[index] = widget
	end
	
	-- Создаём UIWidgetGrid для кнопок
	local ui_scenegraph = self._ui_scenegraph
	local direction = "down"
	local grid_spacing = {0, button_spacing}
	
	self._session_buttons_grid = UIWidgetGrid:new(
		widgets,
		alignment_list,
		ui_scenegraph,
		"sessions_list_pivot",
		direction,
		grid_spacing
	)
	
	local render_scale = self._render_scale
	self._session_buttons_grid:set_render_scale(render_scale)
	
	self._session_button_widgets = widgets
	
	mod:echo("[ChatHistoryView] _create_session_buttons: created " .. tostring(#self._session_button_widgets) .. " widgets")
end

function ChatHistoryView:_on_session_button_pressed(index)
	mod:echo("[ChatHistoryView] _on_session_button_pressed called with index: " .. tostring(index))
	mod:echo("[ChatHistoryView] Total session entries: " .. tostring(#self._session_entries))
	
	if not self._session_entries or #self._session_entries == 0 then
		mod:echo("[ChatHistoryView] ERROR: No session entries available")
		return
	end
	
	if not self._session_entries[index] then
		mod:echo("[ChatHistoryView] ERROR: Invalid index " .. tostring(index) .. " (max: " .. tostring(#self._session_entries) .. ")")
		return
	end
	
	local entry = self._session_entries[index]
	mod:echo("[ChatHistoryView] Entry file: " .. tostring(entry.file))
	
	self._selected_session_index = index
	self:_update_session_selection()
	self:_load_session_messages()
end

function ChatHistoryView:_update_session_selection()
	for i = 1, #self._session_button_widgets do
		local widget = self._session_button_widgets[i]
		if widget and widget.content and widget.content.hotspot then
			widget.content.hotspot.is_selected = (self._selected_session_index == i)
		end
	end
end

function ChatHistoryView:_load_session_messages()
	if not self._messages_grid then
		mod:echo("[ChatHistoryView] No messages grid")
		return
	end
	
	if not self._session_entries or #self._session_entries == 0 then
		mod:echo("[ChatHistoryView] No session entries available")
		self._messages_grid:present_grid_layout({}, blueprints)
		return
	end
	
	local selected_index = self._selected_session_index
	if not selected_index or selected_index < 1 or selected_index > #self._session_entries then
		mod:echo("[ChatHistoryView] Invalid selected index: " .. tostring(selected_index) .. " (total: " .. tostring(#self._session_entries) .. ")")
		self._messages_grid:present_grid_layout({}, blueprints)
		return
	end
	
	local entry = self._session_entries[selected_index]
	if not entry then
		mod:echo("[ChatHistoryView] No entry for index: " .. tostring(selected_index))
		self._messages_grid:present_grid_layout({}, blueprints)
		return
	end
	
	if not entry.file then
		mod:echo("[ChatHistoryView] No file in entry")
		self._messages_grid:present_grid_layout({}, blueprints)
		return
	end
	
	mod:echo("[ChatHistoryView] Loading file: " .. tostring(entry.file))
	
	-- Загружаем данные сессии
	local history_data = mod.history:load_history_entry(entry.file)
	if not history_data then
		mod:echo("[ChatHistoryView] Failed to load history data")
		self._messages_grid:present_grid_layout({}, blueprints)
		return
	end
	
	if not history_data.messages then
		mod:echo("[ChatHistoryView] No messages in history data")
		self._messages_grid:present_grid_layout({}, blueprints)
		return
	end
	
	mod:echo("[ChatHistoryView] Loaded " .. tostring(#history_data.messages) .. " messages")
	
	-- Создаём layout для сообщений
	local layout = Layout.create_messages_layout(history_data.messages)
	self._messages_grid:present_grid_layout(layout, blueprints)
end

function ChatHistoryView:cb_on_back_pressed()
	if Managers and Managers.ui then
		Managers.ui:close_view(self.view_name)
	end
end

function ChatHistoryView:update(dt, t, input_service)
	-- Обновляем grid кнопок сессий
	if self._session_buttons_grid then
		self._session_buttons_grid:update(dt, t, input_service)
	end
	
	ChatHistoryView.super.update(self, dt, t, input_service)
	
	if input_service and input_service:get("back_released") then
		if Managers and Managers.ui then
			Managers.ui:close_view(self.view_name)
		end
	end
end

function ChatHistoryView:draw(dt, t, input_service, layer)
	-- Рисуем кнопки сессий через grid
	if self._session_buttons_grid and self._session_button_widgets and self._ui_renderer then
		local ui_renderer = self._ui_renderer
		local ui_scenegraph = self._ui_scenegraph
		local render_settings = self._render_settings
		
		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)
		
		for i = 1, #self._session_button_widgets do
			local widget = self._session_button_widgets[i]
			if widget and self._session_buttons_grid:is_widget_visible(widget) then
				UIWidget.draw(widget, ui_renderer)
			end
		end
		
		UIRenderer.end_pass(ui_renderer)
	end
	
	ChatHistoryView.super.draw(self, dt, t, input_service, layer)
end

function ChatHistoryView:on_exit()
	if self._input_legend_element then
		self._input_legend_element = nil
		self:_remove_element("input_legend")
	end
	
	if self._messages_grid then
		self._messages_grid = nil
		self:_remove_element("messages_grid")
	end
	
	-- Очищаем grid кнопок
	if self._session_buttons_grid then
		self._session_buttons_grid = nil
	end
	
	-- Удаляем и уничтожаем виджеты кнопок
	if self._session_button_widgets and self._ui_renderer then
		for i = 1, #self._session_button_widgets do
			local widget = self._session_button_widgets[i]
			if widget then
				if widget.name then
					self:_unregister_widget_name(widget.name)
				end
				UIWidget.destroy(self._ui_renderer, widget)
			end
		end
		self._session_button_widgets = nil
	end
	
	ChatHistoryView.super.on_exit(self)
end

return ChatHistoryView
