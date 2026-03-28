local mod = get_mod("EquipmentCommandWheel")

mod:add_require_path("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_settings")
mod:add_require_path("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_definitions")
mod:add_require_path("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_utils")
mod:add_require_path("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/HudElementEquipmentWheel")

local Utils = require("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_utils")

local hud_elements = {
	{
		filename = "EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/HudElementEquipmentWheel",
		class_name = "HudElementEquipmentWheel",
		visibility_groups = {
			"alive",
			"communication_wheel",
			"tactical_overlay",
			"player_in_danger_zone",
		},
	},
}

mod._equipment_wheel_element = nil

mod.get_equipment_wheel_element = function(self)
	return mod._equipment_wheel_element
end

mod._equipment_wheel_eval_func = nil

mod._is_equipment_wheel_key_pressed = function(self)
	if not Utils.is_equipment_wheel_game_mode_allowed() then
		return false
	end

	if not mod._equipment_wheel_eval_func then
		local keys = mod:get("open_equipment_wheel_key")
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
					trigger = "held",
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

		mod._equipment_wheel_eval_func = function()
			if keyboard_check_func and keyboard_check_func() then
				return true
			end

			return false
		end
	end

	if mod._equipment_wheel_eval_func then
		return mod._equipment_wheel_eval_func()
	end

	return false
end

mod.equipment_wheel_held = function(self)
	mod._equipment_wheel_eval_func = nil
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

mod:hook_safe("HudElementEquipmentWheel", "init", function(self, parent, draw_layer, start_scale)
	mod._equipment_wheel_element = self
end)

mod.on_setting_changed = function(setting_id)
	if setting_id == "open_equipment_wheel_key" then
		mod._equipment_wheel_eval_func = nil
	end
end
