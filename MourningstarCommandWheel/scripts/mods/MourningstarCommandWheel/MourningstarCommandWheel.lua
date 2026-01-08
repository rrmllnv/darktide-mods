local mod = get_mod("MourningstarCommandWheel")

mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_settings")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_definitions")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_utils")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_buttons")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_hotkeys")
mod:add_require_path("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/HudElementCommandWheel")

local Utils = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_utils")
local InputDevice = require("scripts/managers/input/input_device")
local is_in_valid_lvl = Utils.is_in_valid_lvl
local is_in_psykhanium = Utils.is_in_psykhanium

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

local can_activate_view = function(ui_manager, view)
	if not ui_manager or not view then
		return false
	end
	
	local success, Views = pcall(require, "scripts/ui/views/views")
	if not success or not Views or not Views[view] then
		return false
	end
	
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

mod.open_view_safe = function(self, view)
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

		local success, result = pcall(function()
			return ui_manager:open_view(view, nil, nil, nil, nil, context)
		end)
		
		if not success then
			-- mod:error("Failed to open view '%s': %s", view, tostring(result))
			return false
		end
		
		return result
	end
	
	return false
end

mod.toggle_view_safe = function(self, view)
	if not view then
		return false
	end
	
	local ui_manager = Managers.ui
	if not ui_manager then
		return false
	end

	if is_in_psykhanium() then
		if not mod:get("enable_in_psykhanium") then
			return false
		end
	end

	local is_view_active = false
	local success, result = pcall(function()
		return ui_manager:view_active(view)
	end)
	if success and result then
		is_view_active = true
	end

	if is_view_active then
		local enable_toggle = mod:get("enable_toggle_view")
		if enable_toggle then
			local close_success = pcall(function()
				ui_manager:close_view(view)
			end)
			
			if close_success then
				return true
			end
		end
		return false
	end
	
	return mod:open_view_safe(view)
end

mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_hotkeys")

mod.change_character = function(self)
	if not is_in_valid_lvl() then
		return false
	end
	
	local success, err = pcall(function()
		if Managers.multiplayer_session and Managers.multiplayer_session.leave then
			Managers.multiplayer_session:leave("exit_to_main_menu")
		else
			-- mod:error("multiplayer_session not available for character change")
			return false
		end
	end)
	
	if not success then
		-- mod:error("Failed to change character: %s", tostring(err))
		return false
	end
	
	return true
end

mod._command_wheel_element = nil

mod.get_command_wheel_element = function(self)
	return mod._command_wheel_element
end

mod._command_wheel_eval_func = nil

mod._is_command_wheel_key_pressed = function(self)
	local function check_controller_button()
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
			controller_key = "xbox_controller_left_trigger"
		elseif device_type == "ps4_controller" then
			controller_key = "ps4_controller_r1"
		else
			return false
		end
		
		local SUPPORTED_CONTROLLER_DEVICES = {"xbox_controller", "ps4_controller"}
		local device_info = Utils.find_device_for_key(controller_key, SUPPORTED_CONTROLLER_DEVICES)
		
		if device_info and device_info.device and device_info.index then
			return device_info.device:held(device_info.index)
		end
		
		return false
	end
	
	if not mod._command_wheel_eval_func then
		local keys = mod:get("open_command_wheel_key")
		local has_keyboard_binding = keys and #keys > 0
		
		local keyboard_check_func = nil
		if has_keyboard_binding then
			local dmf = get_mod("DMF")
			local keywatch_result = dmf.local_keys_to_keywatch_result(keys)
			if keywatch_result and keywatch_result.main then
				local keybind_data = {
					main = keywatch_result.main,
					enablers = keywatch_result.enablers or {},
					disablers = keywatch_result.disablers or {},
					trigger = "held"
				}
				
				local main_key = keybind_data.main
				local SUPPORTED_DEVICES = {"keyboard", "mouse"}
				
				local device_info = Utils.find_device_for_key(main_key, SUPPORTED_DEVICES)
				if device_info then
					local key_info = {
						main_device = device_info.device,
						main_index = device_info.index,
						enablers = {},
						disablers = {},
					}
					
					if #keybind_data.enablers > 0 then
						for _, enabler_key in ipairs(keybind_data.enablers) do
							local device_info_enabler = Utils.find_device_for_key(enabler_key, SUPPORTED_DEVICES)
							if device_info_enabler then
								table.insert(key_info.enablers, device_info_enabler)
							end
						end
					end
					
					if keybind_data.disablers and #keybind_data.disablers > 0 then
						for _, disabler_key in ipairs(keybind_data.disablers) do
							local device_info_disabler = Utils.find_device_for_key(disabler_key, SUPPORTED_DEVICES)
							if device_info_disabler then
								table.insert(key_info.disablers, device_info_disabler)
							end
						end
					end
					
					keyboard_check_func = function()
						for _, enabler in ipairs(key_info.enablers) do
							if not enabler.device:held(enabler.index) then
								return false
							end
						end
						
						for _, disabler in ipairs(key_info.disablers) do
							if disabler.device:held(disabler.index) then
								return false
							end
						end
						
						return key_info.main_device:held(key_info.main_index)
					end
				end
			end
		end
		
		local function check_key_pressed()
			if keyboard_check_func and keyboard_check_func() then
				return true
			end
			
			if check_controller_button() then
				return true
			end
			
			return false
		end
		
		mod._command_wheel_eval_func = check_key_pressed
	end
	
	if mod._command_wheel_eval_func then
		return mod._command_wheel_eval_func()
	end
	
	return false
end

mod.command_wheel_held = function(self)
	mod._command_wheel_eval_func = nil
end

mod.close_command_wheel = function(self)
	mod._command_wheel_eval_func = nil
end

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

mod.on_setting_changed = function(setting_id)
	if setting_id == "open_command_wheel_key" then
		mod._command_wheel_eval_func = nil
	end
end