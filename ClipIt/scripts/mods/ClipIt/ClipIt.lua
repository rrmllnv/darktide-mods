local mod = get_mod("ClipIt")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

mod.version = "1.0.0"
mod.input_blocked = false

-- ChatBlock функционал
function input_get_hook(func, self, action_name)
	-- Don't impact the non gameplay input services
	if self.type == "Ingame" and action_name ~= "voip_push_to_talk" then
		-- When checking if action_two_hold is held
		if action_name == "action_two_hold" then
			local unit = Managers.player:local_player(1).player_unit
			if unit then
				local unit_data = ScriptUnit.extension(unit, "unit_data_system")
				local weapon_action_component = unit_data:read_component("weapon_action")
				local weapon_template = WeaponTemplate.current_weapon_template(weapon_action_component)
				if weapon_template then
					-- If the current held weapon has a block action
					if weapon_template.actions.action_block then
						-- You alt tabbed
						if IS_WINDOWS and not Window.has_focus() then
							return true
						end

						-- Steam overlay is open
						if HAS_STEAM and Managers.steam:is_overlay_active() then
							return true
						end

						-- Chat or some other menu is open
						if mod.input_blocked then
							return true
						end
					end
				end
			end
		end

		-- Act as if any other input is not working while the UI is using input
		-- so you don't move or tag or dodge while typing
		local ui_manager = Managers.ui
		if ui_manager and ui_manager:using_input() then
			local result = func(self, action_name)
			local result_type = type(result)

			if result_type == "boolean" then
				return false
			elseif result_type == "number" then
				return 0
			elseif result_type == "userdata" then
				return Vector3(0, 0, 0)
			else
				return result
			end
		end
	end

	-- Default behaviour for other input services or
	-- while UI not using input
	return func(self, action_name)
end

mod:hook("InputService", "_get", input_get_hook)
mod:hook("InputService", "_get_simulate", input_get_hook)

mod:hook("HumanGameplay", "_input_active", function(func, ...)
	mod.input_blocked = not func(...)

	if Managers.state.cinematic:cinematic_active() then
		return false
	end

	-- Keep the input active so you can block
	return true
end)

-- Функционал копирования чата
local function scrub_chat_text(text)
	if not text then
		return ""
	end
	
	local scrubbed = string.gsub(text, "{#.-}", "")
	scrubbed = string.gsub(scrubbed, "{#.-$", "")
	
	return scrubbed
end

local function copy_to_clipboard(text, count)
	if not text or text == "" then
		return false
	end
	
	if rawget(_G, "Clipboard") and Clipboard.put then
		Clipboard.put(text)
		if count and count > 1 then
			mod:notify(mod:localize("msgs_copied") .. count)
		else
			mod:notify(mod:localize("msg_copied"))
		end
		return true
	end
	
	return false
end

-- Сохраняем оригинальный текст сообщения и отправителя при добавлении
mod:hook("ConstantElementChat", "_add_message_widget_to_message_list", function(func, self, new_message, new_message_widget)
	func(self, new_message, new_message_widget)
	
	-- Сохраняем данные в виджет после его добавления
	if new_message_widget and new_message_widget.content then
		local message_text = new_message.message_text
		local sender_name = new_message.author_name
		
		if message_text and message_text ~= "" then
			new_message_widget.content._clipit_original_message = message_text
		end
		
		if sender_name and sender_name ~= "" then
			-- Очищаем ник от форматирования, если оно есть
			local clean_sender = scrub_chat_text(sender_name)
			if clean_sender and clean_sender ~= "" then
				new_message_widget.content._clipit_original_sender = clean_sender
			else
				new_message_widget.content._clipit_original_sender = sender_name
			end
		end
	end
end)

-- Функция для копирования последних N сообщений (вызывается по горячей клавише)
mod.copy_last_message = function()
	local ui_manager = Managers.ui
	if not ui_manager then
		return
	end
	
	local constant_elements = ui_manager._ui_constant_elements
	if not constant_elements then
		return
	end
	
	local chat_element = constant_elements._elements and constant_elements._elements.ConstantElementChat
	if not chat_element then
		return
	end
	
	local message_widgets = chat_element._message_widgets
	if not message_widgets or #message_widgets == 0 then
		return
	end
	
	local messages_count = mod:get("messages_count") or 1
	local last_index = chat_element._last_message_index
	
	if not last_index then
		return
	end
	
	local collected_messages = {}
	local actual_count = 0
	local used_indices = {}
	
	-- Ограничиваем количество итераций реальным количеством доступных сообщений
	local max_iterations = math.min(messages_count, #message_widgets)
	
	-- Собираем последние N сообщений (от последнего к предыдущим)
	for i = 0, max_iterations - 1 do
		local index = math.index_wrapper(last_index - i, #message_widgets)
		
		-- Пропускаем уже использованные индексы, чтобы избежать дубликатов
		if not used_indices[index] then
			used_indices[index] = true
			local widget = message_widgets[index]
			
			if widget and widget.content then
				local original_text = widget.content._clipit_original_message
				if not original_text or original_text == "" then
					-- Если оригинальный текст не сохранен, пытаемся извлечь из форматированного сообщения
					local formatted_message = widget.content.message
					if formatted_message and formatted_message ~= "" then
						original_text = scrub_chat_text(formatted_message)
					end
				end
				
				if original_text and original_text ~= "" then
					local copy_sender_names = mod:get("copy_sender_names")
					if copy_sender_names == nil then
						copy_sender_names = true
					end
					
					local formatted_message = ""
					
					if copy_sender_names then
						local original_sender = widget.content._clipit_original_sender
						if not original_sender or original_sender == "" then
							original_sender = ""
						end
						
						-- Формируем строку в формате "Ник: сообщение"
						if original_sender and original_sender ~= "" then
							formatted_message = original_sender .. ": " .. original_text
						else
							formatted_message = original_text
						end
					else
						-- Копируем только текст сообщения без ника
						formatted_message = original_text
					end
					
					table.insert(collected_messages, formatted_message)
					actual_count = actual_count + 1
				end
			end
		end
	end
	
	-- Переворачиваем массив, чтобы сообщения шли в хронологическом порядке (старые -> новые)
	local reversed_messages = {}
	for i = #collected_messages, 1, -1 do
		table.insert(reversed_messages, collected_messages[i])
	end
	
	-- Объединяем сообщения с переносами строк
	if #reversed_messages > 0 then
		local combined_text = table.concat(reversed_messages, "\n")
		copy_to_clipboard(combined_text, actual_count)
	end
end


