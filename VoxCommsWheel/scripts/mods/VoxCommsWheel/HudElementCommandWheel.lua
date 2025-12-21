local mod = get_mod("VoxCommsWheel")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")

local CommandWheelSettings = require("VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_settings")

local Definitions = mod:io_dofile("VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_definitions")
local Utils = require("VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_utils")
local Buttons = require("VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_buttons")
local Pages = require("VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_pages")
local InputDevice = require("scripts/managers/input/input_device")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")
local Vector3 = Vector3
local RESOLUTION_LOOKUP = RESOLUTION_LOOKUP

local HOVER_GRACE_PERIOD = 0.4

local is_in_valid_lvl = function()
	if Managers and Managers.state and Managers.state.game_mode then
		local game_mode_name = Managers.state.game_mode:game_mode_name()
		return game_mode_name ~= nil
	end
	return false
end

local localize_text = Utils.localize_text
local activate_option = Utils.activate_option
local apply_style_offset = Utils.apply_style_offset
local apply_style_color = Utils.apply_style_color

local button_definitions = Buttons.button_definitions
local button_definitions_by_id = Buttons.button_definitions_by_id

-- Генерация опций из страницы
local function generate_options_from_page(current_page)
	local options = {}
	
	if not Pages or not Pages.get_page_config then
		return options
	end
	
	local page_config = Pages.get_page_config(current_page)
	
	if not page_config then
		return options
	end
	
	-- Все слоты - команды страницы (центральная кнопка переключения страниц отдельно)
	local commands = page_config.commands
	if commands and type(commands) == "table" then
		for i = 1, math.min(#commands, CommandWheelSettings.wheel_slots) do
			local command_id = commands[i]
			if command_id and button_definitions_by_id and button_definitions_by_id[command_id] then
				options[i] = button_definitions_by_id[command_id]
			end
		end
	end
	
	return options
end

local HudElementVoxCommsWheel = class("HudElementVoxCommsWheel", "HudElementBase")

HudElementVoxCommsWheel.init = function(self, parent, draw_layer, start_scale)
	HudElementVoxCommsWheel.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._wheel_active_progress = 0
	self._wheel_active = false
	self._entries = {}
	self._last_widget_hover_data = {
		index = nil,
		t = nil,
	}
	self._wheel_context = {}
	self._close_delay = nil
	
	-- Инициализация страниц
	self._current_page = 1
	self._max_pages = Pages and Pages.get_max_pages and Pages.get_max_pages() or 1
	
	-- Настройка слотов
	local wheel_slots = CommandWheelSettings.wheel_slots
	self:_setup_entries(wheel_slots)
	
	-- Заполнение колеса
	local options = generate_options_from_page(self._current_page)
	self:_populate_wheel(options)
	
	-- Виджеты
	self._wheel_background_widget = self._widgets_by_name.wheel_background
	self._center_page_button_widget = self._widgets_by_name.center_page_button
	self._page_indicators_widget = self._widgets_by_name.page_indicators
end

HudElementVoxCommsWheel._setup_entries = function(self, num_entries)
	if self._entries then
		for i = 1, #self._entries do
			local entry = self._entries[i]
			local widget = entry.widget
			local widget_name = widget.name

			self:_unregister_widget_name(widget_name)
		end
	end

	local entries = {}
	local definition = Definitions.entry_widget_definition

	for i = 1, num_entries do
		local name = "entry_" .. i
		local widget = self:_create_widget(name, definition)

		entries[i] = {
			widget = widget,
		}
	end

	self._entries = entries
end

HudElementVoxCommsWheel._populate_wheel = function(self, options)
	local entries = self._entries
	local wheel_slots = CommandWheelSettings.wheel_slots

	for i = 1, wheel_slots do
		local option = options[i]
		local entry = entries[i]
		
		if entry then
			local widget = entry.widget
			local content = widget.content

			content.visible = option ~= nil
			entry.option = option

			if option then
				local localized_text = localize_text(option.label_key)
				content.text = localized_text or option.label_key or ""
				
				-- Убеждаемся, что текст установлен
				if not content.text or content.text == "" then
					content.text = option.label_key or "?"
				end
			end
		end
	end
end

HudElementVoxCommsWheel.switch_page = function(self, direction)
	direction = direction or 1
	
	self._current_page = self._current_page + direction
	
	if self._current_page > self._max_pages then
		self._current_page = 1
	elseif self._current_page < 1 then
		self._current_page = self._max_pages
	end
	
	local options = generate_options_from_page(self._current_page)
	self:_populate_wheel(options)
	
	-- Обновление индикаторов страниц
	if self._page_indicators_widget then
		for i = 1, self._max_pages do
			local style = self._page_indicators_widget.style["page_" .. i]
			if style then
				if i == self._current_page then
					style.color = { 255, 255, 255, 255 }
				else
					style.color = { 150, 150, 150, 150 }
				end
			end
		end
	end
	
	-- Обновление центральной кнопки
	if self._center_page_button_widget then
		self._center_page_button_widget.content.page_text = string.format("%d/%d", self._current_page, self._max_pages)
	end
	
	if UISoundEvents.emote_wheel_open then
		Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
	end
end

HudElementVoxCommsWheel.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementVoxCommsWheel.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	self:_update_active_progress(dt)
	self:_update_widget_locations()

	if self._wheel_active then
		self:_update_wheel_presentation(dt, t, ui_renderer, render_settings, input_service)
		
		-- Обновление force_hover для центральной кнопки (даже если нет курсора)
		-- Альфа-канал теперь полностью контролируется в change_function виджета
		if self._center_page_button_widget then
			-- Проверяем, есть ли hover на слоты напрямую через entries
			local any_hover = false
			local entries = self._entries
			if entries then
				for i = 1, #entries do
					local entry = entries[i]
					if entry and entry.widget then
						local widget = entry.widget
						if widget.content and widget.content.hotspot and widget.content.hotspot.is_hover then
							any_hover = true
							break
						end
					end
				end
			end
			
			-- Также проверяем через content.force_hover (на случай если _update_wheel_presentation не вызвался)
			if not any_hover then
				any_hover = self._center_page_button_widget.content.force_hover or false
			end
			
			-- Устанавливаем force_hover для change_function
			self._center_page_button_widget.content.force_hover = any_hover
		end
	end

	self:_handle_input(t, dt, ui_renderer, render_settings, input_service)
end

HudElementVoxCommsWheel._update_active_progress = function(self, dt)
	local active = self._wheel_active
	local anim_speed = CommandWheelSettings.anim_speed
	local progress = self._wheel_active_progress

	if active then
		progress = math.min(progress + dt * anim_speed, 1)
	else
		progress = math.max(progress - dt * anim_speed, 0)
	end

	self._wheel_active_progress = progress
	
	-- Обновление видимости виджетов
	local wheel_background_widget = self._wheel_background_widget
	if wheel_background_widget then
		wheel_background_widget.visible = progress > 0
	end
	
	if self._center_page_button_widget then
		self._center_page_button_widget.visible = progress > 0
	end
	
	if self._page_indicators_widget then
		self._page_indicators_widget.visible = progress > 0
	end
end

HudElementVoxCommsWheel._update_widget_locations = function(self)
	local entries = self._entries
	local start_angle = math.pi / 2
	local num_entries = #entries
	local radians_per_widget = math.pi * 2 / num_entries
	local active_progress = self._wheel_active_progress
	local anim_progress = math.smoothstep(active_progress, 0, 1)
	local wheel_slots = CommandWheelSettings.wheel_slots
	local min_radius = CommandWheelSettings.min_radius
	local max_radius = CommandWheelSettings.max_radius
	local radius = min_radius + anim_progress * (max_radius - min_radius)

	for i = 1, wheel_slots do
		local entry = entries[i]

		if entry then
			local widget = entry.widget
			local content = widget.content
			
			if content.visible or active_progress > 0 then
				local angle = start_angle + (i - 1) * radians_per_widget
				local position_x = math.sin(angle) * radius
				local position_y = math.cos(angle) * radius
				local offset = widget.offset

				content.angle = angle
				offset[1] = position_x
				offset[2] = position_y
			end
		end
	end
end

HudElementVoxCommsWheel._update_wheel_presentation = function(self, dt, t, ui_renderer, render_settings, input_service)
	if not input_service or type(input_service.has) ~= "function" then
		return
	end

	if not input_service:has("cursor") and not (InputDevice.gamepad_active and input_service:has("navigate_controller_right")) then
		return
	end

	local screen_width, screen_height = RESOLUTION_LOOKUP.width, RESOLUTION_LOOKUP.height
	local scale = render_settings.scale
	local cursor = nil

	if input_service:has("cursor") then
		cursor = input_service:get("cursor")
	end

	if not cursor and InputDevice.gamepad_active and input_service:has("navigate_controller_right") then
		cursor = input_service:get("navigate_controller_right")
		if cursor then
			cursor[1] = screen_width * 0.5 + cursor[1] * screen_width * 0.5
			cursor[2] = screen_height * 0.5 - cursor[2] * screen_height * 0.5
		end
	end

	if not cursor then
		return
	end

	local cursor_distance_from_center = math.distance_2d(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2])
	local cursor_angle_from_center = math.angle(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2]) - math.pi * 0.5
	local cursor_angle_degrees_from_center = math.radians_to_degrees(cursor_angle_from_center) % 360
	
	local hover_min_distance = CommandWheelSettings.hover_min_distance or 130
	local entry_hover_degrees = CommandWheelSettings.hover_angle_degrees or 30
	local entry_hover_degrees_half = entry_hover_degrees * 0.5
	local any_hover = false
	local hovered_entry
	local is_hover_started = false
	local entries = self._entries

	for i = 1, #entries do
		local entry = entries[i]
		local widget = entry.widget
		local content = widget.content
		local widget_angle = content.angle
		local is_populated = entry.option ~= nil
		local is_hover = false

		if widget_angle and is_populated and cursor_distance_from_center > hover_min_distance * scale then
			local widget_angle_degrees = -(math.radians_to_degrees(widget_angle) - math.pi * 0.5) % 360
			local angle_diff = (widget_angle_degrees - cursor_angle_degrees_from_center + 180 + 360) % 360 - 180

			if angle_diff <= entry_hover_degrees_half and angle_diff >= -entry_hover_degrees_half then
				is_hover = true
				any_hover = true
				hovered_entry = entry
			end
		end

		if is_hover and not widget.content.hotspot.force_hover then
			is_hover_started = true
		end

		widget.content.hotspot.force_hover = is_hover
	end

	-- Проверка hover для центральной кнопки
	local center_button_hover = false
	if self._center_page_button_widget then
		local center_x = screen_width * 0.5
		local center_y = screen_height * 0.5
		local center_radius = 60
		local distance = math.distance_2d(center_x, center_y, cursor[1], cursor[2])
		center_button_hover = distance <= center_radius * scale
		self._center_page_button_widget.content.hotspot.force_hover = center_button_hover
		-- Устанавливаем force_hover для изменения альфа-канала текста при наведении на слоты
		self._center_page_button_widget.content.force_hover = any_hover
		
		-- Устанавливаем force_hover для change_function (альфа-канал теперь контролируется в change_function)
		-- Не нужно напрямую изменять text_color, так как это делается в change_function
	end

	local wheel_background_widget = self._wheel_background_widget

	if wheel_background_widget then
		-- Устанавливаем угол ромба только когда есть hover на опции
		-- Это предотвращает вращение ромба когда курсор в центре
		if any_hover then
			wheel_background_widget.content.angle = cursor_angle_from_center
		end
		
		wheel_background_widget.content.force_hover = any_hover
		wheel_background_widget.style.mark.color[1] = any_hover and 255 or 0

		if hovered_entry then
			local option = hovered_entry.option
			wheel_background_widget.content.text = localize_text(option.label_key)

			if is_hover_started then
				if UISoundEvents.emote_wheel_entry_hover then
					Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_entry_hover)
				end
			end
		elseif center_button_hover then
			wheel_background_widget.content.text = localize_text("loc_page_switch")
		end
	end
