local mod = get_mod("ClipIt")

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local ViewElementInputLegend = mod:original_require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")

local ChatHistoryView = class("ChatHistoryView", "BaseView")

function ChatHistoryView:init(settings, context)
	self._definitions = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_definitions")
	self._blueprints = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_blueprints")
	self._settings = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_settings")
	
	ChatHistoryView.super.init(self, self._definitions, settings, context)
	
	self._pass_draw = true
	self._pass_input = true
	self._viewing_entry = nil
	self._list_widgets = {}
	self._scroll_offset = 0
	self._selected_index = 0
end

function ChatHistoryView:on_enter()
	ChatHistoryView.super.on_enter(self)
	
	self:_setup_input_legend()
	self:_load_history_list()
end

function ChatHistoryView:_setup_input_legend()
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
	local legend_inputs = self._definitions.legend_inputs
	
	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback
			and callback(self, legend_input.on_pressed_callback)
		local visibility_function = legend_input.visibility_function
		
		self._input_legend_element:add_entry(
			legend_input.display_name,
			legend_input.input_action,
			visibility_function and callback(self, visibility_function) or nil,
			on_pressed_callback,
			legend_input.alignment
		)
	end
end

function ChatHistoryView:_load_history_list()
	self._viewing_entry = nil
	self._list_widgets = {}
	self._scroll_offset = 0
	self._selected_index = 1
	
	-- Обновляем заголовок
	local title_widget = self._widgets_by_name.title
	if title_widget then
		title_widget.content.text = mod:localize("chat_history_view_title")
	end
	
	local entries = mod.history:get_history_entries(true)
	
	if #entries == 0 then
		-- Создаем виджет с сообщением "нет истории"
		local widget = self:_create_text_widget("No chat history", 0)
		table.insert(self._list_widgets, widget)
		return
	end
	
	for i, entry in ipairs(entries) do
		local widget = self:_create_entry_widget(entry, i - 1)
		table.insert(self._list_widgets, widget)
	end
end

function ChatHistoryView:_create_entry_widget(entry, index)
	local blueprint = self._blueprints.session_entry
	local y_offset = index * (blueprint.size[2] + 5)
	
	local widget_definition = UIWidget.create_definition(blueprint.passes, "grid_content", nil, blueprint.size)
	local widget = self:_create_widget("entry_" .. entry.file, widget_definition)
	
	-- Заполняем контент
	local display_name = ""
	if entry.session_type == "mission" then
		display_name = mod:localize("chat_history_session_mission") .. ": " .. entry.location_name
	elseif entry.session_type == "mourningstar" then
		display_name = mod:localize("chat_history_session_mourningstar") .. ": " .. entry.location_name
	else
		display_name = mod:localize("chat_history_session_unknown") .. ": " .. entry.location_name
	end
	
	widget.content.text = display_name
	widget.content.subtext = entry.date
	widget.content.entry_data = entry
	widget.offset[2] = y_offset
	
	return widget
end

function ChatHistoryView:_create_text_widget(text, index)
	local y_offset = index * 65
	
	local widget_definition = UIWidget.create_definition({
		{
			pass_type = "text",
			value = text,
			style_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 24,
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				text_color = {255, 200, 200, 200},
				offset = {0, 0, 1},
			},
		},
	}, "grid_content", nil, {900, 60})
	
	local widget = self:_create_widget("text_" .. text, widget_definition)
	widget.offset[2] = y_offset
	
	return widget
end

function ChatHistoryView:_load_entry_details(entry)
	self._viewing_entry = entry
	self._list_widgets = {}
	self._scroll_offset = 0
	
	-- Обновляем заголовок
	local title_widget = self._widgets_by_name.title
	if title_widget then
		local session_type_localized = ""
		if entry.session_type == "mission" then
			session_type_localized = mod:localize("chat_history_session_mission")
		elseif entry.session_type == "mourningstar" then
			session_type_localized = mod:localize("chat_history_session_mourningstar")
		else
			session_type_localized = mod:localize("chat_history_session_unknown")
		end
		title_widget.content.text = string.format("%s - %s: %s", 
			mod:localize("chat_history_view_title"), 
			session_type_localized, 
			entry.location_name
		)
	end
	
	-- Загружаем данные сессии
	local history_data = mod.history:load_history_entry(entry.file)
	if not history_data or not history_data.messages then
		local widget = self:_create_text_widget("Failed to load messages", 0)
		table.insert(self._list_widgets, widget)
		return
	end
	
	-- Создаем виджеты для сообщений
	for i, message in ipairs(history_data.messages) do
		local widget = self:_create_message_widget(message, i - 1)
		table.insert(self._list_widgets, widget)
	end
end

function ChatHistoryView:_create_message_widget(message, index)
	local blueprint = self._blueprints.message_entry
	local y_offset = index * (blueprint.size[2] + 2)
	
	local widget_definition = UIWidget.create_definition(blueprint.passes, "grid_content", nil, blueprint.size)
	local widget = self:_create_widget("message_" .. message.timestamp, widget_definition)
	
	local formatted_text = string.format("[%s] %s: %s", message.time_str, message.sender, message.message)
	widget.content.text = formatted_text
	widget.offset[2] = y_offset
	
	return widget
end

function ChatHistoryView:_on_back_pressed()
	if self._viewing_entry then
		self:_load_history_list()
	else
		Managers.ui:close_view(self.view_name)
	end
end

function ChatHistoryView:_on_delete_pressed()
	if self._viewing_entry then
		local success = mod.history:delete_history_entry(self._viewing_entry.file)
		if success then
			mod:notify("Chat history deleted")
			self:_load_history_list()
		else
			mod:notify("Failed to delete history")
		end
	end
end

function ChatHistoryView:_is_viewing_details()
	return self._viewing_entry ~= nil
end

function ChatHistoryView:update(dt, t, input_service)
	-- Обработка ввода для выбора
	if not self._viewing_entry and #self._list_widgets > 0 then
		if input_service:get("navigate_up_continuous") then
			self._selected_index = math.max(1, self._selected_index - 1)
		elseif input_service:get("navigate_down_continuous") then
			self._selected_index = math.min(#self._list_widgets, self._selected_index + 1)
		elseif input_service:get("confirm_pressed") then
			local widget = self._list_widgets[self._selected_index]
			if widget and widget.content.entry_data then
				self:_load_entry_details(widget.content.entry_data)
			end
		end
	end
	
	return ChatHistoryView.super.update(self, dt, t, input_service)
end

function ChatHistoryView:_draw_widgets(dt, t, input_service, ui_renderer)
	ChatHistoryView.super._draw_widgets(self, dt, t, input_service, ui_renderer)
	
	-- Рисуем виджеты списка
	for i, widget in ipairs(self._list_widgets) do
		UIWidget.draw(widget, ui_renderer)
	end
end

function ChatHistoryView:on_exit()
	self._viewing_entry = nil
	self._list_widgets = {}
	
	ChatHistoryView.super.on_exit(self)
end

return ChatHistoryView
