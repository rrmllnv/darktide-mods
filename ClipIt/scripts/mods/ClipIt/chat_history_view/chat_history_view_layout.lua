local Layout = {}

Layout.create_sessions_layout = function(entries, mod)
	local layout = {}
	
	for i, entry in ipairs(entries) do
		local location_name = entry.location_name or "Unknown Location"
		local display_name = ""
		if entry.session_type == "mission" then
			display_name = (mod:localize("chat_history_session_mission") or "Mission") .. ": " .. location_name
		elseif entry.session_type == "mourningstar" then
			display_name = (mod:localize("chat_history_session_mourningstar") or "Mourningstar") .. ": " .. location_name
		else
			display_name = (mod:localize("chat_history_session_unknown") or "Unknown") .. ": " .. location_name
		end
		
		table.insert(layout, {
			entry_id = "session_" .. (entry.file or tostring(i)),
			widget_type = "session_entry",
			text = display_name,
			subtext = entry.date or "",
			entry_data = entry,
		})
	end
	
	return layout
end

Layout.create_messages_layout = function(messages)
	local layout = {}
	
	for i, message in ipairs(messages) do
		local sender = message.sender or ""
		local message_text = message.message or ""
		local time_str = message.time_str or ""
		local formatted_text = string.format("[%s] %s: %s", time_str, sender, message_text)
		
		table.insert(layout, {
			entry_id = "message_" .. tostring(message.timestamp or i),
			widget_type = "message_entry",
			text = formatted_text,
		})
	end
	
	return layout
end

return Layout

