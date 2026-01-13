local mod = get_mod("CopyChatMessage")

mod.version = "1.0.0"

-- ============================================================================
-- Функционал копирования чата
-- ============================================================================

-- Очистка текста от форматирования
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
		mod:notify(mod:localize("messages_copied") .. message_count)
	else
		mod:notify(mod:localize("message_copied"))
	end
	
	return true
end

local function extract_message_text(widget_content)
	if not widget_content then
		return nil
	end
	
	local text = widget_content._copy_chat_message_original_message
	
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
	
	return widget_content._copy_chat_message_original_sender or ""
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
		widget_content._copy_chat_message_original_message = new_message.message_text
	end
	
	if new_message.author_name and new_message.author_name ~= "" then
		local cleaned_name = clean_formatting_tags(new_message.author_name)
		widget_content._copy_chat_message_original_sender = cleaned_name ~= "" and cleaned_name or new_message.author_name
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
