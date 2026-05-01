local mod = get_mod("ModderTools")
local ref = "nameplate"

local function nameplate_template_name(marker)
	local template = marker.template

	return template and template.name or marker.type
end

local function is_player_name_world_marker(marker)
	local template_name = nameplate_template_name(marker)

	return template_name == "nameplate" or template_name == "nameplate_party" or template_name == "nameplate_party_hud"
end

local function marker_subject_player(marker)
	local player = marker.data

	if not player or player.__deleted then
		return nil
	end

	local player_type = type(player)

	if player_type ~= "table" and player_type ~= "userdata" then
		return nil
	end

	return player
end

local function resolve_player_display_name(player)
	local ok_name, name_from_api = pcall(function()
		return player:name()
	end)

	if ok_name and type(name_from_api) == "string" and name_from_api ~= "" then
		return name_from_api
	end

	local ok_char, char_name = pcall(function()
		return player:character_name()
	end)

	if ok_char and type(char_name) == "string" and char_name ~= "" then
		return char_name
	end

	return nil
end

local function player_display_key(player)
	if type(mod.player_display_name_cache_key) == "function" then
		local ok_key, key = pcall(function()
			return mod.player_display_name_cache_key(player)
		end)

		if ok_key and key ~= nil then
			return key
		end
	end

	return mod.player_name_cache_key(player)
end

local function apply_replace_to_content_field(content, widget, field_id, account_id, player_name)
	local current_text = content[field_id]

	if type(current_text) ~= "string" or current_text == "" then
		return
	end

	local new_text = mod.replace_name_in_text(current_text, account_id, player_name)

	if new_text ~= current_text then
		content[field_id] = new_text
		widget.dirty = true
	end
end

mod:hook_safe(CLASS.HudElementWorldMarkers, "update", function(self, dt, t, ui_renderer)
	if not mod.is_enabled_feature(ref) or not mod:get("enable_random_names") then
		return
	end

	local markers = self._markers

	if not markers then
		return
	end

	for i = 1, #markers do
		local marker = markers[i]

		if marker and is_player_name_world_marker(marker) then
			local widget = marker.widget

			if widget then
				local player = marker_subject_player(marker)

				if player then
					local account_id = player_display_key(player)

					if account_id then
						local player_name = resolve_player_display_name(player)

						if player_name then
							local content = widget.content

							if content then
								apply_replace_to_content_field(content, widget, "header_text", account_id, player_name)
								apply_replace_to_content_field(content, widget, "header", account_id, player_name)
								apply_replace_to_content_field(content, widget, "text", account_id, player_name)
								apply_replace_to_content_field(content, widget, "icon_text", account_id, player_name)
							end
						end
					end
				end
			end
		end
	end
end)
