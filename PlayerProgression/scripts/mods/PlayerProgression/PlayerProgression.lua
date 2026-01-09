local mod = get_mod("PlayerProgression")

local InputDevice = require("scripts/managers/input/input_device")

-- Функция для поиска устройства по ключу (из MourningstarCommandWheel_utils)
local function find_device_for_key(key, supported_devices)
	if not key or not supported_devices then
		return nil
	end

	if not Managers or not Managers.input then
		return nil
	end

	for _, device_type in ipairs(supported_devices) do
		local device = Managers.input:_find_active_device(device_type)
		if device then
			local index = device:button_index(key)
			if index then
				return {
					device = device,
					index = index,
				}
			end
		end
	end
	
	return nil
end

local view_templates = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/templates/view_templates")
local views = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/modules/views")
local commands = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/modules/commands")
local utilities = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/modules/utilities")
local init = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/modules/init")

local VIEW_NAME = "player_progress_stats_view"

mod.version = "1.0.0"

init.setup(mod, VIEW_NAME, view_templates, views, utilities)
commands.setup(mod)

-- Функции для работы с сохраненными данными через DMF Settings
local function get_selected_data()
	local selected_items = mod:get("playerprogression_selected_items") or {}
	local selected_items_order = mod:get("playerprogression_selected_items_order") or {}
	return selected_items, selected_items_order
end

local function save_selected_data(selected_items, selected_items_order)
	mod:set("playerprogression_selected_items", selected_items)
	mod:set("playerprogression_selected_items_order", selected_items_order)
	
	-- Принудительно сохраняем в файл
	local dmf = get_mod("DMF")
	if dmf and dmf.save_unsaved_settings_to_file then
		dmf.save_unsaved_settings_to_file()
	end
end

local ElementSettings = require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_settings")

local function safe_read_stat(stat_name)
	if not Managers or not Managers.stats or not Managers.stats.read_user_stat then
		return 0
	end

	local success, value = pcall(function()
		local result = Managers.stats:read_user_stat(1, stat_name)
		return result and type(result) == "number" and result or 0
	end)

	return success and value or 0
end

local function format_number(number)
	if not number or type(number) ~= "number" then
		return "0"
	end

	if mod.format_number then
		local success, result = pcall(function()
			return mod.format_number(number)
		end)

		if success and result then
			return result
		end
	end

	return tostring(math.floor(number))
end

local function localize(key)
	if key:match("^loc_") then
		local success, result = pcall(function()
			return Localize(key)
		end)

		if success and result and result ~= "" and result ~= key then
			return result
		end
	end

	local success, result = pcall(function()
		return mod:localize(key)
	end)

	if success and result and result ~= "" then
		return result
	end

	return key
end

local function setup_game_progress(tactical_overlay, ui_renderer)
	local page_key = "game_progress"
	local selected_items, selected_items_order = get_selected_data()
	
	local configs = {
		-- {
		-- 	blueprint = "title",
		-- 	text = mod:localize("tactical_overlay_player_progression"),
		-- },
	}
	
	-- Добавляем выбранные элементы в порядке выбора
	local has_selected = false
	
	-- Итерируемся по порядку выбора
	for _, element_id in ipairs(selected_items_order) do
		local item_data = selected_items[element_id]
		if item_data and item_data.text_key then
			has_selected = true
			local text = localize(item_data.text_key)
			local value = ""
			
			-- Восстанавливаем значение из статистики
			if item_data.stat_name and item_data.stat_name ~= "" then
				local stat_value = safe_read_stat(item_data.stat_name)
				
				-- Если это элемент миссии, преобразуем значение в статус
				if item_data.mission_key or item_data.mission_name then
					-- Для миссий: 1 = пройдено, 0 = не пройдено
					value = (stat_value and stat_value > 0) and localize("mission_progress_done") or localize("mission_progress_not_done")
				else
					-- Для остальных элементов - обычное форматирование числа
					value = format_number(stat_value)
				end
			end
			
			-- Добавляем название миссии, если есть
			if item_data.mission_key or item_data.mission_name then
				local mission_display_name = item_data.mission_name
				if not mission_display_name and item_data.mission_key then
					mission_display_name = localize(item_data.mission_key)
				end
				if mission_display_name and mission_display_name ~= "" then
					text = string.format("%s - %s", mission_display_name, text)
				end
			end
			
			-- Объединяем текст и значение с цветовым форматированием
			local display_text = text
			if value and value ~= "" then
				-- Применяем светлый цвет к значению
				local colored_value = string.format("{#color(255,255,255)}%s", value)
				display_text = string.format("%s: %s", text, colored_value)
			end
			
			-- Определяем blueprint в зависимости от наличия description_key
			local blueprint = "body"
			-- Временно убрано: вывод описания
			-- if item_data.description_key and item_data.description_key ~= "" then
			-- 	local description = localize(item_data.description_key)
			-- 	-- Для описания используем body, но добавляем описание в текст
			-- 	display_text = string.format("%s\n%s", display_text, description)
			-- end
			
			table.insert(configs, {
				blueprint = blueprint,
				text = display_text,
			})
		end
	end
	
	-- Если нет выбранных элементов, показываем заглушку
	if not has_selected then
		table.insert(configs, {
			blueprint = "body",
			text = mod:localize("player_progression_no_selected_items"),
		})
	end
	
	tactical_overlay:_create_right_panel_widgets(page_key, configs, ui_renderer)
