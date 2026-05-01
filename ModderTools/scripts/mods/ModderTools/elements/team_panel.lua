local mod = get_mod("ModderTools")
local ref = "team_panel"

local function valid_player(player)
	if not player or player.__deleted then
		return false
	end

	local player_type = type(player)

	return player_type == "table" or player_type == "userdata"
end

local function player_method_value(player, method_name)
	if not valid_player(player) then
		return nil
	end

	local ok, value = pcall(function()
		return player[method_name](player)
	end)

	return ok and value or nil
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

local function player_display_name(player)
	local name = player_method_value(player, "name")

	if type(name) == "string" and name ~= "" then
		return name
	end

	local character_name = player_method_value(player, "character_name")

	if type(character_name) == "string" and character_name ~= "" then
		return character_name
	end

	return nil
end

-- Хуки для обновления панелей игроков
mod:hook_safe(CLASS.HudElementTeamPanelHandler, "update", function(self, dt, t, ui_renderer)
    if not mod.is_enabled_feature(ref) or not mod:get("enable_random_names") then
        return
    end

    local player_panels_array = self._player_panels_array

	for _, data in ipairs(player_panels_array) do
		local panel = data.panel
		local player = data.player

		if valid_player(player) then
			local account_id = player_display_key(player)
			local widget = panel._widgets_by_name.player_name

			if widget and account_id then
                local content = widget.content
                local current_text = content.text
                local player_name = player_display_name(player)

                if current_text and player_name and account_id then
                    -- Заменяем имя на случайное
                    local new_text = mod.replace_name_in_text(current_text, account_id, player_name)

                    if new_text ~= current_text then
                        content.text = new_text

                        -- Увеличиваем размер контейнера если нужно
                        local container_size = widget.style.text.size
                        if container_size then
                            container_size[1] = 500
                        end
                    end
                end
            end
        end
    end
end)

-- Хуки для хаба (если нужно)
mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "update", function(self)
    if not mod.is_enabled_feature(ref) or not mod:get("enable_random_names") then
        return
    end

	local player = self._data.player

	if valid_player(player) then
		local account_id = player_display_key(player)
		local widget = self._widgets_by_name.player_name

		if widget and account_id then
            local content = widget.content
            local current_text = content.text
            local player_name = player_display_name(player)

            if current_text and player_name and account_id then
                -- Заменяем имя на случайное
                local new_text = mod.replace_name_in_text(current_text, account_id, player_name)

                if new_text ~= current_text then
                    content.text = new_text

                    -- Увеличиваем размер контейнера если нужно
                    local container_size = widget.style.text.size
                    if container_size then
                        container_size[1] = 500
                    end
                end
            end
        end
    end
end)
