local mod = get_mod("MourningstarCommandWheel")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")

-- Загружаем settings через io_dofile, чтобы settings() зарегистрировал глобальный объект
mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")
local CommandWheelSettings = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")

-- Загружаем definitions
local Definitions = mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_definitions")
local InputDevice = require("scripts/managers/input/input_device")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Vector3 = Vector3
local RESOLUTION_LOOKUP = RESOLUTION_LOOKUP

local HOVER_GRACE_PERIOD = 0.4

local valid_lvls = {
	shooting_range = true,
	hub = true,
}

local is_in_valid_lvl = function()
	if Managers and Managers.state and Managers.state.game_mode then
		return valid_lvls[Managers.state.game_mode:game_mode_name()] or false
	end
	return false
end

-- Определения кнопок
local button_definitions = {
	{
		id = "barber",
		view = "barber_vendor_background_view",
		label_key = "button_barber",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "contracts",
		view = "contracts_background_view",
		label_key = "button_contracts",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "crafting",
		view = "crafting_view",
		label_key = "button_crafting",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "credits_vendor",
		view = "credits_vendor_background_view",
		label_key = "button_credits_vendor",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	-- {
	-- 	id = "inbox",
	-- 	view = "inbox_view",
	-- 	label_key = "button_inbox",
	-- 	icon = "content/ui/materials/icons/system/escape/achievements",
	-- },
	{
		id = "mission_board",
		view = "mission_board_view",
		label_key = "button_mission_board",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "premium_store",
		view = "store_view",
		label_key = "button_premium_store",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "training_grounds",
		view = "training_grounds_view",
		label_key = "button_training_grounds",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "social",
		view = "social_menu_view",
		label_key = "button_social",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "commissary",
		view = "cosmetics_vendor_background_view",
		label_key = "button_commissary",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "penance",
		view = "penance_overview_view",
		label_key = "button_penance",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
}

local HudElementCommandWheel = class("HudElementCommandWheel", "HudElementBase")

HudElementCommandWheel.init = function(self, parent, draw_layer, start_scale)
	HudElementCommandWheel.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._wheel_active_progress = 0
	self._wheel_active = false
	self._entries = {}
	self._last_widget_hover_data = {
		index = nil,
		t = nil,
	}
	self._wheel_context = {}
	self._close_delay = nil
	
	-- Автоматически определяем количество слотов по количеству активных кнопок
	local active_buttons_count = #button_definitions
	local wheel_slots = math.max(active_buttons_count, CommandWheelSettings.wheel_slots)
	self:_setup_entries(wheel_slots)
	self:_populate_wheel(button_definitions)
	
	self._wheel_background_widget = self._widgets_by_name.wheel_background
end

HudElementCommandWheel._setup_entries = function(self, num_entries)
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

HudElementCommandWheel._populate_wheel = function(self, options)
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
				content.icon = option.icon or "content/ui/materials/base/ui_default_base"
				content.text = mod:localize(option.label_key)
			end
		end
	end
end

HudElementCommandWheel.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementCommandWheel.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	self:_update_active_progress(dt)
	self:_update_widget_locations()

	if self._wheel_active then
		self:_update_wheel_presentation(dt, t, ui_renderer, render_settings, input_service)
	end

	self:_handle_input(t, dt, ui_renderer, render_settings, input_service)
end

HudElementCommandWheel._update_active_progress = function(self, dt)
	local active = self._wheel_active
	local anim_speed = CommandWheelSettings.anim_speed
	local progress = self._wheel_active_progress

	if active then
		progress = math.min(progress + dt * anim_speed, 1)
	else
		progress = math.max(progress - dt * anim_speed, 0)
	end

	self._wheel_active_progress = progress
	
	-- Управляем видимостью фонового виджета (тень, ромб и круг)
	local wheel_background_widget = self._wheel_background_widget
	if wheel_background_widget then
		wheel_background_widget.visible = progress > 0
	end
end

HudElementCommandWheel._update_widget_locations = function(self)
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
			
			-- Обновляем позицию только если виджет видим или колесо активно
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

HudElementCommandWheel._update_wheel_presentation = function(self, dt, t, ui_renderer, render_settings, input_service)
	local screen_width, screen_height = RESOLUTION_LOOKUP.width, RESOLUTION_LOOKUP.height
	local scale = render_settings.scale
	local cursor = input_service and input_service:get("cursor")

	if input_service and InputDevice.gamepad_active then
		cursor = input_service:get("navigate_controller_right")
		cursor[1] = screen_width * 0.5 + cursor[1] * screen_width * 0.5
		cursor[2] = screen_height * 0.5 - cursor[2] * screen_height * 0.5
	end

	if not cursor then
		return
	end

	local cursor_distance_from_center = math.distance_2d(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2])
	local cursor_angle_from_center = math.angle(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2]) - math.pi * 0.5
	local cursor_angle_degrees_from_center = math.radians_to_degrees(cursor_angle_from_center) % 360
	local entry_hover_degrees = 44
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
		local widget_angle_degrees = -(math.radians_to_degrees(widget_angle) - math.pi * 0.5) % 360
		local is_populated = entry.option ~= nil
		local is_hover = false

		if is_populated and cursor_distance_from_center > 130 * scale then
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

	local wheel_background_widget = self._wheel_background_widget

	if wheel_background_widget then
		wheel_background_widget.content.angle = cursor_angle_from_center
		wheel_background_widget.content.force_hover = any_hover
		wheel_background_widget.style.mark.color[1] = any_hover and 255 or 0

		if hovered_entry then
			local option = hovered_entry.option
			local display_name = mod:localize(option.label_key)

			wheel_background_widget.content.text = display_name

			if is_hover_started then
				if UISoundEvents.emote_wheel_entry_hover then
					Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_entry_hover)
				end
			end
		end
	end