end

HudElementVoxCommsWheel._is_wheel_entry_hovered = function(self, t)
	local entries = self._entries

	for i = 1, #entries do
		local entry = entries[i]
		local widget = entry.widget

		if widget.content.hotspot.is_hover then
			self._last_widget_hover_data.index = i
			self._last_widget_hover_data.t = t
			return entry, i
		end
	end

	local last_hover = self._last_widget_hover_data
	local hover_grace_period = CommandWheelSettings.hover_grace_period or 0.4

	if last_hover.t and t < last_hover.t + hover_grace_period then
		local i = last_hover.index

		return entries[i], i
	end
end

HudElementVoxCommsWheel._is_center_button_hovered = function(self, input_service)
	if not input_service then
		return false
	end
	
	local cursor = input_service:get("cursor")
	if not cursor then
		return false
	end
	
	if not self._center_page_button_widget then
		return false
	end
	
	local screen_width, screen_height = RESOLUTION_LOOKUP.width, RESOLUTION_LOOKUP.height
	local center_x = screen_width * 0.5
	local center_y = screen_height * 0.5
	local center_radius = 60
	
	local distance = math.distance_2d(center_x, center_y, cursor[1], cursor[2])
	return distance <= center_radius
end

HudElementVoxCommsWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
	if self._close_delay then
		self._close_delay = self._close_delay - dt

		if self._close_delay <= 0 then
			self._close_delay = nil
			self:_pop_cursor()
		end

		return
	end

	if Managers.ui and Managers.ui:chat_using_input() then
		if self._wheel_active then
			self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
		end
		return
	end

	local input_pressed = false
	if is_in_valid_lvl() then
		input_pressed = mod:_is_command_wheel_key_pressed()
	end
	
	local wheel_context = self._wheel_context
	local start_time = wheel_context.input_start_time

	if input_pressed and not start_time then
		self:_on_wheel_start(t, input_service)
	elseif not input_pressed and start_time then
		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
		if hovered_entry then
			activate_option(hovered_entry.option)
		end
		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
	end

	local draw_wheel = false
	local start_time = wheel_context.input_start_time

	if start_time then
		draw_wheel = self._wheel_active
		local always_draw_t = start_time + 0.1

		if always_draw_t < t then
			draw_wheel = true
		end
	end

	if draw_wheel and not self._wheel_active then
		self._wheel_active = true
		
		local options = generate_options_from_page(self._current_page)
		self:_populate_wheel(options)

		if UISoundEvents.emote_wheel_open then
			Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
		end

		if not InputDevice.gamepad_active then
			self:_push_cursor()
		end
	elseif not draw_wheel and self._wheel_active then
		self._wheel_active = false
		self._close_delay = InputDevice.gamepad_active and 0.15 or 0
	end

	if not self._wheel_active then
		return
	end

	if not input_service or type(input_service.has) ~= "function" then
		return
	end

	if input_service:has("cancel_pressed") and input_service:get("cancel_pressed") then
		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
		return
	end

	local Mouse = rawget(_G, "Mouse")
	local right_mouse_held = false
	if Mouse then
		right_mouse_held = Mouse.button(1) == 1
	else
		if input_service:has("right_hold") then
			right_mouse_held = input_service:get("right_hold") or false
		end
	end

	if not right_mouse_held and input_service and type(input_service.has) == "function" then
		-- Проверка клика по центральной кнопке
		if self:_is_center_button_hovered(input_service) then
			if input_service:has("left_pressed") and input_service:get("left_pressed") then
				self:switch_page(1)
				return
			end
		end
		
		-- Проверка клика по командам
		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
		
		if hovered_entry and input_service:has("left_pressed") and input_service:get("left_pressed") then
			local option = hovered_entry.option
			
			-- Обычная команда
			if activate_option(option) then
				self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
			end
		end
	end
