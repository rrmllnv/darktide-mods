local mod = get_mod("MourningstarCommandWheel")

local CLASS = CLASS
local InputUtils = require("scripts/managers/input/input_utils")

-- Добавляем пути для require
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_definitions")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/HudElementCommandWheel")

-- Загружаем settings, чтобы settings() зарегистрировал глобальный объект
mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")

-- ##########################################################
-- ################## Variables #############################

local valid_lvls = {
	shooting_range = true,
	hub = true,
}

local hud_elements = {
	{
		filename = "MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/HudElementCommandWheel",
		class_name = "HudElementCommandWheel",
		visibility_groups = {
			"alive",
			"dead",
		},
	},
}

-- ##########################################################
-- ############## Internal Functions ########################

local is_in_valid_lvl = function()
	if Managers and Managers.state and Managers.state.game_mode then
		return valid_lvls[Managers.state.game_mode:game_mode_name()] or false
	end
	return false
end

local can_activate_view = function(ui_manager, view)
	if not ui_manager or not view then
		return false
	end
	
	-- Проверяем, что view существует
	local success, Views = pcall(require, "scripts/ui/views/views")
	if not success or not Views or not Views[view] then
		return false
	end
	
	-- Проверяем, что view доступен
	if ui_manager.view_is_available then
		local success, is_available = pcall(function()
			return ui_manager:view_is_available(view)
		end)
		if not success or not is_available then
			return false
		end
	end
	
	return is_in_valid_lvl() and (not ui_manager:chat_using_input()) and (not ui_manager:has_active_view(view))
end

mod.activate_hub_view = function(self, view)
	if not view then
		return false
	end
	
	local ui_manager = Managers.ui
	if not ui_manager then
		return false
	end

	if can_activate_view(ui_manager, view) then
		local context = {
			hub_interaction = true
		}

		-- Обертываем в pcall для безопасности
		local success, result = pcall(function()
			return ui_manager:open_view(view, nil, nil, nil, nil, context)
		end)
		
		if not success then
			-- Логируем ошибку, но не крашим игру
			mod:error("Failed to open view '%s': %s", view, tostring(result))
			return false
		end
		
		return result
	end
	
	return false
end

mod._command_wheel_element = nil

mod.get_command_wheel_element = function(self)
	return mod._command_wheel_element
end

mod._command_wheel_eval_func = nil

-- Функция для проверки, нажата ли клавиша keybind
mod._is_command_wheel_key_pressed = function(self)
	if not mod._command_wheel_eval_func then
		-- Получаем ключи из настроек keybind
		local keys = mod:get("open_command_wheel_key")
		if not keys or #keys == 0 then
			return false
		end
		
		-- Конвертируем local keys в keywatch result
		local dmf = get_mod("DMF")
		local keywatch_result = dmf.local_keys_to_keywatch_result(keys)
		if not keywatch_result or not keywatch_result.main then
			return false
		end
		
		-- Создаем eval_func как в DMF
		-- Используем внутреннюю логику DMF для проверки клавиши
		local keybind_data = {
			main = keywatch_result.main,
			enablers = keywatch_result.enablers or {},
			disablers = keywatch_result.disablers or {},
			trigger = "held"
		}
		
		-- Получаем device и index для основной клавиши
		local main_key = keybind_data.main
		local device_info = nil
		
		-- Ищем device для основной клавиши
		local SUPPORTED_DEVICES = {"keyboard", "mouse"}
		for _, device_type in ipairs(SUPPORTED_DEVICES) do
			local device = Managers.input:_find_active_device(device_type)
			if device then
				local index = device:button_index(main_key)
				if index then
					device_info = {
						device = device,
						index = index,
						key_id = main_key,
					}
					break
				end
			end
		end
		
		if not device_info then
			return false
		end
		
		-- Сохраняем информацию о клавишах для проверки
		local key_info = {
			main_device = device_info.device,
			main_index = device_info.index,
			enablers = {},
			disablers = {},
		}
		
		-- Добавляем проверку enablers
		if #keybind_data.enablers > 0 then
			for _, enabler_key in ipairs(keybind_data.enablers) do
				for _, device_type in ipairs(SUPPORTED_DEVICES) do
					local device = Managers.input:_find_active_device(device_type)
					if device then
						local index = device:button_index(enabler_key)
						if index then
							table.insert(key_info.enablers, {
								device = device,
								index = index,
							})
							break
						end
					end
				end
			end
		end
		
		-- Добавляем проверку disablers
		if keybind_data.disablers and #keybind_data.disablers > 0 then
			for _, disabler_key in ipairs(keybind_data.disablers) do
				for _, device_type in ipairs(SUPPORTED_DEVICES) do
					local device = Managers.input:_find_active_device(device_type)
					if device then
						local index = device:button_index(disabler_key)
						if index then
							table.insert(key_info.disablers, {
								device = device,
								index = index,
							})
							break
						end
					end
				end
			end
		end
		
		-- Создаем функцию для проверки
		local function check_key_pressed()
			-- Проверяем enablers
			for _, enabler in ipairs(key_info.enablers) do
				if not enabler.device:held(enabler.index) then
					return false
				end
			end
			
			-- Проверяем disablers
			for _, disabler in ipairs(key_info.disablers) do
				if disabler.device:held(disabler.index) then
					return false
				end
			end
			
			-- Проверяем основную клавишу
			return key_info.main_device:held(key_info.main_index)
		end
		
		mod._command_wheel_eval_func = check_key_pressed
	end
	
	-- Вызываем eval_func для проверки состояния клавиши
	if mod._command_wheel_eval_func then
		return mod._command_wheel_eval_func()
	end
	
	return false
end

mod.command_wheel_held = function(self)
	-- Эта функция вызывается при нажатии клавиши
	-- Сбрасываем кэш eval_func, чтобы перепроверить настройки при изменении
	mod._command_wheel_eval_func = nil
end

mod.close_command_wheel = function(self)
	mod._command_wheel_eval_func = nil
end

-- ##########################################################
-- ################### Hooks ################################

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	for _, hud_element in ipairs(hud_elements) do
		if not table.find_by_key(elements, "class_name", hud_element.class_name) then
			table.insert(elements, {
				class_name = hud_element.class_name,
				filename = hud_element.filename,
				visibility_groups = hud_element.visibility_groups,
			})
		end
	end
	
	return func(self, elements, visibility_groups, params)
end)

mod:hook_safe("HudElementCommandWheel", "init", function(self, parent, draw_layer, start_scale)
	mod._command_wheel_element = self
end)

-- Сбрасываем кэш при изменении настроек keybind
mod.on_setting_changed = function(setting_id)
	if setting_id == "open_command_wheel_key" then
		mod._command_wheel_eval_func = nil
	end
end

-- ##########################################################
-- ################### Script ###############################