end

HudElementCommandWheel._is_wheel_entry_hovered = function(self, t)
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

	if last_hover.t and t < last_hover.t + HOVER_GRACE_PERIOD then
		local i = last_hover.index

		return entries[i], i
	end
end

HudElementCommandWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
	if self._close_delay then
		self._close_delay = self._close_delay - dt

		if self._close_delay <= 0 then
			self._close_delay = nil
			self:_pop_cursor()
		end

		return
	end

	-- Проверяем, нажата ли клавиша открытия колеса
	-- Проверяем состояние клавиши напрямую через Keyboard/Mouse
	local input_pressed = false
	if is_in_valid_lvl() then
		input_pressed = mod:_is_command_wheel_key_pressed()
	end
	
	local wheel_context = self._wheel_context
	local start_time = wheel_context.input_start_time

	if input_pressed and not start_time then
		self:_on_wheel_start(t, input_service)
	elseif not input_pressed and start_time then
		-- При отпускании клавиши проверяем, был ли выбран элемент
		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
		if hovered_entry then
			-- Активируем выбранный элемент
			local option = hovered_entry.option
			if option and option.view then
				-- Безопасный вызов с проверкой
				local success, err = pcall(function()
					mod:activate_hub_view(option.view)
				end)
				if not success then
					mod:error("Failed to activate view '%s': %s", tostring(option.view), tostring(err))
				end
			end
		end
		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
	end

	-- Проверяем, нужно ли показывать колесо
	local draw_wheel = false
	local start_time = wheel_context.input_start_time

	if start_time then
		draw_wheel = self._wheel_active
		local always_draw_t = start_time + 0.1 -- небольшая задержка

		if always_draw_t < t then
			draw_wheel = true
		end
	end

	if draw_wheel and not self._wheel_active then
		self._wheel_active = true

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

	-- Закрытие при ESC
	if input_service:get("cancel_pressed") then
		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
		return
	end

	-- Обработка выбора
	local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
	
	if hovered_entry and input_service:get("left_pressed") then
		local option = hovered_entry.option
		if option and option.view then
			-- Безопасный вызов с проверкой
			local success, err = pcall(function()
				mod:activate_hub_view(option.view)
			end)
			if not success then
				mod:error("Failed to activate view '%s': %s", tostring(option.view), tostring(err))
			end
			self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
		end
	end
end

HudElementCommandWheel._on_wheel_start = function(self, t, input_service)
	self._wheel_context = self._wheel_context or {}
	self._wheel_context.input_start_time = t
end

HudElementCommandWheel._on_wheel_stop = function(self, t, ui_renderer, render_settings, input_service)
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


HudElementCommandWheel.using_input = function(self)
	return self._wheel_active
end

HudElementCommandWheel._push_cursor = function(self)
	local input_manager = Managers.input
	local name = self.__class_name
	local position = Vector3(0.5, 0.5, 0)

	input_manager:push_cursor(name)
	input_manager:set_cursor_position(name, position)

	self._cursor_pushed = true
end

HudElementCommandWheel._pop_cursor = function(self)
	if self._cursor_pushed then
		local input_manager = Managers.input
		local name = self.__class_name

		input_manager:pop_cursor(name)

		self._cursor_pushed = false
	end
end

HudElementCommandWheel._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	local active_progress = self._wheel_active_progress

	-- Если колесо не активно, не рисуем ничего (включая фоновый виджет)
	if active_progress == 0 then
		return
	end

	-- Устанавливаем прозрачность на основе прогресса анимации
	render_settings.alpha_multiplier = active_progress

	-- Рисуем виджеты кнопок из entries
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

	-- Рисуем остальные виджеты (wheel_background и т.д.)
	HudElementCommandWheel.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

return HudElementCommandWheel
