local ViewMain = class("PlayerProgressionView", "BaseView")

local mod = get_mod("PlayerProgression")

local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIRenderer = require("scripts/managers/ui/ui_renderer")

local constants = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/views/view_constants")
local blueprints = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/views/view_blueprints")
local scenegraph_module = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/views/view_scenegraph")
local tab_modules = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/views/view_tabs")
local Layout = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/views/view_layout")

local hud_body_font_settings = UIFontSettings.hud_body or {}
local tabs_definitions = constants.tabs_definitions
local scrollbar_width = constants.scrollbar_width
local grid_size = scenegraph_module.grid_size
local mask_size = scenegraph_module.mask_size

local definitions = {
	scenegraph_definition = scenegraph_module.scenegraph_definition,
	widget_definitions = scenegraph_module.widget_definitions,
	legend_inputs = scenegraph_module.legend_inputs,
}

ViewMain.init = function(self, settings, context)
	ViewMain.super.init(self, definitions, settings, context)
	self._context = context
	self._active_tab_index = 1
end

ViewMain.on_enter = function(self)
	ViewMain.super.on_enter(self)

	self:_setup_input_legend()
	self:_setup_tab_buttons()
	self:_setup_stats_grid()
	self._active_tab_index = 1
	self:_update_tab_selection()
	self:_update_title()
end

ViewMain._setup_tab_buttons = function(self)
	for index, tab in ipairs(tabs_definitions) do
		local button_widget = self._widgets_by_name["tab_button_" .. index]

		if button_widget then
			local success, display_name = pcall(function()
				return mod:localize(tab.key)
			end)

			if not success or not display_name or display_name == "" or display_name == tab.key then
				display_name = tab.fallback
			end

			button_widget.content.text = display_name
			button_widget.content.hotspot.pressed_callback = callback(self, "_on_tab_pressed", index)
			button_widget.content.hotspot.is_selected = (self._active_tab_index == index)
			button_widget.dirty = true
		end
	end
end

ViewMain._setup_stats_grid = function(self)
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
	self._stats_grid = self:_add_element(ViewElementGrid, "stats_grid", layer, grid_settings, "grid_pivot")

	self:_update_grid_content()
end

ViewMain._update_tab_selection_visual = function(self)
	-- Обновляем визуальное выделение вкладок для геймпада
	local InputDevice = require("scripts/managers/input/input_device")
	local gamepad_active = InputDevice.gamepad_active

	for i = 1, #tabs_definitions do
		local button_widget = self._widgets_by_name["tab_button_" .. i]
		if button_widget then
			button_widget.content.hotspot.is_selected = (self._active_tab_index == i)
			button_widget.content.hotspot.is_focused = gamepad_active and (self._active_tab_index == i)
			button_widget.dirty = true
		end
	end
end

ViewMain._update_tab_selection = function(self)
	self:_update_tab_selection_visual()
end

ViewMain._on_tab_pressed = function(self, index)
	self._active_tab_index = index
	self:_update_tab_selection()
	self:_update_grid_content()
end

ViewMain._update_title = function(self)
	local title_widget = self._widgets_by_name.title_text

	if not title_widget then
		return
	end

	local success, title_text = pcall(function()
		return mod:localize("player_progression_title")
	end)

	if success and title_text and title_text ~= "" then
		title_widget.content.text = title_text
	else
		title_widget.content.text = "PLAYER STATISTICS"
	end

	title_widget.dirty = true
end

ViewMain._update_grid_content = function(self)
	if not self._stats_grid then
		return
	end

	local layout = self:_create_stat_layout()
	self._stats_grid:present_grid_layout(layout, blueprints)
end

ViewMain._create_stat_layout = function(self)
	return Layout.create_stat_layout(self, mod, tab_modules, constants.DEBUG)
end

ViewMain._setup_input_legend = function(self)
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
	local legend_inputs = definitions.legend_inputs

	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)

		self._input_legend_element:add_entry(legend_input.display_name, legend_input.input_action, legend_input.visibility_function, on_pressed_callback, legend_input.alignment)
	end
end

ViewMain.cb_on_back_pressed = function(self)
	if Managers and Managers.ui then
		Managers.ui:close_view(self.view_name)
	end
end

ViewMain.update = function(self, dt, t, input_service)
	if Managers and Managers.ui and Managers.ui:view_instance("dmf_options_view") then
		Managers.ui:close_view(self.view_name)

		return
	end

	ViewMain.super.update(self, dt, t, input_service)

	if input_service then
		if input_service:get("back_released") then
			if Managers and Managers.ui then
				Managers.ui:close_view(self.view_name)
			end
		end

		-- Обработка навигации по вкладкам с помощью геймпада
		local InputDevice = require("scripts/managers/input/input_device")
		if InputDevice.gamepad_active then
			-- Навигация вверх/вниз для переключения вкладок
			if input_service:get("navigate_up_continuous") then
				if not self._navigate_up_cooldown or self._navigate_up_cooldown <= 0 then
					if self._active_tab_index > 1 then
						self._active_tab_index = self._active_tab_index - 1
						self:_update_tab_selection()
						self:_update_grid_content()
						self._navigate_up_cooldown = 0.2
					end
				end
			elseif input_service:get("navigate_down_continuous") then
				if not self._navigate_down_cooldown or self._navigate_down_cooldown <= 0 then
					if self._active_tab_index < #tabs_definitions then
						self._active_tab_index = self._active_tab_index + 1
						self:_update_tab_selection()
						self:_update_grid_content()
						self._navigate_down_cooldown = 0.2
					end
				end
			end

			-- Обновление кулдаунов для навигации
			if self._navigate_up_cooldown then
				self._navigate_up_cooldown = math.max(0, self._navigate_up_cooldown - dt)
			end
			if self._navigate_down_cooldown then
				self._navigate_down_cooldown = math.max(0, self._navigate_down_cooldown - dt)
			end

			-- Подтверждение выбора вкладки
			if input_service:get("gamepad_confirm_pressed") then
				local button_widget = self._widgets_by_name["tab_button_" .. self._active_tab_index]
				if button_widget and button_widget.content.hotspot.pressed_callback then
					button_widget.content.hotspot.pressed_callback()
				end
			end
		end
	end
end

ViewMain.on_exit = function(self)
	if self._input_legend_element then
		self._input_legend_element = nil
		self:_remove_element("input_legend")
	end

	ViewMain.super.on_exit(self)
end

return ViewMain

