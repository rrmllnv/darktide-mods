local mod = get_mod("VoxCommsWheel")

local function localize_text(label_key)
	if not label_key then
		return ""
	end
	
	-- Сначала пробуем локализацию мода (mod:localize работает для всех ключей из файла локализации)
	local success, mod_result = pcall(function()
		return mod:localize(label_key)
	end)
	
	if success and mod_result and mod_result ~= "" and mod_result ~= label_key then
		return mod_result
	end
	
	-- Для ключей с префиксом loc_ пробуем глобальную локализацию как fallback
	if string.sub(label_key, 1, 4) == "loc_" then
		local success, result = pcall(function()
			return Localize(label_key)
		end)
		
		if success and result and result ~= "" and result ~= label_key then
			return result
		end
	end
	
	-- Если ничего не найдено, возвращаем ключ
	return label_key
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
		
		-- Отправка сообщения в чат (только на английском)
		if option.chat_message_data then
			if not Managers or not Managers.chat then
				return
			end
			
			local chat_manager = Managers.chat
			local channel_tag = option.chat_message_data.channel
			
			if not channel_tag then
				return
			end
			
			-- Получаем channel_handle по channel_tag (как в HudElementSmartTagging)
			local channels = chat_manager:connected_chat_channels()
			local channel_handle = nil
			
			if channels then
				for handle, channel in pairs(channels) do
					if channel.tag == channel_tag then
						channel_handle = handle
						break
					end
				end
			end
			
			if not channel_handle then
				-- Если не нашли канал, пробуем получить первый доступный session
				local sessions = chat_manager:sessions()
				if sessions then
					channel_handle = next(sessions)
				end
			end
			
			if channel_handle then
				-- Получаем английский текст из локализации
				local text_key = option.chat_message_data.text
				local english_text = text_key
				
				-- Если это ключ локализации, получаем английскую версию
				if string.sub(text_key, 1, 4) == "loc_" then
					-- Используем кэшированную локализацию или загружаем заново
					local localization_table = mod._localization_cache
					if not localization_table then
						localization_table = mod:io_dofile("VoxCommsWheel/scripts/mods/VoxCommsWheel/VoxCommsWheel_localization")
						mod._localization_cache = localization_table
					end
					
					if localization_table and localization_table[text_key] then
						english_text = localization_table[text_key].en or text_key
					else
						-- Если не найдено, используем ключ как есть
						english_text = text_key
					end
				end
				
				-- Форматируем сообщение с синим цветом (как в ForTheEmperor)
				-- Цвет RGB: 79, 175, 255 (синий)
				local formatted_message = string.format("{#color(79,175,255)}%s{#reset()}", english_text)
				
				-- Отправляем сообщение через send_channel_message с цветом
				if chat_manager.send_channel_message then
					chat_manager:send_channel_message(channel_handle, formatted_message)
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

