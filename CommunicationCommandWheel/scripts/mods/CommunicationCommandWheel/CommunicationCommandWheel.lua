local mod = get_mod("CommunicationCommandWheel")

mod:hook_require("scripts/settings/ui/ui_hud_settings", function(UIHudSettings)
	local layers = UIHudSettings and UIHudSettings.element_draw_layers

	if layers then
		layers.HudElementCommunicationCommandWheel = layers.HudElementEmoteWheel or 451
	end
end)

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
		if string.sub(key, 1, 13) == "ccw_command_" then
			global_strings[key] = value
		end
	end

	if next(global_strings) then
		mod:add_global_localize_strings(global_strings)
	end
end

local Utils = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_utils")
local Pages = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_pages")
local Buttons = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_buttons")
local ActionUtility = require("scripts/extension_systems/weapon/actions/utilities/action_utility")

local function is_local_player_action(action_self)
	local local_player_unit = Utils.get_local_player_unit and Utils.get_local_player_unit()

	if not local_player_unit or not action_self or not action_self._player_unit then
		return false
	end

	return action_self._player_unit == local_player_unit
end

local function trigger_auto_deployed_message_and_ping(setting_id, message_key, position)
	local enabled = mod:get(setting_id)

	if enabled ~= true and enabled ~= 1 then
		return
	end

	Utils.send_mission_chat_message(message_key)
	Utils.trigger_location_ping_at_position(position)
end

local function get_auto_deploy_message_data(action_self)
	if not is_local_player_action(action_self) then
		return nil
	end

	local action_settings = action_self and action_self._action_settings
	local deployable_settings = action_settings and action_settings.deployable_settings

	if deployable_settings and deployable_settings.name == "medical_crate" then
		return "ccw_auto_chat_medical_crate_deployed", "ccw_auto_message_medical_crate_deployed_here"
	end

	local weapon_template = action_self and action_self._weapon_template
	local pickup_name = action_settings and action_settings.pickup_name or weapon_template and weapon_template.pickup_name

	if pickup_name == "ammo_cache_deployable" then
		return "ccw_auto_chat_ammo_crate_deployed", "ccw_auto_message_ammo_crate_deployed_here"
	end

	return nil
end

local function hook_auto_deploy_action(ActionClass)
	mod:hook_safe(ActionClass, "start", function(self, action_settings, t, time_scale, action_start_params)
		self._ccw_auto_deploy_message_sent = false
	end)

	mod:hook(ActionClass, "fixed_update", function(func, self, dt, t, time_in_action)
		local result = func(self, dt, t, time_in_action)

		if self._ccw_auto_deploy_message_sent then
			return result
		end

		local setting_id, message_key = get_auto_deploy_message_data(self)

		if not setting_id or not message_key then
			return result
		end

		local action_settings = self._action_settings
		local can_place, can_place_time_or_nil, position = self:_get_placement_data_from_component()

		if not can_place or not position then
			return result
		end

		local finish_time = action_settings and action_settings.total_time
		local place_time = action_settings and (action_settings.place_time or finish_time)
		local weapon_action_component = self._weapon_action_component
		local time_scale = weapon_action_component and weapon_action_component.time_scale or 1

		if not place_time or time_scale == 0 then
			return result
		end

		local time_able_to_place = can_place_time_or_nil and (t - can_place_time_or_nil) or time_in_action
		local is_in_placement_time = ActionUtility.is_within_trigger_time(time_able_to_place, dt, place_time / time_scale)

		if not is_in_placement_time then
			return result
		end

		local ammunition_usage = action_settings and action_settings.ammunition_usage

		if ammunition_usage and ammunition_usage > self:_current_ammo() then
			return result
		end

		self._ccw_auto_deploy_message_sent = true

		trigger_auto_deployed_message_and_ping(setting_id, message_key, position)

		return result
	end)
end

local PAGE3_LAYOUT_MIGRATION_VERSION = 6

