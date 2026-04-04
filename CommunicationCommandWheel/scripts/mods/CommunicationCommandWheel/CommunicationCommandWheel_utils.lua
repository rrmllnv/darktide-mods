local mod = get_mod("CommunicationCommandWheel")

local function localize_text(label_key)
	if not label_key then
		return ""
	end

	local success, result = pcall(function()
		return mod:localize(label_key)
	end)

	if success and result and result ~= "" and result ~= label_key then
		return result
	end

	if string.sub(label_key, 1, 13) == "ccw_command_" then
		local success_global, global_result = pcall(function()
			return Localize(label_key)
		end)

		if success_global and global_result and global_result ~= "" and global_result ~= label_key then
			return global_result
		end
	end

	return label_key
end

local function get_local_player_unit()
	if not Managers or not Managers.player then
		return nil
	end

	local local_player = Managers.player:local_player_safe(1)

	if not local_player or not local_player:unit_is_alive() or not local_player.player_unit then
		return nil
	end

	local player_unit = local_player.player_unit

	if not Unit.alive(player_unit) then
		return nil
	end

	return player_unit
end

local function send_mission_chat_message(text_key)
	if not text_key or not Managers or not Managers.chat then
		return false
	end

	local chat_manager = Managers.chat
	local ChannelTags = require("scripts/foundation/managers/chat/chat_manager_constants").ChannelTag
	local channels = chat_manager:connected_chat_channels()
	local channel_handle = nil

	if channels then
		for handle, channel in pairs(channels) do
			if channel.tag == ChannelTags.MISSION then
				channel_handle = handle

				break
			end
		end
	end

	if not channel_handle then
		local sessions = chat_manager:sessions()

		if sessions then
			channel_handle = next(sessions)
		end
	end

	if not channel_handle then
		return false
	end

	local english_text = text_key
	local localization_table = mod._localization_cache

	if not localization_table then
		localization_table = mod:io_dofile("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_localization")
		mod._localization_cache = localization_table
	end

	if localization_table and localization_table[text_key] and localization_table[text_key].en then
		english_text = localization_table[text_key].en
	end

	local formatted_message = string.format("{#color(79,175,255)} %s {#reset()}", english_text)

	if chat_manager.send_channel_message then
		chat_manager:send_channel_message(channel_handle, formatted_message)

		return true
	end

	return false
end

local function trigger_location_ping_at_position(position, player_unit)
	if not position or not Managers or not Managers.state or not Managers.state.extension then
		return false
	end

	local tagger_unit = player_unit or get_local_player_unit()

	if not tagger_unit then
		return false
	end

	local smart_tag_system = Managers.state.extension:system("smart_tag_system")

	if not smart_tag_system then
		return false
	end

	smart_tag_system:set_tag("location_ping", tagger_unit, nil, position)

	return true
end

local function trigger_smart_tag_option(option)
	if not option or not option.smart_tag_type then
		return
	end

	if not Managers or not Managers.player or not Managers.state or not Managers.state.extension then
		return
	end

	local player_unit = get_local_player_unit()

	if not player_unit then
		return
	end

	local smart_tag_system = Managers.state.extension:system("smart_tag_system")

	if not smart_tag_system then
		return
	end

	local function try_set_contextual_tag(target_unit_to_tag)
		if not target_unit_to_tag then
			return false
		end

		local target_extension = smart_tag_system._unit_extension_data and smart_tag_system._unit_extension_data[target_unit_to_tag]
		local template = target_extension and target_extension.contextual_tag_template and target_extension:contextual_tag_template(player_unit)

		if not template then
			return false
		end

		smart_tag_system:set_contextual_unit_tag(player_unit, target_unit_to_tag)

		return true
	end

	local target_unit
	local target_position
	local ScriptUnit = ScriptUnit or require("scripts/extension_systems/core/script_unit")
	local interactor_extension = ScriptUnit and ScriptUnit.has_extension and ScriptUnit.has_extension(player_unit, "interactor_system")
	local interactor_target_unit = interactor_extension and interactor_extension:target_unit()
	local interactor_smart_tag_extension = interactor_target_unit and ScriptUnit.has_extension(interactor_target_unit, "smart_tag_system")

	if interactor_smart_tag_extension then
		target_unit = interactor_target_unit
	end

	if not target_unit then
		local ui_manager = Managers.ui
		local hud = ui_manager and ui_manager._hud
		local smart_tag_element = hud and hud.element and hud:element("HudElementSmartTagging")

		if smart_tag_element and not smart_tag_element.destroyed and smart_tag_element._find_best_smart_tag_interaction then
			local ui_renderer = hud.ui_renderer and hud:ui_renderer() or hud._ui_renderer
			local render_settings = hud._render_settings
			local force_update_targets = true
			local _, best_unit, best_position = smart_tag_element:_find_best_smart_tag_interaction(ui_renderer, render_settings, force_update_targets)

			target_unit = best_unit
			target_position = best_position
		end
	end

	if target_unit and option.prefer_contextual_unit_tag and try_set_contextual_tag(target_unit) then
		return
	end

	if target_position then
		smart_tag_system:set_tag(option.smart_tag_type, player_unit, nil, target_position)
	end
end

local function activate_option(option)
	if not option then
		return false
	end

	local success, err = pcall(function()
		if not Managers or not Managers.player then
			return
		end

		if Managers.state and Managers.state.game_mode then
			local game_mode_name = Managers.state.game_mode:game_mode_name()

			if not game_mode_name or game_mode_name == "menu" then
				return
			end
		end

		if option.voice_event_data then
			local Vo = require("scripts/utilities/vo")
			local voice_tag_concept = option.voice_event_data.voice_tag_concept
			local voice_tag_id = option.voice_event_data.voice_tag_id
			local local_player = Managers.player:local_player_safe(1)

			if not local_player then
				return
			end

			if not local_player:unit_is_alive() or not local_player.player_unit then
				return
			end

			local player_unit = local_player.player_unit

			if not Unit.alive(player_unit) then
				return
			end

			local ScriptUnit = ScriptUnit or require("scripts/extension_systems/core/script_unit")

			if not ScriptUnit or not ScriptUnit.has_extension then
				return
			end

			local dialogue_extension = ScriptUnit.has_extension(player_unit, "dialogue_system")

			if not dialogue_extension then
				return
			end

			if Vo and Vo.on_demand_vo_event then
				Vo.on_demand_vo_event(player_unit, voice_tag_concept, voice_tag_id)
			end
		end

		trigger_smart_tag_option(option)

		if option.chat_message_data and option.chat_message_data.text then
			send_mission_chat_message(option.chat_message_data.text)
		end
	end)

	if not success then
		mod:error("Failed to activate option '%s': %s", tostring(option.id), tostring(err))

		return false
	end

	return true
end

local function find_device_for_key(key, supported_devices)
	if not key or not supported_devices then
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

local function apply_style_offset(style, offset_x, offset_y)
	if style then
		style.offset[1] = offset_x
		style.offset[2] = offset_y
	end
end

local function apply_style_color(style, color)
	if style and color then
		style.color[1] = color[1]
		style.color[2] = color[2]
		style.color[3] = color[3]
		style.color[4] = color[4]
	end
end

return {
	localize_text = localize_text,
	activate_option = activate_option,
	get_local_player_unit = get_local_player_unit,
	send_mission_chat_message = send_mission_chat_message,
	trigger_location_ping_at_position = trigger_location_ping_at_position,
	find_device_for_key = find_device_for_key,
	apply_style_offset = apply_style_offset,
	apply_style_color = apply_style_color,
}
