local mod = get_mod("CommunicationCommandWheel")

mod:add_require_path("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_settings")
mod:add_require_path("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_definitions")
mod:add_require_path("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_utils")
mod:add_require_path("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_buttons")
mod:add_require_path("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_pages")
mod:add_require_path("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/HudElementCommunicationCommandWheel")

local CommunicationCommandWheel_localization = mod:io_dofile("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_localization")

if CommunicationCommandWheel_localization and type(CommunicationCommandWheel_localization) == "table" then
	local global_strings = {}

	for key, value in pairs(CommunicationCommandWheel_localization) do
		if string.sub(key, 1, 4) == "loc_" then
			global_strings[key] = value
		end
	end

	if next(global_strings) then
		mod:add_global_localize_strings(global_strings)
	end
end

local Utils = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_utils")

local hud_elements = {
	{
		filename = "CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/HudElementCommunicationCommandWheel",
		class_name = "HudElementCommunicationCommandWheel",
		visibility_groups = {
			"alive",
			"dead",
		},
	},
}

mod._communication_wheel_element = nil

mod.get_communication_wheel_element = function(self)
	return mod._communication_wheel_element
end

mod._communication_wheel_eval_func = nil

mod._is_communication_wheel_key_pressed = function(self)
	if not mod._communication_wheel_eval_func then
		local keys = mod:get("open_communication_command_wheel_key")

		if not keys or #keys == 0 then
			return false
		end

		local dmf = get_mod("DMF")
		local keywatch_result = dmf.local_keys_to_keywatch_result(keys)

		if not keywatch_result or not keywatch_result.main then
			return false
		end

		local keybind_data = {
			main = keywatch_result.main,
			enablers = keywatch_result.enablers or {},
			disablers = keywatch_result.disablers or {},
			trigger = "held",
		}

		local main_key = keybind_data.main
		local SUPPORTED_DEVICES = {
			"keyboard",
			"mouse",
		}

		local device_info = Utils.find_device_for_key(main_key, SUPPORTED_DEVICES)

		if not device_info then
			return false
		end

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

		local function check_key_pressed()
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

		mod._communication_wheel_eval_func = check_key_pressed
	end

	if mod._communication_wheel_eval_func then
		return mod._communication_wheel_eval_func()
	end

	return false
end

mod.communication_command_wheel_held = function(self)
	mod._communication_wheel_eval_func = nil
end

mod.close_communication_command_wheel = function(self)
	mod._communication_wheel_eval_func = nil
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

mod:hook_safe("HudElementCommunicationCommandWheel", "init", function(self, parent, draw_layer, start_scale)
	mod._communication_wheel_element = self
end)

mod.on_setting_changed = function(setting_id)
	if setting_id == "open_communication_command_wheel_key" then
		mod._communication_wheel_eval_func = nil
	end
end