end

HudElementVoxCommsWheel._on_wheel_start = function(self, t, input_service)
	self._wheel_context = self._wheel_context or {}
	self._wheel_context.input_start_time = t
end

HudElementVoxCommsWheel._on_wheel_stop = function(self, t, ui_renderer, render_settings, input_service)
	local wheel_context = self._wheel_context or {}
	wheel_context.input_start_time = nil
	
	local was_active = self._wheel_active
	
	if was_active or self._close_delay then
		self:_pop_cursor()
	end

	self._wheel_active = false
	self._close_delay = nil

	if was_active and UISoundEvents.emote_wheel_close then
		Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_close)
	end
end

HudElementVoxCommsWheel.using_input = function(self)
	return self._wheel_active
end

HudElementVoxCommsWheel._push_cursor = function(self)
	local input_manager = Managers.input
	local name = self.__class_name
	local position = Vector3(0.5, 0.5, 0)

	input_manager:push_cursor(name)
	input_manager:set_cursor_position(name, position)

	self._cursor_pushed = true
end

HudElementVoxCommsWheel._pop_cursor = function(self)
	if self._cursor_pushed then
		local input_manager = Managers.input
		local name = self.__class_name

		input_manager:pop_cursor(name)

		self._cursor_pushed = false
	end
end

HudElementVoxCommsWheel._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	local active_progress = self._wheel_active_progress

	if active_progress == 0 then
		return
	end

	render_settings.alpha_multiplier = active_progress

	local entries = self._entries

	if entries then
		for i = 1, #entries do
			local entry = entries[i]
			local widget = entry.widget

			UIWidget.draw(widget, ui_renderer)

			if widget.content.hotspot.is_hover then
				local hover_data = self._last_widget_hover_data

				hover_data.t = t
				hover_data.index = i
			end
		end
	end

	HudElementVoxCommsWheel.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
	
	-- Отрисовка текста через UIRenderer.draw_text (ВАРИАНТ 3)
	if active_progress > 0 then
		local simple_button_font_setting_name = "button_medium"
		local simple_button_font_settings = UIFontSettings[simple_button_font_setting_name]
		local font_type = simple_button_font_settings.font_type
		local font_size = CommandWheelSettings.text_font_size or 16
		local text_offset_y = 0--35 -- Смещение текста вниз от центра виджета
		local text_offset_x = -35 -- Смещение текста вниз от центра виджета
		
		-- Опции для текста
		local text_options = {
			text_horizontal_alignment = "center",
			text_vertical_alignment = "center",
		}
		
		-- Таблицы для цветов (переиспользуем для оптимизации)
		local default_text_color = {255, 255, 255, 255} -- Белый
		local hover_text_color = {255, 255, 100, 255} -- Желтый при наведении
		local text_color_table = {255, 255, 255, 255}
		
		-- Позиция и размер для текста
		local text_position = Vector3(0, 0, 500) -- Высокий z-слой
		local text_size = Vector3(200, 50, 0)
		
		for i = 1, #entries do
			local entry = entries[i]
			if entry and entry.option and entry.widget then
				local widget = entry.widget
				local content = widget.content
				
				if content.visible and content.text and content.text ~= "" then
					local widget_offset = widget.offset
					local scenegraph = self._ui_scenegraph
					
					if scenegraph then
						-- Получаем мировую позицию pivot через UIScenegraph
						local UIScenegraph = require("scripts/managers/ui/ui_scenegraph")
						local pivot_world_pos = UIScenegraph.world_position(scenegraph, "pivot")
						
						if pivot_world_pos then
							-- Вычисляем мировую позицию текста
							local world_x = pivot_world_pos[1] + widget_offset[1] + text_offset_x
							local world_y = pivot_world_pos[2] + widget_offset[2] + text_offset_y
							local world_z = 500 -- Высокий z-слой для текста
							
							text_position[1] = world_x
							text_position[2] = world_y
							text_position[3] = world_z
						
						-- Определяем цвет текста (желтый при наведении, белый по умолчанию)
						local hotspot = content.hotspot
						local anim_hover_progress = hotspot and hotspot.anim_hover_progress or 0
						
						-- Интерполируем цвет используя ColorUtilities
						ColorUtilities.color_lerp(default_text_color, hover_text_color, anim_hover_progress, text_color_table, false)
						
						-- Применяем прозрачность из active_progress
						text_color_table[4] = math.floor(text_color_table[4] * active_progress)
						
							-- Рисуем текст
							UIRenderer.draw_text(
								ui_renderer,
								content.text,
								font_size,
								font_type,
								text_position,
								text_size,
								text_color_table,
								text_options
							)
						end
					end
				end
			end
		end
	end
end

return HudElementVoxCommsWheel

