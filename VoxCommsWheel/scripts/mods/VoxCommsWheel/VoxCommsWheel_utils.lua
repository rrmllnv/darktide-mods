local mod = get_mod("VoxCommsWheel")

local function localize_text(label_key)
	if not label_key then
		return ""
	end
	
	if string.sub(label_key, 1, 4) == "loc_" then
		return Localize(label_key)
	else
		return mod:localize(label_key)
	end
end

local function activate_option(option)
	if not option then
		return false
	end

	local success, err = pcall(function()
		-- Проверяем, что Managers доступны
		if not Managers or not Managers.player then
			return
		end
		
		-- Проверяем, что мы в валидном игровом режиме
		if Managers.state and Managers.state.game_mode then
			local game_mode_name = Managers.state.game_mode:game_mode_name()
			-- Не вызываем VO в меню или других неподходящих режимах
			if not game_mode_name or game_mode_name == "menu" then
				return
			end
		end
		
		-- Воспроизведение голосовой реплики
		if option.voice_event_data then
			
			local Vo = require("scripts/utilities/vo")
			local voice_tag_concept = option.voice_event_data.voice_tag_concept
			local voice_tag_id = option.voice_event_data.voice_tag_id
			
			-- Получаем local player unit с проверками
			local local_player = Managers.player:local_player_safe(1)
			if not local_player then
				return
			end
			
			-- Проверяем, что игрок жив и имеет unit
			if not local_player:unit_is_alive() or not local_player.player_unit then
				return
			end
			
			local player_unit = local_player.player_unit
			
			-- Дополнительная проверка через Unit.alive
			if not Unit.alive(player_unit) then
				return
			end
			
			-- Проверяем наличие dialogue_system extension
			local ScriptUnit = ScriptUnit or require("scripts/extension_systems/core/script_unit")
			if not ScriptUnit or not ScriptUnit.has_extension then
				return
			end
			
			local dialogue_extension = ScriptUnit.has_extension(player_unit, "dialogue_system")
			if not dialogue_extension then
				return
			end
			
			-- Вызываем VO только если все проверки пройдены
			if Vo and Vo.on_demand_vo_event then
				Vo.on_demand_vo_event(player_unit, voice_tag_concept, voice_tag_id)
			end
		end
		
		-- Отправка сообщения в чат
		if option.chat_message_data then
			local Managers = Managers
			if Managers and Managers.chat then
				local chat_manager = Managers.chat
				local text = localize_text(option.chat_message_data.text)
				local channel = option.chat_message_data.channel
				
				if channel then
					if chat_manager.send_loc_channel_message then
						chat_manager:send_loc_channel_message(channel, option.chat_message_data.text)
					elseif chat_manager.send_channel_message then
						chat_manager:send_channel_message(channel, text)
					end
				end
			end
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
	find_device_for_key = find_device_for_key,
	apply_style_offset = apply_style_offset,
	apply_style_color = apply_style_color,
}

