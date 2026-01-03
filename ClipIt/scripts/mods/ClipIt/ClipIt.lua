local mod = get_mod("ClipIt")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

mod.version = "1.0.0"

local _cached_settings = {
	block_chat_enabled = false,
	last_check_time = 0,
	check_interval = 0.5
}

local _input_state = {
	is_blocked = false,
	ui_using_input = false
}

local function update_settings_cache()
	local current_time = os.clock()
	if current_time - _cached_settings.last_check_time > _cached_settings.check_interval then
		_cached_settings.block_chat_enabled = mod:get("block_chat") or false
		_cached_settings.last_check_time = current_time
	end
end

local function can_weapon_block()
	local player = Managers.player:local_player(1)
	if not player or not player.player_unit then
		return false
	end
	
	local unit = player.player_unit
	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	
	if not unit_data_extension then
		return false
	end
	
	local weapon_action_component = unit_data_extension:read_component("weapon_action")
	local current_weapon_template = WeaponTemplate.current_weapon_template(weapon_action_component)
	
	return current_weapon_template and current_weapon_template.actions and current_weapon_template.actions.action_block
end

local function should_auto_block()
	if not _cached_settings.block_chat_enabled then
		return false
	end
	
	if not can_weapon_block() then
		return false
	end
	
	if IS_WINDOWS and not Window.has_focus() then
		return true
	end
	
	if HAS_STEAM and Managers.steam and Managers.steam:is_overlay_active() then
		return true
	end
	
	if _input_state.is_blocked then
		return true
	end
	
	return false
end

local function handle_input_service(func, self, action_name)
	-- Обрабатываем только игровой ввод, исключая голосовой чат
	if self.type ~= "Ingame" or action_name == "voip_push_to_talk" then
		return func(self, action_name)
	end
	
	-- Обновляем кеш настроек
	update_settings_cache()
	
	-- Обрабатываем удержание блока
	if action_name == "action_two_hold" and should_auto_block() then
		return true
	end
	
	-- Блокируем другие действия при открытом интерфейсе
	local ui_manager = Managers.ui
	if ui_manager and ui_manager:using_input() then
		local original_result = func(self, action_name)
		local result_type = type(original_result)
		
		-- Возвращаем "пустое" значение соответствующего типа
		if result_type == "boolean" then
			return false
		elseif result_type == "number" then
			return 0
		elseif result_type == "userdata" then
			return Vector3.zero()
		end
		
		return original_result
	end
	
	return func(self, action_name)
end

mod:hook("InputService", "_get", handle_input_service)
mod:hook("InputService", "_get_simulate", handle_input_service)

mod:hook("HumanGameplay", "_input_active", function(func, ...)
	update_settings_cache()
	
	if not _cached_settings.block_chat_enabled then
		return func(...)
	end
	
	_input_state.is_blocked = not func(...)
	
	if Managers.state.cinematic and Managers.state.cinematic:cinematic_active() then
		return false
	end
	
	return true
end)

local function clean_formatting_tags(text)
	if not text or text == "" then
		return ""
	end
	
	local cleaned = text
	local scrubbed_text
	
	while text ~= scrubbed_text do
		text = scrubbed_text or text
		scrubbed_text = string.gsub(text, "{#.-}", "")
	end
	
	scrubbed_text = string.gsub(scrubbed_text, "{#.-$", "")
	
	return scrubbed_text
end

local function clipboard_copy(text, message_count)
	if not text or text == "" then
		return false
	end
	
	local clipboard = rawget(_G, "Clipboard")
	if not clipboard or not clipboard.put then
		return false
	end
	
	clipboard.put(text)
	
	if message_count and message_count > 1 then
		mod:notify(mod:localize("msgs_copied") .. message_count)
	else
		mod:notify(mod:localize("msg_copied"))
	end
	
	return true
end

local function extract_message_text(widget_content)
	if not widget_content then
		return nil
	end
	
	local text = widget_content._clipit_original_message
	
	if not text or text == "" then
		local formatted = widget_content.message
		if formatted and formatted ~= "" then
			text = clean_formatting_tags(formatted)
		end
	else
		text = clean_formatting_tags(text)
	end
	
	return text
end

local function extract_sender_name(widget_content)
	if not widget_content then
		return ""
	end
	
	return widget_content._clipit_original_sender or ""
end

local function format_message(text, sender_name, include_sender)
	if not text or text == "" then
		return nil
	end
	
	if include_sender and sender_name and sender_name ~= "" then
		return sender_name .. ": " .. text
	end
	
	return text
end

local function get_chat_element()
	local ui_manager = Managers.ui
	if not ui_manager then
		return nil
	end
	
	local constant_elements = ui_manager._ui_constant_elements
	if not constant_elements or not constant_elements._elements then
		return nil
	end
	
	return constant_elements._elements.ConstantElementChat
end

mod:hook("ConstantElementChat", "_add_message_widget_to_message_list", function(func, self, new_message, new_message_widget)
	func(self, new_message, new_message_widget)
	
	if not new_message_widget or not new_message_widget.content then
		return
	end
	
	local widget_content = new_message_widget.content
	
	if new_message.message_text and new_message.message_text ~= "" then
		widget_content._clipit_original_message = new_message.message_text
	end
	
	if new_message.author_name and new_message.author_name ~= "" then
		local cleaned_name = clean_formatting_tags(new_message.author_name)
		widget_content._clipit_original_sender = cleaned_name ~= "" and cleaned_name or new_message.author_name
	end
end)

mod.copy_last_message = function()
	local chat_element = get_chat_element()
	if not chat_element then
		return
	end
	
	local message_widgets = chat_element._message_widgets
	local last_message_index = chat_element._last_message_index
	
	if not message_widgets or #message_widgets == 0 or not last_message_index then
		return
	end
	
	local requested_count = mod:get("messages_count") or 1
	local include_sender_names = mod:get("copy_sender_names")
	if include_sender_names == nil then
		include_sender_names = true
	end
	
	local max_available = #message_widgets
	local messages_to_copy = math.min(requested_count, max_available)
	
	local messages_buffer = {}
	
	for offset = 0, messages_to_copy - 1 do
		local widget_index = math.index_wrapper(last_message_index - offset, max_available)
		local widget = message_widgets[widget_index]
		
		if widget and widget.content then
			local message_text = extract_message_text(widget.content)
			
			if message_text then
				local sender_name = extract_sender_name(widget.content)
				local formatted = format_message(message_text, sender_name, include_sender_names)
				
				if formatted then
					table.insert(messages_buffer, 1, formatted)
				end
			end
		end
	end
	
	if #messages_buffer > 0 then
		local final_text = table.concat(messages_buffer, "\n")
		clipboard_copy(final_text, #messages_buffer)
	end
end