end

local function get_selected_items_hash()
	local selected_items, _ = get_selected_data()
	local count = 0
	for _ in pairs(selected_items) do
		count = count + 1
	end
	return count
end

local function update_game_progress(tactical_overlay, dt, ui_renderer)
	if not ui_renderer then
		return
	end
	
	local page_key = "game_progress"
	local has_entry = tactical_overlay._right_panel_entries and tactical_overlay._right_panel_entries[page_key] ~= nil
	
	-- Если entry еще не создано, создаем его (чтобы таб появился)
	if not has_entry then
		setup_game_progress(tactical_overlay, ui_renderer)
		return
	end
	
	-- Обновляем виджеты только если открыта страница game_progress
	local current_key = tactical_overlay._right_panel_key
	if current_key ~= page_key then
		return
	end
	
	local pt = mod:persistent_table("PlayerProgression")
	local current_hash = get_selected_items_hash(pt)
	
	-- Сохраняем хеш в tactical_overlay для отслеживания изменений
	if not tactical_overlay._game_progress_items_hash then
		tactical_overlay._game_progress_items_hash = current_hash
		setup_game_progress(tactical_overlay, ui_renderer)
		return
	end
	
	-- Если хеш изменился, пересоздаем виджеты
	if tactical_overlay._game_progress_items_hash ~= current_hash then
		tactical_overlay._game_progress_items_hash = current_hash
		setup_game_progress(tactical_overlay, ui_renderer)
	end
end

mod:hook("HudElementTacticalOverlay", "init", function(func, self, parent, draw_layer, start_scale, optional_context)
	local result = func(self, parent, draw_layer, start_scale, optional_context)
	
	if not ElementSettings or not ElementSettings.right_panel_grids then
		return result
	end
	
	local game_progress_data = {
		index = 4,
		loc_key = "tactical_overlay_player_progression",
		icon = {
			blueprint_type = "texture_icon",
			value = "content/ui/materials/hud/interactions/icons/havoc",
		},
	}
	
	local original = ElementSettings.right_panel_grids["game_progress"]
	if original then
		self:_override_right_panel_category("game_progress", game_progress_data, nil)
	else
		if not self._grid_overrides then
			self._grid_overrides = {}
		end
		self._grid_overrides["game_progress"] = game_progress_data
	end
	
	if not ElementSettings.right_panel_order[4] then
		ElementSettings.right_panel_order[4] = "game_progress"
	end
	
	return result
end)

mod:hook("HudElementTacticalOverlay", "_setup_right_panel_widgets", function(func, self)
	func(self)
	
	if not ElementSettings.right_panel_order[4] then
		ElementSettings.right_panel_order[4] = "game_progress"
	end
end)

