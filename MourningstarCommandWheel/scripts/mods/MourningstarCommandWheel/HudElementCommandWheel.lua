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
		label_key = "loc_body_shop_view_display_name",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/barber",
	},
	{
		id = "contracts",
		view = "contracts_background_view",
		label_key = "loc_marks_vendor_view_title",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/contracts",
	},
	{
		id = "crafting",
		view = "crafting_view",
		label_key = "loc_crafting_view",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/forge",
	},
	{
		id = "credits_vendor",
		view = "credits_vendor_background_view",
		label_key = "loc_vendor_view_title",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/credits_store",
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
		label_key = "loc_mission_board_view",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/mission_board",
	},
	{
		id = "premium_store",
		view = "store_view",
		label_key = "loc_store_view_display_name",  -- Игровая локализация
		icon = "content/ui/materials/icons/system/escape/premium_store",
	},
	{
		id = "training_grounds",
		view = "training_grounds_view",
		label_key = "loc_training_ground_view",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/training_grounds",
	},
	{
		id = "social",
		view = "social_menu_view",
		label_key = "loc_social_view_display_name",  -- Игровая локализация
		icon = "content/ui/materials/icons/system/escape/social",
	},
	{
		id = "commissary",
		view = "cosmetics_vendor_background_view",
		label_key = "loc_cosmetics_vendor_view_title",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/cosmetics_store",
	},
	{
		id = "penance",
		view = "penance_overview_view",
		label_key = "loc_achievements_view_display_name",  -- Игровая локализация
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "inventory",
		view = "inventory_background_view",
		label_key = "loc_character_view_display_name",  -- Игровая локализация
		icon = "content/ui/materials/icons/system/escape/inventory",
	},
	{
		id = "change_character",
		view = nil, -- Специальная обработка через функцию
		label_key = "loc_exit_to_main_menu_display_name",  -- Игровая локализация
		icon = "content/ui/materials/icons/system/escape/change_character",
		action = "change_character", -- Специальное действие вместо view
	},
	{
		id = "havoc",
		view = "havoc_background_view",
		label_key = "loc_havoc_name",  -- Игровая локализация
		icon = "content/ui/materials/hud/interactions/icons/havoc",
	},
}

-- Создаем словарь для быстрого доступа к кнопкам по id
local button_definitions_by_id = {}
for i, button in ipairs(button_definitions) do
	button_definitions_by_id[button.id] = button
end

-- Функция для загрузки порядка кнопок из настроек
local function load_wheel_config()
	local saved_config = mod:get("wheel_config")
	if saved_config and #saved_config > 0 then
		-- Проверяем, что все сохраненные id существуют
		local valid_config = {}
		for _, id in ipairs(saved_config) do
			if button_definitions_by_id[id] then
				table.insert(valid_config, id)
			end
		end
		-- Добавляем недостающие кнопки в конец
		for _, button in ipairs(button_definitions) do
			local found = false
			for _, saved_id in ipairs(valid_config) do
				if saved_id == button.id then
					found = true
					break
				end
			end
			if not found then
				table.insert(valid_config, button.id)
			end
		end
		return valid_config
	end
	-- Если нет сохраненного порядка, возвращаем порядок по умолчанию
	local default_config = {}
	for _, button in ipairs(button_definitions) do
		table.insert(default_config, button.id)
	end
	return default_config
end

-- Функция для сохранения порядка кнопок в настройки
local function save_wheel_config(wheel_config)
	mod:set("wheel_config", wheel_config)
end

-- Функция для генерации опций из конфига
local function generate_options_from_config(wheel_config)
	local options = {}
	for i, id in ipairs(wheel_config) do
		options[i] = button_definitions_by_id[id]
	end
	return options
