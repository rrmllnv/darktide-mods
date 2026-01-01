local mod = get_mod("ModderTools")
local ref = "team_panel"

-- Хуки для обновления панелей игроков
mod:hook_safe(CLASS.HudElementTeamPanelHandler, "update", function(self, dt, t, ui_renderer)
    if not mod.is_enabled_feature(ref) or not mod:get("enable_random_names") then
        return
    end

    local player_panels_array = self._player_panels_array

    for _, data in ipairs(player_panels_array) do
        local panel = data.panel
        local player = data.player

        if player and not player.__deleted and player:is_human_controlled() then
            local account_id = player:account_id() or player:name() or player:peer_id()
            local widget = panel._widgets_by_name.player_name

            if widget and account_id then
                local content = widget.content
                local current_text = content.text
                local player_name = player:name() or player:character_name()

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

    if player and not player.__deleted and player:is_human_controlled() then
        local account_id = player:account_id() or player:name() or player:peer_id()
        local widget = self._widgets_by_name.player_name

        if widget and account_id then
            local content = widget.content
            local current_text = content.text
            local player_name = player:name() or player:character_name()

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
