local mod = get_mod("ClipIt")

local ViewElementGrid = mod:original_require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local ViewElementInputLegend = mod:original_require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")

local constants = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_constants")
local blueprints = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_blueprints")
local scenegraph_module = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_definitions")
local Layout = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_layout")

local sessions_panel_size = constants.sessions_panel_size
local messages_panel_size = constants.messages_panel_size
local scrollbar_width = constants.scrollbar_width
local sessions_grid_size = constants.sessions_grid_size
local messages_grid_size = constants.messages_grid_size
local sessions_mask_size = constants.sessions_mask_size
local messages_mask_size = constants.messages_mask_size

local definitions = {
	scenegraph_definition = scenegraph_module.scenegraph_definition,
	widget_definitions = scenegraph_module.widget_definitions,
	legend_inputs = scenegraph_module.legend_inputs,
}

local ChatHistoryView = class("ChatHistoryView", "BaseView")

function ChatHistoryView:init(settings, context)
	ChatHistoryView.super.init(self, definitions, settings, context)
	self._context = context
	self._selected_entry = nil
end

function ChatHistoryView:on_enter()
	ChatHistoryView.super.on_enter(self)
	
	self:_setup_input_legend()
	self:_setup_sessions_grid()
	self:_setup_messages_grid()
	self:_load_sessions_list()
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

function ChatHistoryView:_setup_sessions_grid()
	local grid_settings = {
		scrollbar_width = scrollbar_width,
		grid_spacing = {0, 5},
		grid_size = sessions_grid_size,
		mask_size = sessions_mask_size,
		title_height = 0,
		edge_padding = 0,
		use_terminal_background = false,
		hide_dividers = true,
		hide_background = true,
		enable_gamepad_scrolling = true,
	}
	
	local layer = 10
	self._sessions_grid = self:_add_element(ViewElementGrid, "sessions_grid", layer, grid_settings, "sessions_grid_pivot")
end

function ChatHistoryView:_setup_messages_grid()
	local grid_settings = {
		scrollbar_width = scrollbar_width,
		grid_spacing = {0, 2},
		grid_size = messages_grid_size,
		mask_size = messages_mask_size,
		title_height = 0,
		edge_padding = 0,
		use_terminal_background = false,
		hide_dividers = true,
		hide_background = true,
		enable_gamepad_scrolling = true,
	}
	
	local layer = 10
	self._messages_grid = self:_add_element(ViewElementGrid, "messages_grid", layer, grid_settings, "messages_grid_pivot")
end

function ChatHistoryView:_load_sessions_list()
	self._selected_entry = nil
	
	local title_widget = self._widgets_by_name.title
	if title_widget then
		title_widget.content.text = mod:localize("chat_history_view_title") or "Chat History"
		title_widget.dirty = true
	end
	
	local entries = mod.history:get_history_entries(true)
	
	if #entries == 0 then
		if self._sessions_grid then
			self._sessions_grid:present_grid_layout({}, blueprints)
		end
		if self._messages_grid then
			self._messages_grid:present_grid_layout({}, blueprints)
		end
		return
	end
	
	local layout = Layout.create_sessions_layout(entries, mod)
	if self._sessions_grid then
		local left_click_callback = callback(self, "cb_on_grid_entry_left_pressed")
		self._sessions_grid:present_grid_layout(layout, blueprints, left_click_callback)
	end
	
	if #entries > 0 then
		self:_on_session_selected(entries[1])
	end
end

function ChatHistoryView:cb_on_grid_entry_left_pressed(widget, element)
	if element and element.entry_data then
		self:_on_session_selected(element.entry_data)
	end
end

function ChatHistoryView:_on_session_selected(entry)
	if not entry then
		return
	end
	
	self._selected_entry = entry
	
	if self._sessions_grid and self._sessions_grid._widgets_by_entry_id then
		for entry_id, widgets_data in pairs(self._sessions_grid._widgets_by_entry_id) do
			local widget = widgets_data.widget
			if widget and widget.content then
				if widget.content.entry_data == entry then
					widget.content.is_selected = true
				else
					widget.content.is_selected = false
				end
			end
		end
	end
	
	local title_widget = self._widgets_by_name.title
	if title_widget then
		local session_type_localized = ""
		if entry.session_type == "mission" then
			session_type_localized = mod:localize("chat_history_session_mission") or "Mission"
		elseif entry.session_type == "mourningstar" then
			session_type_localized = mod:localize("chat_history_session_mourningstar") or "Mourningstar"
		elseif entry.session_type == "psykhanium" then
			session_type_localized = mod:localize("chat_history_session_psykhanium") or "Psykhanium"
		else
			session_type_localized = mod:localize("chat_history_session_unknown") or "Unknown"
		end
		local location_name = entry.location_name or "Unknown Location"
		title_widget.content.text = string.format("%s - %s: %s", 
			mod:localize("chat_history_view_title") or "Chat History", 
			session_type_localized, 
			location_name
		)
		title_widget.dirty = true
	end
	
	if not entry.file then
		if self._messages_grid then
			self._messages_grid:present_grid_layout({}, blueprints)
		end
		return
	end
	
	local history_data = mod.history:load_history_entry(entry.file)
	if not history_data or not history_data.messages then
		if self._messages_grid then
			self._messages_grid:present_grid_layout({}, blueprints)
		end
		return
	end
	
	local layout = Layout.create_messages_layout(history_data.messages)
	if self._messages_grid then
		self._messages_grid:present_grid_layout(layout, blueprints)
	end
end

function ChatHistoryView:cb_on_back_pressed()
	if Managers and Managers.ui then
		Managers.ui:close_view(self.view_name)
	end
end

function ChatHistoryView:update(dt, t, input_service)
	ChatHistoryView.super.update(self, dt, t, input_service)
	
	if input_service and input_service:get("back_released") then
		if Managers and Managers.ui then
			Managers.ui:close_view(self.view_name)
		end
	end
end

function ChatHistoryView:on_exit()
	if self._input_legend_element then
		self._input_legend_element = nil
		self:_remove_element("input_legend")
	end
	
	if self._sessions_grid then
		self._sessions_grid = nil
		self:_remove_element("sessions_grid")
	end
	
	if self._messages_grid then
		self._messages_grid = nil
		self:_remove_element("messages_grid")
	end
	
	ChatHistoryView.super.on_exit(self)
end

return ChatHistoryView