end

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
	
	-- Загружаем порядок кнопок из настроек
	self._wheel_config = load_wheel_config()
	
	-- Автоматически определяем количество слотов по количеству активных кнопок
	local active_buttons_count = #self._wheel_config
	local wheel_slots = math.max(active_buttons_count, CommandWheelSettings.wheel_slots)
	self:_setup_entries(wheel_slots)
	
	-- Заполняем колесо из конфига
	local options = generate_options_from_config(self._wheel_config)
	self:_populate_wheel(options)
	
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
				-- Используем игровую локализацию для ключей, начинающихся с "loc_", иначе используем локализацию мода
				if option.label_key and string.sub(option.label_key, 1, 4) == "loc_" then
					content.text = Localize(option.label_key)
				else
					content.text = mod:localize(option.label_key)
				end
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
	
	-- Используем настраиваемые параметры для hover
	local hover_min_distance = CommandWheelSettings.hover_min_distance or 130
	local entry_hover_degrees = CommandWheelSettings.hover_angle_degrees or 44
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

		if is_populated and cursor_distance_from_center > hover_min_distance * scale then
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
			-- Используем игровую локализацию для ключей, начинающихся с "loc_", иначе используем локализацию мода
			local display_name
			if option.label_key and string.sub(option.label_key, 1, 4) == "loc_" then
				display_name = Localize(option.label_key)
			else
				display_name = mod:localize(option.label_key)
			end

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
			if option then
				-- Безопасный вызов с проверкой
				local success, err = pcall(function()
					if option.action == "change_character" then
						-- Специальная обработка для смены персонажа
						mod:change_character()
					elseif option.view then
						mod:activate_hub_view(option.view)
					end
				end)
				if not success then
					mod:error("Failed to activate action/view '%s': %s", tostring(option.action or option.view), tostring(err))
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

	-- Получаем объект Mouse для проверки правой кнопки мыши
	local Mouse = rawget(_G, "Mouse")
	local right_mouse_held = false
	if Mouse then
		right_mouse_held = Mouse.button(1) == 1
	else
		-- Альтернативный способ через input_service
		right_mouse_held = input_service:get("right_hold") or false
	end

	-- Обработка перетаскивания правой кнопкой мыши
	local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
	
	if hovered_entry and right_mouse_held then
		-- Начинаем или продолжаем перетаскивание
		if not mod.dragged_entry then
			mod.dragged_entry = hovered_entry
			mod.dragged_index = hovered_index
		end

		-- Если наведены на другой элемент, меняем местами
		if hovered_index ~= mod.dragged_index then
			local wheel_config = self._wheel_config
			local replaced_id = wheel_config[hovered_index]
			wheel_config[hovered_index] = wheel_config[mod.dragged_index]
			wheel_config[mod.dragged_index] = replaced_id

			mod.dragged_entry = hovered_entry
			mod.dragged_index = hovered_index

			-- Обновляем колесо с новым порядком
			local options = generate_options_from_config(wheel_config)
			self:_populate_wheel(options)
			
			-- Сохраняем новый порядок
			save_wheel_config(wheel_config)
		end

		-- Обновляем текст в центре
		local wheel_background_widget = self._wheel_background_widget
		if wheel_background_widget and mod.dragged_entry then
			local option = mod.dragged_entry.option
			if option then
				local display_name
				if option.label_key and string.sub(option.label_key, 1, 4) == "loc_" then
					display_name = Localize(option.label_key)
				else
					display_name = mod:localize(option.label_key)
				end
				wheel_background_widget.content.text = display_name
			end
		end

		-- Визуальная обратная связь при перетаскивании
		self:_update_drag_visual_feedback(hovered_index)
	else
		-- Сбрасываем визуальную обратную связь
		self:_reset_drag_visual_feedback()
		
		-- Сбрасываем перетаскивание
		mod.dragged_entry = nil
		mod.dragged_index = nil
	end

	-- Обработка выбора левой кнопкой мыши (только если не перетаскиваем)
	if not right_mouse_held then
		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
		
		if hovered_entry and input_service:get("left_pressed") then
			local option = hovered_entry.option
			if option then
				-- Безопасный вызов с проверкой
				local success, err = pcall(function()
					if option.action == "change_character" then
						-- Специальная обработка для смены персонажа
						mod:change_character()
					elseif option.view then
						mod:activate_hub_view(option.view)
					end
				end)
				if not success then
					mod:error("Failed to activate action/view '%s': %s", tostring(option.action or option.view), tostring(err))
				end
				self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
			end
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
	
	-- Сбрасываем состояние перетаскивания
	mod.dragged_entry = nil
	mod.dragged_index = nil
	self:_reset_drag_visual_feedback()

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