local function migrate_page3_slots_from_defaults_once()
	if mod:get("_ccw_layout_migration_v") == PAGE3_LAYOUT_MIGRATION_VERSION then
		return
	end

	local by_id = Buttons.button_definitions_by_id
	local layout = Pages.DEFAULT_SLOT_LAYOUT
	local row = layout and layout[3]

	if type(row) ~= "table" or type(by_id) ~= "table" then
		mod:set("_ccw_layout_migration_v", PAGE3_LAYOUT_MIGRATION_VERSION)

		return
	end

	local configured_slots = Pages.CONFIGURED_SLOT_COUNT or 8
	local any_slot_written = false

	mod._ccw_suppress_wheel_refresh = true

	for slot_index = 1, configured_slots do
		local key = string.format("page_3_slot_%d", slot_index)
		local cur = mod:get(key)
		local cur_s = type(cur) == "string" and cur or ""
		local cur_valid = cur_s ~= "" and by_id[cur_s] ~= nil
		local want = row[slot_index]
		local want_s = type(want) == "string" and want or ""

		if not cur_valid and cur_s ~= want_s then
			mod:set(key, want_s)
			any_slot_written = true
		end
	end

	mod._ccw_suppress_wheel_refresh = false

	mod:set("_ccw_layout_migration_v", PAGE3_LAYOUT_MIGRATION_VERSION)

	local element = mod._communication_wheel_element

	if any_slot_written and element and element._refresh_wheel_layout_from_settings then
		element:_refresh_wheel_layout_from_settings()
	end
end

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
mod._ccw_suppress_wheel_refresh = false

mod.get_communication_wheel_element = function(self)
	return mod._communication_wheel_element
end

mod._communication_wheel_eval_func = nil
mod._switch_page_key_eval_func = nil

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

mod._is_switch_page_key_held = function(self)
	if not mod._switch_page_key_eval_func then
		local keys = mod:get("communication_command_wheel_switch_page_key")

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

		local function check_switch_page_key_held()
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

		mod._switch_page_key_eval_func = check_switch_page_key_held
	end

	if mod._switch_page_key_eval_func then
		return mod._switch_page_key_eval_func()
	end

	return false
end

mod.communication_command_wheel_held = function(self)
	mod._communication_wheel_eval_func = nil
end

mod.close_communication_command_wheel = function(self)
	mod._communication_wheel_eval_func = nil
end

mod.communication_command_wheel_switch_page_held = function(self)
	mod._switch_page_key_eval_func = nil
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
	local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
	local layers = UIHudSettings and UIHudSettings.element_draw_layers

	if layers then
		self._draw_layer = layers.HudElementCommunicationCommandWheel or layers.HudElementEmoteWheel or 451
	end

	mod._communication_wheel_element = self
end)

mod:hook_require("scripts/extension_systems/weapon/actions/action_place_pickup", function(ActionPlacePickup)
	hook_auto_deploy_action(ActionPlacePickup)
end)

mod:hook_require("scripts/extension_systems/weapon/actions/action_place_deployable", function(ActionPlaceDeployable)
	hook_auto_deploy_action(ActionPlaceDeployable)
end)

mod.on_setting_changed = function(setting_id)
	if setting_id == "open_communication_command_wheel_key" then
		mod._communication_wheel_eval_func = nil
	elseif setting_id == "communication_command_wheel_switch_page_key" then
		mod._switch_page_key_eval_func = nil
	elseif setting_id == "ccw_scroll_switch_page" then
		local element = mod._communication_wheel_element

		if element and element._ccw_sync_wield_scroll_input_capture then
			element:_ccw_sync_wield_scroll_input_capture()
		end
	elseif setting_id == "reset_slot_commands" then
		if mod:get("reset_slot_commands") == 1 then
			mod:notify(mod:localize("ccw_reset_slot_commands"))
			mod:set("reset_slot_commands", 0)

			local layout = Pages.DEFAULT_SLOT_LAYOUT
			local max_pages = Pages.MAX_PAGES or 3
			local configured_slots = Pages.CONFIGURED_SLOT_COUNT or 8

			mod._ccw_suppress_wheel_refresh = true

			if type(layout) == "table" then
				for page_index = 1, max_pages do
					local row = layout[page_index]

					if type(row) == "table" then
						for slot_index = 1, configured_slots do
							local value = row[slot_index]
							local stored = type(value) == "string" and value or ""

							mod:set(string.format("page_%d_slot_%d", page_index, slot_index), stored)
						end
					end
				end
			end

			mod._ccw_suppress_wheel_refresh = false

			local element = mod._communication_wheel_element

			if element and element._refresh_wheel_layout_from_settings then
				element:_refresh_wheel_layout_from_settings()
			end
		end
	elseif string.match(setting_id, "^page_%d+_slot_%d+$") then
		if mod._ccw_suppress_wheel_refresh then
			return
		end

		local element = mod._communication_wheel_element

		if element and element._refresh_wheel_layout_from_settings then
			element:_refresh_wheel_layout_from_settings()
		end
	end
end

migrate_page3_slots_from_defaults_once()
