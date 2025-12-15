local mod = get_mod("MourningstarCommandWheel")

local CLASS = CLASS

-- Добавляем пути для require
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_settings")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/command_wheel_definitions")

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
	return is_in_valid_lvl() and (not ui_manager:chat_using_input()) and (not ui_manager:has_active_view(view))
end

mod.activate_hub_view = function(self, view)
	local ui_manager = Managers.ui

	if ui_manager and can_activate_view(ui_manager, view) then
		local context = {
			hub_interaction = true
		}

		ui_manager:open_view(view, nil, nil, nil, nil, context)
	end
end

mod._command_wheel_element = nil

mod.get_command_wheel_element = function(self)
	return mod._command_wheel_element
end

mod._command_wheel_input_pressed = false

mod.command_wheel_pressed = function(self)
	if not is_in_valid_lvl() then
		return
	end
	
	-- Устанавливаем флаг нажатия клавиши
	mod._command_wheel_input_pressed = true
end

mod.command_wheel_released = function(self)
	-- Сбрасываем флаг при отпускании
	mod._command_wheel_input_pressed = false
end

mod.close_command_wheel = function(self)
	mod._command_wheel_input_pressed = false
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

-- ##########################################################
-- ################### Script ###############################