HudElementCommandWheel._update_drag_visual_feedback = function(self, hovered_index)
	local entries = self._entries
	local drag_offset = 30

	for i, entry in ipairs(entries) do
		local widget = entry.widget
		local style = widget.style
		local icon_style = style.icon
		local highlight_style = style.slice_highlight
		local slice_style = style.slice

		if i == hovered_index and entry.option then
			-- Применяем смещение для перетаскиваемого элемента
			local angle = entry.widget.content.angle or 0
			local offset_x = math.sin(angle) * drag_offset
			local offset_y = math.cos(angle) * drag_offset

			if icon_style then
				icon_style.offset[1] = offset_x
				icon_style.offset[2] = offset_y
			end
			if highlight_style then
				highlight_style.offset[1] = offset_x
				highlight_style.offset[2] = offset_y
				-- Увеличиваем яркость для визуальной обратной связи
				local hover_color = CommandWheelSettings.button_color_hover or {220, 0, 0, 0}
				highlight_style.color[1] = math.min(255, hover_color[1] + 30)
				highlight_style.color[2] = hover_color[2]
				highlight_style.color[3] = hover_color[3]
				highlight_style.color[4] = hover_color[4]
			end
			if slice_style then
				slice_style.offset[1] = offset_x
				slice_style.offset[2] = offset_y
				-- Увеличиваем яркость для визуальной обратной связи
				local hover_color = CommandWheelSettings.button_color_hover or {220, 0, 0, 0}
				slice_style.color[1] = math.min(255, hover_color[1] + 30)
				slice_style.color[2] = hover_color[2]
				slice_style.color[3] = hover_color[3]
				slice_style.color[4] = hover_color[4]
			end
		else
			-- Сбрасываем смещение для остальных элементов
			if icon_style then
				icon_style.offset[1] = 0
				icon_style.offset[2] = 0
			end
			if highlight_style then
				highlight_style.offset[1] = 0
				highlight_style.offset[2] = 0
				-- Приглушаем цвет для неактивных элементов
				local default_color = CommandWheelSettings.button_color_default or {190, 0, 0, 0}
				highlight_style.color[1] = math.max(50, default_color[1] - 140)
				highlight_style.color[2] = default_color[2]
				highlight_style.color[3] = default_color[3]
				highlight_style.color[4] = default_color[4]
			end
			if slice_style then
				slice_style.offset[1] = 0
				slice_style.offset[2] = 0
				-- Приглушаем цвет для неактивных элементов
				local default_color = CommandWheelSettings.button_color_default or {190, 0, 0, 0}
				slice_style.color[1] = math.max(50, default_color[1] - 140)
				slice_style.color[2] = default_color[2]
				slice_style.color[3] = default_color[3]
				slice_style.color[4] = default_color[4]
			end
		end
	end
end

HudElementCommandWheel._reset_drag_visual_feedback = function(self)
	local entries = self._entries

	for _, entry in ipairs(entries) do
		local widget = entry.widget
		local style = widget.style
		local icon_style = style.icon
		local highlight_style = style.slice_highlight
		local slice_style = style.slice

		if icon_style then
			icon_style.offset[1] = 0
			icon_style.offset[2] = 0
		end
		if highlight_style then
			highlight_style.offset[1] = 0
			highlight_style.offset[2] = 0
			-- Возвращаем нормальный цвет
			local default_color = CommandWheelSettings.button_color_default or {190, 0, 0, 0}
			highlight_style.color[1] = default_color[1]
			highlight_style.color[2] = default_color[2]
			highlight_style.color[3] = default_color[3]
			highlight_style.color[4] = default_color[4]
		end
		if slice_style then
			slice_style.offset[1] = 0
			slice_style.offset[2] = 0
			-- Возвращаем нормальный цвет
			local default_color = CommandWheelSettings.button_color_default or {190, 0, 0, 0}
			slice_style.color[1] = default_color[1]
			slice_style.color[2] = default_color[2]
			slice_style.color[3] = default_color[3]
			slice_style.color[4] = default_color[4]
		end
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
