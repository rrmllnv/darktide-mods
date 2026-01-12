local mod = get_mod("PlayerProgression")

local InputDevice = require("scripts/managers/input/input_device")

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
local tactical_overlay = mod:io_dofile("PlayerProgression/scripts/mods/PlayerProgression/hud/tactical_overlay")

local VIEW_NAME = "player_progress_stats_view"

mod.version = "2.0.0"

init.setup(mod, VIEW_NAME, view_templates, views, utilities)
commands.setup(mod)
tactical_overlay.setup()

local function get_selected_data()
	local selected_items = mod:get("playerprogression_selected_items") or {}
	local selected_items_order = mod:get("playerprogression_selected_items_order") or {}
	return selected_items, selected_items_order
end

local function save_selected_data(selected_items, selected_items_order)
	mod:set("playerprogression_selected_items", selected_items)
	mod:set("playerprogression_selected_items_order", selected_items_order)
	
	local dmf = get_mod("DMF")
	if dmf and dmf.save_unsaved_settings_to_file then
		dmf.save_unsaved_settings_to_file()
	end
end

mod._controller_button_was_held = false

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

mod:hook("UIHud", "update", function(func, self, dt, t, input_service)
	local result = func(self, dt, t, input_service)
	
	local controller_held = mod:_is_controller_button_held()
	
	if controller_held and not mod._controller_button_was_held then
		mod.toggle_stats_display()
	end
	
	mod._controller_button_was_held = controller_held
	
	return result
end)

function mod.on_setting_changed(setting_id)
	if setting_id == "reset_selected_items" then
		if mod:get("reset_selected_items") == 1 then
			mod:notify("Selected items cleared")
			mod:set("reset_selected_items", 0)
			
			mod:set("playerprogression_selected_items", {})
			mod:set("playerprogression_selected_items_order", {})
			mod:set("playerprogression_checkbox_states", {})
			
			local dmf = get_mod("DMF")
			if dmf and dmf.save_unsaved_settings_to_file then
				dmf.save_unsaved_settings_to_file()
			end
		end
	elseif setting_id == "playstation_controller_button" or setting_id == "xbox_controller_button" then
		mod._controller_button_was_held = false
	end
end