mod:hook("HudElementTacticalOverlay", "_get_page", function(func, self, page_key)
	local result = func(self, page_key)
	
	if page_key == "game_progress" then
		if not result then
			-- Если настройки не найдены, создаем их
			result = {
				index = 4,
				loc_key = "tactical_overlay_player_progression",
				icon = {
					blueprint_type = "texture_icon",
					value = "content/ui/materials/hud/interactions/icons/havoc",
				},
			}
			
			-- Сохраняем в grid_overrides для последующих вызовов
			if not self._grid_overrides then
				self._grid_overrides = {}
			end
			self._grid_overrides["game_progress"] = result
		else
			-- Обновляем локализованный заголовок
			local localized_title = mod:localize("tactical_overlay_player_progression")
			result.loc_key = localized_title
		end
	end
	
	return result
end)

mod:hook("HudElementTacticalOverlay", "_update_right_tab_bar", function(func, self, ui_renderer)
	if not ElementSettings.right_panel_order[4] then
		ElementSettings.right_panel_order[4] = "game_progress"
	end
	
	func(self, ui_renderer)
	
	local current_key = self._right_panel_key
	if current_key == "game_progress" then
		local title_widget = self._widgets_by_name.right_header_title
		if title_widget then
			title_widget.content.text = Utf8.upper(mod:localize("tactical_overlay_player_progression"))
		end
	end
end)

mod:hook("HudElementTacticalOverlay", "update", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local result = func(self, dt, t, ui_renderer, render_settings, input_service)
	
	if ui_renderer and self._right_panel_entries then
		update_game_progress(self, dt, ui_renderer)
	end
	
	return result
end)

-- Переменная для отслеживания предыдущего состояния кнопки контроллера
mod._controller_button_was_held = false

-- Функция проверки нажатия кнопки контроллера (из MourningstarCommandWheel)
mod._is_controller_button_held = function(self)
	if not InputDevice.gamepad_active then
		return false
	end
	
	local last_device = InputDevice.last_pressed_device
	if not last_device then
		return false
	end
	
	local device_type = last_device:type()
	local controller_key = nil
	
	if device_type == "xbox_controller" then
		local selected_button = mod:get("xbox_controller_button")
		if selected_button == "default" or not selected_button then
			controller_key = "xbox_controller_right_shoulder"
		else
			controller_key = selected_button
		end
	elseif device_type == "ps4_controller" then
		local selected_button = mod:get("playstation_controller_button")
		if selected_button == "default" or not selected_button then
			controller_key = "ps4_controller_r1"
		else
			controller_key = selected_button
		end
	else
		return false
	end
	
	local SUPPORTED_CONTROLLER_DEVICES = {"xbox_controller", "ps4_controller"}
	local device_info = find_device_for_key(controller_key, SUPPORTED_CONTROLLER_DEVICES)
	
	if device_info and device_info.device and device_info.index then
		return device_info.device:held(device_info.index)
	end
	
	return false
end

-- Хук для проверки нажатия кнопки контроллера и открытия окна
mod:hook("UIHud", "update", function(func, self, dt, t, input_service)
	local result = func(self, dt, t, input_service)
	
	-- Проверяем удержание кнопки контроллера
	local controller_held = mod:_is_controller_button_held()
	
	-- Вызываем toggle_stats_display только при переходе из false в true (однократное нажатие)
	if controller_held and not mod._controller_button_was_held then
		mod.toggle_stats_display()
	end
	
	-- Обновляем состояние для следующего кадра
	mod._controller_button_was_held = controller_held
	
	return result
end)

function mod.on_setting_changed(setting_id)
	if setting_id == "reset_selected_items" then
		if mod:get("reset_selected_items") == 1 then
			mod:notify("Selected items cleared")
			mod:set("reset_selected_items", 0)
			
			-- Очищаем выбранные элементы
			mod:set("playerprogression_selected_items", {})
			mod:set("playerprogression_selected_items_order", {})
			mod:set("playerprogression_checkbox_states", {})
			
			-- Принудительно сохраняем в файл
			local dmf = get_mod("DMF")
			if dmf and dmf.save_unsaved_settings_to_file then
				dmf.save_unsaved_settings_to_file()
			end
		end
	elseif setting_id == "playstation_controller_button" or setting_id == "xbox_controller_button" then
		-- Сбрасываем состояние кнопки при изменении настроек контроллера
		mod._controller_button_was_held = false
	end
end


