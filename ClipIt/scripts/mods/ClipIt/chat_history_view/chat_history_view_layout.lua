local Layout = {}

-- Локализация названия миссии
local function get_mission_display_name(mission_name)
	if not mission_name or mission_name == "" or mission_name == "unknown" then
		return "Unknown"
	end
	
	local Missions = mod:original_require("scripts/settings/mission/mission_templates")
	local mission_settings = Missions[mission_name]
	
	if mission_settings and mission_settings.mission_name then
		local localized = Localize(mission_settings.mission_name)
		if localized and localized ~= "" and localized ~= mission_settings.mission_name then
			return localized
		end
	end
	
	return mission_name
end

Layout.create_sessions_layout = function(entries, mod)
	local layout = {}
	
	for i, entry in ipairs(entries) do
		local location_name = entry.location_name or "Unknown Location"
		local display_name = ""
		
		if entry.session_type == "mission" then
			local mission_display = get_mission_display_name(location_name)
			display_name = (mod:localize("chat_history_session_mission") or "Mission") .. ": " .. mission_display
		elseif entry.session_type == "mourningstar" then
			display_name = (mod:localize("chat_history_session_mourningstar") or "Mourningstar") .. ": " .. (location_name == "hub_ship" and "The Mourningstar" or location_name)
		elseif entry.session_type == "psykhanium" then
			display_name = (mod:localize("chat_history_session_psykhanium") or "Psykhanium") .. ": " .. (location_name == "tg_shooting_range" and "Psykhanium" or location_name)
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

